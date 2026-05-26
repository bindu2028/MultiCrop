from app.utils.pubchem import get_cids_for_name, get_properties_for_cid

for name in ["quercetin", "caffeine", "aspirin"]:
    cids = get_cids_for_name(name)
    if cids:
        props = get_properties_for_cid(cids[0])
        if props:
            print(f"{name.capitalize()}: {props['smiles']}")
