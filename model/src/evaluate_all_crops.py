from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path

import numpy as np
import tensorflow as tf


def slugify(name: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", name.strip().lower())
    return slug.strip("_")


def resolve_split_dir(data_root: Path, split_name: str) -> Path:
    candidates = [split_name.lower(), split_name.capitalize(), split_name.upper()]
    for candidate in candidates:
        split_dir = data_root / candidate
        if split_dir.exists():
            return split_dir
    raise FileNotFoundError(
        f"Missing split folder for '{split_name}' in {data_root}. Tried: {candidates}"
    )


def has_required_splits(crop_dir: Path) -> bool:
    names = {p.name.lower() for p in crop_dir.iterdir() if p.is_dir()}
    return {"train", "val", "test"}.issubset(names)


def discover_crop_dirs(dataset_root: Path) -> list[Path]:
    crops = [p for p in dataset_root.iterdir() if p.is_dir() and has_required_splits(p)]
    return sorted(crops, key=lambda p: p.name.lower())


def load_class_names(crop_slug: str, test_dir: Path, artifacts_dir: Path) -> list[str]:
    class_names_file = artifacts_dir / f"class_names_{crop_slug}.json"
    if class_names_file.exists():
        data = json.loads(class_names_file.read_text(encoding="utf-8"))
        if isinstance(data, list) and data:
            return [str(x) for x in data]

    classes = [p.name for p in test_dir.iterdir() if p.is_dir()]
    if not classes:
        raise ValueError(f"No class folders found in test split: {test_dir}")
    return sorted(classes, key=lambda x: x.lower())


def make_test_dataset(
    crop_dir: Path,
    img_size: int,
    batch_size: int,
    class_names: list[str],
):
    test_dir = resolve_split_dir(crop_dir, "test")
    return tf.keras.utils.image_dataset_from_directory(
        test_dir,
        labels="inferred",
        label_mode="int",
        class_names=class_names,
        image_size=(img_size, img_size),
        batch_size=batch_size,
        shuffle=False,
    )


def compute_class_metrics(confusion_matrix: np.ndarray, class_names: list[str]) -> list[dict]:
    metrics: list[dict] = []
    total = float(np.sum(confusion_matrix))

    for idx, class_name in enumerate(class_names):
        tp = float(confusion_matrix[idx, idx])
        fp = float(np.sum(confusion_matrix[:, idx]) - tp)
        fn = float(np.sum(confusion_matrix[idx, :]) - tp)
        tn = total - tp - fp - fn

        precision = tp / (tp + fp) if (tp + fp) else 0.0
        recall = tp / (tp + fn) if (tp + fn) else 0.0
        f1 = (2 * precision * recall / (precision + recall)) if (precision + recall) else 0.0
        support = int(np.sum(confusion_matrix[idx, :]))

        metrics.append(
            {
                "class": class_name,
                "precision": precision,
                "recall": recall,
                "f1_score": f1,
                "support": support,
                "tp": int(tp),
                "fp": int(fp),
                "fn": int(fn),
                "tn": int(tn),
            }
        )

    return metrics


def save_confusion_matrix_csv(
    confusion_matrix: np.ndarray,
    class_names: list[str],
    output_file: Path,
) -> None:
    output_file.parent.mkdir(parents=True, exist_ok=True)
    with output_file.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["actual\\predicted", *class_names])
        for i, class_name in enumerate(class_names):
            row = [class_name, *confusion_matrix[i, :].tolist()]
            writer.writerow(row)


def evaluate_crop(
    crop_dir: Path,
    model_dir: Path,
    artifacts_dir: Path,
    eval_dir: Path,
    img_size: int,
    batch_size: int,
) -> dict:
    crop_slug = slugify(crop_dir.name)
    model_path = model_dir / f"plant_disease_{crop_slug}.h5"
    if not model_path.exists():
        raise FileNotFoundError(f"Model not found for crop '{crop_dir.name}': {model_path}")

    test_dir = resolve_split_dir(crop_dir, "test")
    class_names = load_class_names(crop_slug, test_dir, artifacts_dir)

    test_ds = make_test_dataset(crop_dir, img_size, batch_size, class_names)
    test_ds = test_ds.prefetch(tf.data.AUTOTUNE)

    model = tf.keras.models.load_model(model_path)
    predictions = model.predict(test_ds, verbose=0)
    y_pred = np.argmax(predictions, axis=1)

    y_true_batches = []
    for _, labels in test_ds:
        y_true_batches.append(labels.numpy())
    y_true = np.concatenate(y_true_batches, axis=0)

    if len(y_true) != len(y_pred):
        raise ValueError(
            f"Prediction/sample length mismatch for {crop_slug}: "
            f"y_true={len(y_true)}, y_pred={len(y_pred)}"
        )

    confusion_matrix = tf.math.confusion_matrix(
        y_true,
        y_pred,
        num_classes=len(class_names),
    ).numpy()

    accuracy = float(np.mean(y_true == y_pred))
    class_metrics = compute_class_metrics(confusion_matrix, class_names)

    eval_dir.mkdir(parents=True, exist_ok=True)
    cm_csv = eval_dir / f"confusion_matrix_{crop_slug}.csv"
    report_json = eval_dir / f"classification_report_{crop_slug}.json"

    save_confusion_matrix_csv(confusion_matrix, class_names, cm_csv)

    report = {
        "crop": crop_dir.name,
        "crop_slug": crop_slug,
        "model_path": str(model_path),
        "samples": int(len(y_true)),
        "accuracy": accuracy,
        "class_names": class_names,
        "class_metrics": class_metrics,
        "confusion_matrix_csv": str(cm_csv),
    }
    report_json.write_text(json.dumps(report, indent=2), encoding="utf-8")

    return report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Evaluate all crop models and generate confusion matrix/report files."
    )
    parser.add_argument(
        "--dataset_root",
        type=str,
        required=True,
        help="Root directory containing crop folders (Apple, Potato, etc.)",
    )
    parser.add_argument(
        "--model_dir",
        type=str,
        default="model/saved_model",
        help="Directory containing per-crop .h5 model files.",
    )
    parser.add_argument(
        "--artifacts_dir",
        type=str,
        default="model/artifacts",
        help="Directory containing class_names_<crop>.json files (optional but recommended).",
    )
    parser.add_argument(
        "--eval_dir",
        type=str,
        default="model/artifacts/evaluation",
        help="Directory to save evaluation outputs.",
    )
    parser.add_argument("--img_size", type=int, default=224)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument(
        "--skip_missing_models",
        action="store_true",
        help="Skip crop folders that do not have corresponding model files.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    dataset_root = Path(args.dataset_root)
    model_dir = Path(args.model_dir)
    artifacts_dir = Path(args.artifacts_dir)
    eval_dir = Path(args.eval_dir)

    if not dataset_root.exists():
        raise FileNotFoundError(f"Dataset root not found: {dataset_root}")
    if not model_dir.exists():
        raise FileNotFoundError(f"Model directory not found: {model_dir}")

    crops = discover_crop_dirs(dataset_root)
    if not crops:
        raise ValueError(f"No crop folders with Train/Val/Test found under: {dataset_root}")

    print(f"Found {len(crops)} crop folders for evaluation.")

    summary: dict[str, dict] = {}
    failures: dict[str, str] = {}

    for crop_dir in crops:
        crop_slug = slugify(crop_dir.name)
        model_path = model_dir / f"plant_disease_{crop_slug}.h5"
        if not model_path.exists() and args.skip_missing_models:
            print(f"[SKIP] {crop_dir.name}: model file missing at {model_path}")
            continue

        print("\n" + "=" * 72)
        print(f"Evaluating crop: {crop_dir.name}")
        print("=" * 72)

        try:
            report = evaluate_crop(
                crop_dir=crop_dir,
                model_dir=model_dir,
                artifacts_dir=artifacts_dir,
                eval_dir=eval_dir,
                img_size=args.img_size,
                batch_size=args.batch_size,
            )
            summary[crop_slug] = report
            print(f"[DONE] {crop_dir.name} | accuracy={report['accuracy']:.4f}")
        except Exception as exc:
            failures[crop_dir.name] = str(exc)
            print(f"[FAILED] {crop_dir.name} -> {exc}")

    eval_dir.mkdir(parents=True, exist_ok=True)
    summary_file = eval_dir / "evaluation_summary.json"
    payload = {
        "evaluated_crops": sorted(summary.keys()),
        "reports": summary,
        "failures": failures,
    }
    summary_file.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    print("\n" + "=" * 72)
    print(f"Summary file: {summary_file}")
    if failures:
        print("Evaluation finished with failures:")
        for crop_name, reason in failures.items():
            print(f"- {crop_name}: {reason}")
        raise SystemExit(1)

    print("Evaluation finished successfully for all crops.")


if __name__ == "__main__":
    main()
