from datetime import timedelta

from flask import Blueprint, jsonify, request, current_app
from flask_jwt_extended import create_access_token, create_refresh_token, jwt_required, get_jwt_identity

from app.services.user_service import verify_credentials, create_user

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.post("/login")
def login():
    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Missing username or password"}), 400

    if not verify_credentials(username, password):
        return jsonify({"error": "Invalid credentials"}), 401

    access_expires = timedelta(seconds=current_app.config.get("JWT_ACCESS_TOKEN_EXPIRES", 3600))
    refresh_expires = timedelta(seconds=current_app.config.get("JWT_REFRESH_TOKEN_EXPIRES", 604800))
    
    access = create_access_token(identity=username, expires_delta=access_expires)
    refresh = create_refresh_token(identity=username, expires_delta=refresh_expires)

    return jsonify({"access_token": access, "refresh_token": refresh}), 200


@auth_bp.post("/register")
def register():
    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Missing username or password"}), 400
    if len(password) < 6:
        return jsonify({"error": "Password must be at least 6 characters"}), 400

    user = create_user(username, password)
    if not user:
        return jsonify({"error": "Username already exists"}), 409

    access_expires = timedelta(seconds=current_app.config.get("JWT_ACCESS_TOKEN_EXPIRES", 3600))
    refresh_expires = timedelta(seconds=current_app.config.get("JWT_REFRESH_TOKEN_EXPIRES", 604800))
    
    access = create_access_token(identity=username, expires_delta=access_expires)
    refresh = create_refresh_token(identity=username, expires_delta=refresh_expires)
    return jsonify({"access_token": access, "refresh_token": refresh}), 201

@auth_bp.post("/refresh")
@jwt_required(refresh=True)
def refresh():
    identity = get_jwt_identity()
    access_expires = timedelta(seconds=current_app.config.get("JWT_ACCESS_TOKEN_EXPIRES", 3600))
    new_token = create_access_token(identity=identity, expires_delta=access_expires)
    return jsonify({"access_token": new_token}), 200


@auth_bp.get("/me")
@jwt_required()
def me():
    identity = get_jwt_identity()
    return jsonify({"username": identity}), 200
