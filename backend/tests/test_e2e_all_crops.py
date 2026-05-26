import os
import requests
from pathlib import Path

login_url = "https://plantlens-backend.onrender.com/auth/login"
login_payload = {
    "username": "testuser_6875@gmail.com",
    "password": "password123"
}
headers = {
    "Content-Type": "application/json"
}

print("Logging in to live Render backend...")
try:
    login_resp = requests.post(login_url, json=login_payload, headers=headers, timeout=15)
    if login_resp.status_code != 200:
        print(f"Failed to log in: {login_resp.status_code} {login_resp.text}")
        exit(1)
    token = login_resp.json()["access_token"]
    print("Successfully logged in.\n")
except Exception as e:
    print(f"Login failed: {e}")
    exit(1)

auth_headers = {
    "Authorization": f"Bearer {token}"
}
predict_url = "https://plantlens-backend.onrender.com/predict"

CROP_MAPPING = {
    "apple": "Apple",
    "bell_pepper": "Bell Pepper",
    "cherry": "Cherry",
    "corn_maize": "Corn (Maize)",
    "grape": "Grape",
    "peach": "Peach",
    "potato": "Potato",
    "strawberry": "Strawberry",
    "tomato": "Tomato"
}

dataset_root = Path(r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\dataset\multicrop")

print("=" * 80)
print(f"{'CROP E2E SCAN VERIFICATION SWEEP':^80}")
print("=" * 80)

success_count = 0
failed_count = 0

for crop_slug, crop_dir_name in CROP_MAPPING.items():
    crop_dir = dataset_root / crop_dir_name
    
    # Recursively find the first valid image file
    image_file = None
    if crop_dir.exists():
        for ext in ["*.jpg", "*.jpeg", "*.png", "*.JPG", "*.JPEG", "*.PNG"]:
            found_files = list(crop_dir.glob(f"**/{ext}"))
            if found_files:
                image_file = found_files[0]
                break
                
    if not image_file:
        print(f"[-] {crop_slug:<15}: No sample image found in dataset directory.")
        failed_count += 1
        continue
        
    print(f"[*] {crop_slug:<15}: Found image {image_file.name}")
    print(f"    Sending prediction request to live server...")
    
    try:
        with open(image_file, "rb") as f:
            img_bytes = f.read()
            
        files = {
            "image": (image_file.name, img_bytes, "image/jpeg")
        }
        data = {
            "crop": crop_slug
        }
        
        response = requests.post(predict_url, headers=auth_headers, files=files, data=data, timeout=30)
        
        if response.status_code == 200:
            res_data = response.json()
            disease = res_data.get("disease", "N/A")
            confidence = res_data.get("confidence", 0.0)
            severity = res_data.get("severity_label", "N/A")
            print(f"    [+] Success! Predicted: {disease} (Confidence: {confidence:.2%}, Severity: {severity})")
            success_count += 1
        else:
            print(f"    [x] Failed! Status Code: {response.status_code}")
            print(f"        Error Response: {response.text}")
            failed_count += 1
            
    except Exception as e:
        print(f"    [x] Request error: {e}")
        failed_count += 1
        
    print("-" * 80)

print("\n" + "=" * 80)
print(f"{'VERIFICATION SUMMARY':^80}")
print("=" * 80)
print(f"Total Crops Tested : {success_count + failed_count}")
print(f"Successful Scans   : {success_count}")
print(f"Failed Scans       : {failed_count}")
print("=" * 80)

if failed_count == 0:
    print("ALL CROPS ARE VERIFIED AND WORKING PERFECTLY!")
else:
    print(f"Verification completed with {failed_count} crop checks failing.")
