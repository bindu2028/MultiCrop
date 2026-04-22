# AI Plant Disease Detection (Mobile + API)

## Overview
This project detects plant leaf diseases from images and provides remedy suggestions.

The active stack is:
- Flutter mobile app client (`mobile_app/`)
- Flask REST API backend (`backend/`)
- TensorFlow model/training artifacts (`model/`)

The old standalone website frontend has been removed.

## Current Scope
- Upload or capture a plant leaf image from the mobile app
- Send image to backend API for inference
- Return disease, confidence, and remedy
- Save local history and support queued scans in app flow

## Project Structure
```text
Real_Project/
|-- README.md
|-- backend/
|-- dataset/
|-- model/
|-- mobile_app/
|-- render.yaml
```

## Backend Setup (Flask)
From repository root:

```powershell
Set-Location .\backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python run.py
```

Backend default URL:
- `http://127.0.0.1:5000`

Useful endpoints:
- `GET /health`
- `GET /crops`
- `POST /predict`

## Mobile App Setup (Flutter)
From repository root:

```powershell
Set-Location .\mobile_app
flutter pub get
flutter run
```

For a stable browser URL during development, use the fixed Chrome port:

```powershell
Set-Location .\mobile_app
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8091
```

In VS Code, you can also use the task named `flutter: mobile web on 8091`.

For LAN testing on phone browser (web-server mode):

```powershell
Set-Location .\mobile_app
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8091
```

Then open from phone on same Wi-Fi:
- `http://<your-laptop-ip>:8091`

## Notes
- Keep backend and frontend on different ports.
- Use port `8091` for the main Chrome/web development flow unless that port is already busy.
- If `8091` is busy, stop the old Flutter run before picking a different port.
- If UI changes are not visible immediately, refresh the browser page.
