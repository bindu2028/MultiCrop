from flask import Flask
from flask_cors import CORS

from app.config import Config
from app.routes.predict import predict_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.from_object(Config)
    CORS(app)

    app.register_blueprint(predict_bp)
    return app
