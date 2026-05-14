# Project Review Guide

## 1. Project Overview

This project is a plant disease detection system that lets a user capture or upload a leaf image from a Flutter mobile/web app, send it to a Flask backend, run TensorFlow-based inference, and receive a disease prediction with confidence and remedy guidance.

The current stack is:
- Flutter client in `mobile_app/`
- Flask API backend in `backend/`
- TensorFlow models and artifacts in `model/`
- SQLite database for persistence in `backend/app.db`
- JWT-based authentication for secure API access
- Redis/Celery for background task processing

## 2. What Has Been Built So Far

### User-facing features
- Authentication flow with login and registration
- JWT token issuance and refresh
- Authenticated app navigation after login
- Crop selection screen
- Image upload / camera capture flow for leaf scanning
- Prediction result handling
- Scan history foundation
- Plant tracking foundation
- Diary/notes foundation in the data layer
- Mobile/web responsive Flutter UI

### Backend features
- `/health` endpoint
- `/crops` endpoint
- `/predict` endpoint for inference
- `/auth/login`
- `/auth/register`
- `/auth/refresh`
- `/auth/me`
- JWT token validation
- Model loading and prediction pipeline
- Remedy suggestion mapping
- SQLite persistence for users and scan-related data

### ML / model side
- Trained TensorFlow models stored under `model/saved_model/`
- Class label artifacts stored under `model/artifacts/`
- Evaluation and training scripts under `model/src/`
- Dataset verification utilities for crop folders and class structure

## 3. Technology Stack and Why It Was Used

### 3.1 Flutter
Used for the client app because it supports:
- One codebase for mobile and web
- Fast UI development
- Good rendering performance
- Easy stateful UI for camera, upload, and result screens

Why not plain native Android/iOS only?
- Native would require two separate codebases and more maintenance.
- Flutter gives faster iteration and consistent UI across platforms.

Why not React Native?
- Flutter’s UI control is more predictable for custom screens.
- The project already benefits from Flutter’s single-rendering layer and strong desktop/web support.

### 3.2 Flask
Used for the backend because it is:
- Lightweight
- Easy to integrate with Python ML code
- Good for REST APIs
- Simple to extend with JWT, CORS, rate limiting, and Celery

Why not Django?
- Django is heavier and better when you need a full admin-heavy web platform.
- This project mainly needs a compact API layer around ML inference.
- Flask is easier to keep focused for an app + model backend.

Why not FastAPI?
- FastAPI is excellent, but the project is already structured around Flask and synchronous ML inference.
- Flask integrates cleanly with the current codebase and is sufficient here.

### 3.3 TensorFlow / Keras
Used for the disease classifier because:
- The model training pipeline already exists in the project
- TensorFlow is well suited for image classification
- Keras makes training, saving, and loading models straightforward

Why not PyTorch?
- PyTorch is also strong, but the existing project artifacts and scripts are already TensorFlow-based.
- Rewriting the entire ML stack would add unnecessary migration work.

### 3.4 SQLite
Used for persistence because:
- Very simple to set up locally
- No separate database server needed
- Good for development, demos, and small deployments
- Works well with Flask-SQLAlchemy

Why not PostgreSQL right now?
- PostgreSQL is better for scale and concurrent production use.
- SQLite was faster to get working for the current stage.
- The project is still in a review/demo phase, so lightweight persistence is practical.

Why not MongoDB?
- The data here is relational: users, scan history, and plant tracker records.
- SQL fits this structure better than document storage.

### 3.5 JWT (Flask-JWT-Extended)
Used for authentication because:
- Stateless auth is a good fit for API-based apps
- Tokens can be reused by Flutter web/mobile clients
- Access and refresh token flow improves security and session handling

Why not server sessions only?
- Sessions are less convenient for mobile/web clients and distributed APIs.
- JWT makes the client simpler when talking to the backend.

### 3.6 SQLAlchemy / Flask-SQLAlchemy
Used to define and manage database models because:
- ORM keeps code readable
- Easier to map Python objects to tables
- Simplifies queries and relationships
- Makes future migration to PostgreSQL easier

Why not raw SQL only?
- Raw SQL is harder to maintain as the app grows.
- ORM improves consistency for users, scans, and plant records.

### 3.7 Celery + Redis
Used for background task processing because:
- ML and email tasks can be slow or asynchronous
- Celery lets the app offload heavy work
- Redis is a simple broker/result backend for task queues

Why not do all work in the request thread?
- Heavy work can block the API and make the app feel slow.
- Background jobs keep the app responsive.

## 4. Architecture Summary

### Request flow
1. User signs in from Flutter.
2. Flutter sends credentials to Flask `/auth/login`.
3. Backend returns access and refresh JWT tokens.
4. Flutter stores tokens locally.
5. Authenticated requests include `Authorization: Bearer <token>`.
6. `/predict` receives the leaf image.
7. Backend loads the TensorFlow model, predicts the disease, and returns the result.
8. Result can be stored in SQLite and later shown in history.

### Data flow
- User input enters Flutter UI.
- Flutter sends JSON or multipart request to Flask.
- Flask validates request and JWT.
- Flask uses SQLAlchemy for persistence.
- TensorFlow model provides prediction.
- Response returns JSON to Flutter.

## 5. Current State of the Database

The current SQLite database is in `backend/app.db`.

Current active tables:
- `users`
- `scan_history`
- `plant_tracker`

Important note for review:
- SQLite is currently used in a local development style.
- The project does not yet use migrations like Alembic/Flask-Migrate.
- That means schema changes must be handled carefully.

## 6. Important Design Decisions

### Username-based auth instead of email-based auth
Why it was done:
- Simpler login flow
- Reduced schema complexity during debugging
- Faster to stabilize the authentication path

Why it is acceptable:
- The app only needed a stable login mechanism at this stage
- The project can later expand to email-based recovery if needed

### JWT instead of cookie sessions
Why it was done:
- Better fit for mobile and web API access
- Cleaner token-based client integration
- Easier refresh token support

### SQLite instead of a server DB
Why it was done:
- Fastest path to a working demo
- No extra infrastructure required
- Useful for review and local testing

### Flutter web for testing
Why it was done:
- Easier live browser validation
- Same UI code works for mobile and browser testing
- Helpful for quick debugging during review prep

## 7. Known Limitations Right Now

These are realistic limitations you can mention in a technical round if asked:
- Schema migrations are not fully automated yet.
- Production-grade secret management still needs improvement.
- Database should eventually move to PostgreSQL for scale.
- Some features are foundation-level only, such as history and diary persistence.
- Not every ML flow has been load-tested under production traffic.
- `/predict` is protected now, but broader authorization policies can still be expanded.

## 8. What Can Be Asked in a Review

### Core technical questions and answers

#### Q1. What is the goal of this project?
**A:** To detect plant diseases from leaf images using a Flutter client, Flask backend, and TensorFlow classifier, then return disease, confidence, and remedy guidance.

#### Q2. Why did you choose Flutter?
**A:** Flutter gives one codebase for mobile and web, fast UI iteration, and good cross-platform consistency.

#### Q3. Why did you choose Flask instead of Django?
**A:** Flask is lighter and better suited to a compact ML API backend. Django would be heavier than needed for this project stage.

#### Q4. Why did you use JWT?
**A:** JWT is stateless, works well with mobile/web clients, and supports access/refresh token flow for better session handling.

#### Q5. Why did you use SQLite?
**A:** SQLite was the quickest reliable persistence layer for development and demo purposes without needing a separate DB server.

#### Q6. Why not use PostgreSQL from the start?
**A:** PostgreSQL is better for production scale, but SQLite was simpler for the current review stage. The code can later be migrated to PostgreSQL with SQLAlchemy.

#### Q7. How does authentication work?
**A:** The client sends username/password to `/auth/login`, the backend verifies credentials, then issues access and refresh tokens. The access token is used for protected endpoints.

#### Q8. How do you refresh tokens?
**A:** The client can call `/auth/refresh` using the refresh token to get a new access token when the old one expires.

#### Q9. What does `/predict` do?
**A:** It accepts a leaf image upload, validates the input, runs the TensorFlow classifier, and returns the predicted disease and confidence.

#### Q10. How are models stored?
**A:** Trained model files are stored under `model/saved_model/` and class label artifacts under `model/artifacts/`.

#### Q11. Why is background processing needed?
**A:** Some tasks like inference workflows or notifications can be slow, so Celery lets the backend keep the API responsive.

#### Q12. Why Redis with Celery?
**A:** Redis is lightweight and easy to use as a broker and result backend for asynchronous tasks.

#### Q13. Why SQLAlchemy instead of plain SQL?
**A:** SQLAlchemy makes the code easier to maintain, supports relationships, and reduces low-level SQL handling.

#### Q14. What tables exist in the database?
**A:** `users`, `scan_history`, and `plant_tracker`.

#### Q15. Why did you use the username instead of email for login?
**A:** It simplified the authentication flow and avoided extra schema complexity while stabilizing the project.

#### Q16. How does the client know where the backend is?
**A:** The Flutter client derives the base URL from environment/config and platform, so web and device builds can point to the correct backend.

#### Q17. How do you handle unauthorized requests?
**A:** Protected endpoints require a valid JWT. If the token is missing or invalid, the backend returns 401 and the client can refresh or re-login.

#### Q18. What happens if the model file is missing?
**A:** The backend model loader raises an error, preventing silent failure so the issue is visible immediately.

#### Q19. What is the role of the remedy service?
**A:** It maps predicted diseases to treatment or prevention guidance for the user.

#### Q20. What is your biggest current limitation?
**A:** Schema migration and production hardening are not complete yet. The app works for demo and review purposes, but it still needs stronger deployment and migration practices.

### Deeper follow-up questions

#### Q21. How would you scale this system for many users?
**A:** Move the database to PostgreSQL, add a production WSGI server, use Redis-backed Celery, add caching, and deploy model inference carefully to avoid bottlenecks.

#### Q22. How would you improve the machine learning side?
**A:** Add more balanced training data, experiment with stronger augmentation, compare architectures, and track per-class metrics and confusion matrices.

#### Q23. How would you improve security?
**A:** Use strong secrets, HTTPS, proper env handling, token expiry policies, rate limiting, input validation, and production database credentials.

#### Q24. How would you support offline use?
**A:** Cache history locally, queue uploads, and sync when the network is available.

#### Q25. How would you make the app more maintainable?
**A:** Add tests, migrations, typed data models, modular services, and a more formal release pipeline.

## 9. Strong Review Points to Mention

- The app is end-to-end: client, API, ML, auth, and persistence are all connected.
- The project uses a real cross-platform frontend rather than a mock UI.
- JWT was implemented properly with refresh support.
- SQLite works for local demo, while the architecture can move to PostgreSQL later.
- The model is integrated into the backend, not handled manually in the client.
- The app has a path for history and plant tracking, not only prediction.

## 10. Suggested Improvement Roadmap

If asked what you would do next, say:
1. Add migrations with Flask-Migrate/Alembic.
2. Move from SQLite to PostgreSQL in production.
3. Add stronger error logging and monitoring.
4. Expand tests for auth and prediction.
5. Make scan history fully visible in the Flutter UI.
6. Harden deployment with proper secrets and HTTPS.

## 11. One-Line Summary

This project is a Flutter + Flask + TensorFlow plant disease detection system with JWT auth, SQLite persistence, and asynchronous task support, designed for leaf image upload, classification, and treatment guidance.
