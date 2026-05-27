from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

from app.models.user import User
from app.models.scan_history import ScanHistory
from app.models.plant_tracker import PlantTracker
from app.models.compound import Compound
from app.models.alias import Alias
from app.models.compound_cache import CompoundCache
from app.models.token_blocklist import TokenBlocklist

__all__ = ["db", "User", "ScanHistory", "PlantTracker", "Compound", "Alias", "CompoundCache", "TokenBlocklist"]
