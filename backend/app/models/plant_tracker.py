from datetime import datetime
from app.models import db


class PlantTracker(db.Model):
    __tablename__ = "plant_tracker"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False, index=True)
    plant_name = db.Column(db.String(150), nullable=False)
    crop_type = db.Column(db.String(100), nullable=False)  # e.g., "Tomato", "Apple"
    status = db.Column(db.String(50), default="healthy")  # "healthy", "diseased", "recovering"
    last_disease = db.Column(db.String(150), nullable=True)
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self) -> dict:
        """Convert plant to dictionary."""
        return {
            "id": self.id,
            "plant_name": self.plant_name,
            "crop_type": self.crop_type,
            "status": self.status,
            "last_disease": self.last_disease,
            "notes": self.notes,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    def __repr__(self) -> str:
        return f"<PlantTracker {self.plant_name} ({self.crop_type})>"
