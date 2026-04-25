import requests
import json

API_KEY = "AIzaSyBFpk4TjVXBW0lE60qouiSgWbGhRMvDN8Q"
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
