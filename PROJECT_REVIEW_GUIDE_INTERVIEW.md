# Project Review Guide - Interview Friendly

## 1. One-Minute Summary

This project is a plant disease detection system built with a Flutter client, Flask backend, TensorFlow model, JWT authentication, and SQLite persistence. A user can log in, capture or upload a leaf image, send it to the backend, get a disease prediction with confidence, and later view scan-related data.

## 2. What We Have Built

### User-facing features
- Login and registration with JWT
- Logout and token refresh support
- Crop selection screen
- Leaf image upload / camera capture flow
- Disease prediction result flow
- Foundations for scan history and plant tracking
- Flutter web/mobile responsive UI

### Backend features
- `/health` for app status
- `/crops` to fetch crop options
- `/predict` for model inference
- `/auth/login`, `/auth/register`, `/auth/refresh`, `/auth/me`
- JWT-protected API access
- SQLite persistence through SQLAlchemy

### ML features
- TensorFlow/Keras image classification model
- Model artifacts and class labels stored in `model/`
- Training and evaluation scripts in `model/src/`

## 3. Technology Choices and Why

### Flutter
Chosen for one codebase across mobile and web. It gave fast UI development and consistent behavior across platforms.

Why not native Android/iOS?
- Two codebases would take more time.

Why not React Native?
- Flutter gave more control over custom UI and smooth rendering for this project.

### Flask
Chosen because it is lightweight and integrates easily with Python ML code.

Why not Django?
- Django is heavier than needed for an API-first ML backend.

Why not FastAPI?
- Flask already fit the project structure and was easier to extend quickly.

### TensorFlow
Chosen because the disease detection model and training pipeline were already built around it.

Why not PyTorch?
- Switching would require rewriting the model pipeline.

### SQLite
Chosen for simple local persistence with no extra database server.

Why not PostgreSQL?
- PostgreSQL is better for production scale, but SQLite was faster for development and demo work.

### JWT
Chosen for stateless authentication that works well for web and mobile clients.

Why not server sessions?
- JWT is easier to manage for API clients and refresh flows.

### SQLAlchemy
Chosen to manage database models cleanly and reduce raw SQL usage.

### Celery + Redis
Chosen to support background work like asynchronous jobs without blocking API requests.

## 4. Current Database State

Active tables in `backend/app.db`:
- `users`
- `scan_history`
- `plant_tracker`

Note: the project still needs proper migration tooling if the schema changes later.

## 5. Architecture Flow

1. User logs in from Flutter.
2. Flutter sends credentials to Flask.
3. Flask verifies the user and issues JWT tokens.
4. Flutter stores the tokens locally.
5. Authenticated requests include the access token.
6. User uploads an image to `/predict`.
7. Flask loads the TensorFlow model and returns the prediction.
8. The app can later save or display history data.

## 6. Key Design Decisions

### Username-based login
We used username instead of email to keep the authentication flow simpler and more stable.

### JWT authentication
We used JWT because the app is API-driven and needs a secure, stateless login system.

### SQLite over a server database
We used SQLite for speed and simplicity during development.

### Flutter web for testing
It made live browser testing easier while still using the same app code.

## 7. Limitations You Can Honestly Mention

- Database migrations are not yet fully formalized.
- Production secrets still need hardening.
- SQLite is fine for demo use but not ideal for high-scale deployment.
- Some history/diary features are still foundation-level.
- Broader production deployment work is still pending.

## 8. Interview Questions and Answers

### Q1. What is the project about?
**A:** It detects plant diseases from leaf images and returns the disease name, confidence, and remedy guidance.

### Q2. Why did you choose Flutter?
**A:** Flutter gave us one codebase for mobile and web and made UI development faster.

### Q3. Why Flask?
**A:** Flask is lightweight and works well for a Python ML backend.

### Q4. Why JWT?
**A:** JWT gives stateless authentication and works well for API clients.

### Q5. Why SQLite?
**A:** It was the fastest and simplest database for development and review.

### Q6. What does `/predict` do?
**A:** It accepts a leaf image, validates it, runs the model, and returns the prediction.

### Q7. How are tokens stored?
**A:** The Flutter client stores access and refresh tokens locally.

### Q8. What happens when the access token expires?
**A:** The app uses the refresh token to get a new access token.

### Q9. Why SQLAlchemy?
**A:** It keeps the database code clean and easier to maintain.

### Q10. Why Celery and Redis?
**A:** They help move slow work out of the request path.

### Q11. What tables are in the database?
**A:** `users`, `scan_history`, and `plant_tracker`.

### Q12. How would you scale this project?
**A:** Move to PostgreSQL, add migrations, add monitoring, and deploy behind a production WSGI server.

### Q13. What is the main current limitation?
**A:** Production hardening and schema migration support are still incomplete.

### Q14. Why did you use username instead of email?
**A:** It simplified the auth flow and reduced schema issues during development.

### Q15. What is the role of TensorFlow here?
**A:** It handles the image classification model for disease detection.

## 9. Best Closing Statement for Review

This project is a cross-platform plant disease detection app with a Flask API, TensorFlow inference, JWT security, and SQLite persistence. It already supports the end-to-end user flow and can be extended into a production system with migrations, PostgreSQL, and stronger deployment hardening.
