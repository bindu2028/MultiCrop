"""
LLM Agent Service.
Uses Gemini to dynamically generate compound profiles.
Migrated to google-genai SDK (replaces deprecated google-generativeai).
"""
import os
import json
import logging
from google import genai
from typing import Dict, Any, Optional


GEMINI_MODEL_NAME = "gemini-1.5-flash-002"

def get_gemini_key():
    # Attempt to load from environment first
    key = os.getenv("GEMINI_API_KEY")
    if key:
        return key

    # Try reading from mobile app .env as a fallback for this specific setup
    try:
        env_path = os.path.join(os.path.dirname(__file__), "..", "..", "..", "mobile_app", ".env")
        if os.path.exists(env_path):
            with open(env_path, "r") as f:
                for line in f:
                    if line.startswith("GEMINI_API_KEY="):
                        return line.split("=")[1].strip().strip('"').strip("'")
    except Exception as e:
        logging.exception("Failed to read GEMINI_API_KEY from mobile .env fallback: %s", e)
    return None

def generate_compound_knowledge(compound_name: str) -> Optional[Dict[str, Any]]:
    """
    Uses Gemini to act as a phytochemist and dynamically generate a structured profile
    for a compound that isn't in our local dictionary.
    """
    key = get_gemini_key()
    if not key:
        logging.warning("GEMINI_API_KEY is not set. Dynamic compound knowledge fallback is disabled.")
        return None

    client = genai.Client(api_key=key)

    prompt = f"""
    You are an expert phytochemist and pharmacognosist. 
    I need a structured profile for the natural compound: "{compound_name}".
    
    Provide your response as a pure JSON object matching exactly this structure:
    {{
        "common_name": "string",
        "compound_class": "string (e.g. Flavonoid, Alkaloid, Terpenoid, Antibiotic, etc)",
        "source_organisms": ["string", "string"],
        "source_type": "string (Plant, Fungi, Bacteria, or Animal)",
        "traditional_use": "string (A short paragraph on its historical or traditional medicinal use)",
        "medicinal_remedy": {{
            "primary_use": "string",
            "conditions_treated": ["string"],
            "how_used": "string (How is it typically administered or consumed)",
            "research_notes": "string (Mechanism of action or recent findings)",
            "caution": "string (Side effects or interactions)"
        }},
        "bioactivity": ["string", "string"]
    }}
    
    CRITICAL INSTRUCTIONS:
    - Return ONLY valid JSON.
    - Do not include markdown blocks like ```json
    - Do not include any explanations outside the JSON.
    - If the compound is completely unknown or not a real natural compound, return an empty JSON object: {{}}
    """

    try:
        response = client.models.generate_content(
            model=GEMINI_MODEL_NAME,
            contents=prompt,
        )
        text = response.text.strip()

        # Clean up possible markdown
        if text.startswith("```json"):
            text = text[7:]
        if text.startswith("```"):
            text = text[3:]
        if text.endswith("```"):
            text = text[:-3]

        data = json.loads(text)
        if not data or "common_name" not in data:
            return None

        return data

    except Exception as e:
        logging.warning("[LLM Agent] Failed to generate knowledge for %s: %s", compound_name, e)
        return None
