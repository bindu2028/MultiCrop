"""
Clean a COCONUT-derived CSV into the simplified `natural_compounds.csv` layout.

Usage:
  python backend/scripts/clean_coconut_csv.py backend/data/raw/COCONUT4MetFrag_april.csv backend/data/natural_compounds.csv

This script uses heuristics to pick columns from the raw CSV. It won't compute molecular weight.
"""
import sys
import csv
from pathlib import Path


PREFERRED_SMILES = [
    "canonical_smiles",
    "clean_smiles",
    "smiles",
    "SMILES",
    "isomeric_smiles",
]

PREFERRED_NAME = ["name", "compound_name", "natural_product_name", "coconut_id"]
PREFERRED_CLASS = ["np_classifier_pathway", "compound_class", "compound_classification", "class"]
PREFERRED_SOURCE = ["source_organism", "source", "origin"]
PREFERRED_FORMULA = ["molecular_formula", "formula"]
PREFERRED_MW = ["molecular_weight", "mw"]


def choose_field(row, candidates):
    for c in candidates:
        if c in row and row[c]:
            return row[c]
    return ""


def clean(input_csv: Path, output_csv: Path):
    with input_csv.open(encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        fields_out = [
            "compound_name",
            "canonical_smiles",
            "compound_class",
            "source_organism",
            "molecular_formula",
            "molecular_weight",
        ]
        with output_csv.open("w", encoding="utf-8", newline="") as out:
            writer = csv.DictWriter(out, fieldnames=fields_out)
            writer.writeheader()
            for row in reader:
                name = choose_field(row, PREFERRED_NAME) or ""
                if not name:
                    # fallback to coconut_id if exists
                    name = row.get("coconut_id", "")

                smiles = choose_field(row, PREFERRED_SMILES)
                cls = choose_field(row, PREFERRED_CLASS)
                src = choose_field(row, PREFERRED_SOURCE)
                formula = choose_field(row, PREFERRED_FORMULA)
                mw = choose_field(row, PREFERRED_MW)

                writer.writerow({
                    "compound_name": name,
                    "canonical_smiles": smiles,
                    "compound_class": cls,
                    "source_organism": src,
                    "molecular_formula": formula,
                    "molecular_weight": mw,
                })


def main():
    if len(sys.argv) < 3:
        print("Usage: python clean_coconut_csv.py input.csv output.csv")
        sys.exit(1)
    inp = Path(sys.argv[1])
    out = Path(sys.argv[2])
    if not inp.exists():
        print("Input not found:", inp)
        sys.exit(1)
    clean(inp, out)
    print("Wrote", out)


if __name__ == "__main__":
    main()
