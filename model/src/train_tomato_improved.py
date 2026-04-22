from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import List

import numpy as np
import tensorflow as tf


def resolve_split_dir(data_root: Path, split_name: str) -> Path:
    candidates = [split_name.lower(), split_name.capitalize(), split_name.upper()]
    for candidate in candidates:
        split_dir = data_root / candidate
        if split_dir.exists():
            return split_dir
    raise FileNotFoundError(
        f"Missing split folder for '{split_name}' in {data_root}. Tried: {candidates}"
    )


def infer_class_names(train_dir: Path) -> List[str]:
    class_dirs = [path.name for path in train_dir.iterdir() if path.is_dir()]
    if not class_dirs:
        raise ValueError(f"No class folders found in training split: {train_dir}")
    return sorted(class_dirs, key=lambda value: value.lower())


def validate_class_folders(split_dir: Path, class_names: List[str]) -> None:
    missing = [name for name in class_names if not (split_dir / name).exists()]
    if missing:
        raise FileNotFoundError(
            f"Missing class folders in {split_dir}: {', '.join(missing)}"
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train an improved tomato disease model using transfer learning."
    )
    parser.add_argument(
        "--data_root",
        type=str,
        default="dataset/multicrop/Tomato",
        help="Tomato dataset root containing Train/Val/Test folders.",
    )
    parser.add_argument("--img_size", type=int, default=224)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument("--epochs_head", type=int, default=10)
    parser.add_argument("--epochs_finetune", type=int, default=8)
    parser.add_argument("--fine_tune_at", type=int, default=200)
    parser.add_argument(
        "--model_out",
        type=str,
        default="model/saved_model/plant_disease_tomato_improved.h5",
    )
    parser.add_argument(
        "--history_out",
        type=str,
        default="model/artifacts/tomato_improved_history.json",
    )
    parser.add_argument(
        "--metrics_out",
        type=str,
        default="model/artifacts/tomato_improved_metrics.json",
    )
    parser.add_argument(
        "--class_names_out",
        type=str,
        default="model/artifacts/class_names_tomato_improved.json",
    )
    return parser.parse_args()


def make_datasets(data_root: Path, img_size: int, batch_size: int, class_names: List[str]):
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
    return (
        train_ds.prefetch(autotune),
        val_ds.prefetch(autotune),
        test_ds.prefetch(autotune),
    )


def count_images_per_class(split_dir: Path) -> Counter:
    counts: Counter = Counter()
    for class_dir in split_dir.iterdir():
        if class_dir.is_dir():
            counts[class_dir.name] = sum(1 for item in class_dir.iterdir() if item.is_file())
    return counts


def compute_class_weights(train_dir: Path, class_names: List[str]) -> dict[int, float]:
    counts = count_images_per_class(train_dir)
    total = sum(counts.get(name, 0) for name in class_names)
    num_classes = len(class_names)
    class_weights: dict[int, float] = {}

    for idx, class_name in enumerate(class_names):
        class_count = counts.get(class_name, 0)
        if class_count == 0:
            class_weights[idx] = 0.0
        else:
            class_weights[idx] = float(total / (num_classes * class_count))
    return class_weights


def build_model(img_size: int, num_classes: int):
    data_augmentation = tf.keras.Sequential(
        [
            tf.keras.layers.RandomFlip("horizontal"),
            tf.keras.layers.RandomRotation(0.15),
            tf.keras.layers.RandomZoom(0.15),
            tf.keras.layers.RandomContrast(0.15),
            tf.keras.layers.RandomTranslation(0.08, 0.08),
        ],
        name="augmentation",
    )

    base_model = tf.keras.applications.EfficientNetB0(
        include_top=False,
        weights="imagenet",
        input_shape=(img_size, img_size, 3),
    )
    base_model.trainable = False

    inputs = tf.keras.layers.Input(shape=(img_size, img_size, 3))
    x = data_augmentation(inputs)
    x = tf.keras.applications.efficientnet.preprocess_input(x)
    x = base_model(x, training=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.Dropout(0.4)(x)
    x = tf.keras.layers.Dense(256, activation="relu")(x)
    x = tf.keras.layers.Dropout(0.3)(x)
    outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)

    model = tf.keras.Model(inputs, outputs, name="tomato_efficientnet")
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy"],
    )
    return model, base_model


def save_history(history, out_file: Path):
    serializable = {k: [float(v) for v in vals] for k, vals in history.history.items()}
    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text(json.dumps(serializable, indent=2), encoding="utf-8")


def main() -> None:
    args = parse_args()
    tf.random.set_seed(42)

    data_root = Path(args.data_root)
    model_out = Path(args.model_out)
    history_out = Path(args.history_out)
    metrics_out = Path(args.metrics_out)
    class_names_out = Path(args.class_names_out)

    train_dir = resolve_split_dir(data_root, "train")
    class_names = infer_class_names(train_dir)
    print(f"Using {len(class_names)} classes: {class_names}")

    train_ds, val_ds, test_ds = make_datasets(
        data_root=data_root,
        img_size=args.img_size,
        batch_size=args.batch_size,
        class_names=class_names,
    )

    class_weights = compute_class_weights(train_dir, class_names)
    print(f"Class weights: {class_weights}")

    model, base_model = build_model(args.img_size, len(class_names))
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

    print("Training classifier head...")
    history_head = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs_head,
        callbacks=callbacks,
        class_weight=class_weights,
        verbose=1,
    )

    print("Fine-tuning backbone...")
    base_model.trainable = True
    for layer in base_model.layers[: args.fine_tune_at]:
        layer.trainable = False

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy"],
    )

    history_finetune = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs_head + args.epochs_finetune,
        initial_epoch=history_head.epoch[-1] + 1,
        callbacks=callbacks,
        class_weight=class_weights,
        verbose=1,
    )

    print("Evaluating on test set...")
    test_loss, test_acc = model.evaluate(test_ds, verbose=1)

    metrics = {
        "test_loss": float(test_loss),
        "test_accuracy": float(test_acc),
        "class_names": class_names,
        "class_weights": class_weights,
    }

    combined_history = {}
    for key, values in history_head.history.items():
        combined_history[key] = [float(v) for v in values]
    for key, values in history_finetune.history.items():
        combined_history.setdefault(key, [])
        combined_history[key].extend(float(v) for v in values)

    save_history(type("History", (), {"history": combined_history})(), history_out)
    metrics_out.write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    class_names_out.write_text(json.dumps(class_names, indent=2), encoding="utf-8")
    model.save(str(model_out))

    print("Training complete.")


if __name__ == "__main__":
    main()
