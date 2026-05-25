from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from app.services.compound_service import (
    search_by_name,
    search_by_smiles,
    get_by_id,
    find_similar_by_smiles,
    resolve_name,
    create_or_update_alias,
)
from app.utils.pubchem import (
    get_cids_for_name,
    get_full_properties_for_cid,
    get_synonyms_for_cid,
    get_description_for_cid,
    get_structure_image_url,
    get_3d_verified_similar_compounds
)
from app.services.compound_knowledge import get_compound_knowledge
from app.services.llm_agent import generate_compound_knowledge
from app.models.compound_cache import CompoundCache
from app.models import db
import json
import logging

module2_bp = Blueprint("module2", __name__, url_prefix="/api/module2")


@module2_bp.route("/search", methods=["GET"])
@jwt_required()
def search_name():
    name = request.args.get("name", "")
    if not name:
        return jsonify({"error": "name parameter required"}), 400
    results = search_by_name(name)
    return jsonify([r.to_dict() for r in results])


@module2_bp.route("/smiles", methods=["GET"])
@jwt_required()
def search_smiles():
    query = request.args.get("query", "")
    if not query:
        return jsonify({"error": "query parameter required"}), 400
    results = search_by_smiles(query)
    return jsonify([r.to_dict() for r in results])


@module2_bp.route("/details/<int:compound_id>", methods=["GET"])
@jwt_required()
def details(compound_id: int):
    comp = get_by_id(compound_id)
    if not comp:
        return jsonify({"error": "not found"}), 404
    # Optionally include similar compounds
    similar = []
    if comp.smiles:
        sims = find_similar_by_smiles(comp.smiles, top_n=5)
        similar = [s.to_dict() for s in sims if s.id != comp.id]
    out = comp.to_dict()
    out["similar"] = similar
    return jsonify(out)


@module2_bp.route("/resolve", methods=["GET"])
@jwt_required()
def resolve():
    name = request.args.get("name", "")
    if not name:
        return jsonify({"error": "name parameter required"}), 400
    res = resolve_name(name)
    return jsonify(res)


@module2_bp.route("/alias", methods=["POST"])
@jwt_required()
def create_alias():
    data = request.get_json(force=True)
    if not data or 'query' not in data:
        return jsonify({"error": "query field required"}), 400
    query = data.get('query')
    local_compound_id = data.get('local_compound_id')
    smiles = data.get('smiles')
    synonyms = data.get('synonyms')
    # ensure synonyms is a list if provided
    if synonyms is not None and not isinstance(synonyms, list):
        try:
            # try to coerce from comma-separated
            synonyms = [s.strip() for s in str(synonyms).split(',') if s.strip()]
        except Exception:
            synonyms = None
    alias = create_or_update_alias(query, local_compound_id=local_compound_id, smiles=smiles, synonyms=synonyms)
    return jsonify({"alias": alias.to_dict()}), 201


@module2_bp.route("/compound/<name>", methods=["GET"])
@jwt_required()
def get_compound_full(name: str):
    """
    Returns full compound profile:
    - Chemical data from PubChem (CID, SMILES, formula, MW, InChIKey, IUPAC name)
    - Description text from PubChem
    - Synonyms (first 15)
    - Source organisms (from knowledge base)
    - Medicinal remedy sections (from knowledge base)
    - Structure image URL
    """
    # 0. Check Database Cache First
    name_lower = name.strip().lower()
    cached = CompoundCache.query.filter_by(query_name=name_lower).first()
    if cached:
        return jsonify(json.loads(cached.json_data))

    result = {
        "name": name,
        "pubchem": None,
        "description": None,
        "synonyms": [],
        "structure_image": None,
        "source_organisms": [],
        "source_type": None,
        "compound_class": None,
        "bioactivity": [],
        "medicinal_remedy": None,
        "traditional_use": None,
        "found_in_knowledge_base": False,
        "found_in_pubchem": False,
        "similar_compounds": [],
        "render_3d": True, # Molecular weight gatekeeper
    }
    
    # 1. Check local knowledge base
    kb = get_compound_knowledge(name)
    if kb:
        result.update(kb)
        result["found_in_knowledge_base"] = True
    else:
        # 1.5. Dynamic LLM Fallback
        llm_kb = generate_compound_knowledge(name)
        if llm_kb:
            result.update(llm_kb)
            result["found_in_knowledge_base"] = True
    
    # 2. Always enrich with PubChem data
    cids = get_cids_for_name(name)
    if cids:
        cid = cids[0]
        props = get_full_properties_for_cid(cid)
        syns = get_synonyms_for_cid(cid)
        desc = get_description_for_cid(cid)
        result["pubchem"] = props
        result["synonyms"] = syns[:15]
        result["description"] = desc
        result["structure_image"] = get_structure_image_url(cid)
        result["found_in_pubchem"] = True
        
        # Atom-Count / Molecular Weight Gatekeeping
        try:
            mw = float(props.get("molecular_weight", 0))
            if mw > 800:
                result["render_3d"] = False
        except Exception as e:
            logging.exception("Failed to parse molecular weight for %s", name)
            
        # 3D Pharmacophore Screening
        target_smiles = props.get("canonical_smiles") or props.get("isomeric_smiles")
        if target_smiles:
            result["similar_compounds"] = get_3d_verified_similar_compounds(cid, target_smiles, limit=6)

    # 3. Save to Database Cache
    if result["found_in_pubchem"] or result["found_in_knowledge_base"]:
        try:
            new_cache = CompoundCache(
                query_name=name_lower,
                json_data=json.dumps(result)
            )
            db.session.add(new_cache)
            db.session.commit()
        except Exception:
            db.session.rollback()
            logging.exception("Failed to write compound cache for %s", name_lower)
    
    return jsonify(result)

