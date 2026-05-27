enum InteractionSeverity {
  highRisk,    // Red
  caution,     // Yellow
  synergistic  // Green
}

class InteractionItem {
  final String herbName;
  final String medicationName;
  final InteractionSeverity severity;
  final String title;
  final String description;
  final String safetyAdvice;

  const InteractionItem({
    required this.herbName,
    required this.medicationName,
    required this.severity,
    required this.title,
    required this.description,
    required this.safetyAdvice,
  });
}

// Curated list of typical synthetic medications to choose from
const List<String> kSyntheticMedications = [
  'Aspirin (NSAID)',
  'Warfarin (Blood Thinner)',
  'Antibiotics (e.g. Macrolides)',
  'Liver-Metabolized Meds (Statins)',
  'Insulin / Diabetes Meds',
  'Immunosuppressants',
];

const List<InteractionItem> kInteractionData = [
  InteractionItem(
    herbName: 'Turmeric',
    medicationName: 'Warfarin (Blood Thinner)',
    severity: InteractionSeverity.highRisk,
    title: 'Severe Bleeding Risk',
    description: 'Curcumin possesses natural antiplatelet properties. When combined with prescription blood thinners like Warfarin, it can significantly amplify the thinning effect, dangerously raising the risk of internal bleeding.',
    safetyAdvice: 'Avoid therapeutic doses of Turmeric supplements if you are on Warfarin or other anticoagulants. Speak to your doctor before consuming more than culinary amounts.',
  ),
  InteractionItem(
    herbName: 'Turmeric',
    medicationName: 'Aspirin (NSAID)',
    severity: InteractionSeverity.caution,
    title: 'Increased Bruising & Gastric Sensitivity',
    description: 'Turmeric and Aspirin both reduce blood clotting. Taking them together in high doses can lead to easy bruising, nosebleeds, and mild gastric discomfort.',
    safetyAdvice: 'Monitor for bruising or black stools. Avoid taking concentrated curcumin extracts concurrently with daily low-dose Aspirin unless supervised by a physician.',
  ),
  InteractionItem(
    herbName: 'Willow Bark',
    medicationName: 'Aspirin (NSAID)',
    severity: InteractionSeverity.highRisk,
    title: 'Doubled Salicylate Toxicity',
    description: 'Willow Bark contains salicin, which converts to salicylic acid (the direct natural precursor of Aspirin) in the body. Combining it with standard Aspirin leads to a double dose of salicylate, heavily stressing the stomach lining and kidneys.',
    safetyAdvice: 'NEVER take Willow Bark while taking Aspirin or other NSAIDs (Ibuprofen, Naproxen). It can cause stomach ulcers, nausea, or acute renal strain.',
  ),
  InteractionItem(
    herbName: 'Willow Bark',
    medicationName: 'Warfarin (Blood Thinner)',
    severity: InteractionSeverity.highRisk,
    title: 'Dangerous Hemorrhage Warning',
    description: 'The natural salicylates in Willow Bark thin the blood. Combining this with a strong anticoagulant like Warfarin poses a severe risk of spontaneous bleeding and hemorrhage.',
    safetyAdvice: 'Avoid Willow Bark completely if you are taking any prescription blood thinners. Use alternative remedies for fever or pain relief.',
  ),
  InteractionItem(
    herbName: 'Ginger',
    medicationName: 'Warfarin (Blood Thinner)',
    severity: InteractionSeverity.caution,
    title: 'Moderate Anticoagulation Enhancement',
    description: 'Ginger contains active gingerols that can mildly inhibit blood clotting. While safer than Turmeric, high medicinal amounts can enhance the effects of Warfarin.',
    safetyAdvice: 'Culinary ginger in food is completely safe. Avoid large concentrated ginger root extracts, capsules, or strong ginger shots while on Warfarin.',
  ),
  InteractionItem(
    herbName: 'Chili Pepper',
    medicationName: 'Aspirin (NSAID)',
    severity: InteractionSeverity.caution,
    title: 'Gastrointestinal Coating Strain',
    description: 'Capsaicin increases gastric acid secretion. Taking high doses of capsaicin supplements along with Aspirin can exacerbate stomach irritation and gastric lining erosion.',
    safetyAdvice: 'Limit heavy chili consumption or capsaicin pills if taking daily Aspirin. Always take Aspirin with food to protect your stomach.',
  ),
  InteractionItem(
    herbName: 'Peppermint',
    medicationName: 'Liver-Metabolized Meds (Statins)',
    severity: InteractionSeverity.caution,
    title: 'Slightly Altered Drug Metabolism',
    description: 'Peppermint oil can inhibit certain liver enzymes (CYP3A4) that break down statins (like Lipitor or Lovastatin), slightly raising the concentration of the drug in your body.',
    safetyAdvice: 'Avoid drinking multiple cups of strong peppermint tea or taking enteric-coated peppermint oil pills at the exact same time as your statin medication.',
  ),
  InteractionItem(
    herbName: 'Green Tea',
    medicationName: 'Warfarin (Blood Thinner)',
    severity: InteractionSeverity.caution,
    title: 'Antagonist Vitamin K Interaction',
    description: 'Green Tea contains trace amounts of Vitamin K, which naturally promotes blood clotting. This directly opposes and decreases the therapeutic effectiveness of the blood thinner Warfarin.',
    safetyAdvice: 'Keep your daily green tea intake consistent. Sudden increases in green tea consumption can throw off your INR blood clotting tests.',
  ),
  InteractionItem(
    herbName: 'Green Tea',
    medicationName: 'Aspirin (NSAID)',
    severity: InteractionSeverity.synergistic,
    title: 'Enhanced Cardio Protection (Synergy)',
    description: 'Low-dose green tea antioxidants (EGCG) work synergistically with low-dose Aspirin to reduce arterial inflammation and improve arterial lining elasticity without extra stomach bleeding risk.',
    safetyAdvice: 'A moderate cup of green tea daily complements an Aspirin regimen beautifully for cardiac health. Maintain a balanced diet.',
  ),
  InteractionItem(
    herbName: 'Oyster Mushroom',
    medicationName: 'Liver-Metabolized Meds (Statins)',
    severity: InteractionSeverity.caution,
    title: 'Cumulative HMG-CoA Reductase Block',
    description: 'Oyster Mushrooms contain natural lovastatin. Taking them in large dietary amounts alongside prescription statins creates an additive effect, increasing the chance of statin side effects like muscle soreness.',
    safetyAdvice: 'If you are taking prescription statins, eat oyster mushrooms in moderate culinary amounts. Inform your doctor if you experience muscle aches.',
  ),
  InteractionItem(
    herbName: 'Oyster Mushroom',
    medicationName: 'Insulin / Diabetes Meds',
    severity: InteractionSeverity.synergistic,
    title: 'Supportive Glycemic Control (Synergy)',
    description: 'Oyster Mushrooms contain high beta-glucan fibers that improve insulin sensitivity and slow sugar absorption, helping naturally stabilize blood sugar levels alongside standard diabetic medications.',
    safetyAdvice: 'Highly recommended culinary addition for diabetic diets. Monitor your blood glucose levels as you may see improved stability!',
  ),
  InteractionItem(
    herbName: 'Sweet Wormwood',
    medicationName: 'Liver-Metabolized Meds (Statins)',
    severity: InteractionSeverity.caution,
    title: 'Moderate Liver Enzyme Competition',
    description: 'Artemisinin in Sweet Wormwood is metabolized by liver enzymes CYP2B6 and CYP3A4. Taking it alongside statins can compete for clearance, increasing drug levels.',
    safetyAdvice: 'Avoid wormwood extracts during active statin regimens. Do not take wormwood for longer than 2 consecutive weeks.',
  ),
];

// Helper extension or class to quickly look up interactions
class InteractionLookup {
  static InteractionItem? find(String herbName, String medicationName) {
    for (final item in kInteractionData) {
      if (item.herbName.toLowerCase() == herbName.toLowerCase() &&
          item.medicationName.toLowerCase() == medicationName.toLowerCase()) {
        return item;
      }
    }
    return null;
  }
}
