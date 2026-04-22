from pathlib import Path
import json
import re

import numpy as np
import tensorflow as tf

from app.config import Config


def resolve_model_path() -> Path:
    for candidate in Config.MODEL_CANDIDATES:
        if candidate and candidate.exists():
            return candidate
    raise FileNotFoundError(
        "No trained model found. Expected one of: "
        + ", ".join(str(path) for path in Config.MODEL_CANDIDATES)
    )


MODEL_PATH = resolve_model_path()
MODEL = tf.keras.models.load_model(MODEL_PATH)

# Used only when class_names_<crop>.json is missing.
# Recommended: keep class_names files in model/artifacts for exact label order.
FALLBACK_CLASS_LABELS_BY_CROP: dict[str, list[str]] = {
    "apple": ["Apple Scab", "Black Rot", "Cedar Apple Rust", "Healthy"],
    "bell_pepper": ["Bacterial Spot", "Healthy"],
    "cherry": ["Healthy", "Powdery Mildew"],
    "corn_maize": [
        "Cercospora Leaf Spot",
        "Common Rust",
        "Healthy",
        "Northern Leaf Blight",
    ],
    "grape": ["Black Rot", "Esca", "Healthy", "Leaf Blight"],
    "peach": ["Bacterial Spot", "Healthy"],
    "potato": ["Early Blight", "Healthy", "Late Blight"],
    "strawberry": ["Healthy", "Leaf Scorch"],
    "tomato": [
        "Bacterial Spot",
        "Early Blight",
        "Healthy",
        "Late Blight",
        "Septoria Leaf Spot",
        "Yellow Leaf Curl Virus",
    ],
}


def _slugify_crop_name(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", name.strip().lower()).strip("_")


def _discover_models() -> dict[str, Path]:
    model_dir = Config.PROJECT_ROOT / "model" / "saved_model"
    models: dict[str, Path] = {}
    if model_dir.exists():
        for path in model_dir.glob("plant_disease_*.h5"):
            slug = path.stem.replace("plant_disease_", "", 1)
            if slug and slug != "model":
                models[slug] = path
    return models


def _load_class_names(crop_slug: str) -> list[str]:
    artifacts_dir = Config.PROJECT_ROOT / "model" / "artifacts"
    class_file = artifacts_dir / f"class_names_{crop_slug}.json"
    if class_file.exists():
        data = json.loads(class_file.read_text(encoding="utf-8"))
        if isinstance(data, list) and data:
            return [str(label) for label in data]
    if crop_slug in FALLBACK_CLASS_LABELS_BY_CROP:
        return FALLBACK_CLASS_LABELS_BY_CROP[crop_slug]
    if crop_slug == "model":
        return Config.CLASS_LABELS
    return Config.CLASS_LABELS


MODEL_BY_CROP: dict[str, Path] = _discover_models()
MODEL_CACHE: dict[str, tf.keras.Model] = {}


def available_crops() -> list[str]:
    return sorted(MODEL_BY_CROP.keys())


def _resolve_requested_crop(crop: str | None) -> str | None:
    if not crop:
        return None
    slug = _slugify_crop_name(crop)
    if slug in MODEL_BY_CROP:
        return slug
    return None


def _load_model_for_crop(crop_slug: str | None) -> tuple[tf.keras.Model, list[str], str]:
    if crop_slug:
        if crop_slug not in MODEL_BY_CROP:
            raise ValueError(
                f"Unknown crop '{crop_slug}'. Available crops: {', '.join(available_crops())}"
            )
        model_path = MODEL_BY_CROP[crop_slug]
        if crop_slug not in MODEL_CACHE:
            MODEL_CACHE[crop_slug] = tf.keras.models.load_model(model_path)
        model = MODEL_CACHE[crop_slug]
        labels = _load_class_names(crop_slug)
        model_class_count = int(model.output_shape[-1])
        if len(labels) != model_class_count:
            raise ValueError(
                f"Class labels mismatch for crop '{crop_slug}'. "
                f"Model outputs {model_class_count} classes but labels count is {len(labels)}. "
                f"Please add model/artifacts/class_names_{crop_slug}.json"
            )
        return model, labels, crop_slug

    # Fallback to default model path for backward compatibility.
    default_slug = _slugify_crop_name(MODEL_PATH.stem.replace("plant_disease_", "", 1))
    return MODEL, Config.CLASS_LABELS, default_slug or "default"


def _predict_with_model(
    image_array: np.ndarray,
    model: tf.keras.Model,
    labels: list[str],
) -> tuple[str, float, dict[str, float]]:
    predictions = model.predict(image_array, verbose=0)
    scores = predictions[0]
    class_index = int(np.argmax(scores))
    confidence = float(scores[class_index])
    if class_index >= len(labels):
        raise ValueError("Model output classes do not match class label metadata.")

    disease = labels[class_index]
    probabilities = {
        labels[idx]: float(score) for idx, score in enumerate(scores[: len(labels)])
    }
    if confidence < Config.CONFIDENCE_THRESHOLD:
        disease = "Uncertain"
    return disease, confidence, probabilities


def predict_auto_crop(
    image_array: np.ndarray,
) -> tuple[str, float, dict[str, float], str]:
    crops = available_crops()
    if not crops:
        raise ValueError("No crop models available for auto detection.")

    best: tuple[str, float, dict[str, float], str] | None = None
    for crop_slug in crops:
        model, labels, selected_crop = _load_model_for_crop(crop_slug)
        disease, confidence, probabilities = _predict_with_model(image_array, model, labels)
        if best is None or confidence > best[1]:
            best = (disease, confidence, probabilities, selected_crop)

    if best is None:
        raise ValueError("Auto crop detection failed.")
    return best


def predict_image(
    image_array: np.ndarray,
    crop: str | None = None,
) -> tuple[str, float, dict[str, float], str]:
    if crop and _slugify_crop_name(crop) == "auto":
        return predict_auto_crop(image_array)

    crop_slug = _resolve_requested_crop(crop)
    model, labels, selected_crop = _load_model_for_crop(crop_slug)
    disease, confidence, probabilities = _predict_with_model(image_array, model, labels)
    return disease, confidence, probabilities, selected_crop
