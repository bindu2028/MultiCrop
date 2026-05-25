from __future__ import annotations

import json
import os
import numpy as np
import tensorflow as tf
from pathlib import Path
from collections import Counter

# Set seeds for reproducibility
tf.random.set_seed(42)
np.random.seed(42)

DATASET_ROOT = Path("dataset/multicrop")
SAVED_MODEL_DIR = Path("model/saved_model")
ARTIFACTS_DIR = Path("model/artifacts")

def resolve_split_dir(data_root: Path, split_name: str) -> Path:
    candidates = [split_name.lower(), split_name.capitalize(), split_name.upper()]
    for candidate in candidates:
        split_dir = data_root / candidate
        if split_dir.exists():
            return split_dir
    raise FileNotFoundError(f"Missing split folder for '{split_name}' in {data_root}.")

def count_images_per_class(split_dir: Path, class_names: list[str]) -> dict[str, int]:
    counts = {}
    for name in class_names:
        class_path = split_dir / name
        if class_path.exists():
            counts[name] = sum(1 for item in class_path.iterdir() if item.is_file() and item.suffix.lower() in [".jpg", ".jpeg", ".png", ".bmp"])
        else:
            counts[name] = 0
    return counts

def compute_class_weights(train_dir: Path, class_names: list[str]) -> dict[int, float]:
    counts = count_images_per_class(train_dir, class_names)
    total = sum(counts.values())
    num_classes = len(class_names)
    class_weights = {}
    print(f"Image counts for {train_dir.parent.name}: {counts}")
    for idx, name in enumerate(class_names):
        count = counts.get(name, 0)
        if count == 0:
            class_weights[idx] = 1.0
        else:
            # Traditional inverse frequency weighting
            class_weights[idx] = float(total / (num_classes * count))
    return class_weights

def build_robust_model(img_size: int, num_classes: int) -> tf.keras.Model:
    """Builds a regularized CNN with Batch Normalization to prevent degeneracy."""
    data_augmentation = tf.keras.Sequential([
        tf.keras.layers.RandomFlip("horizontal"),
        tf.keras.layers.RandomRotation(0.12),
        tf.keras.layers.RandomZoom(0.15),
        tf.keras.layers.RandomContrast(0.10)
    ])

    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(img_size, img_size, 3)),
        data_augmentation,
        tf.keras.layers.Rescaling(1.0 / 255),
        
        tf.keras.layers.Conv2D(32, (3, 3), padding="same", kernel_regularizer=tf.keras.regularizers.l2(1e-4)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.MaxPooling2D(),
        
        tf.keras.layers.Conv2D(64, (3, 3), padding="same", kernel_regularizer=tf.keras.regularizers.l2(1e-4)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.MaxPooling2D(),
        
        tf.keras.layers.Conv2D(128, (3, 3), padding="same", kernel_regularizer=tf.keras.regularizers.l2(1e-4)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.MaxPooling2D(),
        
        tf.keras.layers.Conv2D(256, (3, 3), padding="same", kernel_regularizer=tf.keras.regularizers.l2(1e-4)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.MaxPooling2D(),
        
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, kernel_regularizer=tf.keras.regularizers.l2(1e-4)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.ReLU(),
        tf.keras.layers.Dropout(0.4),
        tf.keras.layers.Dense(num_classes, activation="softmax")
    ])
    
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy"]
    )
    return model

def audit_model(model: tf.keras.Model, class_names: list[str]) -> bool:
    """Verifies that the model is NOT degenerate (doesn't predict same class for noise and green)."""
    green = np.full((1, 224, 224, 3), [80, 140, 80], dtype=np.float32)
    p_green = model.predict(green, verbose=0)[0]
    
    noise = np.random.uniform(0, 255, (1, 224, 224, 3)).astype(np.float32)
    p_noise = model.predict(noise, verbose=0)[0]
    
    idx_green = np.argmax(p_green)
    idx_noise = np.argmax(p_noise)
    
    is_degenerate = (p_green[idx_green] > 0.95 and p_noise[idx_noise] > 0.95 and idx_green == idx_noise)
    
    print(f"Audit prediction - Green: class '{class_names[idx_green]}' (conf={p_green[idx_green]:.4f})")
    print(f"Audit prediction - Noise: class '{class_names[idx_noise]}' (conf={p_noise[idx_noise]:.4f})")
    
    if is_degenerate:
        print("[AUDIT FAILED] Model is still degenerate (always outputs same class).")
        return False
    else:
        print("[AUDIT PASSED] Model is robust and dynamic!")
        return True

def retrain_crop(crop_name: str, epochs: int = 15, batch_size: int = 32):
    print("\n" + "=" * 72)
    print(f"RETRAINING CROP: {crop_name}")
    print("=" * 72)
    
    crop_dir = DATASET_ROOT / crop_name
    train_dir = resolve_split_dir(crop_dir, "train")
    val_dir = resolve_split_dir(crop_dir, "val")
    test_dir = resolve_split_dir(crop_dir, "test")
    
    class_names = sorted([p.name for p in train_dir.iterdir() if p.is_dir()], key=lambda v: v.lower())
    num_classes = len(class_names)
    print(f"Classes resolved: {class_names}")
    
    # Pre-loading datasets
    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir, image_size=(224, 224), batch_size=batch_size, shuffle=True, seed=42
    )
    val_ds = tf.keras.utils.image_dataset_from_directory(
        val_dir, image_size=(224, 224), batch_size=batch_size, shuffle=False
    )
    test_ds = tf.keras.utils.image_dataset_from_directory(
        test_dir, image_size=(224, 224), batch_size=batch_size, shuffle=False
    )
    
    autotune = tf.data.AUTOTUNE
    train_ds = train_ds.prefetch(autotune)
    val_ds = val_ds.prefetch(autotune)
    test_ds = test_ds.prefetch(autotune)
    
    # Compute class weights
    class_weights = compute_class_weights(train_dir, class_names)
    print(f"Computed Class Weights: {class_weights}")
    
    # Building model
    model = build_robust_model(224, num_classes)
    
    callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor="val_accuracy", patience=5, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=2, verbose=1)
    ]
    
    # Training
    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=epochs,
        class_weight=class_weights,
        callbacks=callbacks,
        verbose=1
    )
    
    # Evaluate
    test_loss, test_acc = model.evaluate(test_ds, verbose=0)
    print(f"Test Accuracy: {test_acc:.4%}")
    
    # Audit
    audit_passed = audit_model(model, class_names)
    
    # Save output
    crop_slug = crop_name.lower().replace(" ", "_").replace("(", "").replace(")", "")
    SAVED_MODEL_DIR.mkdir(parents=True, exist_ok=True)
    ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)
    
    model_path = SAVED_MODEL_DIR / f"plant_disease_{crop_slug}.h5"
    model.save(str(model_path))
    print(f"Saved robust model to: {model_path}")
    
    # Save metadata artifacts
    class_names_path = ARTIFACTS_DIR / f"class_names_{crop_slug}.json"
    class_names_path.write_text(json.dumps(class_names, indent=2))
    
    metrics = {
        "test_loss": float(test_loss),
        "test_accuracy": float(test_acc),
        "class_names": class_names,
        "audit_passed": audit_passed
    }
    metrics_path = ARTIFACTS_DIR / f"test_metrics_{crop_slug}.json"
    metrics_path.write_text(json.dumps(metrics, indent=2))
    
    return audit_passed

def main():
    crops_to_retrain = ["Apple", "Bell Pepper"]
    status = {}
    for crop in crops_to_retrain:
        status[crop] = retrain_crop(crop, epochs=15)
        
    print("\n--- RETRAINING COMPLETE SUMMARY ---")
    for crop, passed in status.items():
        print(f"{crop}: {'[AUDIT PASSED]' if passed else '[AUDIT FAILED]'}")

if __name__ == "__main__":
    main()
