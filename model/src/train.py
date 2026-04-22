from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import List

import tensorflow as tf


def resolve_split_dir(data_root: Path, split_name: str) -> Path:
    """Resolve split directories with either lowercase or titlecase names."""
    candidates = [split_name.lower(), split_name.capitalize(), split_name.upper()]
    for candidate in candidates:
        split_dir = data_root / candidate
        if split_dir.exists():
            return split_dir
    raise FileNotFoundError(
        f"Missing split folder for '{split_name}' in {data_root}. "
        f"Tried: {candidates}"
    )


def infer_class_names(train_dir: Path) -> List[str]:
    class_dirs = [path.name for path in train_dir.iterdir() if path.is_dir()]
    if not class_dirs:
        raise ValueError(f"No class folders found in training split: {train_dir}")
    return sorted(class_dirs, key=lambda value: value.lower())


def parse_class_names(value: str | None) -> List[str] | None:
    if not value:
        return None
    names = [name.strip() for name in value.split(",") if name.strip()]
    return names or None


def validate_class_folders(split_dir: Path, class_names: List[str]) -> None:
    missing = [name for name in class_names if not (split_dir / name).exists()]
    if missing:
        raise FileNotFoundError(
            f"Missing class folders in {split_dir}: {', '.join(missing)}"
        )


def make_datasets(
    data_root: Path,
    img_size: int,
    batch_size: int,
    class_names: List[str],
):
    train_dir = resolve_split_dir(data_root, "train")
    val_dir = resolve_split_dir(data_root, "val")
    test_dir = resolve_split_dir(data_root, "test")

    validate_class_folders(train_dir, class_names)
    validate_class_folders(val_dir, class_names)
    validate_class_folders(test_dir, class_names)

    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir,
        labels="inferred",
        label_mode="int",
        class_names=class_names,
        image_size=(img_size, img_size),
        batch_size=batch_size,
        shuffle=True,
        seed=42,
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        val_dir,
        labels="inferred",
        label_mode="int",
        class_names=class_names,
        image_size=(img_size, img_size),
        batch_size=batch_size,
        shuffle=False,
    )

    test_ds = tf.keras.utils.image_dataset_from_directory(
        test_dir,
        labels="inferred",
        label_mode="int",
        class_names=class_names,
        image_size=(img_size, img_size),
        batch_size=batch_size,
        shuffle=False,
    )

    autotune = tf.data.AUTOTUNE
    train_ds = train_ds.prefetch(autotune)
    val_ds = val_ds.prefetch(autotune)
    test_ds = test_ds.prefetch(autotune)

    return train_ds, val_ds, test_ds


def build_model(img_size: int, num_classes: int):
    data_augmentation = tf.keras.Sequential(
        [
            tf.keras.layers.RandomFlip("horizontal"),
            tf.keras.layers.RandomRotation(0.08),
            tf.keras.layers.RandomZoom(0.12),
        ]
    )

    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(img_size, img_size, 3)),
            data_augmentation,
            tf.keras.layers.Rescaling(1.0 / 255),
            tf.keras.layers.Conv2D(32, (3, 3), activation="relu", padding="same"),
            tf.keras.layers.MaxPooling2D(),
            tf.keras.layers.Conv2D(64, (3, 3), activation="relu", padding="same"),
            tf.keras.layers.MaxPooling2D(),
            tf.keras.layers.Conv2D(128, (3, 3), activation="relu", padding="same"),
            tf.keras.layers.MaxPooling2D(),
            tf.keras.layers.Conv2D(256, (3, 3), activation="relu", padding="same"),
            tf.keras.layers.MaxPooling2D(),
            tf.keras.layers.Flatten(),
            tf.keras.layers.Dense(256, activation="relu"),
            tf.keras.layers.Dropout(0.3),
            tf.keras.layers.Dense(num_classes, activation="softmax"),
        ]
    )

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy"],
    )
    return model


def save_history(history, out_file: Path):
    serializable = {k: [float(v) for v in vals] for k, vals in history.history.items()}
    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text(json.dumps(serializable, indent=2), encoding="utf-8")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Train plant disease CNN model for any crop dataset"
    )
    parser.add_argument(
        "--data_root",
        type=str,
        default="dataset/processed",
        help="Dataset root with train/val/test folders",
    )
    parser.add_argument("--img_size", type=int, default=224)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument("--epochs", type=int, default=12)
    parser.add_argument(
        "--model_out",
        type=str,
        default="model/saved_model/plant_disease_model.h5",
    )
    parser.add_argument(
        "--history_out",
        type=str,
        default="model/artifacts/training_history.json",
    )
    parser.add_argument(
        "--metrics_out",
        type=str,
        default="model/artifacts/test_metrics.json",
    )
    parser.add_argument(
        "--class_names",
        type=str,
        default=None,
        help=(
            "Optional comma-separated class names in required order. "
            "If omitted, classes are inferred from train split folders."
        ),
    )
    parser.add_argument(
        "--class_names_out",
        type=str,
        default="model/artifacts/class_names.json",
        help="Where to save class labels metadata.",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    tf.random.set_seed(42)

    data_root = Path(args.data_root)
    model_out = Path(args.model_out)
    history_out = Path(args.history_out)
    metrics_out = Path(args.metrics_out)
    class_names_out = Path(args.class_names_out)

    train_dir = resolve_split_dir(data_root, "train")
    class_names = parse_class_names(args.class_names) or infer_class_names(train_dir)
    print(f"Using {len(class_names)} classes: {class_names}")

    print("Loading datasets...")
    train_ds, val_ds, test_ds = make_datasets(
        data_root=data_root,
        img_size=args.img_size,
        batch_size=args.batch_size,
        class_names=class_names,
    )

    print("Building model...")
    model = build_model(img_size=args.img_size, num_classes=len(class_names))
    model.summary()

    model_out.parent.mkdir(parents=True, exist_ok=True)
    history_out.parent.mkdir(parents=True, exist_ok=True)
    metrics_out.parent.mkdir(parents=True, exist_ok=True)
    class_names_out.parent.mkdir(parents=True, exist_ok=True)

    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_accuracy", patience=4, restore_best_weights=True
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss", factor=0.5, patience=2, verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(model_out),
            monitor="val_accuracy",
            save_best_only=True,
            verbose=1,
        ),
    ]

    print("Training started...")
    history = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs,
        callbacks=callbacks,
        verbose=1,
    )

    print("Evaluating on test set...")
    test_loss, test_acc = model.evaluate(test_ds, verbose=1)

    metrics = {
        "test_loss": float(test_loss),
        "test_accuracy": float(test_acc),
        "class_names": class_names,
    }

    save_history(history, history_out)
    metrics_out.write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    class_names_out.write_text(json.dumps(class_names, indent=2), encoding="utf-8")

    # Save final model snapshot too.
    model.save(str(model_out))

    print("Training complete.")
    print(json.dumps(metrics, indent=2))


if __name__ == "__main__":
    main()
