from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def has_split_folders(crop_dir: Path) -> bool:
    candidates = ["Train", "Val", "Test", "train", "val", "test"]
    names = {p.name for p in crop_dir.iterdir() if p.is_dir()}
    return any(name in names for name in candidates)


def crop_dirs_from_root(dataset_root: Path) -> list[Path]:
    dirs = [p for p in dataset_root.iterdir() if p.is_dir() and has_split_folders(p)]
    return sorted(dirs, key=lambda p: p.name.lower())


def run_command(command: list[str]) -> int:
    process = subprocess.run(command)
    return process.returncode


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train one model per crop folder (each crop has Train/Val/Test)."
    )
    parser.add_argument(
        "--dataset_root",
        type=str,
        required=True,
        help="Root directory containing crop folders (Apple, Grape, etc.).",
    )
    parser.add_argument(
        "--epochs",
        type=int,
        default=15,
        help="Training epochs for each crop.",
    )
    parser.add_argument("--img_size", type=int, default=224)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument(
        "--output_dir",
        type=str,
        default="model/saved_model",
        help="Directory for per-crop model files.",
    )
    parser.add_argument(
        "--artifacts_dir",
        type=str,
        default="model/artifacts",
        help="Directory for per-crop history/metrics/class names.",
    )
    parser.add_argument(
        "--skip_existing",
        action="store_true",
        help="Skip training for crop if model file already exists.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    dataset_root = Path(args.dataset_root)
    output_dir = Path(args.output_dir)
    artifacts_dir = Path(args.artifacts_dir)

    if not dataset_root.exists():
        raise FileNotFoundError(f"Dataset root not found: {dataset_root}")

    output_dir.mkdir(parents=True, exist_ok=True)
    artifacts_dir.mkdir(parents=True, exist_ok=True)

    crops = crop_dirs_from_root(dataset_root)
    if not crops:
        raise ValueError(
            "No crop directories with Train/Val/Test found under: "
            f"{dataset_root}"
        )

    print(f"Found {len(crops)} crop folders:")
    for crop in crops:
        print(f"- {crop.name}")

    script_path = Path(__file__).with_name("train.py")
    python_exe = sys.executable

    failures: list[str] = []

    for crop_dir in crops:
        crop_slug = crop_dir.name.lower().replace(" ", "_").replace("(", "").replace(")", "")
        model_out = output_dir / f"plant_disease_{crop_slug}.h5"
        history_out = artifacts_dir / f"training_history_{crop_slug}.json"
        metrics_out = artifacts_dir / f"test_metrics_{crop_slug}.json"
        class_names_out = artifacts_dir / f"class_names_{crop_slug}.json"

        if args.skip_existing and model_out.exists():
            print(f"\n[SKIP] {crop_dir.name}: model already exists at {model_out}")
            continue

        command = [
            python_exe,
            str(script_path),
            "--data_root",
            str(crop_dir),
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
        print(f"Training crop: {crop_dir.name}")
        print("=" * 72)
        print(" ".join(command))

        exit_code = run_command(command)
        if exit_code != 0:
            failures.append(crop_dir.name)
            print(f"[FAILED] {crop_dir.name}")
        else:
            print(f"[DONE] {crop_dir.name}")

    print("\n" + "=" * 72)
    if failures:
        print("Training completed with failures:")
        for crop in failures:
            print(f"- {crop}")
        raise SystemExit(1)

    print("Training completed successfully for all crops.")


if __name__ == "__main__":
    main()
