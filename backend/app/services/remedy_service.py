import re


DEFAULT_REMEDY_SECTIONS = {
    "immediate_action": "Isolate affected leaves and avoid watering over foliage until reassessment.",
    "spray_plan": "Apply a broad-spectrum preventive treatment as per label guidance and local extension advice.",
    "prevention": "Improve spacing, airflow, and field hygiene. Remove plant debris after pruning.",
    "monitoring": "Re-scan after 3 to 5 days and track spread before repeating treatment.",
}

DEFAULT_DISEASE_EXPLANATION = (
    "This looks like a leaf health issue. The app suggests treatment steps based on similar patterns."
)


DISEASE_EXPLANATION_BY_DISEASE = {
    "Apple Scab": "A fungus is creating dark, rough spots on apple leaves.",
    "Bacterial Spot": "A bacterial infection is making small dark spots on the leaves.",
    "Black Rot": "A fungal infection is damaging leaves and can spread quickly in wet weather.",
    "Cedar Apple Rust": "A rust fungus is causing orange-yellow spots on the leaves.",
    "Cercospora Leaf Spot": "A fungus is causing circular spots that can reduce leaf health.",
    "Common Rust": "Rust fungus is forming powdery orange-brown patches on leaves.",
    "Early Blight": "An early fungal disease is causing brown target-like spots on leaves.",
    "Esca (Black Measles)": "This vine disease weakens grape plants and causes leaf discoloration.",
    "Healthy": "The leaf appears healthy, with no strong disease signs right now.",
    "Leaf Blight": "A leaf infection is causing fast browning and drying of tissue.",
    "Leaf Scorch": "Leaf edges are drying or burning, often from stress or imbalance.",
    "Late Blight": "A serious fast-spreading disease is attacking the leaf in humid conditions.",
    "Northern Leaf Blight": "A fungal disease is creating long gray-brown streaks on corn leaves.",
    "Powdery Mildew": "A white powder-like fungus is growing on the leaf surface.",
    "Septoria Leaf Spot": "A fungal disease is causing many small dark leaf spots.",
    "Yellow Leaf Curl Virus": "A virus is curling and yellowing leaves, usually spread by whiteflies.",
    "Uncertain": "The image is not clear enough for a confident diagnosis yet.",
}


DISEASE_TYPE_BY_DISEASE = {
    "Apple Scab": "Fungal",
    "Bacterial Spot": "Bacterial",
    "Black Rot": "Fungal",
    "Cedar Apple Rust": "Fungal",
    "Cercospora Leaf Spot": "Fungal",
    "Common Rust": "Fungal",
    "Early Blight": "Fungal",
    "Esca (Black Measles)": "Fungal",
    "Healthy": "N/A",
    "Leaf Blight": "Fungal",
    "Leaf Scorch": "Environmental",
    "Late Blight": "Fungal",
    "Northern Leaf Blight": "Fungal",
    "Powdery Mildew": "Fungal",
    "Septoria Leaf Spot": "Fungal",
    "Yellow Leaf Curl Virus": "Virus",
    "Uncertain": "Unknown",
}


DRUG_COMPOUNDS_BY_CROP = {
    "apple": ["Quercetin", "Catechin", "Chlorogenic Acid", "Phloridzin"],
    "bell pepper": ["Capsanthin", "Lutein", "Zeaxanthin", "Vitamin C"],
    "cherry": ["Anthocyanins", "Cyanidin", "Melatonin", "Quercetin"],
    "corn maize": ["Zeaxanthin", "Lutein", "Ferulic Acid", "Beta-carotene"],
    "grape": ["Resveratrol", "Quercetin", "Tannins", "Ellagic Acid"],
    "peach": ["Chlorogenic Acid", "Catechin", "Rutin", "Beta-cryptoxanthin"],
    "potato": ["Solanine", "Quercetin", "Chlorogenic Acid", "Caffeic Acid"],
    "strawberry": ["Ellagic Acid", "Pelargonidin", "Vitamin C", "Fisetin"],
    "tomato": ["Lycopene", "Tomatine", "Quercetin", "Chlorophyll"],
}


REMEDY_SECTIONS_BY_DISEASE = {
    "Apple Scab": {
        "immediate_action": "Remove infected leaves and fallen debris from around the tree.",
        "spray_plan": "Apply sulfur or copper-based fungicide every 7 to 10 days during humid weather.",
        "prevention": "Prune canopy for airflow and avoid prolonged leaf wetness.",
        "monitoring": "Inspect new leaves weekly and re-scan if fresh olive-brown spots appear.",
    },
    "Bacterial Spot": {
        "immediate_action": "Prune infected leaves and disinfect tools after each plant.",
        "spray_plan": "Use copper-based bactericide/fungicide at recommended intervals.",
        "prevention": "Avoid overhead irrigation and handle plants when dry.",
        "monitoring": "Track lesion spread every 2 to 3 days and remove heavily affected foliage.",
    },
    "Black Rot": {
        "immediate_action": "Remove and destroy infected leaves, shoots, and mummified fruit.",
        "spray_plan": "Start preventive fungicide coverage during warm and wet periods.",
        "prevention": "Improve canopy ventilation and keep the field floor clean.",
        "monitoring": "Recheck after rain events for new circular lesions.",
    },
    "Cedar Apple Rust": {
        "immediate_action": "Remove heavily infected leaves where practical.",
        "spray_plan": "Apply labeled fungicide from early leaf stage during rainy periods.",
        "prevention": "Limit nearby alternate hosts and maintain open canopy structure.",
        "monitoring": "Inspect weekly for new orange rust pustules and re-scan if needed.",
    },
    "Cercospora Leaf Spot": {
        "immediate_action": "Remove lower infected leaves and minimize splash spread.",
        "spray_plan": "Use approved fungicide when disease pressure remains moderate to high.",
        "prevention": "Improve row spacing and avoid long wet leaf duration.",
        "monitoring": "Review symptom progression every 3 days and capture follow-up scans.",
    },
    "Common Rust": {
        "immediate_action": "Remove heavily rusted leaves if infection is localized.",
        "spray_plan": "Apply rust-targeted fungicide when pustules spread rapidly.",
        "prevention": "Maintain balanced nutrition and avoid prolonged humidity in canopy.",
        "monitoring": "Check new leaf layers twice weekly for fresh rust pustules.",
    },
    "Early Blight": {
        "immediate_action": "Prune infected lower leaves and dispose away from field.",
        "spray_plan": "Apply bio-fungicide or labeled fungicide at regular intervals.",
        "prevention": "Use mulch to reduce soil splash and avoid overhead watering.",
        "monitoring": "Re-scan after 3 to 4 days and note lesion expansion.",
    },
    "Esca (Black Measles)": {
        "immediate_action": "Mark symptomatic vines and prune diseased wood during dry weather.",
        "spray_plan": "Follow local vine protection guidance; prioritize wound protection practices.",
        "prevention": "Avoid large pruning wounds and sanitize blades between cuts.",
        "monitoring": "Inspect vine vigor and canopy symptoms weekly.",
    },
    "Healthy": {
        "immediate_action": "No immediate treatment needed.",
        "spray_plan": "Continue preventive spray only if part of your routine schedule.",
        "prevention": "Maintain balanced irrigation, nutrition, and airflow.",
        "monitoring": "Continue routine scouting and monthly scans.",
    },
    "Leaf Blight": {
        "immediate_action": "Remove infected leaves promptly and reduce canopy density.",
        "spray_plan": "Apply broad-spectrum fungicide if lesions continue spreading.",
        "prevention": "Avoid wet foliage periods and improve ventilation.",
        "monitoring": "Review every 2 to 3 days and record new lesion count.",
    },
    "Leaf Scorch": {
        "immediate_action": "Remove severely scorched leaves and reduce plant stress.",
        "spray_plan": "Spray is usually secondary; prioritize irrigation correction first.",
        "prevention": "Maintain consistent moisture and review nutrient balance.",
        "monitoring": "Observe new growth quality over the next week.",
    },
    "Late Blight": {
        "immediate_action": "Immediately remove and isolate heavily infected plant parts.",
        "spray_plan": "Apply late-blight effective fungicide as per label without delay.",
        "prevention": "Keep foliage dry and improve airflow around plants.",
        "monitoring": "Re-scan within 48 to 72 hours to confirm control.",
    },
    "Northern Leaf Blight": {
        "immediate_action": "Remove severely affected leaves and reduce humidity pockets.",
        "spray_plan": "Apply recommended fungicide where pressure is sustained.",
        "prevention": "Rotate crops and remove infected residue after harvest.",
        "monitoring": "Check upper leaves twice weekly for new elongated lesions.",
    },
    "Powdery Mildew": {
        "immediate_action": "Prune infected leaves and thin dense canopy sections.",
        "spray_plan": "Use sulfur, potassium bicarbonate, or neem-based treatment weekly.",
        "prevention": "Improve airflow and avoid excess nitrogen-heavy growth.",
        "monitoring": "Monitor underside of leaves every 2 to 3 days.",
    },
    "Septoria Leaf Spot": {
        "immediate_action": "Remove spotted leaves and keep fallen debris off soil surface.",
        "spray_plan": "Apply fungicide at recommended intervals when spots continue to spread.",
        "prevention": "Use mulch and avoid overhead watering.",
        "monitoring": "Re-scan in 3 to 5 days and compare spot density.",
    },
    "Yellow Leaf Curl Virus": {
        "immediate_action": "Isolate severely infected plants to reduce vector transmission.",
        "spray_plan": "Control whiteflies using sticky traps and labeled insecticidal options.",
        "prevention": "Use clean seedlings and remove nearby weed hosts.",
        "monitoring": "Track new curling/yellowing leaves daily for one week.",
    },
    "Uncertain": {
        "immediate_action": "Capture a new close-up image of a single leaf in brighter light.",
        "spray_plan": "Do not start aggressive treatment until a clearer diagnosis is available.",
        "prevention": "Use focused, non-blurry framing and avoid mixed backgrounds in scans.",
        "monitoring": "Retake scan immediately and again after 2 days if symptoms persist.",
    },
}


def _normalize_label(label: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", label.lower()).strip()


def _resolve_sections(disease: str) -> dict[str, str]:
    direct = REMEDY_SECTIONS_BY_DISEASE.get(disease)
    if direct:
        return direct

    normalized = _normalize_label(disease)
    for label, sections in REMEDY_SECTIONS_BY_DISEASE.items():
        if _normalize_label(label) == normalized:
            return sections

    for label, sections in REMEDY_SECTIONS_BY_DISEASE.items():
        key = _normalize_label(label)
        if key and (key in normalized or normalized in key):
            return sections

    return DEFAULT_REMEDY_SECTIONS


def get_remedy_sections(disease: str) -> dict[str, str]:
    sections = _resolve_sections(disease)
    return {
        "immediate_action": sections["immediate_action"],
        "spray_plan": sections["spray_plan"],
        "prevention": sections["prevention"],
        "monitoring": sections["monitoring"],
    }


def get_disease_explanation(disease: str) -> str:
    direct = DISEASE_EXPLANATION_BY_DISEASE.get(disease)
    if direct:
        return direct

    normalized = _normalize_label(disease)
    for label, explanation in DISEASE_EXPLANATION_BY_DISEASE.items():
        if _normalize_label(label) == normalized:
            return explanation

    for label, explanation in DISEASE_EXPLANATION_BY_DISEASE.items():
        key = _normalize_label(label)
        if key and (key in normalized or normalized in key):
            return explanation

    return DEFAULT_DISEASE_EXPLANATION


def get_remedy(disease: str) -> str:
    sections = get_remedy_sections(disease)
    return (
        f"Immediate action; {sections['immediate_action']}. "
        f"Spray plan; {sections['spray_plan']}. "
        f"Prevention; {sections['prevention']}. "
        f"Monitoring; {sections['monitoring']}"
    )


def get_disease_type(disease: str) -> str:
    direct = DISEASE_TYPE_BY_DISEASE.get(disease)
    if direct:
        return direct
    normalized = _normalize_label(disease)
    for label, dtype in DISEASE_TYPE_BY_DISEASE.items():
        if _normalize_label(label) == normalized:
            return dtype
    return "Unknown"


def get_drug_compounds(crop: str) -> list[str]:
    if not crop:
        return []
    normalized = _normalize_label(crop)
    for label, compounds in DRUG_COMPOUNDS_BY_CROP.items():
        if _normalize_label(label) == normalized:
            return compounds
    return []
