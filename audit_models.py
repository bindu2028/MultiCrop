import tensorflow as tf
import numpy as np
import json
import os
from pathlib import Path

MODEL_DIR = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\model\saved_model"
ARTIFACTS_DIR = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\model\artifacts"

def test_model(model_path, labels):
    try:
        model = tf.keras.models.load_model(model_path)
        
        # Test 1: Uniform Green
        green = np.full((1, 224, 224, 3), [80, 140, 80], dtype=np.float32)
        p_green = model.predict(green, verbose=0)[0]
        
        # Test 2: Random Noise
        noise = np.random.uniform(0, 255, (1, 224, 224, 3)).astype(np.float32)
        p_noise = model.predict(noise, verbose=0)[0]
        
        # Check for degeneracy: if max pred is > 0.99 for both noise AND green on SAME class
        idx_green = np.argmax(p_green)
        idx_noise = np.argmax(p_noise)
        
        is_degenerate = (p_green[idx_green] > 0.95 and p_noise[idx_noise] > 0.95 and idx_green == idx_noise)
        
        return {
            "status": "degenerate" if is_degenerate else "ok",
            "top_class": labels[idx_green] if idx_green < len(labels) else "OUT_OF_BOUNDS",
            "conf": float(p_green[idx_green])
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

results = {}
for model_file in Path(MODEL_DIR).glob("*.h5"):
    crop = model_file.stem.replace("plant_disease_", "")
    if crop == "model": continue
    
    label_file = Path(ARTIFACTS_DIR) / f"class_names_{crop}.json"
    if not label_file.exists():
        results[crop] = {"status": "missing_labels"}
        continue
        
    with open(label_file) as f:
        labels = json.load(f)
        
    print(f"Auditing {crop}...")
    results[crop] = test_model(str(model_file), labels)

print("\n--- FINAL AUDIT REPORT ---")
print(json.dumps(results, indent=2))
