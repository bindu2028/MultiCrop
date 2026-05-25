from pathlib import Path
import os
import logging
from dotenv import load_dotenv
import secrets


# Load .env from the backend folder if present
BACKEND_DIR = Path(__file__).resolve().parents[1]
env_path = BACKEND_DIR / '.env'
if env_path.exists():
    load_dotenv(dotenv_path=env_path)

# Also load .env from the root folder if present
ROOT_DIR = Path(__file__).resolve().parents[2]
root_env_path = ROOT_DIR / '.env'
if root_env_path.exists():
    load_dotenv(dotenv_path=root_env_path)


class Config:
    BASE_DIR = Path(__file__).resolve().parents[1]
    PROJECT_ROOT = BASE_DIR.parent

    # SQLAlchemy
    _db_url = os.getenv("DATABASE_URL")
    if _db_url:
        if _db_url.startswith("postgres://"):
            _db_url = _db_url.replace("postgres://", "postgresql://", 1)
        SQLALCHEMY_DATABASE_URI = _db_url
    else:
        SQLALCHEMY_DATABASE_URI = f"sqlite:///{BASE_DIR / 'app.db'}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    MODEL_CANDIDATES = [
        Path(os.getenv("MODEL_PATH", "")) if os.getenv("MODEL_PATH") else None,
        PROJECT_ROOT / "model" / "saved_model" / "plant_disease_model.h5",
        BASE_DIR / "model" / "plant_disease_model.h5",
        PROJECT_ROOT / "model" / "saved_model" / "tomato_disease_cnn.h5",
    ]
    IMAGE_SIZE = 224
    CONFIDENCE_THRESHOLD = 0.60
    ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
    MAX_CONTENT_LENGTH = 10 * 1024 * 1024  # 10 MB max upload size
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,   # Reconnect if DB connection dropped (important for PostgreSQL)
        "pool_recycle": 280,     # Recycle connections before 5-min Render timeout
    }
    CLASS_LABELS = [
        "Bacterial Spot",
        "Early Blight",
        "Healthy",
        "Late Blight",
        "Septoria Leaf Spot",
        "Yellow Leaf Curl Virus",
    ]

    # JWT: require a strong secret for production. If missing or too short, generate an ephemeral key and log a warning.
    _jwt_env = os.getenv("JWT_SECRET_KEY")
    if not _jwt_env or len(_jwt_env) < 32:
        generated = secrets.token_urlsafe(48)
        logging.warning(
            "JWT_SECRET_KEY not set or is too short (<32). An ephemeral key was generated for this process."
            " Set JWT_SECRET_KEY in your .env for persistent, secure tokens in production."
        )
        JWT_SECRET_KEY = generated
        JWT_SECRET_WAS_GENERATED = True
    else:
        JWT_SECRET_KEY = _jwt_env
        JWT_SECRET_WAS_GENERATED = False

    JWT_ACCESS_TOKEN_EXPIRES = int(os.getenv("JWT_ACCESS_EXPIRES_SECONDS", 3600))       # 1 hour
    JWT_REFRESH_TOKEN_EXPIRES = int(os.getenv("JWT_REFRESH_EXPIRES_SECONDS", 604800))   # 7 days
