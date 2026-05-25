#!/usr/bin/env python
import sys
sys.path.insert(0, 'backend')

from app import create_app
app = create_app()

with app.app_context():
    from app.services.compound_service import load_compounds_from_csv
    print('Loading compounds from backend/data/natural_compounds.csv')
    n = load_compounds_from_csv('backend/data/natural_compounds.csv')
    print(f'✓ Loaded {n} compounds into the database')
    
    # Verify
    from app.models.compound import Compound
    total = Compound.query.count()
    print(f'✓ Total compounds in DB: {total}')
    
    # Show a sample
    sample = Compound.query.first()
    if sample:
        print(f'\nSample compound:')
        print(f'  Name: {sample.compound_name}')
        print(f'  SMILES: {sample.smiles}')
        print(f'  Formula: {sample.molecular_formula}')
