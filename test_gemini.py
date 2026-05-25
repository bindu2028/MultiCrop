import requests
import json
import os
import sys
from pathlib import Path

# Load backend/.env if it exists
backend_env = Path(__file__).resolve().parent / "backend" / ".env"
if backend_env.exists():
    from dotenv import load_dotenv
    load_dotenv(dotenv_path=backend_env)

API_KEY = os.getenv("GEMINI_API_KEY")
if not API_KEY:
    print("ERROR: GEMINI_API_KEY environment variable is not configured.")
    sys.exit(1)

url = f"https://generativelanguage.googleapis.com/v1beta/models?key={API_KEY}"

print(f"Testing Gemini API Key: {API_KEY[:4]}...{API_KEY[-4:]}")
try:
    response = requests.get(url, headers={'Content-Type': 'application/json'})
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        models = [m['name'] for m in data.get('models', [])]
        if models:
            print(f"SUCCESS! Your key has access to {len(models)} models.")
            with open("models.txt", "w") as f:
                for m in models:
                    f.write(m + "\n")
            print("Full list saved to models.txt")
        else:
            print("FAILURE! Your key is valid but has access to ZERO models.")
            print("Response:", data)
    else:
        print("FAILURE! Server returned an error.")
        print("Error Details:", response.text)
except Exception as e:
    print(f"NETWORK ERROR: Could not reach Google servers: {e}")
