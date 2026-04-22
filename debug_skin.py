#!/usr/bin/env python3
"""Debug script to check skin/hand detection."""

import sys
import numpy as np
from PIL import Image
from io import BytesIO

sys.path.insert(0, r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\backend")

from app.utils.image_utils import _is_skin_color


def create_test_hand_image():
    """Create a synthetic hand-like image with skin tones."""
    img_array = np.zeros((224, 224, 3), dtype=np.uint8)
    
    for i in range(224):
        for j in range(224):
            noise = np.random.randint(-10, 10, 3)
            img_array[i, j] = np.clip([210, 160, 110] + noise, 0, 255)
    
    img = Image.fromarray(img_array, mode='RGB')
    img_bytes = BytesIO()
    img.save(img_bytes, format='PNG')
    return img_bytes.getvalue()


def test_skin_detection():
    """Test skin detection on synthetic hand image."""
    hand_bytes = create_test_hand_image()
    
    # Decode and check
    hand_img = Image.open(BytesIO(hand_bytes)).convert('RGB')
    hand_img = hand_img.resize((224, 224))
    rgb = np.array(hand_img, dtype=np.float32)
    
    print("Hand Image Analysis:")
    print(f"  Shape: {rgb.shape}")
    print(f"  Min RGB: {rgb.min(axis=(0,1))}")
    print(f"  Max RGB: {rgb.max(axis=(0,1))}")
    print(f"  Mean RGB: {rgb.mean(axis=(0,1))}")
    
    # Check specific pixels
    r = rgb[:, :, 0]
    g = rgb[:, :, 1]
    b = rgb[:, :, 2]
    
    r_norm = r / 255.0
    g_norm = g / 255.0
    b_norm = b / 255.0
    
    print(f"\n  Normalized Mean RGB: [{r_norm.mean():.2f}, {g_norm.mean():.2f}, {b_norm.mean():.2f}]")
    print(f"  R > 0.35: {(r_norm > 0.35).sum() / (224*224) * 100:.1f}%")
    print(f"  G > 0.25: {(g_norm > 0.25).sum() / (224*224) * 100:.1f}%")
    print(f"  B < 0.25: {(b_norm < 0.25).sum() / (224*224) * 100:.1f}%")
    print(f"  |R - G| < 0.1: {(np.abs(r_norm - g_norm) < 0.1).sum() / (224*224) * 100:.1f}%")
    print(f"  R > B + 0.05: {(r_norm > b_norm + 0.05).sum() / (224*224) * 100:.1f}%")
    
    skin_ratio = _is_skin_color(rgb)
    print(f"\n  Skin Ratio: {skin_ratio:.3f}")
    print(f"  Threshold: 0.25")
    print(f"  Should Reject: {skin_ratio > 0.25}")


test_skin_detection()
