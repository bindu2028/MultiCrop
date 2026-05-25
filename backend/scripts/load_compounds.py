"""
Load cleaned natural_compounds.csv into the application's database.

Usage:
  python backend/scripts/load_compounds.py backend/data/natural_compounds.csv
"""
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print("Usage: python load_compounds.py path/to/natural_compounds.csv")
    sys.exit(1)

csv_path = Path(sys.argv[1])
if not csv_path.exists():
    print("CSV not found:", csv_path)
    sys.exit(1)

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from app import create_app

app = create_app()
with app.app_context():
    from app.services.compound_service import load_compounds_from_csv
    print('Loading', csv_path)
    n = load_compounds_from_csv(str(csv_path))
    print('Loaded rows:', n)
