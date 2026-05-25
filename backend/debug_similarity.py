import requests

def run_sim(cid):
    url = f"https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsimilarity_2d/cid/{cid}/property/Title,CanonicalSMILES/JSON?Threshold=80&MaxRecords=5"
    resp = requests.get(url)
    print(resp.json())


if __name__ == '__main__':
    run_sim(5280343)  # Quercetin
