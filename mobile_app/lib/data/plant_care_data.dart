/// Static local knowledge base for plant care tips.
/// Covers all 9 model crops with care summaries, common mistakes,
/// pro tips, companion plants, and pest watch info.
library;

class CareSummary {
  final String water;
  final String sunlight;
  final String soil;
  final String temperature;
  final String humidity;
  final String fertilizer;

  const CareSummary({
    required this.water,
    required this.sunlight,
    required this.soil,
    required this.temperature,
    required this.humidity,
    required this.fertilizer,
  });
}

class PestInfo {
  final String name;
  final String signs;
  final String solution;

  const PestInfo({
    required this.name,
    required this.signs,
    required this.solution,
  });
}

class PlantCareInfo {
  final String cropName;
  final String emoji;
  final String cropKey;
  final CareSummary care;
  final List<String> commonMistakes;
  final List<String> proTips;
  final List<String> companionPlants;
  final List<PestInfo> pestWatch;

  const PlantCareInfo({
    required this.cropName,
    required this.emoji,
    required this.cropKey,
    required this.care,
    required this.commonMistakes,
    required this.proTips,
    required this.companionPlants,
    required this.pestWatch,
  });
}

const List<PlantCareInfo> kPlantCareData = [
  // ── APPLE ──────────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Apple',
    emoji: '🍎',
    cropKey: 'apple',
    care: CareSummary(
      water: 'Deep water weekly during growing season; 1–2 inches per week. Reduce in winter dormancy.',
      sunlight: 'Full sun — at least 6–8 hours of direct sunlight daily for best fruit production.',
      soil: 'Well-drained loamy soil with pH 6.0–7.0. Avoid heavy clay that retains too much moisture.',
      temperature: 'Thrives in 60–75°F (15–24°C). Requires 500–1000 chill hours below 45°F for fruiting.',
      humidity: 'Moderate humidity. High humidity increases risk of apple scab and fire blight.',
      fertilizer: 'Apply balanced 10-10-10 fertilizer in early spring. Avoid late-season nitrogen to prevent soft growth.',
    ),
    commonMistakes: [
      'Skipping dormant pruning — leads to dense canopy, poor airflow, and increased disease.',
      'Overwatering in autumn — prevents trees from entering dormancy properly and weakens roots.',
      'Not thinning fruit — too many apples per cluster results in small, poor-quality fruit.',
      'Planting a single variety — most apples need a different variety nearby for cross-pollination.',
    ],
    proTips: [
      'Paint tree trunks with diluted white latex paint to prevent sunscald and borer damage in winter.',
      'Hang red sphere traps coated in sticky adhesive to monitor and trap apple maggot flies.',
      'Apply a 3–4 inch mulch ring around the base (not touching the trunk) to retain moisture and suppress weeds.',
      'Prune to an open-center shape to maximize sunlight penetration and improve fruit colour.',
    ],
    companionPlants: [
      'Clover — fixes nitrogen and attracts beneficial pollinators',
      'Nasturtium — repels aphids and codling moths',
      'Chives — deters apple scab with natural sulfur compounds',
      'Comfrey — deep roots mine minerals and make excellent mulch',
    ],
    pestWatch: [
      PestInfo(
        name: 'Codling Moth',
        signs: 'Small entry holes in fruit with frass (sawdust-like droppings). Worms inside apples.',
        solution: 'Hang pheromone traps. Apply kaolin clay spray. Time insecticide at peak moth flight.',
      ),
      PestInfo(
        name: 'Aphids',
        signs: 'Curled, sticky leaves with clusters of tiny green/black insects on new growth.',
        solution: 'Encourage ladybugs and lacewings. Spray with insecticidal soap or neem oil.',
      ),
      PestInfo(
        name: 'Apple Maggot',
        signs: 'Dimpled fruit surface with brown trails inside flesh. Premature fruit drop.',
        solution: 'Red sticky sphere traps. Pick up fallen fruit immediately. Apply spinosad at petal fall.',
      ),
    ],
  ),

  // ── BELL PEPPER ────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Bell Pepper',
    emoji: '🫑',
    cropKey: 'bell_pepper',
    care: CareSummary(
      water: '1–2 inches per week. Keep soil consistently moist but never waterlogged. Use drip irrigation.',
      sunlight: 'Full sun — 8+ hours of direct sunlight daily. Heat-loving crop.',
      soil: 'Sandy loam rich in organic matter, pH 6.0–6.8. Add compost before planting.',
      temperature: 'Optimal 70–85°F (21–29°C). Will not set fruit below 60°F or above 90°F.',
      humidity: 'Moderate to high. Low humidity causes blossom drop; high humidity invites bacterial diseases.',
      fertilizer: 'Use low-nitrogen fertilizer after first fruit set. Too much nitrogen = leafy plant, no peppers.',
    ),
    commonMistakes: [
      'Transplanting too early — cold soil stunts growth. Wait until soil is consistently above 65°F.',
      'Over-fertilizing with nitrogen — produces lush foliage but very few fruit.',
      'Irregular watering — causes blossom end rot (calcium uptake issue) and cracked fruit.',
      'Not hardening off seedlings — transplant shock kills or sets back plants for weeks.',
    ],
    proTips: [
      'Pinch off early blossoms until the plant is 12+ inches tall to encourage stronger root development.',
      'Use black plastic mulch to warm soil and conserve moisture — peppers love warm roots.',
      'Harvest the first few peppers while green to signal the plant to produce more fruit.',
      'Epsom salt foliar spray (1 tbsp per gallon) provides magnesium and improves fruit set.',
    ],
    companionPlants: [
      'Basil — repels aphids, spider mites, and improves flavour',
      'Carrots — loosen soil and don\'t compete for nutrients',
      'Spinach — provides living mulch and shade for roots',
      'Marigold — repels nematodes and whiteflies',
    ],
    pestWatch: [
      PestInfo(
        name: 'Aphids',
        signs: 'Clusters on leaf undersides, sticky honeydew, distorted new growth.',
        solution: 'Blast with water. Apply insecticidal soap. Introduce ladybugs.',
      ),
      PestInfo(
        name: 'Pepper Hornworm',
        signs: 'Large caterpillars on stems, rapid defoliation, dark droppings.',
        solution: 'Hand-pick at dusk. Apply Bacillus thuringiensis (Bt) spray.',
      ),
      PestInfo(
        name: 'Whiteflies',
        signs: 'Tiny white insects flying when leaves are disturbed. Yellow sticky leaves.',
        solution: 'Yellow sticky traps. Neem oil spray. Encourage parasitic wasps.',
      ),
    ],
  ),

  // ── CHERRY ─────────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Cherry',
    emoji: '🍒',
    cropKey: 'cherry',
    care: CareSummary(
      water: 'Deep water every 10–14 days. Avoid standing water — cherries hate wet feet.',
      sunlight: 'Full sun — 6–8 hours daily. Afternoon shade is acceptable in very hot climates.',
      soil: 'Well-drained loam to sandy loam, pH 6.0–7.5. Raised beds help in heavy soil.',
      temperature: 'Best at 60–75°F (15–24°C). Needs 700–1000 chill hours for proper dormancy break.',
      humidity: 'Low to moderate preferred. High humidity promotes powdery mildew and brown rot.',
      fertilizer: 'Light feeder — apply low-nitrogen fertilizer in early spring. Excess nitrogen reduces fruit quality.',
    ),
    commonMistakes: [
      'Overwatering — cherry trees are very prone to root rot in soggy soil.',
      'Pruning in wet weather — opens wounds for bacterial canker infection. Prune only when dry.',
      'Not protecting fruit from birds — unnetted trees lose 50%+ of ripe cherries to birds.',
      'Ignoring brown rot — mummified fruit left on the tree spreads the disease next season.',
    ],
    proTips: [
      'Install bird netting 2–3 weeks before harvest when fruit starts changing colour.',
      'Train young trees to an open-vase or modified-central-leader shape for best light exposure.',
      'Apply copper spray at leaf fall and again at bud swell to prevent bacterial canker.',
      'Water deeply but infrequently — this encourages deep root growth and drought tolerance.',
    ],
    companionPlants: [
      'Alliums (garlic/chives) — repel borers and aphids',
      'Marigold — deters nematodes in the root zone',
      'Clover — living mulch that fixes nitrogen',
      'Tansy — repels flying insects and fruit flies',
    ],
    pestWatch: [
      PestInfo(
        name: 'Cherry Fruit Fly',
        signs: 'Small larvae inside ripe cherries. Sunken, dimpled spots on fruit.',
        solution: 'Yellow sticky traps. Apply spinosad spray when flies are first detected.',
      ),
      PestInfo(
        name: 'Black Cherry Aphid',
        signs: 'Tightly curled leaves at branch tips, black sticky residue.',
        solution: 'Dormant oil spray in late winter. Insecticidal soap during the season.',
      ),
      PestInfo(
        name: 'Brown Rot',
        signs: 'Fuzzy tan/brown mould on ripening fruit. Mummified fruit on branches.',
        solution: 'Remove mummies promptly. Apply fungicide at bloom and pre-harvest.',
      ),
    ],
  ),

  // ── CORN / MAIZE ───────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Corn / Maize',
    emoji: '🌽',
    cropKey: 'corn_maize',
    care: CareSummary(
      water: '1 inch per week minimum. Critical during silking/tasseling — drought here means empty ears.',
      sunlight: 'Full sun — 8+ hours daily. Corn is a C4 plant that thrives in strong light.',
      soil: 'Deep, well-drained loam, pH 5.8–6.8. Heavy nitrogen feeder — amend with compost.',
      temperature: 'Plant when soil is 50°F+. Optimal growth at 77–91°F (25–33°C).',
      humidity: 'Moderate. Extended leaf wetness promotes gray leaf spot and other foliar diseases.',
      fertilizer: 'Side-dress with nitrogen at V6 (knee-high) stage. Corn is a very heavy nitrogen feeder.',
    ),
    commonMistakes: [
      'Planting in a single row — corn is wind-pollinated and needs block planting (4+ rows) for full ears.',
      'Planting too early in cold soil — seeds rot instead of germinating. Wait for 50°F soil.',
      'Skipping nitrogen side-dressing — corn starves mid-season, producing small, half-filled ears.',
      'Not scouting for corn earworm — larvae enter through silk and destroy kernels unseen.',
    ],
    proTips: [
      'Plant in blocks of at least 4 rows for wind pollination — not in single long rows.',
      'Apply mineral oil to silk tips 3–5 days after silk appears to suffocate corn earworm eggs.',
      'Succession plant every 2 weeks for continuous harvest through the summer.',
      'Use the "Three Sisters" method: plant corn with beans (nitrogen) and squash (living mulch).',
    ],
    companionPlants: [
      'Beans — fix nitrogen that corn needs in abundance',
      'Squash — large leaves shade out weeds and retain moisture',
      'Sunflowers — attract pollinators and beneficial insects',
      'Peas — another nitrogen fixer that works well near corn',
    ],
    pestWatch: [
      PestInfo(
        name: 'Corn Earworm',
        signs: 'Larvae boring into ear tips through silk. Frass and damaged kernels.',
        solution: 'Apply mineral oil to silks. Use Bt spray. Plant early to avoid peak populations.',
      ),
      PestInfo(
        name: 'European Corn Borer',
        signs: 'Broken tassels, holes in stalks, sawdust-like frass at entry points.',
        solution: 'Release Trichogramma wasps for biological control. Apply Bt at egg hatch.',
      ),
      PestInfo(
        name: 'Armyworm',
        signs: 'Ragged, chewed leaves — damage progresses from whorl outward. Caterpillars feed at night.',
        solution: 'Scout at dawn/dusk. Apply Bt or spinosad when larvae are small.',
      ),
    ],
  ),

  // ── GRAPE ──────────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Grape',
    emoji: '🍇',
    cropKey: 'grape',
    care: CareSummary(
      water: 'Deep water weekly. Reduce in late summer to concentrate sugars before harvest.',
      sunlight: 'Full sun — 7–8 hours daily. South-facing slopes ideal for warmth and drainage.',
      soil: 'Well-drained loamy or sandy soil, pH 5.5–6.5. Rocky soils often produce the best grapes.',
      temperature: 'Grows best at 60–90°F (15–32°C). Needs 150+ frost-free days per season.',
      humidity: 'Low humidity preferred. High humidity promotes downy mildew, powdery mildew, and black rot.',
      fertilizer: 'Light feeder — apply compost in spring. Avoid excess nitrogen which promotes foliage over fruit.',
    ),
    commonMistakes: [
      'Over-fertilizing — excess nitrogen creates vigorous vines with small, poor-quality fruit clusters.',
      'Not pruning enough — grapes fruit on new wood; unpruned vines become tangled and unproductive.',
      'Leaving mummified berries — these harbor black rot fungus and reinfect vines next season.',
      'Poor trellis support — heavy fruit loads can snap untrained vines and reduce yield.',
    ],
    proTips: [
      'Remove leaves around fruit clusters after fruit set to improve airflow and sun exposure.',
      'Test sugar content (brix) with a refractometer — harvest table grapes at 16–20 brix.',
      'Prune aggressively in winter dormancy — remove 80–90% of last year\'s growth.',
      'Use reflective mulch under vines to bounce light up to fruit clusters for even ripening.',
    ],
    companionPlants: [
      'Clover — living mulch, nitrogen fixation, and pollinator attractant',
      'Hyssop — repels flea beetles and attracts beneficial insects',
      'Geranium — repels leafhoppers (major grape pest)',
      'Mustard — acts as a biofumigant cover crop between rows',
    ],
    pestWatch: [
      PestInfo(
        name: 'Grape Berry Moth',
        signs: 'Webbed berries with larvae feeding inside. Premature fruit drop.',
        solution: 'Pheromone traps for monitoring. Apply insecticide at 2nd generation flight.',
      ),
      PestInfo(
        name: 'Japanese Beetles',
        signs: 'Skeletonized leaves — beetles eat tissue between veins, leaving lace-like pattern.',
        solution: 'Hand-pick into soapy water. Apply milky spore to lawn for grub control.',
      ),
      PestInfo(
        name: 'Grape Leafhopper',
        signs: 'Tiny hoppers on leaf undersides. White stippling and premature leaf drop.',
        solution: 'Encourage parasitic wasps. Apply kaolin clay or insecticidal soap.',
      ),
    ],
  ),

  // ── PEACH ──────────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Peach',
    emoji: '🍑',
    cropKey: 'peach',
    care: CareSummary(
      water: 'Weekly deep watering. Increase during fruit fill stage (final 4–6 weeks before harvest).',
      sunlight: 'Full sun — 8 hours daily minimum. Peaches need maximum heat for sweet fruit.',
      soil: 'Well-drained sandy loam, pH 6.0–6.5. Avoid heavy clay soils completely.',
      temperature: 'Optimal 75–85°F (24–29°C). Needs 600–900 chill hours below 45°F for fruit set.',
      humidity: 'Low to moderate. High humidity promotes bacterial spot and brown rot.',
      fertilizer: 'Apply 10-10-10 in early spring. Add extra nitrogen if tree growth is slow (<12 inches/year).',
    ),
    commonMistakes: [
      'Not thinning fruit — overloaded branches break and fruit is small and tasteless.',
      'Skipping dormant copper spray — bacterial spot is nearly impossible to control once started.',
      'Planting in low spots — cold air settles in valleys and kills blossoms during late frosts.',
      'Ignoring peach leaf curl — must spray copper in autumn BEFORE leaves drop for prevention.',
    ],
    proTips: [
      'Thin fruit to 4–6 inch spacing when they reach marble size — this is critical for large, sweet peaches.',
      'Apply copper fungicide at leaf fall AND again at bud swell for double protection against leaf curl.',
      'Train to an open vase shape with 3–4 main scaffold branches for maximum sunlight and airflow.',
      'Harvest when the background colour changes from green to yellow — even if the blush isn\'t full.',
    ],
    companionPlants: [
      'Garlic — repels borers and discourages aphids',
      'Tansy — repels peach tree borers and flying pests',
      'Strawberries — low ground cover that doesn\'t compete for light',
      'Basil — repels flies and improves the orchard microclimate',
    ],
    pestWatch: [
      PestInfo(
        name: 'Peach Tree Borer',
        signs: 'Gummy sap oozing from trunk base. Sawdust frass near soil line.',
        solution: 'Apply beneficial nematodes to soil around trunk. Use pheromone traps.',
      ),
      PestInfo(
        name: 'Oriental Fruit Moth',
        signs: 'Wilted shoot tips (flagging). Larvae boring into fruit near the pit.',
        solution: 'Mating disruption with pheromone ties. Apply insecticide at petal fall.',
      ),
      PestInfo(
        name: 'Plum Curculio',
        signs: 'Crescent-shaped scars on fruit. Premature fruit drop with larvae inside.',
        solution: 'Spread a tarp and shake branches at dawn to collect beetles. Apply kaolin clay.',
      ),
    ],
  ),

  // ── POTATO ─────────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Potato',
    emoji: '🥔',
    cropKey: 'potato',
    care: CareSummary(
      water: '1–2 inches per week. Critical during tuber bulking (flowering stage). Avoid overhead watering.',
      sunlight: 'Full sun — 6–8 hours daily. Tubers that get sunlight turn green and toxic.',
      soil: 'Loose, well-drained sandy loam, pH 4.8–5.5. Acidic soil reduces scab risk.',
      temperature: 'Plant when soil is 45°F+. Tubers form best at 60–70°F (15–21°C). Halt above 85°F.',
      humidity: 'Moderate. Excessive humidity with cool temps creates ideal conditions for late blight.',
      fertilizer: 'Apply 5-10-10 at planting. Potatoes need more phosphorus and potassium than nitrogen.',
    ),
    commonMistakes: [
      'Not hilling soil — exposed tubers turn green from sunlight and become toxic (solanine).',
      'Using grocery store potatoes — they may carry disease and aren\'t certified virus-free.',
      'Overwatering after vine die-back — causes tuber rot in the ground. Stop watering when vines yellow.',
      'Growing in the same spot yearly — builds up soil-borne diseases like scab and verticillium.',
    ],
    proTips: [
      'Hill soil 6–8 inches around stems when plants are 8 inches tall — repeat 2–3 times as they grow.',
      'Plant in containers or grow bags for easy harvesting and disease-free soil each year.',
      'Wait 2 weeks after vine die-back to harvest — this toughens skins for better storage.',
      'Cure potatoes at 50–60°F and 85% humidity for 10–14 days before long-term storage.',
    ],
    companionPlants: [
      'Horseradish — repels Colorado potato beetles (plant at row ends)',
      'Beans — fix nitrogen and don\'t compete with potatoes',
      'Marigold — repels nematodes and beetles',
      'Corn — tall corn provides partial shade in hot climates',
    ],
    pestWatch: [
      PestInfo(
        name: 'Colorado Potato Beetle',
        signs: 'Yellow-orange striped adults and red larvae. Rapid defoliation from leaf margins.',
        solution: 'Hand-pick beetles and crush orange egg masses. Apply Bt var. tenebrionis or spinosad.',
      ),
      PestInfo(
        name: 'Wireworms',
        signs: 'Narrow tunnels bored through tubers. Thin, hard, yellow-brown larvae in soil.',
        solution: 'Set bait traps (potato halves buried on sticks). Rotate crops. Beneficial nematodes.',
      ),
      PestInfo(
        name: 'Flea Beetles',
        signs: 'Tiny round "shot holes" in leaves. Adults are small, shiny, and jump when disturbed.',
        solution: 'Row covers over young plants. Apply kaolin clay. Neem oil spray.',
      ),
    ],
  ),

  // ── STRAWBERRY ─────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Strawberry',
    emoji: '🍓',
    cropKey: 'strawberry',
    care: CareSummary(
      water: '1–1.5 inches per week. Drip irrigation strongly preferred to keep leaves dry.',
      sunlight: 'Full sun — 6–8 hours daily. Morning sun helps dry dew and reduces disease.',
      soil: 'Well-drained sandy loam, rich in organic matter, pH 5.5–6.5.',
      temperature: 'Fruiting best at 60–80°F (15–27°C). Protect blossoms from late spring frosts.',
      humidity: 'Low to moderate. High humidity with wet leaves promotes botrytis gray mould.',
      fertilizer: 'Apply balanced fertilizer at planting and again after first harvest. Avoid excess nitrogen during fruiting.',
    ),
    commonMistakes: [
      'Planting too deep — the crown must be at soil level. Buried crowns rot; exposed roots dry out.',
      'Not removing runners — runners divert energy from fruit production in the first year.',
      'Overhead watering — wet foliage invites gray mould (botrytis), the #1 strawberry disease.',
      'Letting fruit touch bare soil — causes rot and slug damage. Use straw or plastic mulch.',
    ],
    proTips: [
      'Pinch off all flowers in the first year for June-bearing varieties — this doubles next year\'s harvest.',
      'Use straw mulch around plants to keep fruit clean, retain moisture, and suppress weeds.',
      'Renovate beds immediately after harvest — mow tops, thin rows to 6 inches, and fertilize.',
      'Cover plants with row covers when frost is forecast to protect spring blossoms.',
    ],
    companionPlants: [
      'Borage — attracts pollinators and may improve strawberry flavour and yield',
      'Thyme — low ground cover that repels worms',
      'Lettuce — shade-tolerant companion that uses space between rows',
      'Onion — deters slugs and other pests with strong scent',
    ],
    pestWatch: [
      PestInfo(
        name: 'Slugs & Snails',
        signs: 'Irregular holes in fruit. Slime trails on leaves and soil surface.',
        solution: 'Beer traps. Iron phosphate bait (safe for pets). Copper tape around beds.',
      ),
      PestInfo(
        name: 'Spider Mites',
        signs: 'Stippled, bronzed leaves. Fine webbing on leaf undersides in hot, dry weather.',
        solution: 'Spray with strong water. Release predatory mites. Apply miticides if severe.',
      ),
      PestInfo(
        name: 'Strawberry Bud Weevil',
        signs: 'Flower buds hanging by a thread — females clip stems after laying eggs inside.',
        solution: 'Hand-pick adults at dawn. Apply pyrethrin spray before bloom.',
      ),
    ],
  ),

  // ── TOMATO ─────────────────────────────────────────────────────────────
  PlantCareInfo(
    cropName: 'Tomato',
    emoji: '🍅',
    cropKey: 'tomato',
    care: CareSummary(
      water: '1–2 inches per week, consistently. Water at the base — never on leaves. Morning watering is best.',
      sunlight: 'Full sun — 8 hours daily minimum. More sun = sweeter tomatoes.',
      soil: 'Well-drained, fertile loam, pH 6.0–6.8. Amend with compost and aged manure.',
      temperature: 'Optimal 70–85°F (21–29°C). Won\'t set fruit below 55°F or above 95°F.',
      humidity: 'Moderate. High humidity promotes every major tomato disease (blight, mold, spot).',
      fertilizer: 'Low nitrogen, high phosphorus at transplant (5-10-10). Switch to balanced feed after first fruit set.',
    ),
    commonMistakes: [
      'Inconsistent watering — causes blossom end rot and fruit cracking, the two most common complaints.',
      'Not removing suckers on indeterminate varieties — creates a jungle with small, late-ripening fruit.',
      'Planting too close together — poor airflow is the #1 cause of foliar diseases.',
      'Over-fertilizing with nitrogen — produces a giant bush with few tomatoes.',
    ],
    proTips: [
      'Bury the stem up to the top 2 leaf sets when transplanting — buried stems grow extra roots for a stronger plant.',
      'Prune suckers below the first fruit cluster for indeterminate types to focus energy on fruit.',
      'Apply 3–4 inches of mulch after soil warms to prevent soil splash (reduces early blight by 50%+).',
      'Add crushed eggshells to the planting hole — slow-release calcium prevents blossom end rot.',
    ],
    companionPlants: [
      'Basil — improves flavour and repels aphids, hornworms, and whiteflies',
      'Marigold — repels root-knot nematodes and whiteflies',
      'Carrots — loosen soil and attract beneficial wasps',
      'Parsley — attracts hoverflies that eat aphids',
    ],
    pestWatch: [
      PestInfo(
        name: 'Tomato Hornworm',
        signs: 'Large green caterpillar with white V-shaped marks. Rapid defoliation overnight.',
        solution: 'Hand-pick (check leaf undersides). Leave parasitized hornworms (white cocoons on body).',
      ),
      PestInfo(
        name: 'Whiteflies',
        signs: 'Tiny white moths on leaf undersides. Yellow sticky leaves, sooty mould.',
        solution: 'Yellow sticky traps. Neem oil. Encourage Encarsia formosa parasitic wasps.',
      ),
      PestInfo(
        name: 'Spider Mites',
        signs: 'Stippled yellow leaves. Fine webbing in hot, dry weather. Leaves bronze and drop.',
        solution: 'Strong water spray. Predatory mites (Phytoseiulus persimilis). Neem oil.',
      ),
    ],
  ),
];

/// Lookup plant care data by crop key (case-insensitive).
PlantCareInfo? lookupPlantCare(String cropKey) {
  final key = cropKey.trim().toLowerCase();
  for (final crop in kPlantCareData) {
    if (crop.cropKey.toLowerCase() == key ||
        crop.cropName.toLowerCase() == key ||
        crop.cropName.toLowerCase().contains(key) ||
        key.contains(crop.cropKey.toLowerCase())) {
      return crop;
    }
  }
  return null;
}
