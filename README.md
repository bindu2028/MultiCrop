# 🌿 PlantLens: Smart AI Plant Disease Detection & Botanical Encyclopedia

PlantLens is an advanced, high-fidelity agronomy assistant that leverages artificial intelligence to analyze plant leaf scans, detect diseases, suggest organic/chemical treatment blueprints, and explore a comprehensive database of natural chemical compounds and drug-herb safety interactions.

---

## 🚀 Key Features

### 📦 Module 1: Plant Care & Scan Analytics
* **🌱 Plant Care Tips / Knowledge Base**: Searchable grid covering 9 major crop classes. Provides expert summaries on soil pH, sunlight, watering needs, common beginner mistakes, pro growing tips, companion planting, and expandable pest indicators.
* **📊 Interactive Scan Analytics**: A custom-painted circular distribution chart (healthy vs. diseased) designed with Flutter's `CustomPainter` (zero package overhead) paired with interactive weekly sparkline bars to track crop diagnostics over time.

### 🧪 Module 2: Natural Apothecary & Molecular Simulator
* **🌿 Botanical Explorer**: Interactive medicinal plant directory mapping herbs (such as Ashwagandha, Neem, Ginger, and Turmeric) directly to their active chemical constituents, allowing seamless discovery paths.
* **⚠️ Virtual Clinician (Drug-Herb Safety Checker)**: A searchable safety evaluator that checks contraindications between medicinal plants and common prescription drugs (Aspirin, Metformin, etc.), displaying dynamic red, amber, and teal alert cards.
* **🗺️ Habitat & Cultivation Matrix**: Interactive curved circular progress gauges displaying exact soil pH bounds, temperature thresholds, water indexes, and native geography inside chemical detail sheets.
* **🧪 Molecular Blueprint Simulator**: Control dials and sliders to search and filter plant compound structures by Bioactivity, Molecular Weight ranges, and chemical tags.

### ⚙️ Client Experience Enhancements
* **🗺️ Material 3 Navigation Tabs**: Integrated a premium Navigation Bar hosting both the **Dashboard** and the **Settings** view (profile editors, reset portals, notification toggle sliders, and language selectors).
* **🌓 Ultra-Premium Ambient Dark Mode**: Added a persistent, native Material 3 dynamic theme toggler (obsidian gradients, neon-emerald primary buttons, organic slate text scales) cached via `SharedPreferences`.
* **📱 Adaptive Keyboard Scroll**: Wrapped input forms inside scroll containers to dynamically handle virtual keyboard display and eliminate all pixel overflow errors.
* **🔐 Strict UTC Session Management**: Patched JWT auth timeouts using strict ISO UTC boundaries, preventing invalid local timezone session logging drops.

---

## 📂 Project Structure

```text
MultiCrop/
│
├── backend/                       # Python Flask Web Service
│   ├── app/                       # Core Flask application
│   │   ├── routes/                # Auth, Crop, and Compound routes
│   │   ├── services/              # ML inference and Gemini AI generation
│   │   └── models/                # SQL relational databases
│   └── run.py                     # Entry point for backend
│
├── mobile_app/                    # Flutter Mobile Application
│   ├── lib/
│   │   ├── data/                  # Curated care & compound matrices
│   │   ├── models/                # Local data models & API responses
│   │   ├── screens/               # Premium custom-designed Flutter widgets
│   │   └── services/              # API connections & Session managers
│   └── android/                   # Native Android wrapper & Manifests
│
├── dataset/                       # ML Dataset resources
├── model/                         # TensorFlow/PyTorch model files & weights
└── render.yaml                    # Infrastructure blueprint for production
```

---

## 🛠️ Backend Setup (Flask)

The backend provides JWT authorization, ML prediction endpoints, and handles Gemini AI generations.

### Local Development Start:
From the project root:
```powershell
# Navigate to backend
cd backend

# Create virtual environment
python -m venv .venv

# Activate environment (Windows)
.\.venv\Scripts\Activate.ps1

# Install requirements
pip install -r requirements.txt

# Start Flask
python run.py
```

* **Local Base URL**: `http://127.0.0.1:5000`
* **Production Base URL**: `https://plantlens-backend.onrender.com`
* **Health Check**: `GET /health` (Returns `{"status": "ok"}`)

---

## 📱 Mobile App Setup (Flutter)

The mobile client leverages Material 3, custom graphics engines, and responsive widgets.

### Local Run:
From the project root:
```powershell
# Navigate to mobile app
cd mobile_app

# Fetch packages
flutter pub get

# Launch on connected simulator or physical device
flutter run
```

### Build Optimized Android APK:
```powershell
flutter build apk --release
```
* **Output Path**: `mobile_app/build/app/outputs/flutter-apk/app-release.apk`

---

## 🌐 Production Architecture (Render)

This project is configured to deploy instantly using **Render Blueprints** via [render.yaml](file:///c:/Users/BINDU%20SREE/Desktop/Real_Project/MultiCrop/render.yaml):

1. **PostgreSQL Database**: Configured as `plantlens-db`.
2. **Flask API Web Service**: Bootstrapped inside python container (`plantlens-backend`).
3. **Static Web App**: Host endpoints (`plantlens-web`).

*To deploy, simply link your GitHub repository to your **Render.com** account, create a new **Blueprint**, set your `GEMINI_API_KEY` in the environment tab of `plantlens-backend`, and wait for the automated build to turn green!* ✅
