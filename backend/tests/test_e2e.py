import io
from app import create_app
import pytest
from pathlib import Path


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def test_predict_e2e(client):
    # Use a small sample image from the test dataset
    sample = Path(__file__).resolve().parents[2] / "dataset" / "processed" / "test" / "Healthy" / "085cbe78-1d5c-45eb-877f-f409526032d5___GH_HL Leaf 469.JPG"
    assert sample.exists(), f"Sample image not found: {sample}"

    with open(sample, "rb") as f:
        data = {
            "image": (io.BytesIO(f.read()), sample.name),
            # let server auto-detect crop
        }
        resp = client.post("/predict", content_type="multipart/form-data", data=data)

    assert resp.status_code == 200, resp.get_data(as_text=True)
    json_data = resp.get_json()
    assert "disease" in json_data
    assert "confidence" in json_data
    assert "remedy" in json_data
