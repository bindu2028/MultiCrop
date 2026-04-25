/// Static local knowledge base for plant diseases.
/// Key: lowercase disease name (matches prediction response).
library;

class DiseaseInfo {
  final String name;
  final String symptoms;
  final String causes;
  final String spread;
  final String prevention;
  final String organicTreatment;
  final String chemicalTreatment;

  const DiseaseInfo({
    required this.name,
    required this.symptoms,
    required this.causes,
    required this.spread,
    required this.prevention,
    required this.organicTreatment,
    required this.chemicalTreatment,
  });
}

const Map<String, DiseaseInfo> kDiseaseKnowledge = {
  // ── APPLE ────────────────────────────────────────────────────────────────
  'apple scab': DiseaseInfo(
    name: 'Apple Scab',
    symptoms:
        'Olive-green or brown velvety spots on leaves and fruit. Leaves may yellow and drop early. Fruit shows dark, corky lesions.',
    causes:
        'Caused by the fungus Venturia inaequalis. Thrives in cool, moist spring weather.',
    spread:
        'Spores from infected fallen leaves are released in spring and carried by wind and rain to new tissue.',
    prevention:
        'Rake and destroy fallen leaves. Plant resistant varieties. Ensure good air circulation by pruning.',
    organicTreatment:
        'Apply sulfur-based sprays or copper fungicide early in the season. Neem oil can suppress mild infections.',
    chemicalTreatment:
        'Captan, Myclobutanil, or Mancozeb applied at 7–10 day intervals starting at green tip until 2 weeks after petal fall.',
  ),
  'apple black rot': DiseaseInfo(
    name: 'Apple Black Rot',
    symptoms:
        'Purple or tan circular leaf spots with dark borders. Fruit shows rotting that starts at the calyx end and turns mummified.',
    causes:
        'Caused by the fungus Botryosphaeria obtusa. Wounds and dead wood serve as entry points.',
    spread:
        'Spores spread through rain splash and wind from infected bark, mummified fruit, and dead branches.',
    prevention:
        'Prune out dead and diseased wood. Remove mummified fruit. Avoid injuring bark.',
    organicTreatment:
        'Copper-based sprays during dormant season. Remove all infected plant material promptly.',
    chemicalTreatment:
        'Captan or Thiophanate-methyl fungicides applied at 10–14 day intervals from pink bud through harvest.',
  ),
  'cedar apple rust': DiseaseInfo(
    name: 'Cedar Apple Rust',
    symptoms:
        'Bright orange-yellow spots on upper leaf surface in spring. Tube-like structures appear on the underside of leaves.',
    causes:
        'Caused by Gymnosporangium juniperi-virginianae, a fungus requiring two hosts: apple and eastern red cedar.',
    spread:
        'Bright orange gelatinous spore horns on cedar galls release spores during wet weather in spring.',
    prevention:
        'Plant rust-resistant apple varieties. Remove nearby cedar/juniper trees if possible.',
    organicTreatment:
        'Sulfur sprays applied before infection periods (when cedar galls are releasing spores).',
    chemicalTreatment:
        'Myclobutanil or Triadimefon applied at pink bud stage through first cover spray.',
  ),
  'apple healthy': DiseaseInfo(
    name: 'Healthy Apple',
    symptoms: 'No symptoms — leaves are green, firm, and blemish-free.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Maintain regular pruning, balanced fertilisation, and monitor weekly for early signs of disease.',
    organicTreatment: 'No treatment needed. Continue good cultural practices.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── BELL PEPPER ──────────────────────────────────────────────────────────
  'pepper bell bacterial spot': DiseaseInfo(
    name: 'Bacterial Spot (Bell Pepper)',
    symptoms:
        'Water-soaked spots on leaves that turn brown with yellow halos. Raised, scabby lesions on fruit.',
    causes:
        'Caused by Xanthomonas campestris pv. vesicatoria bacteria. Favoured by warm, wet conditions.',
    spread:
        'Spread through infected seed, rain splash, contaminated tools, and infected transplants.',
    prevention:
        'Use certified disease-free seed. Avoid overhead irrigation. Rotate crops for 2–3 years.',
    organicTreatment:
        'Copper-based bactericides applied at first sign of disease. Remove and destroy infected plant material.',
    chemicalTreatment:
        'Copper hydroxide + Mancozeb combination sprays on a 5–7 day schedule during wet weather.',
  ),
  'pepper bell healthy': DiseaseInfo(
    name: 'Healthy Bell Pepper',
    symptoms: 'Vibrant green leaves, firm stems, no spots or discolouration.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Maintain soil moisture consistency, avoid waterlogging, and inspect weekly.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── CHERRY ───────────────────────────────────────────────────────────────
  'cherry powdery mildew': DiseaseInfo(
    name: 'Cherry Powdery Mildew',
    symptoms:
        'White powdery coating on new leaves, shoots, and fruit. Affected leaves curl and may drop early.',
    causes:
        'Caused by Podosphaera clandestina fungus. Favoured by warm days, cool nights, and high humidity (without rain).',
    spread:
        'Wind-dispersed spores. Dense canopies with poor airflow greatly accelerate spread.',
    prevention:
        'Prune for open canopy. Avoid excess nitrogen. Plant resistant varieties.',
    organicTreatment:
        'Sulfur fungicides, potassium bicarbonate, or neem oil sprayed at first sign and every 7–10 days.',
    chemicalTreatment:
        'Myclobutanil or Trifloxystrobin applied as protective sprays from shuck split through harvest.',
  ),
  'cherry healthy': DiseaseInfo(
    name: 'Healthy Cherry',
    symptoms: 'Glossy, dark green leaves with no spots or powdery residue.',
    causes: 'N/A',
    spread: 'N/A',
    prevention: 'Annual pruning and monitoring for pest/disease pressure.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── CORN / MAIZE ─────────────────────────────────────────────────────────
  'corn maize cercospora leaf spot gray leaf spot': DiseaseInfo(
    name: 'Gray Leaf Spot (Corn)',
    symptoms:
        'Rectangular, tan to gray lesions on leaves that run parallel to leaf veins. Lesions may merge, causing large dead areas.',
    causes:
        'Caused by Cercospora zeae-maydis fungus. Favoured by warm, humid nights and prolonged dew periods.',
    spread:
        'Airborne spores and residue-borne infection. Continuous corn cropping greatly increases risk.',
    prevention:
        'Plant tolerant hybrids. Rotate with non-host crops. Till to reduce surface residue.',
    organicTreatment:
        'No effective organic treatment — focus on prevention through resistant hybrids and crop rotation.',
    chemicalTreatment:
        'Azoxystrobin or Pyraclostrobin fungicides applied at VT/R1 growth stage when conditions favour disease.',
  ),
  'corn maize common rust': DiseaseInfo(
    name: 'Common Rust (Corn)',
    symptoms:
        'Oval to elongated cinnamon-brown pustules (uredia) on both leaf surfaces. Pustules rupture and release powdery spores.',
    causes:
        'Caused by Puccinia sorghi. Favoured by cool temperatures (60–77°F) and high humidity.',
    spread:
        'Spores carried long distances by wind currents from southern overwintering areas.',
    prevention:
        'Plant resistant hybrids. Early planting reduces exposure to peak spore periods.',
    organicTreatment:
        'Sulfur-based sprays can reduce severity if applied early at first pustule appearance.',
    chemicalTreatment:
        'Triazole or strobilurin fungicides applied before tasseling when 5% of plants show pustules.',
  ),
  'corn maize northern leaf blight': DiseaseInfo(
    name: 'Northern Leaf Blight (Corn)',
    symptoms:
        'Long (1–6 inch), cigar-shaped tan/gray lesions with wavy, irregular margins on leaves.',
    causes:
        'Caused by Exserohilum turcicum. Thrives in moderate temperatures with long dew periods.',
    spread:
        'Airborne spores from infected crop residue. Most severe in continuous corn fields.',
    prevention:
        'Use resistant hybrids. Rotate crops. Till infected residue after harvest.',
    organicTreatment:
        'No highly effective organic option — cultural practices are the primary defence.',
    chemicalTreatment:
        'Propiconazole or Azoxystrobin applied at or before tasseling when disease appears in lower canopy.',
  ),
  'corn maize healthy': DiseaseInfo(
    name: 'Healthy Corn / Maize',
    symptoms: 'Upright, green leaves with no lesions, pustules, or discolouration.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Rotate crops, choose resistant hybrids, and monitor fields weekly during humid periods.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── GRAPE ────────────────────────────────────────────────────────────────
  'grape black rot': DiseaseInfo(
    name: 'Grape Black Rot',
    symptoms:
        'Tan circular leaf spots with dark borders. Berries shrivel into hard, black mummies.',
    causes:
        'Caused by Guignardia bidwellii. Favoured by warm, wet weather (65–85°F) during shoot growth.',
    spread:
        'Spores released from overwintering mummies and infected canes during rainy periods in spring.',
    prevention:
        'Remove mummified berries and infected canes. Ensure canopy airflow. Use resistant varieties.',
    organicTreatment:
        'Copper fungicides and sulfur applied from bud swell through berry touch stage.',
    chemicalTreatment:
        'Mancozeb or Myclobutanil on a 10–14 day schedule from early shoot growth to bunch closure.',
  ),
  'grape esca black measles': DiseaseInfo(
    name: 'Esca / Black Measles (Grape)',
    symptoms:
        'Tiger-stripe pattern of yellowing and browning between leaf veins. Berries show dark spots and may crack.',
    causes:
        'A wood disease complex caused by multiple fungi (Phaeomoniella, Phaeoacremonium). Associated with pruning wounds.',
    spread:
        'Fungi enter through pruning wounds. Disease progresses slowly through the vine\'s wood.',
    prevention:
        'Prune during dry, dormant periods. Seal large pruning wounds. Remove infected wood.',
    organicTreatment:
        'No proven organic cure. Trunk renewal (removing and regrowing the trunk) can help severely infected vines.',
    chemicalTreatment:
        'Sodium arsenite (where permitted) or thiophanate-methyl applied to pruning wounds as a protectant.',
  ),
  'grape leaf blight isariopsis leaf spot': DiseaseInfo(
    name: 'Grape Leaf Blight',
    symptoms:
        'Irregular dark brown spots on older leaves. Spots may have a red or purple border. Severe cases cause defoliation.',
    causes:
        'Caused by Pseudocercospora vitis (Isariopsis). Favoured by warm, wet conditions in mid-to-late season.',
    spread:
        'Spores spread by rain and wind from infected leaf debris on the orchard floor.',
    prevention:
        'Improve canopy airflow with leaf removal. Collect and destroy fallen leaves. Avoid excessive nitrogen.',
    organicTreatment:
        'Copper-based fungicides applied in mid-season when weather conditions are warm and wet.',
    chemicalTreatment:
        'Mancozeb or Captan sprays starting when symptom risk is high (warm, humid weather).',
  ),
  'grape healthy': DiseaseInfo(
    name: 'Healthy Grape',
    symptoms: 'Uniform green leaves, firm canes, and blemish-free developing fruit.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Annual dormant pruning, balanced feeding, and weekly scouting for pest/disease pressure.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── PEACH ────────────────────────────────────────────────────────────────
  'peach bacterial spot': DiseaseInfo(
    name: 'Bacterial Spot (Peach)',
    symptoms:
        'Water-soaked spots on leaves that turn brown and drop out, giving a "shot-hole" appearance. Sunken, dark lesions on fruit.',
    causes:
        'Caused by Xanthomonas arboricola pv. pruni. Warm, wet, and windy conditions accelerate infection.',
    spread:
        'Rain-splashed bacteria move from cankers in bark to new leaf and fruit tissue.',
    prevention:
        'Plant resistant cultivars. Avoid susceptible areas with heavy spring rain. Prune for airflow.',
    organicTreatment:
        'Copper bactericides applied at petal fall and repeated weekly during wet periods.',
    chemicalTreatment:
        'Oxytetracycline or copper hydroxide mixed with Mancozeb on a 5–7 day schedule.',
  ),
  'peach healthy': DiseaseInfo(
    name: 'Healthy Peach',
    symptoms: 'Lush green leaves, no spots or shot-holes, clean fruit surface.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Regular dormant pruning, copper sprays in autumn, and weekly monitoring.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── POTATO ───────────────────────────────────────────────────────────────
  'potato early blight': DiseaseInfo(
    name: 'Early Blight (Potato)',
    symptoms:
        'Dark brown, circular spots with concentric rings (target-board pattern) on older leaves. Yellow halo surrounds spots.',
    causes:
        'Caused by Alternaria solani. Favoured by warm (75–85°F), humid weather after periods of plant stress.',
    spread:
        'Airborne spores from infected debris. Rain and dew splash spreads spores to new plant tissue.',
    prevention:
        'Rotate crops (3 years). Remove infected debris. Avoid overhead watering. Fertilise adequately.',
    organicTreatment:
        'Copper fungicide or Bacillus subtilis-based products applied at first sign on a 7-day schedule.',
    chemicalTreatment:
        'Chlorothalonil or Azoxystrobin applied every 7–14 days starting when plants are under stress or disease appears.',
  ),
  'potato late blight': DiseaseInfo(
    name: 'Late Blight (Potato)',
    symptoms:
        'Pale green to brown water-soaked lesions on leaves and stems. White mould appears on underside in humid conditions. Tubers show brown rot.',
    causes:
        'Caused by Phytophthora infestans oomycete (water mould). Spread explosively in cool, moist conditions.',
    spread:
        'Spores travel by wind and rain. Can destroy an entire field within days under ideal conditions.',
    prevention:
        'Plant certified disease-free seed tubers. Destroy volunteer plants. Create good drainage.',
    organicTreatment:
        'Copper-based fungicides applied preventively every 5–7 days during high-risk (cool, wet) periods.',
    chemicalTreatment:
        'Metalaxyl + Mancozeb or Cymoxanil applied preventively on a 5–7 day rotation. Alternate fungicide classes to avoid resistance.',
  ),
  'potato healthy': DiseaseInfo(
    name: 'Healthy Potato',
    symptoms: 'Upright, dark green foliage with no spots or wilting.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Use certified seed, rotate crops, hill up adequately, and monitor weekly.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── STRAWBERRY ───────────────────────────────────────────────────────────
  'strawberry leaf scorch': DiseaseInfo(
    name: 'Leaf Scorch (Strawberry)',
    symptoms:
        'Small, dark purple spots on upper leaf surface. Spots enlarge and leaf turns brown between veins, giving a "scorched" look.',
    causes:
        'Caused by Diplocarpon earlianum fungus. Favoured by warm, wet weather.',
    spread:
        'Spores spread by rain splash from infected leaves. Infected plant debris carries the fungus winter-to-season.',
    prevention:
        'Remove old infected leaves in autumn. Avoid overhead irrigation. Thin beds for airflow.',
    organicTreatment:
        'Copper fungicides applied in early spring before bloom and after harvest.',
    chemicalTreatment:
        'Captan or Myclobutanil applied on a 10–14 day schedule from early growth through harvest.',
  ),
  'strawberry healthy': DiseaseInfo(
    name: 'Healthy Strawberry',
    symptoms: 'Bright green, firm leaves with no spots. White flowers and clean fruit.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Renovate beds annually, remove old foliage, and use drip irrigation to keep leaves dry.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),

  // ── TOMATO ───────────────────────────────────────────────────────────────
  'tomato bacterial spot': DiseaseInfo(
    name: 'Bacterial Spot (Tomato)',
    symptoms:
        'Small, water-soaked spots on leaves that turn brown with yellow halos. Scabby raised spots on fruit.',
    causes:
        'Caused by Xanthomonas species. Warm (75–86°F), wet weather with frequent rain drives infections.',
    spread:
        'Spread by rain, wind, tools, and infected transplants. Seed transmission is also possible.',
    prevention:
        'Use disease-free certified seed. Avoid working in wet fields. Rotate crops annually.',
    organicTreatment:
        'Copper-based bactericides (copper hydroxide or copper octanoate) applied every 5–7 days during wet weather.',
    chemicalTreatment:
        'Copper + Mancozeb tank mix. Streptomycin may be allowed in some regions — check local regulations.',
  ),
  'tomato early blight': DiseaseInfo(
    name: 'Early Blight (Tomato)',
    symptoms:
        'Brown target-board spots on lower, older leaves. Yellow halo surrounds lesions. Severe cases cause defoliation.',
    causes:
        'Caused by Alternaria solani. Stress (drought, over-fertilisation) increases susceptibility.',
    spread:
        'Airborne and rain-splash spores from infected soil and debris.',
    prevention:
        'Mulch to reduce soil splash. Stake plants for airflow. Rotate crops. Remove infected leaves early.',
    organicTreatment:
        'Copper fungicide or Bacillus subtilis every 7 days starting at first signs.',
    chemicalTreatment:
        'Chlorothalonil or Azoxystrobin applied every 7–14 days from transplant through fruit set.',
  ),
  'tomato late blight': DiseaseInfo(
    name: 'Late Blight (Tomato)',
    symptoms:
        'Large, greasy, grayish-green water-soaked areas on leaves. White mildew on leaf underside. Brown firm rot on fruit.',
    causes:
        'Phytophthora infestans. Cool nights (50–60°F) and warm, humid days create ideal conditions.',
    spread:
        'Spores spread rapidly by wind. Disease can wipe out a crop within a week under ideal conditions.',
    prevention:
        'Stake and prune plants for airflow. Avoid overhead irrigation. Do not compost infected plants.',
    organicTreatment:
        'Copper fungicide applied preventively every 5–7 days during cool, wet weather.',
    chemicalTreatment:
        'Metalaxyl/Mefenoxam, Cymoxanil, or Fluopicolide applied on a 5–7 day protective schedule.',
  ),
  'tomato leaf mold': DiseaseInfo(
    name: 'Leaf Mold (Tomato)',
    symptoms:
        'Pale greenish-yellow spots on upper leaf surface with olive-green to gray-brown velvety mould on underside.',
    causes:
        'Caused by Passalora fulva. Occurs in greenhouses or humid field conditions (>85% RH).',
    spread:
        'Airborne spores that thrive in high humidity and poor ventilation.',
    prevention:
        'Increase ventilation in greenhouses. Reduce humidity. Avoid wetting leaves.',
    organicTreatment:
        'Copper fungicide or sulfur sprays every 7 days when humidity is persistently high.',
    chemicalTreatment:
        'Chlorothalonil or Mancozeb applied every 7–10 days; ensure good coverage of leaf underside.',
  ),
  'tomato septoria leaf spot': DiseaseInfo(
    name: 'Septoria Leaf Spot (Tomato)',
    symptoms:
        'Numerous small circular spots with dark borders and light tan/gray centres on lower leaves. Small black dots visible inside spots.',
    causes:
        'Caused by Septoria lycopersici. Warm (60–80°F), wet weather with high humidity drives disease.',
    spread:
        'Rain splash from infected soil and plant debris. Spreads upward through the canopy.',
    prevention:
        'Mulch to reduce soil splash. Stake plants. Remove infected lower leaves immediately.',
    organicTreatment:
        'Copper fungicide applied at first sign; repeat every 7–10 days during wet weather.',
    chemicalTreatment:
        'Chlorothalonil or Mancozeb on a 7–10 day schedule; begin applications before disease appears in high-risk periods.',
  ),
  'tomato spider mites two spotted spider mite': DiseaseInfo(
    name: 'Spider Mites (Tomato)',
    symptoms:
        'Tiny yellow stippling on leaves. Fine webbing on leaf underside. Severe infestations cause leaves to bronze and drop.',
    causes:
        'Caused by Tetranychus urticae (two-spotted spider mite). Hot, dry conditions trigger rapid population explosions.',
    spread:
        'Mites move by crawling, wind, and contaminated tools or clothing.',
    prevention:
        'Maintain adequate soil moisture. Avoid dusty conditions. Encourage natural predators (ladybugs, predatory mites).',
    organicTreatment:
        'Neem oil, insecticidal soap, or predatory mite releases (Phytoseiulus persimilis). Strong water spray dislodges mites.',
    chemicalTreatment:
        'Abamectin or Bifenazate miticides. Rotate chemical classes to prevent resistance.',
  ),
  'tomato target spot': DiseaseInfo(
    name: 'Target Spot (Tomato)',
    symptoms:
        'Brown circular lesions with concentric ring patterns on leaves. Lesions may have a yellow halo. Fruit can also be infected.',
    causes:
        'Caused by Corynespora cassiicola. Favoured by warm, humid conditions.',
    spread:
        'Airborne spores from infected plant debris spread to new tissue during wet weather.',
    prevention:
        'Remove lower infected leaves. Avoid overhead irrigation. Improve canopy airflow.',
    organicTreatment:
        'Copper fungicide sprays applied every 7–10 days starting at first sign of disease.',
    chemicalTreatment:
        'Azoxystrobin or Boscalid + Pyraclostrobin applied every 7–14 days during high-risk conditions.',
  ),
  'tomato yellow leaf curl virus': DiseaseInfo(
    name: 'Yellow Leaf Curl Virus (Tomato)',
    symptoms:
        'Upward curling and yellowing of young leaves. Stunted plant growth. Flowers drop without setting fruit.',
    causes:
        'Tomato Yellow Leaf Curl Virus (TYLCV) transmitted by silverleaf whitefly (Bemisia tabaci).',
    spread:
        'Carried exclusively by whitefly vectors. No seed transmission. Spreads rapidly in warm climates.',
    prevention:
        'Use whitefly-resistant or TYLCV-tolerant varieties. Use reflective mulches to repel whiteflies. Install insect-proof nets.',
    organicTreatment:
        'Yellow sticky traps to monitor and reduce whitefly populations. Neem oil or insecticidal soap to manage whiteflies.',
    chemicalTreatment:
        'Imidacloprid or Thiamethoxam applied as soil drench at transplant to control whitefly vectors. No cure for infected plants — remove and destroy.',
  ),
  'tomato mosaic virus': DiseaseInfo(
    name: 'Mosaic Virus (Tomato)',
    symptoms:
        'Irregular light and dark green mosaic pattern on leaves. Leaves may be puckered or distorted. Stunted growth and reduced yield.',
    causes:
        'Tomato Mosaic Virus (ToMV) or Tobacco Mosaic Virus (TMV). Highly stable and persistent in soil and on surfaces.',
    spread:
        'Mechanically spread by hands, tools, clothing, and even smoke from tobacco products. No insect vector.',
    prevention:
        'Wash hands with soap before handling plants. Disinfect tools with bleach solution. Remove infected plants promptly.',
    organicTreatment:
        'No cure. Remove and bag infected plants immediately. Disinfect all tools and surfaces.',
    chemicalTreatment:
        'No effective chemical treatment. Prevention through hygiene is the only control.',
  ),
  'tomato healthy': DiseaseInfo(
    name: 'Healthy Tomato',
    symptoms: 'Deep green, firm leaves. Upright growth. No spots, curling, or discolouration.',
    causes: 'N/A',
    spread: 'N/A',
    prevention:
        'Consistent watering, good airflow, regular scouting, and stake/prune for open canopy.',
    organicTreatment: 'No treatment needed.',
    chemicalTreatment: 'No treatment needed.',
  ),
};

/// Fuzzy lookup — tries exact key, then partial match.
DiseaseInfo? lookupDisease(String rawName) {
  final key = rawName.trim().toLowerCase();
  if (kDiseaseKnowledge.containsKey(key)) {
    return kDiseaseKnowledge[key];
  }
  // Partial match fallback
  for (final entry in kDiseaseKnowledge.entries) {
    if (entry.key.contains(key) || key.contains(entry.key)) {
      return entry.value;
    }
  }
  return null;
}
