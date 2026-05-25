import json
import pytest
from io import BytesIO
from app import create_app
from app.models import db, User, ScanHistory, PlantTracker


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///:memory:"
    app.config["JWT_SECRET_KEY"] = "test-secret-key-for-migrations-and-testing-12345"
    
    with app.app_context():
        db.create_all()
        yield app.test_client()
        db.drop_all()


def get_auth_headers(client, username="testuser", password="password123"):
    # Register
    client.post(
        "/auth/register",
        data=json.dumps({"username": username, "password": password}),
        content_type="application/json"
    )
    
    # Login
    response = client.post(
        "/auth/login",
        data=json.dumps({"username": username, "password": password}),
        content_type="application/json"
    )
    
    token = response.get_json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_auth_routes(client):
    # Register a new user
    response = client.post(
        "/auth/register",
        data=json.dumps({"username": "newuser", "password": "securepass"}),
        content_type="application/json"
    )
    assert response.status_code == 201
    assert "access_token" in response.get_json()

    # Login with the user
    response = client.post(
        "/auth/login",
        data=json.dumps({"username": "newuser", "password": "securepass"}),
        content_type="application/json"
    )
    assert response.status_code == 200
    assert "access_token" in response.get_json()


def test_unauthenticated_sync_denied(client):
    # Try fetching scans without JWT
    response = client.get("/api/history/scans")
    assert response.status_code == 401


def test_scan_history_sync(client):
    headers = get_auth_headers(client)

    # 1. Fetch initial scan history (should be empty)
    response = client.get("/api/history/scans", headers=headers)
    assert response.status_code == 200
    assert len(response.get_json()) == 0

    # 2. Add a scan history item
    scan_data = {
        "crop_name": "Tomato",
        "disease": "Early Blight",
        "confidence": 0.895,
        "remedy": "Apply copper-based fungicide",
        "raw_prediction": json.dumps([0.1, 0.895, 0.005])
    }
    response = client.post(
        "/api/history/scans",
        data=json.dumps(scan_data),
        content_type="application/json",
        headers=headers
    )
    assert response.status_code == 201
    added_scan = response.get_json()
    assert added_scan["crop_name"] == "Tomato"
    assert added_scan["disease"] == "Early Blight"
    assert added_scan["confidence"] == 0.895

    # 3. Fetch again and confirm it exists
    response = client.get("/api/history/scans", headers=headers)
    assert response.status_code == 200
    scans_list = response.get_json()
    assert len(scans_list) == 1
    assert scans_list[0]["disease"] == "Early Blight"

    # 4. Clear scan history
    response = client.delete("/api/history/scans", headers=headers)
    assert response.status_code == 200

    # 5. Fetch and confirm empty
    response = client.get("/api/history/scans", headers=headers)
    assert len(response.get_json()) == 0


def test_plant_tracker_sync(client):
    headers = get_auth_headers(client)

    # 1. Fetch plants (should be empty)
    response = client.get("/api/history/plants", headers=headers)
    assert response.status_code == 200
    assert len(response.get_json()) == 0

    # 2. Add a plant tracker item
    plant_data = {
        "plant_name": "Backyard Tomato",
        "crop_type": "Tomato",
        "status": "healthy",
        "notes": "No disease detected. Watering twice weekly."
    }
    response = client.post(
        "/api/history/plants",
        data=json.dumps(plant_data),
        content_type="application/json",
        headers=headers
    )
    assert response.status_code == 200
    added_plant = response.get_json()
    assert added_plant["plant_name"] == "Backyard Tomato"
    assert added_plant["status"] == "healthy"
    
    plant_id = added_plant["id"]

    # 3. Update the plant tracker item
    update_data = {
        "id": plant_id,
        "plant_name": "Backyard Tomato (Updated)",
        "crop_type": "Tomato",
        "status": "diseased",
        "last_disease": "Early Blight",
        "notes": "Identified early blight on lower leaves. Sprayed organic copper fungicide."
    }
    response = client.post(
        "/api/history/plants",
        data=json.dumps(update_data),
        content_type="application/json",
        headers=headers
    )
    assert response.status_code == 200
    updated_plant = response.get_json()
    assert updated_plant["plant_name"] == "Backyard Tomato (Updated)"
    assert updated_plant["status"] == "diseased"
    assert updated_plant["last_disease"] == "Early Blight"

    # 4. Fetch list and confirm update
    response = client.get("/api/history/plants", headers=headers)
    plants_list = response.get_json()
    assert len(plants_list) == 1
    assert plants_list[0]["plant_name"] == "Backyard Tomato (Updated)"

    # 5. Delete the plant
    response = client.delete(f"/api/history/plants/{plant_id}", headers=headers)
    assert response.status_code == 200

    # 6. Fetch again and confirm empty
    response = client.get("/api/history/plants", headers=headers)
    assert len(response.get_json()) == 0
