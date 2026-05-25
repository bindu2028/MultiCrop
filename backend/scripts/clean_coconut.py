"""
Script to extract and clean COCONUT dataset into a simplified CSV.

Usage:
  python backend/scripts/clean_coconut.py /path/to/coconut.json backend/data/natural_compounds.csv

This script does not download COCONUT automatically. Place the raw file locally and point to it.
"""
import sys
import json
import csv
from pathlib import Path


def extract(input_path: Path, output_path: Path):
    with input_path.open(encoding="utf-8") as fh:
        data = json.load(fh)

    fields = [
        "compound_name",
        "canonical_smiles",
        "compound_class",
        "source_organism",
        "molecular_formula",
        "molecular_weight",
    ]

    with output_path.open("w", encoding="utf-8", newline="") as out:
        writer = csv.DictWriter(out, fieldnames=fields)
        writer.writeheader()
        for rec in data:
            # COCONUT JSON fields vary. try common keys
            name = rec.get("name") or rec.get("compound_name") or rec.get("natural_product_name")
            smiles = rec.get("smiles") or rec.get("canonical_smiles") or rec.get("inchikey")
            cls = None
            # np_classifier_pathway sometimes nested
            cls = rec.get("np_classifier_pathway") or rec.get("compound_class")
            src = None
            if rec.get("source_organism"):
                src = rec.get("source_organism")
            elif rec.get("source"):
                src = rec.get("source")
            formula = rec.get("molecular_formula") or rec.get("formula")
            mw = rec.get("molecular_weight") or rec.get("mw")

            if not name:
                continue

            writer.writerow({
                "compound_name": name,
                "canonical_smiles": smiles or "",
                "compound_class": cls or "",
                "source_organism": src or "",
                "molecular_formula": formula or "",
                "molecular_weight": mw or "",
            })


def main():
    if len(sys.argv) < 3:
        print("Usage: python clean_coconut.py /path/to/coconut.json output.csv")
        sys.exit(1)
    inp = Path(sys.argv[1])
    out = Path(sys.argv[2])
    if not inp.exists():
        print("Input not found:", inp)
        sys.exit(1)
    extract(inp, out)
    print("Wrote", out)


if __name__ == "__main__":
    main()
