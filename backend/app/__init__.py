from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager

from app.config import Config
from app.models import db
from app.routes.predict import predict_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Initialize database
    db.init_app(app)
    
    CORS(app)
    
    # Initialize JWT manager
    jwt = JWTManager(app)

    # Register blueprints
    app.register_blueprint(predict_bp)

    # Import and register auth blueprint lazily to avoid circular imports
    from app.routes.auth import auth_bp
    app.register_blueprint(auth_bp)
    
    # Create database tables
    with app.app_context():
        db.create_all()
        # Bootstrap admin user if database is empty
        from app.services.user_service import bootstrap_admin_user
        bootstrap_admin_user()
    
    return app
