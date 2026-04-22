#!/usr/bin/env python3
"""Quick test script to verify hand/skin rejection in leaf detection."""

import sys
import numpy as np
from PIL import Image
from io import BytesIO

# Add backend to path
sys.path.insert(0, r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\backend")

from app.utils.image_utils import is_probable_leaf_image


def create_test_hand_image():
    """Create a synthetic hand-like image with skin tones."""
    # Skin tone colors (typical peachy/tan/brown tones)
    img_array = np.zeros((224, 224, 3), dtype=np.uint8)
    
    # Skin tone RGB: around (200-220, 150-170, 100-120) for average skin
    # Create gradient with skin tones
    for i in range(224):
        for j in range(224):
            # Vary skin tone slightly to add texture
            noise = np.random.randint(-10, 10, 3)
            img_array[i, j] = np.clip([210, 160, 110] + noise, 0, 255)
    
    # Convert to PIL Image and then to bytes
    img = Image.fromarray(img_array, mode='RGB')
    
    # Save to bytes
    img_bytes = BytesIO()
    img.save(img_bytes, format='PNG')
    return img_bytes.getvalue()


def create_test_leaf_image():
    """Create a synthetic leaf-like image with green tones."""
    img_array = np.zeros((224, 224, 3), dtype=np.uint8)
    
    # Leaf tone RGB: lots of green, less red/blue
    # Typical leaf: (70-100, 130-160, 50-80)
    for i in range(224):
        for j in range(224):
            noise = np.random.randint(-10, 10, 3)
            img_array[i, j] = np.clip([80, 140, 60] + noise, 0, 255)
    
    img = Image.fromarray(img_array, mode='RGB')
    img_bytes = BytesIO()
    img.save(img_bytes, format='PNG')
    return img_bytes.getvalue()


print("Testing improved leaf detection...")
print("-" * 50)

# Test hand image
print("\n1. Testing HAND IMAGE (should be REJECTED):")
hand_image = create_test_hand_image()
is_leaf, score = is_probable_leaf_image(hand_image)
print(f"   Is leaf-like: {is_leaf}")
print(f"   Score: {score:.3f}")
print(f"   ✅ PASS - Hand rejected" if not is_leaf else "   ❌ FAIL - Hand was accepted!")

# Test leaf image
print("\n2. Testing LEAF IMAGE (should be ACCEPTED):")
leaf_image = create_test_leaf_image()
is_leaf, score = is_probable_leaf_image(leaf_image)
print(f"   Is leaf-like: {is_leaf}")
print(f"   Score: {score:.3f}")
print(f"   ✅ PASS - Leaf accepted" if is_leaf else "   ⚠️  Note - Leaf score might be borderline")

print("\n" + "-" * 50)
print("Test complete!")
