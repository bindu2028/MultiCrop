"""
Curated Knowledge Base for Natural Drug Compounds.
Maps compounds to their source organisms and medicinal properties.
"""

COMPOUND_KNOWLEDGE = {
    "quercetin": {
        "common_name": "Quercetin",
        "compound_class": "Flavonoid / Polyphenol",
        "source_organisms": [
            "Capers (Capparis spinosa) — highest concentration",
            "Red onions, apples, berries",
            "Kale, broccoli, lovage"
        ],
        "source_type": "Plant",
        "traditional_use": "Used in Ayurvedic and Traditional Chinese Medicine for inflammation and allergy relief.",
        "medicinal_remedy": {
            "primary_use": "Anti-inflammatory and antioxidant supplement",
            "conditions_treated": ["Allergies", "Inflammation", "Cardiovascular support", "Viral infections"],
            "how_used": "Typically taken orally as 500–1000 mg daily.",
            "research_notes": "Reduces allergic reactions and protects cells from damage caused by free radicals.",
            "caution": "May interact with blood thinners and certain antibiotics."
        },
        "bioactivity": ["Antioxidant", "Anti-inflammatory", "Antiviral", "Antihistamine"]
    },
    "curcumin": {
        "common_name": "Curcumin",
        "compound_class": "Diarylheptanoid / Polyphenol",
        "source_organisms": [
            "Turmeric (Curcuma longa)"
        ],
        "source_type": "Plant",
        "traditional_use": "A staple of Ayurvedic medicine used for joint pain, digestion, and healing.",
        "medicinal_remedy": {
            "primary_use": "Strong anti-inflammatory and pain relief",
            "conditions_treated": ["Arthritis", "Metabolic syndrome", "Hyperlipidemia", "Anxiety"],
            "how_used": "Taken orally, often with piperine (black pepper) to boost absorption by 2000%.",
            "research_notes": "Reduces inflammation throughout the body and protects cells from damage.",
            "caution": "High doses may cause digestive upset or interact with blood-thinning medications."
        },
        "bioactivity": ["Anti-inflammatory", "Antioxidant", "Antimicrobial", "Hepatoprotective"]
    },
    "berberine": {
        "common_name": "Berberine",
        "compound_class": "Isoquinoline Alkaloid",
        "source_organisms": [
            "Goldenseal (Hydrastis canadensis)",
            "Barberry (Berberis vulgaris)",
            "Oregon grape, Tree turmeric"
        ],
        "source_type": "Plant",
        "traditional_use": "Used extensively in Traditional Chinese Medicine for treating diarrhea and infections.",
        "medicinal_remedy": {
            "primary_use": "Blood sugar regulation and antimicrobial",
            "conditions_treated": ["Type 2 Diabetes", "High cholesterol", "PCOS", "Gastrointestinal infections"],
            "how_used": "Usually 500 mg taken 2-3 times daily before meals.",
            "research_notes": "Activates the body's natural metabolism control system, helping regulate blood sugar and energy.",
            "caution": "May interact strongly with macrolide antibiotics and medications metabolized by the liver."
        },
        "bioactivity": ["Antimicrobial", "Hypoglycemic", "Anti-inflammatory", "Lipid-lowering"]
    },
    "caffeine": {
        "common_name": "Caffeine",
        "compound_class": "Purine Alkaloid",
        "source_organisms": [
            "Coffee beans (Coffea species)",
            "Tea leaves (Camellia sinensis)",
            "Cacao pods, Guarana berries"
        ],
        "source_type": "Plant",
        "traditional_use": "Historically consumed in brews to reduce fatigue and improve focus.",
        "medicinal_remedy": {
            "primary_use": "Central nervous system stimulant",
            "conditions_treated": ["Fatigue", "Migraines", "Asthma (mild)", "Mental alertness"],
            "how_used": "Consumed in beverages or taken as an additive in headache medications.",
            "research_notes": "Blocks the signals that make you feel tired, helping you stay alert and focused.",
            "caution": "Can cause insomnia, jitteriness, and increased heart rate at high doses."
        },
        "bioactivity": ["Stimulant", "Bronchodilator", "Diuretic"]
    },
    "lycopene": {
        "common_name": "Lycopene",
        "compound_class": "Tetraterpene / Carotenoid",
        "source_organisms": [
            "Tomatoes (Solanum lycopersicum)",
            "Watermelon, Pink grapefruit, Guava"
        ],
        "source_type": "Plant",
        "traditional_use": "Dietary component recognized for promoting heart and prostate health.",
        "medicinal_remedy": {
            "primary_use": "Potent antioxidant",
            "conditions_treated": ["Prostate health", "Sunburn protection", "Cardiovascular support"],
            "how_used": "Best absorbed from cooked tomato products with a fat source.",
            "research_notes": "Protects your cells and tissues from damage caused by aging and sun exposure.",
            "caution": "Excessive intake can cause lycopenodermia (harmless orange skin coloration)."
        },
        "bioactivity": ["Antioxidant", "Chemopreventive"]
    },
    "capsaicin": {
        "common_name": "Capsaicin",
        "compound_class": "Capsaicinoid",
        "source_organisms": [
            "Chili peppers (Capsicum species)"
        ],
        "source_type": "Plant",
        "traditional_use": "Used topically for pain relief and consumed for circulatory health.",
        "medicinal_remedy": {
            "primary_use": "Topical analgesic (pain relief)",
            "conditions_treated": ["Neuropathy", "Arthritis", "Muscle pain", "Cluster headaches"],
            "how_used": "Applied as creams/patches (0.025% to 8%) or used as a nasal spray.",
            "research_notes": "Blocks the nerve signals that carry pain to your brain, providing relief.",
            "caution": "Can cause severe burning if rubbed into eyes or sensitive skin."
        },
        "bioactivity": ["Analgesic", "Thermogenic", "Anti-inflammatory"]
    },
    "resveratrol": {
        "common_name": "Resveratrol",
        "compound_class": "Stilbenoid",
        "source_organisms": [
            "Grapes (Vitis vinifera) — skin",
            "Japanese knotweed",
            "Blueberries, Peanuts"
        ],
        "source_type": "Plant",
        "traditional_use": "Derived from plants used in traditional Asian medicine for heart and circulatory issues.",
        "medicinal_remedy": {
            "primary_use": "Anti-aging and cardiovascular support",
            "conditions_treated": ["High blood pressure", "Insulin resistance", "Neurodegeneration"],
            "how_used": "Taken as a supplement, often extracted from Japanese knotweed.",
            "research_notes": "Activates genes linked to longevity and slowing the aging process.",
            "caution": "Can interfere with blood clotting; caution with NSAIDs and blood thinners."
        },
        "bioactivity": ["Antioxidant", "Cardioprotective", "Anti-aging"]
    },
    "penicillin": {
        "common_name": "Penicillin",
        "compound_class": "Beta-lactam Antibiotic",
        "source_organisms": [
            "Penicillium fungi (e.g., Penicillium chrysogenum)"
        ],
        "source_type": "Fungi",
        "traditional_use": "Discovered from mold; revolutionized modern medicine's treatment of infection.",
        "medicinal_remedy": {
            "primary_use": "Bacterial infection treatment",
            "conditions_treated": ["Strep throat", "Syphilis", "Respiratory infections", "Skin infections"],
            "how_used": "Administered orally or via injection (prescription only).",
            "research_notes": "Stops bacteria from building their protective outer shell, causing them to die and be destroyed.",
            "caution": "Common cause of severe drug allergies (anaphylaxis)."
        },
        "bioactivity": ["Antibacterial"]
    },
    "lovastatin": {
        "common_name": "Lovastatin",
        "compound_class": "Polyketide / Statin",
        "source_organisms": [
            "Oyster mushrooms (Pleurotus ostreatus)",
            "Red yeast rice (Monascus purpureus on rice)",
            "Aspergillus terreus (Fungus)"
        ],
        "source_type": "Fungi",
        "traditional_use": "Red yeast rice has been used in Traditional Chinese Medicine for centuries to improve blood circulation.",
        "medicinal_remedy": {
            "primary_use": "Cholesterol lowering",
            "conditions_treated": ["Hypercholesterolemia", "Cardiovascular disease risk"],
            "how_used": "Taken as a prescription medication or naturally via red yeast rice supplements.",
            "research_notes": "Blocks the enzyme your liver uses to make cholesterol, helping reduce blood cholesterol levels.",
            "caution": "May cause muscle pain (myopathy); avoid grapefruit juice which affects its metabolism."
        },
        "bioactivity": ["Hypolipidemic"]
    },
    "streptomycin": {
        "common_name": "Streptomycin",
        "compound_class": "Aminoglycoside",
        "source_organisms": [
            "Streptomyces griseus (Soil bacteria)"
        ],
        "source_type": "Bacteria",
        "traditional_use": "First discovered antibiotic to treat tuberculosis.",
        "medicinal_remedy": {
            "primary_use": "Treatment of severe bacterial infections",
            "conditions_treated": ["Tuberculosis", "Plague", "Tularemia", "Endocarditis"],
            "how_used": "Administered via intramuscular injection.",
            "research_notes": "Disrupts bacteria's ability to build proteins and survive, causing them to die.",
            "caution": "Can cause hearing loss (ototoxicity) and kidney damage (nephrotoxicity)."
        },
        "bioactivity": ["Antibacterial"]
    },
    "taxol": {
        "common_name": "Paclitaxel (Taxol)",
        "compound_class": "Taxane Diterpenoid",
        "source_organisms": [
            "Pacific yew tree (Taxus brevifolia) — bark",
            "Endophytic fungi (e.g., Taxomyces andreanae)"
        ],
        "source_type": "Plant / Fungi",
        "traditional_use": "Native American tribes used yew preparations for non-cancerous ailments, but taxol itself is a modern discovery.",
        "medicinal_remedy": {
            "primary_use": "Chemotherapy drug",
            "conditions_treated": ["Ovarian cancer", "Breast cancer", "Lung cancer", "Kaposi's sarcoma"],
            "how_used": "Administered intravenously in clinical settings.",
            "research_notes": "Prevents cancer cells from dividing and multiplying by stabilizing their internal structure.",
            "caution": "Causes significant side effects including hair loss, neuropathy, and bone marrow suppression."
        },
        "bioactivity": ["Antineoplastic (Anticancer)"]
    },
    "morphine": {
        "common_name": "Morphine",
        "compound_class": "Opiate Alkaloid",
        "source_organisms": [
            "Opium poppy (Papaver somniferum)"
        ],
        "source_type": "Plant",
        "traditional_use": "Opium has been used for millennia for pain relief and sleep.",
        "medicinal_remedy": {
            "primary_use": "Severe pain management",
            "conditions_treated": ["Acute pain", "Cancer pain", "Palliative care", "Myocardial infarction"],
            "how_used": "Administered orally or intravenously under strict medical supervision.",
            "research_notes": "Works on the brain and spinal cord to reduce the pain signals sent throughout your body.",
            "caution": "Highly addictive. High risk of respiratory depression and overdose."
        },
        "bioactivity": ["Analgesic", "Narcotic"]
    },
    "aspirin": {
        "common_name": "Salicylic Acid (Aspirin precursor)",
        "compound_class": "Phenolic Acid",
        "source_organisms": [
            "Willow bark (Salix species)",
            "Meadowsweet (Filipendula ulmaria)"
        ],
        "source_type": "Plant",
        "traditional_use": "Willow bark was chewed by ancient Egyptians and Greeks to relieve pain and fever.",
        "medicinal_remedy": {
            "primary_use": "Pain relief and anti-inflammatory",
            "conditions_treated": ["Pain", "Fever", "Inflammation", "Prevention of heart attacks (as Acetylsalicylic acid)"],
            "how_used": "Taken orally as synthesized Acetylsalicylic acid (Aspirin).",
            "research_notes": "Blocks the body's pain and inflammation signaling system, reducing discomfort.",
            "caution": "Can cause gastrointestinal bleeding and ulcers."
        },
        "bioactivity": ["Analgesic", "Antipyretic", "Anti-inflammatory", "Antiplatelet"]
    },
    "artemisinin": {
        "common_name": "Artemisinin",
        "compound_class": "Sesquiterpene Lactone",
        "source_organisms": [
            "Sweet wormwood (Artemisia annua)"
        ],
        "source_type": "Plant",
        "traditional_use": "Used in Traditional Chinese Medicine for over 2,000 years to treat fevers.",
        "medicinal_remedy": {
            "primary_use": "Antimalarial drug",
            "conditions_treated": ["Malaria (especially Plasmodium falciparum)"],
            "how_used": "Used in combination therapies (ACTs) to prevent resistance.",
            "research_notes": "Creates harmful effects that damage malaria parasites at the cellular level, stopping their growth.",
            "caution": "Resistance is emerging; must be used in combination."
        },
        "bioactivity": ["Antimalarial"]
    },
    "menthol": {
        "common_name": "Menthol",
        "compound_class": "Monoterpene",
        "source_organisms": [
            "Peppermint (Mentha x piperita)",
            "Corn mint (Mentha arvensis)"
        ],
        "source_type": "Plant",
        "traditional_use": "Used globally to relieve sore throats, coughs, and digestive issues.",
        "medicinal_remedy": {
            "primary_use": "Topical analgesic and cooling agent",
            "conditions_treated": ["Sore throat", "Minor muscle aches", "Sunburn", "Congestion"],
            "how_used": "Found in lozenges, balms, and nasal inhalers.",
            "research_notes": "Activates cold-sensitive receptors in your skin, creating a cooling and soothing sensation.",
            "caution": "Can be toxic if pure essential oil is ingested in large amounts."
        },
        "bioactivity": ["Analgesic", "Antitussive", "Cooling agent"]
    },
    "penicillin": {
        "common_name": "Penicillin G",
        "compound_class": "Beta-lactam Antibiotic",
        "source_organisms": [
            "Penicillium chrysogenum (Fungus)",
            "Penicillium notatum"
        ],
        "source_type": "Fungi",
        "traditional_use": "Discovered accidentally by Alexander Fleming; revolutionized modern medicine by curing previously fatal bacterial infections.",
        "medicinal_remedy": {
            "primary_use": "Antibacterial antibiotic",
            "conditions_treated": ["Streptococcal infections", "Syphilis", "Lyme disease", "Diphtheria"],
            "how_used": "Administered orally or intravenously depending on the specific derivative.",
            "research_notes": "Stops bacteria from building their protective outer shell, causing them to die and be destroyed.",
            "caution": "Can cause severe allergic reactions (anaphylaxis) in some individuals."
        },
        "bioactivity": ["Antibacterial", "Antibiotic"]
    },
    "streptomycin": {
        "common_name": "Streptomycin",
        "compound_class": "Aminoglycoside",
        "source_organisms": [
            "Streptomyces griseus (Soil Bacterium)"
        ],
        "source_type": "Bacteria",
        "traditional_use": "The first antibiotic ever discovered that was effective against tuberculosis.",
        "medicinal_remedy": {
            "primary_use": "Antibiotic for severe infections",
            "conditions_treated": ["Tuberculosis", "Plague", "Tularemia", "Endocarditis"],
            "how_used": "Given via intramuscular injection.",
            "research_notes": "Binds to the 30S ribosomal subunit, preventing protein synthesis in bacteria.",
            "caution": "Can cause ototoxicity (hearing loss) and nephrotoxicity (kidney damage)."
        },
        "bioactivity": ["Antibiotic", "Protein synthesis inhibitor"]
    },
        "gingerol": {
        "common_name": "Gingerol",
        "compound_class": "Phenolic Ketone",
        "source_organisms": [
            "Fresh Ginger rhizome (Zingiber officinale)"
        ],
        "source_type": "Plant",
        "traditional_use": "Used in Ayurveda and Traditional Chinese Medicine for warming the body, soothing nausea, and aiding digestion.",
        "medicinal_remedy": {
            "primary_use": "Natural anti-nausea and digestive aid",
            "conditions_treated": ["Nausea / Motion sickness", "Indigestion", "Osteoarthritis pain", "Muscle soreness"],
            "how_used": "Consumed naturally in fresh ginger root, teas, or taken as a 1000 mg supplement daily.",
            "research_notes": "Stimulates digestive saliva and blocks brain signals that trigger vomiting, while acting as a natural anti-inflammatory.",
            "caution": "High doses may cause mild heartburn or interact with blood-thinning medications."
        },
        "bioactivity": ["Anti-nausea", "Anti-inflammatory", "Antioxidant", "Gastroprotective"]
    },

}

def get_compound_knowledge(name: str) -> dict | None:
    """
    Fuzzy lookup for compound knowledge.
    Tries exact match, then substring match.
    """
    if not name:
        return None
        
    query = name.strip().lower()
    
    # Exact match
    if query in COMPOUND_KNOWLEDGE:
        return COMPOUND_KNOWLEDGE[query]
        
    # Substring match
    for key, data in COMPOUND_KNOWLEDGE.items():
        if key in query or query in key:
            return data
            
    # Try synonym matching
    for key, data in COMPOUND_KNOWLEDGE.items():
        common = data.get("common_name", "").lower()
        if query in common or common in query:
            return data
            
    return None
