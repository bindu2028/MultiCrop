import tensorflow as tf
import numpy as np
import json
from PIL import Image
import os

MODEL_PATH = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\model\saved_model\plant_disease_apple.h5"
CLASS_FILE = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\model\artifacts\class_names_apple.json"

print("Loading apple model...")
model = tf.keras.models.load_model(MODEL_PATH)
print(f"Model output shape: {model.output_shape}")
print(f"Input shape: {model.input_shape}")

with open(CLASS_FILE) as f:
    labels = json.load(f)
print(f"Class labels: {labels}")

# Check if model has class_names in its metadata (Keras sometimes stores this)
if hasattr(model, 'class_names'):
    print(f"Model internal class_names: {model.class_names}")

# Check training config
print("\nModel layers (last 3):")
for layer in model.layers[-3:]:
    print(f"  {layer.name}: {layer.__class__.__name__}")
    if hasattr(layer, 'units'):
        print(f"    units: {layer.units}")

# Check the apple training data folder if it exists
DATA_ROOT = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\dataset"
apple_dir = os.path.join(DATA_ROOT, "apple")
if os.path.exists(apple_dir):
    subdirs = sorted(os.listdir(apple_dir))
    print(f"\nApple dataset folders (sorted): {subdirs}")
    print("These are the alphabetical class indices the TRAINING used:")
    for i, d in enumerate(subdirs):
        print(f"  Index {i}: {d}")
else:
    print(f"\nDataset folder not found at: {DATA_ROOT}")
    # Try other paths
    for alt_path in ["dataset", "data", "datasets"]:
        alt = os.path.join(r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop", alt_path)
        if os.path.exists(alt):
            print(f"Found data at {alt}: {os.listdir(alt)}")
