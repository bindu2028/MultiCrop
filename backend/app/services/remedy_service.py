REMEDY_BY_DISEASE = {
    "Bacterial Spot": (
        "Spray copper-based organic fungicide every 7 to 10 days and remove infected leaves."
    ),
    "Early Blight": (
        "Use neem oil or bio-fungicide, prune lower infected leaves, and avoid overhead watering."
    ),
    "Late Blight": (
        "Improve airflow, remove heavily infected parts, and apply approved organic fungicidal spray."
    ),
    "Healthy": (
        "No treatment needed. Continue preventive care with balanced watering and good airflow."
    ),
    "Septoria Leaf Spot": (
        "Remove infected leaves, mulch the soil surface, and use neem-based spray at regular intervals."
    ),
    "Yellow Leaf Curl Virus": (
        "Control whiteflies using sticky traps and neem spray, and isolate severely infected plants."
    ),
    "Uncertain": (
        "Prediction confidence is low. Upload a clearer close-up image in good lighting for a reliable result."
    ),
}


def get_remedy(disease: str) -> str:
    return REMEDY_BY_DISEASE.get(
        disease,
        "No remedy is available for this prediction.",
    )
