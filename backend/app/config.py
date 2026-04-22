from pathlib import Path
import os


class Config:
    BASE_DIR = Path(__file__).resolve().parents[1]
    PROJECT_ROOT = BASE_DIR.parent
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
