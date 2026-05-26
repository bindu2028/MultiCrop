"""
Severity Scoring Service.
Uses Gemini Vision to estimate disease severity from the leaf image.
Migrated to google-genai SDK (replaces deprecated google-generativeai).
"""
import os
import json
import logging
from app.utils.secrets import get_secret


GEMINI_MODEL_NAME = "gemini-1.5-flash"


def _get_api_key() -> str:
    # Use the centralized secret retrieval helper. Returns empty string if not found.
    return get_secret("GEMINI_API_KEY")


def estimate_severity(image_bytes: bytes, disease_name: str) -> dict:
    """
    Uses Gemini 1.5 Flash Vision to estimate disease severity.

    Returns a dict with:
      - severity_score: int 1-10
      - severity_label: "Mild" | "Moderate" | "Severe" | "Critical"
      - affected_area_pct: int 0-100
      - severity_recommendation: str
    """
    try:
        from google import genai
        from google.genai import types as genai_types
        from PIL import Image as PILImage
        from io import BytesIO

        client = genai.Client(api_key=_get_api_key())

        pil_image = PILImage.open(BytesIO(image_bytes)).convert("RGB")
        pil_image = pil_image.resize((512, 512))

        prompt = (
            f"You are an expert plant pathologist. This leaf has been diagnosed with '{disease_name}'.\n"
            "Analyze the image and provide a severity assessment.\n\n"
            "Return your answer as a JSON object with EXACTLY these fields:\n"
            "{\n"
            '  "severity_score": <integer 1-10>,\n'
            '  "severity_label": "<Mild|Moderate|Severe|Critical>",\n'
            '  "affected_area_pct": <integer 0-100, estimate of percentage of leaf area affected>,\n'
            '  "severity_recommendation": "<one sentence recommendation based on severity>"\n'
            "}\n\n"
            "CRITICAL: Return ONLY valid JSON, no markdown, no explanation outside the JSON."
        )

        response = client.models.generate_content(
            model=GEMINI_MODEL_NAME,
            contents=[prompt, pil_image],
            config=genai_types.GenerateContentConfig(
                max_output_tokens=150,
                temperature=0.1,
            ),
        )

        text = response.text.strip()
        # Clean up possible markdown wrapper
        if text.startswith("```json"):
            text = text[7:]
        if text.startswith("```"):
            text = text[3:]
        if text.endswith("```"):
            text = text[:-3]

        data = json.loads(text.strip())

        # Validate and clamp values
        score = max(1, min(10, int(data.get("severity_score", 5))))
        pct = max(0, min(100, int(data.get("affected_area_pct", 30))))
        label = data.get("severity_label", "Moderate")
        if label not in ("Mild", "Moderate", "Severe", "Critical"):
            if score <= 3:
                label = "Mild"
            elif score <= 5:
                label = "Moderate"
            elif score <= 7:
                label = "Severe"
            else:
                label = "Critical"

        rec = data.get("severity_recommendation", "Monitor the plant closely and apply treatment as needed.")

        logging.info("[Severity Service] %s: score=%d/10, area=%d%%, label=%s", disease_name, score, pct, label)

        return {
            "severity_score": score,
            "severity_label": label,
            "affected_area_pct": pct,
            "severity_recommendation": rec,
        }

    except Exception as e:
        logging.warning("[Severity Service] Error: %s", e)
        # Return sensible defaults so the app doesn't crash
        return {
            "severity_score": 5,
            "severity_label": "Moderate",
            "affected_area_pct": 30,
            "severity_recommendation": "Monitor the plant and apply recommended treatment.",
        }
