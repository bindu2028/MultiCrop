from datetime import datetime
from app.models import db


class Alias(db.Model):
    __tablename__ = "aliases"

    id = db.Column(db.Integer, primary_key=True)
    search_query = db.Column(db.String(255), unique=True, nullable=False)
    local_compound_id = db.Column(db.Integer, db.ForeignKey("compounds.id"), nullable=True)
    smiles = db.Column(db.Text, nullable=True)
    synonyms = db.Column(db.Text, nullable=True)
    pubchem_cid = db.Column(db.Integer, nullable=True)
    molecular_weight = db.Column(db.String(50), nullable=True)
    inchikey = db.Column(db.String(255), nullable=True)
    cached_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "search_query": self.search_query,
            "local_compound_id": self.local_compound_id,
            "smiles": self.smiles,
            "synonyms": self.synonyms,
            "pubchem_cid": self.pubchem_cid,
            "molecular_weight": self.molecular_weight,
            "inchikey": self.inchikey,
            "cached_at": self.cached_at.isoformat() if self.cached_at else None,
        }
