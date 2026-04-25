class LocalExpertService {
  /// Provides professional, structured advice for a disease if the AI is unavailable.
  static String getQuickAdvice(String crop, String disease) {
    final Map<String, Map<String, String>> database = {
      'apple': {
        'scab': 'Prune affected branches to improve airflow. Use sulfur-based fungicides early in the season. Dispose of fallen leaves immediately.',
        'cedar_apple_rust': 'Remove nearby juniper plants (the alternate host). Apply fungicides in late spring when galls release spores.',
        'black_rot': 'Remove all mummified fruit from trees. Prune out cankers during the dormant season. Keep the orchard floor clean.'
      },
      'bell_pepper': {
        'bacterial_spot': 'Always use certified disease-free seeds. Avoid overhead irrigation to stop bacteria-laden water splashes. Apply copper-based fungicides if symptoms persist.',
      },
      'cherry': {
        'powdery_mildew': 'Ensure trees are in full sun. Prune for better light penetration. Use neem oil or potassium bicarbonate as an organic treatment.',
      },
      'corn': {
        'common_rust': 'Plant resistant hybrids. Fungicides are rarely needed unless the infection is severe on young plants. Improve soil drainage.',
        'northern_leaf_blight': 'Rotate crops with non-grass species. Manage crop residue from previous years to reduce inoculum levels.',
      },
      'grape': {
        'black_rot': 'Critical: Destroy all diseased berries and prunings. Maintain a strict fungicide schedule from bloom until berries reach 10% sugar.',
        'leaf_blight': 'Improve canopy management to reduce humidity. Remove late-season infected leaves.',
      },
      'peach': {
        'bacterial_spot': 'Choose resistant cultivars like "Contender". Apply copper sprays during late dormancy and again after harvest.',
      },
      'potato': {
        'early_blight': 'Maintain plant vigor with balanced fertilization. Rotate with legumes. Apply protectant fungicides before rainy periods.',
        'late_blight': 'Urgent: Remove and destroy all infected plants. Do not compost! This disease spreads rapidly in wet weather. Use metalaxyl-based sprays.',
      },
      'strawberry': {
        'leaf_scorch': 'Avoid excessive nitrogen in spring. Renew plantings every 3 years. Use drip irrigation instead of sprinklers.',
      },
      'tomato': {
        'bacterial_spot': 'Do not work in the field when plants are wet. Copper-mancozeb sprays can provide moderate control. Rotate with corn or wheat.',
        'early_blight': 'Mulch the base of plants to prevent soil splashback. Stake plants for better airflow. Remove lower leaves showing spots.',
        'late_blight': 'Monitor daily in humid weather. Preventive bio-fungicides can help, but severe outbreaks require immediate plant removal.',
        'leaf_mold': 'Common in greenhouses—improve ventilation. Lower the humidity below 85%. Use resistant varieties.',
        'septoria_leaf_spot': 'Similar to early blight: mulch and avoid overhead watering. This pathogen survives on weed hosts; keep the area weed-free.',
        'yellow_leaf_curl_virus': 'This is spread by Whiteflies. Use reflective mulches to repel them. Remove infected plants immediately to prevent spread to neighbors.',
        'mosaic_virus': 'Extremely contagious! Wash hands with soap after touching infected plants. Do not smoke near plants (Tobacco Mosaic Virus).',
      }
    };

    final cropData = database[crop.toLowerCase()];
    if (cropData != null) {
      final advice = cropData[disease.toLowerCase().replaceAll(' ', '_')];
      if (advice != null) {
        return 'Expert Insight (Local Fallback): $advice \n\nNote: I am providing this verified local advice while my advanced AI brain is momentarily busy with high demand. I will be back to conversational mode soon!';
      }
    }

    return 'Elite Tip: For $disease on $crop, focusing on moisture control and immediate removal of infected foliage is the best first step. I am currently experiencing high demand in my AI engine, but please try again in a few minutes for a deeper analysis!';
  }
}
