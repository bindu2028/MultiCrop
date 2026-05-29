import sys
from pathlib import Path
from io import BytesIO

# Ensure backend folder is on path
backend_dir = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\backend"
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from app import create_app
from app.models import db

app = create_app()
app.config["TESTING"] = True
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///:memory:"

client = app.test_client()

image_path = r"c:\Users\BINDU SREE\Desktop\Real_Project\MultiCrop\dataset\multicrop\Apple\Test\Apple Scab\03354abb-aa1c-4f9d-a1ef-9f40505cd539___FREC_Scab 3355.JPG"

print(f"Reading image from {image_path}...")
with open(image_path, "rb") as f:
    img_bytes = f.read()

print("Sending local POST /predict with crop=apple...")
with app.app_context():
    db.create_all()
    
    data = {
        "image": (BytesIO(img_bytes), "leaf.jpg"),
        "crop": "apple"
    }
    
    response = client.post(
        "/predict",
        data=data,
        content_type="multipart/form-data"
    )
    
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.get_json()}")
