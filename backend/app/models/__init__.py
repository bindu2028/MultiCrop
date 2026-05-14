from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

from app.models.user import User
from app.models.scan_history import ScanHistory
from app.models.plant_tracker import PlantTracker

__all__ = ["db", "User", "ScanHistory", "PlantTracker"]
