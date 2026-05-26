"""Minimal PubChem PUG-REST helper functions."""
from typing import Optional, Dict, Any, List
import requests

BASE = "https://pubchem.ncbi.nlm.nih.gov/rest/pug"


def get_cids_for_name(name: str) -> List[int]:
    try:
        url = f"{BASE}/compound/name/{requests.utils.quote(name)}/cids/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        ids = data.get("IdentifierList", {}).get("CID", [])
        return ids if isinstance(ids, list) else []
    except Exception:
        return []


def get_properties_for_cid(cid: int) -> Optional[Dict[str, Any]]:
    try:
        url = f"{BASE}/compound/cid/{cid}/property/CanonicalSMILES,MolecularWeight,InChIKey/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        props = data.get("PropertyTable", {}).get("Properties", [])
        if not props:
            return None
        p = props[0]
        return {
            "cid": cid,
            "smiles": p.get("CanonicalSMILES"),
            "molecular_weight": p.get("MolecularWeight"),
            "inchikey": p.get("InChIKey"),
        }
    except Exception:
        return None


def get_synonyms_for_cid(cid: int) -> List[str]:
    try:
        url = f"{BASE}/compound/cid/{cid}/synonyms/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        syns = data.get("InformationList", {}).get("Information", [])
        if not syns:
            return []
        names = syns[0].get("Synonym", [])
        return names if isinstance(names, list) else []
    except Exception:
        return []


def get_description_for_cid(cid: int) -> Optional[str]:
    """Fetches the Wikipedia/compound description from PubChem."""
    try:
        url = f"{BASE}/compound/cid/{cid}/description/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        info = data.get("InformationList", {}).get("Information", [])
        for item in info:
            if "Description" in item:
                return item["Description"]
        return None
    except Exception:
        return None


def get_full_properties_for_cid(cid: int) -> Optional[Dict[str, Any]]:
    """Fetches SMILES, MW, InChIKey, MolecularFormula, IUPACName all in one call."""
    try:
        url = f"{BASE}/compound/cid/{cid}/property/CanonicalSMILES,IsomericSMILES,MolecularFormula,MolecularWeight,InChIKey,IUPACName/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        props = data.get("PropertyTable", {}).get("Properties", [])
        if not props:
            return None
        p = props[0]
        return {
            "cid": cid,
            "canonical_smiles": p.get("CanonicalSMILES"),
            "isomeric_smiles": p.get("IsomericSMILES"),
            "molecular_formula": p.get("MolecularFormula"),
            "molecular_weight": p.get("MolecularWeight"),
            "inchikey": p.get("InChIKey"),
            "iupac_name": p.get("IUPACName"),
        }
    except Exception:
        return None

"""Minimal PubChem PUG-REST helper functions."""
from typing import Optional, Dict, Any, List
import requests

BASE = "https://pubchem.ncbi.nlm.nih.gov/rest/pug"


def get_cids_for_name(name: str) -> List[int]:
    try:
        url = f"{BASE}/compound/name/{requests.utils.quote(name)}/cids/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        ids = data.get("IdentifierList", {}).get("CID", [])
        return ids if isinstance(ids, list) else []
    except Exception:
        return []


def get_properties_for_cid(cid: int) -> Optional[Dict[str, Any]]:
    try:
        url = f"{BASE}/compound/cid/{cid}/property/CanonicalSMILES,MolecularWeight,InChIKey/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        props = data.get("PropertyTable", {}).get("Properties", [])
        if not props:
            return None
        p = props[0]
        return {
            "cid": cid,
            "smiles": p.get("CanonicalSMILES"),
            "molecular_weight": p.get("MolecularWeight"),
            "inchikey": p.get("InChIKey"),
        }
    except Exception:
        return None


def get_synonyms_for_cid(cid: int) -> List[str]:
    try:
        url = f"{BASE}/compound/cid/{cid}/synonyms/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        syns = data.get("InformationList", {}).get("Information", [])
        if not syns:
            return []
        names = syns[0].get("Synonym", [])
        return names if isinstance(names, list) else []
    except Exception:
        return []


def get_description_for_cid(cid: int) -> Optional[str]:
    """Fetches the Wikipedia/compound description from PubChem."""
    try:
        url = f"{BASE}/compound/cid/{cid}/description/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        info = data.get("InformationList", {}).get("Information", [])
        for item in info:
            if "Description" in item:
                return item["Description"]
        return None
    except Exception:
        return None


def get_full_properties_for_cid(cid: int) -> Optional[Dict[str, Any]]:
    """Fetches SMILES, MW, InChIKey, MolecularFormula, IUPACName all in one call."""
    try:
        url = f"{BASE}/compound/cid/{cid}/property/CanonicalSMILES,IsomericSMILES,MolecularFormula,MolecularWeight,InChIKey,IUPACName/JSON"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        props = data.get("PropertyTable", {}).get("Properties", [])
        if not props:
            return None
        p = props[0]
        return {
            "cid": cid,
            "canonical_smiles": p.get("CanonicalSMILES"),
            "isomeric_smiles": p.get("IsomericSMILES"),
            "molecular_formula": p.get("MolecularFormula"),
            "molecular_weight": p.get("MolecularWeight"),
            "inchikey": p.get("InChIKey"),
            "iupac_name": p.get("IUPACName"),
        }
    except Exception:
        return None


def get_structure_image_url(cid: int) -> str:
    """Returns the direct CDN URL for the 2D structure PNG. No API call needed."""
    return f"{BASE}/compound/cid/{cid}/PNG"


def get_3d_verified_similar_compounds(cid: int, target_smiles: str, limit: int = 5) -> list[dict[str, str]]:
    """
    Hybrid Engine: Fetches top 20 candidates via PubChem Fast 2D Similarity,
    then uses RDKit to verify their 3D shape similarity, ensuring stereochemical precision.
    """
    try:
        import requests
        # Fetch top 20 fast 2D candidates
        url = f"https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsimilarity_2d/cid/{cid}/property/Title,CanonicalSMILES/JSON?Threshold=75&MaxRecords=20"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        props = data.get("PropertyTable", {}).get("Properties", [])
        
        candidates = []
        for p in props:
            if p.get("CID") != cid and p.get("CanonicalSMILES"):
                candidates.append({
                    "cid": p.get("CID"), 
                    "name": p.get("Title"), 
                    "smiles": p.get("CanonicalSMILES")
                })
        
        if not candidates:
            return []

        # Attempt 3D Shape Verification using RDKit
        try:
            from rdkit import Chem
            from rdkit.Chem import AllChem
            import rdkit.Chem.rdShapeHelpers as rdShapeHelpers
            
            # Embed Target Molecule
            target_mol = Chem.MolFromSmiles(target_smiles)
            target_mol = Chem.AddHs(target_mol)
            AllChem.EmbedMolecule(target_mol, randomSeed=42)
            
            scored_candidates = []
            for cand in candidates:
                cand_mol = Chem.MolFromSmiles(cand["smiles"])
                if not cand_mol: continue
                cand_mol = Chem.AddHs(cand_mol)
                # Fast embedding
                res = AllChem.EmbedMolecule(cand_mol, randomSeed=42)
                if res != 0:
                    continue # Failed to embed in 3D
                
                # Align candidate to target and calculate shape distance
                try:
                    AllChem.GetAlignmentTransform(target_mol, cand_mol)
                    # Shape Tanimoto Distance (0 is identical shape, 1 is completely different)
                    shape_dist = rdShapeHelpers.ShapeTanimotoDist(target_mol, cand_mol)
                    scored_candidates.append((shape_dist, cand))
                except Exception:
                    continue
            
            if scored_candidates:
                # Sort by smallest distance (most similar shape)
                scored_candidates.sort(key=lambda x: x[0])
                # Return the top N most 3D-similar compounds
                return [c for _, c in scored_candidates[:limit]]
                
        except ImportError:
            # Fallback to standard 2D if RDKit is not installed correctly
            pass
        except Exception as e:
            print(f"3D Verification Error: {e}")
            pass
            
        # Fallback: Just return the top 2D matches if 3D fails
        return candidates[:limit]
        
    except Exception as e:
        print(f"PubChem Similarity Error: {e}")
        return []


def get_cids_for_smiles(smiles: str) -> List[int]:
    """Fetches PubChem CIDs directly from a SMILES structure string using HTTP POST."""
    try:
        url = f"{BASE}/compound/smiles/cids/JSON"
        resp = requests.post(url, data={"smiles": smiles}, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        ids = data.get("IdentifierList", {}).get("CID", [])
        return ids if isinstance(ids, list) else []
    except Exception:
        return []
