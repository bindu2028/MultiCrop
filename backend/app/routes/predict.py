from pathlib import Path

from flask import Blueprint, jsonify, request

from app.services.model_service import available_crops, predict_image
from app.services.remedy_service import (
    get_disease_explanation,
    get_remedy,
    get_remedy_sections,
    get_disease_type,
    get_drug_compounds,
)
from app.config import Config
from app.utils.image_utils import is_probable_leaf_image, preprocess_image_bytes


predict_bp = Blueprint("predict", __name__)


@predict_bp.get("/health")
def health_check():
    return jsonify({"status": "ok"})


@predict_bp.get("/crops")
def crops_list():
    return jsonify({"crops": ["auto", *available_crops()]})


@predict_bp.post("/predict")
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    file = request.files["image"]
    if not file.filename:
        return jsonify({"error": "Empty file name"}), 400

    extension = Path(file.filename).suffix.lower()
    if extension not in Config.ALLOWED_EXTENSIONS:
        return jsonify({
            "error": "Unsupported file type. Please upload a valid image file."
        }), 400

    if not file.mimetype or not file.mimetype.startswith("image/"):
        return jsonify({"error": "Uploaded file is not an image."}), 400

    image_bytes = file.read()
    if not image_bytes:
        return jsonify({"error": "Uploaded image is empty."}), 400

    is_leaf_like, leaf_score = is_probable_leaf_image(image_bytes)
    if not is_leaf_like:
        return jsonify({
            "error": "This image does not look like a leaf. Please capture a clear photo of a single plant leaf.",
            "code": "non_leaf_image",
            "leaf_score": round(leaf_score, 3),
        }), 422

    crop = request.form.get("crop") or request.args.get("crop")
    crops = available_crops()
    if len(crops) > 1 and not crop:
        return jsonify({
            "error": "Please select a crop before prediction.",
            "available_crops": ["auto", *crops],
        }), 400

    try:
        image_array = preprocess_image_bytes(image_bytes)
        disease, confidence, probabilities, selected_crop = predict_image(image_array, crop=crop)
        disease_explanation = get_disease_explanation(disease)
        remedy = get_remedy(disease)
        remedy_sections = get_remedy_sections(disease)
        disease_type = get_disease_type(disease)
        drug_compounds = get_drug_compounds(selected_crop)

        return jsonify({
            "disease": disease,
            "disease_explanation": disease_explanation,
            "confidence": confidence,
            "probabilities": probabilities,
            "remedy": remedy,
            "remedy_sections": remedy_sections,
            "disease_type": disease_type,
            "drug_compounds": drug_compounds,
            "crop": selected_crop,
            "is_uncertain": disease == "Uncertain",
        })
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500
