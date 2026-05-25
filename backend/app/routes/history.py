from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
import json

from app.models import db, User, ScanHistory, PlantTracker

history_bp = Blueprint("history", __name__, url_prefix="/api/history")


@history_bp.route("/scans", methods=["GET"])
@jwt_required()
def get_scans():
    username = get_jwt_identity()
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Pagination: default to 50 most-recent scans, max 200
    try:
        limit = min(int(request.args.get("limit", 50)), 200)
        offset = max(int(request.args.get("offset", 0)), 0)
    except (ValueError, TypeError):
        limit, offset = 50, 0

    scans = (
        ScanHistory.query
        .filter_by(user_id=user.id)
        .order_by(ScanHistory.scanned_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )
    return jsonify([s.to_dict() for s in scans]), 200


@history_bp.route("/scans", methods=["POST"])
@jwt_required()
def add_scan():
    username = get_jwt_identity()
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json(force=True) or {}
    crop_name = data.get("crop_name")
    disease = data.get("disease")
    confidence = data.get("confidence")

    if not crop_name or not disease or confidence is None:
        return jsonify({"error": "Missing crop_name, disease, or confidence"}), 400

    scan = ScanHistory(
        user_id=user.id,
        crop_name=crop_name,
        disease=disease,
        confidence=float(confidence),
        image_url=data.get("image_url"),
        image_filename=data.get("image_filename"),
        remedy=data.get("remedy"),
        raw_prediction=data.get("raw_prediction"),
        scanned_at=datetime.utcnow()
    )

    db.session.add(scan)
    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Failed to save scan: {str(e)}"}), 500

    return jsonify(scan.to_dict()), 201


@history_bp.route("/scans", methods=["DELETE"])
@jwt_required()
def clear_scans():
    username = get_jwt_identity()
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    ScanHistory.query.filter_by(user_id=user.id).delete()
    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Failed to clear history: {str(e)}"}), 500

    return jsonify({"message": "Scan history cleared successfully"}), 200


@history_bp.route("/plants", methods=["GET"])
@jwt_required()
def get_plants():
    username = get_jwt_identity()
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    plants = PlantTracker.query.filter_by(user_id=user.id).order_by(PlantTracker.updated_at.desc()).all()
    return jsonify([p.to_dict() for p in plants]), 200


@history_bp.route("/plants", methods=["POST"])
@jwt_required()
def add_or_update_plant():
    username = get_jwt_identity()
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json(force=True) or {}
    plant_id = data.get("id")
    plant_name = data.get("plant_name")
    crop_type = data.get("crop_type")
    status = data.get("status", "healthy")
    last_disease = data.get("last_disease")
    notes = data.get("notes")

    if not plant_name or not crop_type:
        return jsonify({"error": "Missing plant_name or crop_type"}), 400

    if plant_id:
        # Update existing
        plant = PlantTracker.query.filter_by(id=plant_id, user_id=user.id).first()
        if not plant:
            # Fallback check: if ID is a string or from local timestamp, check name/crop
            plant = PlantTracker.query.filter_by(plant_name=plant_name, user_id=user.id).first()
            if not plant:
                plant = PlantTracker(user_id=user.id)
                db.session.add(plant)
        
        plant.plant_name = plant_name
        plant.crop_type = crop_type
        plant.status = status
        plant.last_disease = last_disease
        plant.notes = notes
        plant.updated_at = datetime.utcnow()
    else:
        # Create new
        plant = PlantTracker(
            user_id=user.id,
            plant_name=plant_name,
            crop_type=crop_type,
            status=status,
            last_disease=last_disease,
            notes=notes,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        db.session.add(plant)

    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Failed to save plant tracker: {str(e)}"}), 500

    return jsonify(plant.to_dict()), 200


@history_bp.route("/plants/<int:plant_id>", methods=["DELETE"])
@jwt_required()
def delete_plant(plant_id: int):
    username = get_jwt_identity()
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    plant = PlantTracker.query.filter_by(id=plant_id, user_id=user.id).first()
    if not plant:
        return jsonify({"error": "Plant tracker item not found"}), 404

    db.session.delete(plant)
    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Failed to delete plant tracker: {str(e)}"}), 500

    return jsonify({"message": "Plant tracker item deleted"}), 200
