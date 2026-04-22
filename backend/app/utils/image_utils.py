from io import BytesIO

import numpy as np
from PIL import Image

from app.config import Config


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
    # Main indicators: R > B, G > B, R and G are relatively close
    skin_mask = (
        (r_norm > 0.5) &  # Red channel must be moderately strong
        (g_norm > 0.4) &  # Green channel present
        (b_norm < 0.6) &  # Blue channel weaker than red
        (r_norm > b_norm) &  # R noticeably higher than B
        (g_norm > b_norm) &  # G higher than B (lemon-like yellow)
        ((r_norm - g_norm) < 0.25)  # R and G moderately close (not pure red)
    )
    
    skin_ratio = float(np.mean(skin_mask))
    return skin_ratio


def is_probable_leaf_image(image_bytes: bytes) -> tuple[bool, float]:
    """Heuristic leaf check to prevent obvious non-leaf photos from prediction.

    Returns:
        (is_leaf_like, score)
    """
    image = _decode_rgb(image_bytes).resize((224, 224))
    rgb = np.array(image, dtype=np.float32)

    r = rgb[:, :, 0]
    g = rgb[:, :, 1]
    b = rgb[:, :, 2]

    # Reject obvious skin tones (hand, face, body parts)
    skin_ratio = _is_skin_color(rgb)
    if skin_ratio > 0.25:  # If > 25% of image is skin-like, reject
        return False, 0.0

    # Excess Green index: strong indicator of foliage/plant regions.
    exg = (2.0 * g) - r - b
    exg_ratio = float(np.mean(exg > 10.0))

    # Saturation/texture signal helps avoid accepting flat backgrounds.
    max_rgb = np.max(rgb, axis=2)
    min_rgb = np.min(rgb, axis=2)
    saturation = (max_rgb - min_rgb) / np.clip(max_rgb, 1.0, None)
    sat_ratio = float(np.mean(saturation > 0.20))

    grayscale = (0.299 * r) + (0.587 * g) + (0.114 * b)
    texture_std = float(np.std(grayscale) / 255.0)

    # Weighted score tuned to reject common non-leaf photos on phone camera.
    score = (0.60 * exg_ratio) + (0.25 * sat_ratio) + (0.15 * texture_std)
    # Tighten thresholds: require higher green content and score
    is_leaf_like = score >= 0.15 and exg_ratio >= 0.06
    return is_leaf_like, score
