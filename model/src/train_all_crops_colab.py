from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


REQUIRED_SPLITS = {"train", "val", "test"}


def has_required_splits(crop_dir: Path) -> bool:
    names = {p.name.lower() for p in crop_dir.iterdir() if p.is_dir()}
    return REQUIRED_SPLITS.issubset(names)


def find_crop_dirs(dataset_root: Path) -> list[Path]:
    crop_dirs = [p for p in dataset_root.iterdir() if p.is_dir() and has_required_splits(p)]
    return sorted(crop_dirs, key=lambda p: p.name.lower())


def slugify(name: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", name.strip().lower())
    return slug.strip("_")


def run(command: list[str]) -> int:
    print(" ".join(command))
    result = subprocess.run(command)
    return result.returncode


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Train one model per crop directory. "
            "Each crop must contain Train/Val/Test (or lowercase variants)."
        )
    )
    parser.add_argument(
        "--dataset_root",
        type=str,
        required=True,
        help="Root directory containing crop folders (Apple, Bell Pepper, etc.).",
    )
    parser.add_argument(
        "--train_script",
        type=str,
        default="model/src/train.py",
        help="Path to train.py script.",
    )
    parser.add_argument("--epochs", type=int, default=15)
    parser.add_argument("--img_size", type=int, default=224)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument(
        "--output_dir",
        type=str,
        default="model/saved_model",
        help="Directory to save per-crop model files.",
    )
    parser.add_argument(
        "--artifacts_dir",
        type=str,
        default="model/artifacts",
        help="Directory to save per-crop metrics/history/class names.",
    )
    parser.add_argument(
        "--skip_existing",
        action="store_true",
        help="Skip crop training if the output model file already exists.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    dataset_root = Path(args.dataset_root)
    train_script = Path(args.train_script)
    output_dir = Path(args.output_dir)
    artifacts_dir = Path(args.artifacts_dir)

    if not dataset_root.exists():
        raise FileNotFoundError(f"Dataset root not found: {dataset_root}")

    if not train_script.exists():
        raise FileNotFoundError(f"train.py not found at: {train_script}")

    output_dir.mkdir(parents=True, exist_ok=True)
    artifacts_dir.mkdir(parents=True, exist_ok=True)

    crops = find_crop_dirs(dataset_root)
    if not crops:
        raise ValueError(
            "No crop folders found with Train/Val/Test under: "
            f"{dataset_root}"
        )

    print(f"Found {len(crops)} crop folders:")
    for crop in crops:
        print(f"- {crop.name}")

    python_exe = sys.executable
    failed: list[str] = []

    for crop in crops:
        crop_slug = slugify(crop.name)
        model_out = output_dir / f"plant_disease_{crop_slug}.h5"
        history_out = artifacts_dir / f"training_history_{crop_slug}.json"
        metrics_out = artifacts_dir / f"test_metrics_{crop_slug}.json"
        class_names_out = artifacts_dir / f"class_names_{crop_slug}.json"

        if args.skip_existing and model_out.exists():
            print(f"\n[SKIP] {crop.name}: model already exists at {model_out}")
            continue

        command = [
            python_exe,
            str(train_script),
            "--data_root",
            str(crop),
            "--epochs",
            str(args.epochs),
            "--img_size",
            str(args.img_size),
            "--batch_size",
            str(args.batch_size),
            "--model_out",
            str(model_out),
            "--history_out",
            str(history_out),
            "--metrics_out",
            str(metrics_out),
            "--class_names_out",
            str(class_names_out),
        ]

        print("\n" + "=" * 72)
        print(f"Training crop: {crop.name}")
        print("=" * 72)
        code = run(command)

        if code != 0:
            failed.append(crop.name)
            print(f"[FAILED] {crop.name}")
        else:
            print(f"[DONE] {crop.name}")

    print("\n" + "=" * 72)
    if failed:
        print("Training finished with failures:")
        for crop_name in failed:
            print(f"- {crop_name}")
        raise SystemExit(1)

    print("Training finished successfully for all crops.")


if __name__ == "__main__":
    main()
