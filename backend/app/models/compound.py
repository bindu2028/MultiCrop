from datetime import datetime
from app.models import db


class Compound(db.Model):
    __tablename__ = "compounds"

    id = db.Column(db.Integer, primary_key=True)
    compound_name = db.Column(db.String(256), nullable=False, index=True)
    smiles = db.Column(db.String(1024), nullable=True, index=True)
    compound_class = db.Column(db.String(128), nullable=True, index=True)
    source_organism = db.Column(db.String(256), nullable=True)
    molecular_formula = db.Column(db.String(128), nullable=True)
    molecular_weight = db.Column(db.Float, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "compound_name": self.compound_name,
            "smiles": self.smiles,
            "compound_class": self.compound_class,
            "source_organism": self.source_organism,
            "molecular_formula": self.molecular_formula,
            "molecular_weight": self.molecular_weight,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
