import requests
import json
import random

url = "https://plantlens-backend.onrender.com/auth/register"
email = f"testuser_{random.randint(1000, 9999)}@gmail.com"
payload = {
    "username": email,
    "password": "password123"
}
headers = {
    "Content-Type": "application/json"
}

print(f"Sending POST to {url} with email {email}...")
try:
    response = requests.post(url, json=payload, headers=headers, timeout=10)
    print(f"Status Code: {response.status_code}")
    print(f"Response Headers: {response.headers}")
    print(f"Response Body: '{response.text}'")
except Exception as e:
    print(f"Error: {e}")
