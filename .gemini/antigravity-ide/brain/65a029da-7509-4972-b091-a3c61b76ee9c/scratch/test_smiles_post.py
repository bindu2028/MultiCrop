import requests

BASE = "https://pubchem.ncbi.nlm.nih.gov/rest/pug"
smiles = "C1=CC(=C(C=C1C2=C(C(=O)C3=C(O2)C=C(C=C3O)O)O)O)O"

url = f"{BASE}/compound/smiles/cids/JSON"
print(f"Sending POST to {url} with smiles: {smiles}...")

try:
    resp = requests.post(url, data={"smiles": smiles}, timeout=10)
    print(f"Status Code: {resp.status_code}")
    print(f"Response Body: '{resp.text}'")
except Exception as e:
    print(f"Error: {e}")
