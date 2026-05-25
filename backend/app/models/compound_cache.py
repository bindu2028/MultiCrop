from app.models import db
import datetime

class CompoundCache(db.Model):
    __tablename__ = 'compound_cache'

    id = db.Column(db.Integer, primary_key=True)
    query_name = db.Column(db.String(255), unique=True, nullable=False, index=True)
    json_data = db.Column(db.Text, nullable=False)  # The entire Module 2 response
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "query_name": self.query_name,
            "json_data": self.json_data,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }
