from pathlib import Path
import os


class Config:
    BASE_DIR = Path(__file__).resolve().parents[1]
    PROJECT_ROOT = BASE_DIR.parent
    
    # SQLAlchemy
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
    CLASS_LABELS = [
        "Bacterial Spot",
        "Early Blight",
        "Healthy",
        "Late Blight",
        "Septoria Leaf Spot",
        "Yellow Leaf Curl Virus",
    ]
    # JWT
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "change-me-in-production")
    JWT_ACCESS_TOKEN_EXPIRES = int(os.getenv("JWT_ACCESS_EXPIRES_SECONDS", 3600))       # 1 hour
    JWT_REFRESH_TOKEN_EXPIRES = int(os.getenv("JWT_REFRESH_EXPIRES_SECONDS", 604800))   # 7 days
