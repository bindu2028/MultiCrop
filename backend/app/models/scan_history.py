from datetime import datetime
import json
from app.models import db


class ScanHistory(db.Model):
    __tablename__ = "scan_history"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False, index=True)
    crop_name = db.Column(db.String(100), nullable=False)
    disease = db.Column(db.String(150), nullable=False)
    confidence = db.Column(db.Float, nullable=False)  # 0.0 to 1.0
    image_filename = db.Column(db.String(255), nullable=True)  # Stored image file
    image_url = db.Column(db.String(500), nullable=True)  # Path or URL to image
    remedy = db.Column(db.Text, nullable=True)  # Treatment recommendations
    raw_prediction = db.Column(db.Text, nullable=True)  # JSON string with full model output
    scanned_at = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self) -> dict:
        """Convert scan to dictionary."""
        return {
            "id": self.id,
            "crop_name": self.crop_name,
            "disease": self.disease,
            "confidence": round(self.confidence, 4),
            "image_url": self.image_url,
            "remedy": self.remedy,
            "scanned_at": self.scanned_at.isoformat() if self.scanned_at else None,
        }

    def __repr__(self) -> str:
        return f"<ScanHistory {self.crop_name} - {self.disease} ({self.confidence:.2%})>"
