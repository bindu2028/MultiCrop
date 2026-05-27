class HerbItem {
  final String name;
  final String scientificName;
  final String emoji;
  final String description;
  final double soilPh; // e.g., 6.5
  final String waterNeeds; // Low, Medium, High
  final String sunExposure; // Full Sun, Partial Shade, Full Shade
  final String tempRange; // e.g., "18°C - 35°C"
  final String harvestTime; // e.g., "90 - 120 Days"
  final String geographicalRegion;
  final List<String> activeCompounds; // Maps to keys in COMPOUND_KNOWLEDGE
  final List<String> traditionalRemedies;

  const HerbItem({
    required this.name,
    required this.scientificName,
    required this.emoji,
    required this.description,
    required this.soilPh,
    required this.waterNeeds,
    required this.sunExposure,
    required this.tempRange,
    required this.harvestTime,
    required this.geographicalRegion,
    required this.activeCompounds,
    required this.traditionalRemedies,
  });
}

const List<HerbItem> kHerbLibraryData = [
  HerbItem(
    name: 'Turmeric',
    scientificName: 'Curcuma longa',
    emoji: '🌿',
    description: 'A vibrant golden rhizome famous for its incredible anti-inflammatory and cellular healing properties.',
    soilPh: 6.2,
    waterNeeds: 'Medium',
    sunExposure: 'Partial Shade',
    tempRange: '20°C - 30°C',
    harvestTime: '240 - 270 Days',
    geographicalRegion: 'Native to Southern Asia (India)',
    activeCompounds: ['Curcumin'],
    traditionalRemedies: [
      'Golden Milk: Warm milk mixed with 1/2 tsp turmeric powder and black pepper to boost absorption by 2000%.',
      'Healing Paste: Ground turmeric mixed with a small amount of water or honey applied topically to minor cuts.'
    ],
  ),
  HerbItem(
    name: 'Ginger',
    scientificName: 'Zingiber officinale',
    emoji: '🥔',
    description: 'A pungent, warming root spice used globally to soothe digestion, reduce nausea, and relieve cold symptoms.',
    soilPh: 6.0,
    waterNeeds: 'Medium',
    sunExposure: 'Partial Shade',
    tempRange: '22°C - 35°C',
    harvestTime: '240 - 300 Days',
    geographicalRegion: 'Native to Maritime Southeast Asia',
    activeCompounds: ['Gingerol'],
    traditionalRemedies: [
      'Ginger Tea: Sliced fresh ginger root simmered in boiling water for 10 minutes to soothe stomach upset.',
      'Inhalation: Sliced ginger in hot steaming water to clear sinus congestion.'
    ],
  ),
  HerbItem(
    name: 'Willow Bark',
    scientificName: 'Salix alba',
    emoji: '🌳',
    description: 'Nature\'s original aspirin, harvested from willow trees and consumed for thousands of years to treat fevers and aches.',
    soilPh: 6.8,
    waterNeeds: 'High',
    sunExposure: 'Full Sun',
    tempRange: '5°C - 25°C',
    harvestTime: 'Spring Harvest',
    geographicalRegion: 'Native to Europe and Western Asia',
    activeCompounds: ['Aspirin'],
    traditionalRemedies: [
      'Bark Decoction: 1-2 tsp of dried willow bark simmered in water for 15 minutes, strained and consumed for headaches.',
      'Compress: Strained decoction cooled and applied via clean cloth to swollen joints.'
    ],
  ),
  HerbItem(
    name: 'Chili Pepper',
    scientificName: 'Capsicum annuum',
    emoji: '🌶️',
    description: 'A spicy pod containing heat compounds that deplete pain-signaling chemicals in the nervous system.',
    soilPh: 6.5,
    waterNeeds: 'Medium',
    sunExposure: 'Full Sun',
    tempRange: '18°C - 32°C',
    harvestTime: '70 - 90 Days',
    geographicalRegion: 'Native to Southern North America',
    activeCompounds: ['Capsaicin'],
    traditionalRemedies: [
      'Analgesic Salve: Infusing dried cayenne powder in warm coconut oil to create a rub for arthritis relief.',
      'Sore Throat Gargle: A tiny pinch of cayenne in warm honey water to numb throat pain.'
    ],
  ),
  HerbItem(
    name: 'Peppermint',
    scientificName: 'Mentha piperita',
    emoji: '🍃',
    description: 'A cooling, aromatic leaf that acts as a natural muscle relaxant, antispasmodic, and respiratory aid.',
    soilPh: 6.5,
    waterNeeds: 'High',
    sunExposure: 'Partial Shade',
    tempRange: '15°C - 25°C',
    harvestTime: '80 - 90 Days',
    geographicalRegion: 'Native to Europe and Middle East',
    activeCompounds: ['Menthol'],
    traditionalRemedies: [
      'Peppermint Infusion: Fresh crushed mint leaves steeped in warm water to relieve bloating and gas.',
      'Direct Oil Rub: Diluted oil applied to temples to relieve tension headaches.'
    ],
  ),
  HerbItem(
    name: 'Green Tea',
    scientificName: 'Camellia sinensis',
    emoji: '🍵',
    description: 'A rich source of antioxidants and thermogenics that gently stimulates the central nervous system and promotes cellular health.',
    soilPh: 5.5,
    waterNeeds: 'Medium',
    sunExposure: 'Full Sun',
    tempRange: '13°C - 30°C',
    harvestTime: '3 - 4 Years',
    geographicalRegion: 'Native to East and Southeast Asia',
    activeCompounds: ['Caffeine'],
    traditionalRemedies: [
      'Concentrated Brew: Steeping high-quality leaves at 80°C for 3 minutes to improve physical alertness and metabolism.',
      'Eye Compress: Chilled used tea bags applied to eyes to reduce puffiness.'
    ],
  ),
  HerbItem(
    name: 'Oyster Mushroom',
    scientificName: 'Pleurotus ostreatus',
    emoji: '🍄',
    description: 'A fan-shaped edible fungus that contains natural cholesterol-regulating compounds and boosts immune health.',
    soilPh: 6.5,
    waterNeeds: 'Medium',
    sunExposure: 'Full Shade',
    tempRange: '15°C - 20°C',
    harvestTime: '20 - 30 Days',
    geographicalRegion: 'Native to temperate regions globally',
    activeCompounds: ['Lovastatin'],
    traditionalRemedies: [
      'Dietary Integration: Regularly adding sautéed oyster mushrooms to meals to support cardiovascular and lipid health.',
      'Mushroom Broth: Dried mushrooms simmered with herbs to create a nutrient-dense immune-supporting stock.'
    ],
  ),
  HerbItem(
    name: 'Opium Poppy',
    scientificName: 'Papaver somniferum',
    emoji: '🌺',
    description: 'A beautiful flower containing powerful alkaloids used for clinical pain relief and surgical anesthesia.',
    soilPh: 6.8,
    waterNeeds: 'Medium',
    sunExposure: 'Full Sun',
    tempRange: '15°C - 25°C',
    harvestTime: '120 - 140 Days',
    geographicalRegion: 'Native to Mediterranean and Western Asia',
    activeCompounds: ['Morphine'],
    traditionalRemedies: [
      'Caution Note: Opium poppy contains highly addictive alkaloids; traditional teas are extremely high-risk and dangerous without clinical standardization.'
    ],
  ),
  HerbItem(
    name: 'Tomatoes',
    scientificName: 'Solanum lycopersicum',
    emoji: '🍅',
    description: 'A common garden crop loaded with powerful carotenoids that protect the prostate, heart, and skin from oxidation.',
    soilPh: 6.5,
    waterNeeds: 'Medium',
    sunExposure: 'Full Sun',
    tempRange: '21°C - 29°C',
    harvestTime: '60 - 80 Days',
    geographicalRegion: 'Native to Western South America',
    activeCompounds: ['Lycopene'],
    traditionalRemedies: [
      'Cooked Paste: Simmering tomatoes with olive oil to unlock and concentrate lycopene for maximum body absorption.',
      'Skin Relief: Sliced raw tomato rubbed on mild sunburn to cool and soothe skin.'
    ],
  ),
  HerbItem(
    name: 'Sweet Wormwood',
    scientificName: 'Artemisia annua',
    emoji: '🌿',
    description: 'A highly aromatic shrub containing potent therapeutic compounds used to combat malaria and parasitic infections.',
    soilPh: 6.0,
    waterNeeds: 'Medium',
    sunExposure: 'Full Sun',
    tempRange: '18°C - 28°C',
    harvestTime: '150 - 180 Days',
    geographicalRegion: 'Native to Temperate Asia',
    activeCompounds: ['Artemisinin'],
    traditionalRemedies: [
      'Cold Infusion: Steeping dried leaves in cold water overnight to treat fevers and digestive parasites.'
    ],
  ),
];
