from typing import List, Optional
import csv
from pathlib import Path
from app.models.compound import Compound
from app.models import db
from app.models.alias import Alias
from app.utils.pubchem import get_cids_for_name, get_properties_for_cid, get_synonyms_for_cid
import json
import logging

try:
    from rdkit import Chem
    from rdkit.Chem import AllChem
    _RD_AVAILABLE = True
except Exception:
    _RD_AVAILABLE = False


def load_compounds_from_csv(csv_path: str) -> int:
    path = Path(csv_path)
    if not path.exists():
        raise FileNotFoundError(csv_path)

    count = 0
    with path.open(encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            name = row.get("compound_name") or row.get("name")
            smiles = row.get("canonical_smiles") or row.get("smiles")
            cls = row.get("compound_class") or row.get("np_classifier_pathway")
            src = row.get("source_organism")
            formula = row.get("molecular_formula")
            mw = row.get("molecular_weight")
            try:
                mw_val = float(mw) if mw else None
            except Exception:
                logging.exception("Failed to parse molecular weight: %s", mw)
                mw_val = None

            if not name:
                continue

            comp = Compound(
                compound_name=name.strip(),
                smiles=smiles.strip() if smiles else None,
                compound_class=cls.strip() if cls else None,
                source_organism=src.strip() if src else None,
                molecular_formula=formula.strip() if formula else None,
                molecular_weight=mw_val,
            )
            db.session.add(comp)
            count += 1
    db.session.commit()
    return count


def search_by_name(name: str, limit: int = 20) -> List[Compound]:
    q = Compound.query.filter(Compound.compound_name.ilike(f"%{name}%"))
    return q.limit(limit).all()


def get_by_id(compound_id: int) -> Optional[Compound]:
    return Compound.query.get(compound_id)


def search_by_smiles(smiles_query: str, limit: int = 20) -> List[Compound]:
    # Exact or substring match first
    q = Compound.query.filter(Compound.smiles.ilike(f"%{smiles_query}%"))
    results = q.limit(limit).all()
    if results:
        return results

    # Optional: try RDKit substructure/similarity if available
    if _RD_AVAILABLE:
        mol = Chem.MolFromSmiles(smiles_query)
        if mol is None:
            return []
        fp_q = AllChem.GetMorganFingerprintAsBitVect(mol, 2, nBits=2048)
        sims = []
        for comp in Compound.query.filter(Compound.smiles.isnot(None)).all():
            try:
                m = Chem.MolFromSmiles(comp.smiles)
                if m is None:
                    continue
                fp = AllChem.GetMorganFingerprintAsBitVect(m, 2, nBits=2048)
                # Tanimoto
                sim = DataStructs.TanimotoSimilarity(fp_q, fp)
                sims.append((sim, comp))
            except Exception:
                logging.exception("RDKit similarity computation failed for compound id=%s", getattr(comp, 'id', None))
                continue
        sims.sort(key=lambda x: x[0], reverse=True)
        return [c for _, c in sims[:limit]]

    return []


def find_similar_by_smiles(smiles: str, top_n: int = 5):
    if not _RD_AVAILABLE:
        return []
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return []
    fp_q = AllChem.GetMorganFingerprintAsBitVect(mol, 2, nBits=2048)
    import rdkit.DataStructs as DataStructs

    sims = []
    for comp in Compound.query.filter(Compound.smiles.isnot(None)).all():
        try:
            m = Chem.MolFromSmiles(comp.smiles)
            if m is None:
                continue
            fp = AllChem.GetMorganFingerprintAsBitVect(m, 2, nBits=2048)
            sim = DataStructs.TanimotoSimilarity(fp_q, fp)
            sims.append((sim, comp))
        except Exception:
            logging.exception("RDKit similarity computation failed for compound id=%s", getattr(comp, 'id', None))
            continue
    sims.sort(key=lambda x: x[0], reverse=True)
    return [c for _, c in sims[:top_n]]


def find_alias(query: str):
    if not query:
        return None
    return Alias.query.filter_by(search_query=query).first()


def create_or_update_alias(query: str, local_compound_id: int = None, smiles: str = None, synonyms: list | None = None, pubchem_cid: int = None, molecular_weight: str = None, inchikey: str = None):
    a = find_alias(query)
    syn_text = None
    if synonyms:
        try:
            syn_text = json.dumps(synonyms, ensure_ascii=False)
        except Exception:
            syn_text = ",".join(synonyms)
    if a:
        a.local_compound_id = local_compound_id
        a.smiles = smiles
        a.synonyms = syn_text
        a.pubchem_cid = pubchem_cid
        a.molecular_weight = molecular_weight
        a.inchikey = inchikey
        a.cached_at = db.func.now()
    else:
        a = Alias(search_query=query, local_compound_id=local_compound_id, smiles=smiles, synonyms=syn_text, pubchem_cid=pubchem_cid, molecular_weight=molecular_weight, inchikey=inchikey)
        db.session.add(a)
    db.session.commit()
    return a


def resolve_name(name: str, limit: int = 20) -> dict:
    # Check cache first
    cached = find_alias(name)
    if cached:
        local = None
        if cached.local_compound_id:
            local = get_by_id(cached.local_compound_id)
        local_matches = [local.to_dict()] if local else []
        # attempt to include any direct smiles matches
        if cached.smiles:
            sm_q = Compound.query.filter(Compound.smiles.ilike(f"%{cached.smiles}%"))
            for c in sm_q.limit(limit).all():
                if not local or c.id != local.id:
                    local_matches.append(c.to_dict())
        
        # Reconstruct pubchem data from cached alias
        pub = None
        if cached.synonyms:
            try:
                syns = json.loads(cached.synonyms) if isinstance(cached.synonyms, str) else cached.synonyms
            except Exception:
                logging.exception("Failed to parse cached synonyms for alias %s", cached.id)
                syns = []
            # Return reconstructed pubchem with available data from cache
            props = {
                "cid": cached.pubchem_cid,
                "smiles": cached.smiles,
                "molecular_weight": cached.molecular_weight,
                "inchikey": cached.inchikey,
            }
            pub = {"cid": cached.pubchem_cid, "properties": props, "synonyms": syns}
        
        return {
            "cached": True,
            "alias": cached.to_dict(),
            "local_matches": local_matches,
            "pubchem": pub,
        }

    # Not cached: query PubChem
    ids = get_cids_for_name(name)
    if not ids:
        return {"cached": False, "alias": None, "local_matches": [], "pubchem": None}

    try:
        cid = ids[0]
        props = get_properties_for_cid(cid)
        syns = get_synonyms_for_cid(cid)
        pub = {"cid": cid, "properties": props, "synonyms": syns}

        # Attempt to match in local DB by smiles first
        local_matches = []
        if props and props.get("smiles"):
            q = Compound.query.filter(Compound.smiles.ilike(f"%{props.get('smiles')}%"))
            local_matches = [c.to_dict() for c in q.limit(limit).all()]

        # Attempt synonym match against compound_name
        if not local_matches and syns:
            for s in syns[:10]:
                q2 = Compound.query.filter(Compound.compound_name.ilike(f"%{s}%"))
                for c in q2.limit(5).all():
                    local_matches.append(c.to_dict())

        # Cache the mapping (store first local id if any)
        first_local_id = local_matches[0]["id"] if local_matches else None
        create_or_update_alias(
            name,
            local_compound_id=first_local_id,
            smiles=(props.get("smiles") if props else None),
            synonyms=syns,
            pubchem_cid=cid,
            molecular_weight=(props.get("molecular_weight") if props else None),
            inchikey=(props.get("inchikey") if props else None)
        )

        return {"cached": False, "alias": None, "local_matches": local_matches, "pubchem": pub}
    except Exception as e:
        logging.exception("resolve_name exception for '%s': %s", name, e)
        return {"cached": False, "alias": None, "local_matches": [], "pubchem": None}
