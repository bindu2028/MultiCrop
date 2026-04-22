from io import BytesIO

from app import create_app


def make_client():
    app = create_app()
    app.config["TESTING"] = True
    return app.test_client()


def test_health_endpoint():
    client = make_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_predict_requires_image_file():
    client = make_client()
    response = client.post("/predict", data={}, content_type="multipart/form-data")
    assert response.status_code == 400
    assert "error" in response.get_json()


def test_predict_rejects_non_image_extension():
    client = make_client()
    fake_text = BytesIO(b"not-an-image")
    response = client.post(
        "/predict",
        data={"image": (fake_text, "note.txt")},
        content_type="multipart/form-data",
    )
    assert response.status_code == 400
    assert "error" in response.get_json()
