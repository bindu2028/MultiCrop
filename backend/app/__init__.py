from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager

from app.config import Config
from app.models import db
from app.routes.predict import predict_bp

import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import os

try:
    # Optional: Sentry for error reporting
    import sentry_sdk
    from sentry_sdk.integrations.flask import FlaskIntegration
except Exception:
    sentry_sdk = None

try:
    # Optional: Prometheus metrics
    from prometheus_client import make_wsgi_app
    from werkzeug.middleware.dispatcher import DispatcherMiddleware
except Exception:
    make_wsgi_app = None
    DispatcherMiddleware = None


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Initialize database
    db.init_app(app)
    from flask_migrate import Migrate
    migrate = Migrate(app, db)
    
    CORS(app)
    
    # Setup basic logging with rotation
    try:
        logs_dir = Path(__file__).resolve().parents[2] / 'logs'
        logs_dir.mkdir(parents=True, exist_ok=True)
        file_handler = RotatingFileHandler(logs_dir / 'app.log', maxBytes=10 * 1024 * 1024, backupCount=5)
        formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]')
        file_handler.setFormatter(formatter)
        file_handler.setLevel(logging.INFO)
        app.logger.addHandler(file_handler)
        app.logger.setLevel(logging.INFO)
        app.logger.info('App startup')
    except Exception:
        # Logging setup should never prevent app from starting
        logging.exception('Failed to configure RotatingFileHandler')

    # Rate limiting
    limiter = Limiter(key_func=get_remote_address, default_limits=["200 per day", "50 per hour"])
    limiter.init_app(app)

    # Initialize JWT manager
    jwt = JWTManager(app)

    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        from app.models.token_blocklist import TokenBlocklist
        jti = jwt_payload["jti"]
        token = TokenBlocklist.query.filter_by(jti=jti).first()
        return token is not None

    # Initialize Sentry if DSN configured
    sentry_dsn = os.getenv("SENTRY_DSN")
    if sentry_dsn and sentry_sdk is not None:
        sentry_sdk.init(dsn=sentry_dsn, integrations=[FlaskIntegration()], traces_sample_rate=0.0)


    # Register blueprints
    app.register_blueprint(predict_bp)

    # Register Module 2 blueprint (natural compounds)
    from app.routes.module2 import module2_bp
    app.register_blueprint(module2_bp)

    # Register history and plant sync blueprint
    from app.routes.history import history_bp
    app.register_blueprint(history_bp)

    # Import and register auth blueprint lazily to avoid circular imports
    from app.routes.auth import auth_bp
    app.register_blueprint(auth_bp)
    
    # Create database tables
    with app.app_context():
        db.create_all()
        # Bootstrap admin user if database is empty
        from app.services.user_service import bootstrap_admin_user
        bootstrap_admin_user()
    
    # Mount Prometheus metrics at /metrics if prometheus_client available
    if make_wsgi_app is not None and DispatcherMiddleware is not None:
        app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
            '/metrics': make_wsgi_app()
        })

    return app
