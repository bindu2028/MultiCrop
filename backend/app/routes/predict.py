from pathlib import Path

from flask import Blueprint, jsonify, request, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.services.model_service import available_crops, predict_image
from app.services.remedy_service import (
    get_disease_explanation,
    get_remedy,
    get_remedy_sections,
    get_disease_type,
    get_drug_compounds,
)
from app.config import Config
from app.utils.image_utils import is_valid_plant_image, verify_crop_match, preprocess_image_bytes


predict_bp = Blueprint("predict", __name__)


@predict_bp.get("/health")
def health_check():
    return jsonify({"status": "ok"})


@predict_bp.get("/crops")
@jwt_required()
def crops_list():
    return jsonify({"crops": ["auto", *available_crops()]})


@predict_bp.post("/predict")
@jwt_required(optional=True)
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

    # ===== SMART GATEKEEPER (Heuristic + Gemini Vision) =====
    is_plant, rejection_reason, is_multi_leaf = is_valid_plant_image(image_bytes)
    if not is_plant:
        return jsonify({
            "error": rejection_reason,
            "code": "non_leaf_image",
        }), 422

    crop = request.form.get("crop") or request.args.get("crop")
    crops = available_crops()
    if len(crops) > 1 and not crop:
        return jsonify({
            "error": "Please select a crop before prediction.",
            "available_crops": ["auto", *crops],
        }), 400

    # ===== CROP TYPE VERIFICATION =====
    # Verify that the leaf actually matches the selected crop
    if crop and crop.lower() != "auto":
        crop_match, mismatch_msg = verify_crop_match(image_bytes, crop)
        if not crop_match:
            return jsonify({
                "error": mismatch_msg,
                "code": "crop_mismatch",
            }), 422

    try:
        image_array = preprocess_image_bytes(image_bytes)
        disease, confidence, probabilities, selected_crop, alt_diagnosis, is_ambiguous = predict_image(image_array, crop=crop, image_bytes=image_bytes)
        disease_explanation = get_disease_explanation(disease)
        remedy = get_remedy(disease)
        remedy_sections = get_remedy_sections(disease)
        disease_type = get_disease_type(disease)
        drug_compounds = get_drug_compounds(selected_crop)

        # ===== FIX 2: Unknown Crop Rejection =====
        # If the best confidence is extremely low, the crop is likely unsupported
        UNKNOWN_CROP_THRESHOLD = 0.30
        is_unsupported_crop = False
        if confidence < UNKNOWN_CROP_THRESHOLD and disease != "Healthy":
            is_unsupported_crop = True
            disease = "Unsupported Crop"
            disease_explanation = (
                "The AI model could not confidently identify a disease on this leaf. "
                "This may be a crop type that the model has not been trained on. "
                f"Currently supported crops: {', '.join(crops)}."
            )

        # ===== FIX 4: Severity Scoring via Gemini =====
        severity_data = {}
        if not is_unsupported_crop and disease != "Healthy" and disease != "Uncertain":
            from app.services.severity_service import estimate_severity
            severity_data = estimate_severity(image_bytes, disease)

        response_data = {
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
            "is_ambiguous": is_ambiguous,
            "alternative_diagnosis": alt_diagnosis,
            "multi_leaf_warning": is_multi_leaf,
            "is_unsupported_crop": is_unsupported_crop,
            **severity_data,
        }

        # ===== AUTO-SAVE SCAN HISTORY IF AUTHENTICATED =====
        username = get_jwt_identity()
        if username:
            try:
                from datetime import datetime
                import json
                from app.models import db
                from app.models.user import User
                from app.models.scan_history import ScanHistory
                
                user = User.query.filter_by(username=username).first()
                if user:
                    scan = ScanHistory(
                        user_id=user.id,
                        crop_name=selected_crop,
                        disease=disease,
                        confidence=float(confidence),
                        remedy=remedy,
                        raw_prediction=json.dumps(probabilities),
                        scanned_at=datetime.utcnow()
                    )
                    db.session.add(scan)
                    db.session.commit()
            except Exception as e:
                db.session.rollback()
                current_app.logger.exception("Failed to auto-save scan history for %s: %s", username, e)

        return jsonify(response_data)
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500

