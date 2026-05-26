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
login_resp = requests.post(login_url, json=login_payload, headers=headers, timeout=15)
if login_resp.status_code != 200:
    print(f"Failed to log in: {login_resp.status_code} {login_resp.text}")
    exit(1)

token = login_resp.json()["access_token"]
print("Successfully logged in.")

predict_url = "https://plantlens-backend.onrender.com/predict"
auth_headers = {
    "Authorization": f"Bearer {token}"
}

image_path = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\dataset\multicrop\Strawberry\Test\Healthy\02808b3e-ae88-4259-9b2c-f9096db336e4___RS_HL 1827_new30degFlipLR.JPG"
print(f"Reading image from {image_path}...")
with open(image_path, "rb") as f:
    img_bytes = f.read()

files = {
    "image": ("leaf.jpg", img_bytes, "image/jpeg")
}
data = {
    "crop": "strawberry"
}

print(f"Sending POST to {predict_url}...")
try:
    response = requests.post(predict_url, headers=auth_headers, files=files, data=data, timeout=30)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")
