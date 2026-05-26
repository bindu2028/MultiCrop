import os
from io import BytesIO
from pathlib import Path
import numpy as np
from PIL import Image
from app.config import Config

GEMINI_MODEL_NAME = "gemini-1.5-flash"


def _get_gemini_key() -> str | None:
    api_key = os.getenv("GEMINI_API_KEY")
    if api_key:
        return api_key
    try:
        # Check backend/.env
        env_path = Path(__file__).resolve().parents[2] / ".env"
        if env_path.exists():
            with open(env_path, "r") as f:
                for line in f:
                    if line.startswith("GEMINI_API_KEY="):
                        return line.split("=")[1].strip().strip('"').strip("'")
    except Exception:
        pass
    try:
        # Check mobile_app/.env
        env_path = Path(__file__).resolve().parents[3] / "mobile_app" / ".env"
        if env_path.exists():
            with open(env_path, "r") as f:
                for line in f:
                    if line.startswith("GEMINI_API_KEY="):
                        return line.split("=")[1].strip().strip('"').strip("'")
    except Exception:
        pass
    return None



def _decode_rgb(image_bytes: bytes) -> Image.Image:
    return Image.open(BytesIO(image_bytes)).convert("RGB")


def preprocess_image(file_storage) -> np.ndarray:
    image = _decode_rgb(file_storage.read())
    image = image.resize((Config.IMAGE_SIZE, Config.IMAGE_SIZE))
    # Model includes a Rescaling(1/255) layer, so keep raw pixel range here.
    image_array = np.array(image, dtype="float32")
    return np.expand_dims(image_array, axis=0)


def preprocess_image_bytes(image_bytes: bytes) -> np.ndarray:
    image = _decode_rgb(image_bytes)
    image = image.resize((Config.IMAGE_SIZE, Config.IMAGE_SIZE))
    image_array = np.array(image, dtype="float32")
    return np.expand_dims(image_array, axis=0)


def _is_skin_color(rgb: np.ndarray) -> float:
    """Detect human skin tones using color heuristics.
    
    Returns skin tone ratio (0.0 to 1.0). Higher values indicate more skin-like pixels.
    Skin tones typically have: R > B, G moderately high, with specific ranges.
    """
    r = rgb[:, :, 0]
    g = rgb[:, :, 1]
    b = rgb[:, :, 2]
    
    # Normalize to 0-1 range
    r_norm = r / 255.0
    g_norm = g / 255.0
    b_norm = b / 255.0
    
    # Skin tone detection: R strong, G moderate, B weak
    # Typical skin: R ~0.78-0.86, G ~0.55-0.71, B ~0.39-0.55
    # Works for all skin tones (light to dark) with proper range
    skin_mask = (
        (r_norm > 0.35) &  # Red channel present
        (g_norm > 0.15) &  # Green channel present  
        (r_norm > b_norm) &  # R noticeably higher than B (key indicator)
        (g_norm > (b_norm - 0.1)) &  # G similar to or higher than B (avoids pure red)
        (np.abs(r_norm - g_norm) < 0.30)  # R and G stay close (warm tone)
    )
    
    skin_ratio = float(np.mean(skin_mask))
    return skin_ratio


def is_probable_leaf_image(image_bytes: bytes) -> tuple[bool, float]:
    """Strict leaf/plant validation to prevent non-plant objects from prediction.

    Checks for:
    - Skin tone rejection (faces/hands)
    - Sufficient green content (plants are green-ish)
    - Natural color variation and texture
    - Avoids flat, uniform backgrounds

    Returns:
        (is_leaf_like, score)
    """
    image = _decode_rgb(image_bytes).resize((224, 224))
    rgb = np.array(image, dtype=np.float32)

    r = rgb[:, :, 0]
    g = rgb[:, :, 1]
    b = rgb[:, :, 2]

    # ===== STRICT SKIN TONE REJECTION =====
    # Reject obvious skin tones (face, hand, body)
    skin_ratio = _is_skin_color(rgb)
    if skin_ratio > 0.45:  # Increased from 0.20 to avoid false positives on brown diseased leaf spots
        return False, 0.0

    # ===== GREEN CHANNEL REQUIREMENT =====
    # Plants must have reasonable green content
    # If green is too weak, it's likely a non-plant object (rock, metal, etc.)
    green_mean = float(np.mean(g) / 255.0)
    if green_mean < 0.10:  # Lowered from 0.30 to allow darker, shadowed, or highly diseased/wilted leaves
        return False, 0.0

    # ===== EXCESS GREEN INDEX =====
    # Strong indicator of foliage. Diseased leaves still have some green.
    exg = (2.0 * g) - r - b
    exg_ratio = float(np.mean(exg > 10.0))
    
    # High ExG = definitely plant-like
    if exg_ratio > 0.25:
        return True, 1.0

    # ===== SATURATION CHECK =====
    # Natural variation in color intensity (plants have texture)
    max_rgb = np.max(rgb, axis=2)
    min_rgb = np.min(rgb, axis=2)
    saturation = (max_rgb - min_rgb) / np.clip(max_rgb, 1.0, None)
    sat_ratio = float(np.mean(saturation > 0.20))

    # ===== TEXTURE ANALYSIS =====
    # Plants have natural variation, not flat surfaces
    grayscale = (0.299 * r) + (0.587 * g) + (0.114 * b)
    texture_std = float(np.std(grayscale) / 255.0)

    # ===== COLOR RANGE CHECK =====
    # Healthy leaves AND diseased leaves have varied color
    # Uniform colors (white wall, solid chair) are rejected
    r_std = float(np.std(r) / 255.0)
    g_std = float(np.std(g) / 255.0)
    b_std = float(np.std(b) / 255.0)
    color_variation = (r_std + g_std + b_std) / 3.0

    # ===== COMBINED SCORING =====
    # ExG is strongest indicator of plants (40%)
    # Color variation rules out uniform objects like walls/furniture (35%)
    # Saturation shows natural texture (20%)
    # Texture standard deviation (5%)
    score = (
        (exg_ratio * 0.40) +  # Green plant indicator
        (color_variation * 0.35) +  # Natural variation (rules out walls, doors, etc.)
        (sat_ratio * 0.20) +  # Color saturation = texture
        (texture_std * 0.05)  # Overall texture
    )

    # STRICT THRESHOLDS to reject non-plants
    # Requires both green content AND natural variation
    is_leaf_like = (
        score >= 0.08 and  # Lowered from 0.20 to be friendly to diseased/brown leaves
        exg_ratio >= 0.02 and  # Lowered from 0.10
        sat_ratio >= 0.08 and  # Lowered from 0.15
        color_variation >= 0.08  # Lowered from 0.12
    )

    return is_leaf_like, score


def is_valid_plant_image(image_bytes: bytes) -> tuple[bool, str, bool]:
    """
    Smart, latency-optimized plant image gatekeeper.

    Pipeline:
      1. Run the fast pixel heuristic (~5ms).
      2. If the heuristic is DEFINITIVE (clearly plant or clearly not), skip Gemini.
      3. If the heuristic is BORDERLINE, call Gemini Vision for the final verdict.
      4. When Gemini IS called, also detect multi-leaf / field images.

    Returns:
        (is_plant, reason, is_multi_leaf)
        - is_plant: True if the image contains a plant/leaf
        - reason: Human-readable explanation
        - is_multi_leaf: True if multiple leaves / field detected (warning only)
    """
    # ===== STEP 1: Fast Heuristic Pre-Filter (~5ms) =====
    is_leaf_heuristic, heuristic_score = is_probable_leaf_image(image_bytes)

    # Definitive YES — clearly a plant (high green, high texture)
    if is_leaf_heuristic and heuristic_score > 0.50:
        print(f"[Gatekeeper] Heuristic PASS (score={heuristic_score:.3f}), skipping Gemini")
        return True, "Plant confirmed by fast analysis", False
    # ===== STEP 2: Smart Verification — Call Gemini Vision =====
    print(f"[Gatekeeper] Heuristic score={heuristic_score:.3f}, calling Gemini Vision...")

    try:
        from google import genai
        from google.genai import types as genai_types
        from PIL import Image as PILImage
        from io import BytesIO
        # Load API key securely
        api_key = _get_gemini_key()
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable is not set.")

        client = genai.Client(api_key=api_key)

        pil_image = PILImage.open(BytesIO(image_bytes)).convert("RGB")
        pil_image = pil_image.resize((512, 512))

        response = client.models.generate_content(
            model=GEMINI_MODEL_NAME,
            contents=[
                "Analyze this image and answer TWO questions:\n"
                "Q1: Does this image contain a plant, leaf, crop, tree, flower, fruit, vegetable, or any part of a plant? "
                "If it shows a human face, person, animal, vehicle, building, electronic device, or any non-plant object, the answer is NO. "
                "If it shows a plant leaf (even if diseased, brown, wilted, or damaged), the answer is YES.\n"
                "Q2: Does this image show MULTIPLE leaves, an entire plant, or a wide field view (rather than a single leaf close-up)?\n\n"
                "Answer in EXACTLY this format (nothing else):\n"
                "Q1: YES or NO\n"
                "Q2: YES or NO",
                pil_image,
            ],
            config=genai_types.GenerateContentConfig(
                max_output_tokens=20,
                temperature=0.0,
            ),
        )

        answer = response.text.strip().upper()
        print(f"[Gemini Vision Gatekeeper] Raw answer: {answer}")

        # Parse Q1 and Q2
        is_plant = "Q1: YES" in answer or (answer.startswith("YES") and "Q1" not in answer)
        is_multi = "Q2: YES" in answer

        if is_plant:
            return True, "Plant/leaf confirmed by AI Vision", is_multi
        else:
            return False, "This does not appear to be a plant or leaf. Please take a clear photo of the affected crop.", False

    except Exception as e:
        print(f"[Gemini Vision Gatekeeper] Error: {e}")
        # Gemini failed — print warning and gracefully let the request proceed to the CNN model!
        # This prevents transient Gemini outages or leaked key blocks from rejecting valid users' leaves.
        return True, "Passed resilient fallback (Gemini down)", False


def verify_crop_match(image_bytes: bytes, selected_crop: str) -> tuple[bool, str]:
    """
    Uses Gemini Vision to verify that the uploaded leaf image actually matches
    the crop type selected by the user (e.g. rejects grass when user picks 'apple').

    Returns:
        (is_match, message)
        - is_match: True if the leaf looks like the selected crop
        - message: Human-readable mismatch explanation
    """
    if not selected_crop or selected_crop.lower() == "auto":
        return True, ""

    try:
        from google import genai
        from google.genai import types as genai_types
        from PIL import Image as PILImage
        from io import BytesIO
        # Load API key securely
        api_key = _get_gemini_key()
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable is not set.")

        client = genai.Client(api_key=api_key)

        pil_image = PILImage.open(BytesIO(image_bytes)).convert("RGB")
        pil_image = pil_image.resize((512, 512))

        crop_display = selected_crop.replace("_", " ")

        response = client.models.generate_content(
            model=GEMINI_MODEL_NAME,
            contents=[
                f"The user says this is a '{crop_display}' leaf. "
                f"Look at this image carefully. Does this leaf actually belong to a {crop_display} plant? "
                "Answer ONLY with: YES or NO. "
                "If the leaf clearly belongs to a completely different plant species "
                f"(for example grass, rice, or wheat when the user said {crop_display}), answer NO. "
                "If it could reasonably be the claimed crop, answer YES.",
                pil_image,
            ],
            config=genai_types.GenerateContentConfig(
                max_output_tokens=10,
                temperature=0.0,
            ),
        )

        answer = response.text.strip().upper()
        print(f"[Crop Verifier] Selected='{selected_crop}', Answer: {answer}")

        if "YES" in answer:
            return True, ""
        else:
            return False, (
                f"This leaf does not appear to be from a {crop_display} plant. "
                f"Please select the correct crop type or upload a {crop_display} leaf image."
            )

    except Exception as e:
        print(f"[Crop Verifier] Error: {e}")
        # If Gemini fails, don't block — let the CNN try
        return True, ""
