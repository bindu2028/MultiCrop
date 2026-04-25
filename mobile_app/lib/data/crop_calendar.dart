/// Static local crop calendar data.
library;

class SeasonTip {
  final String season;
  final String tip;
  const SeasonTip(this.season, this.tip);
}

class CropCalendarInfo {
  final String cropName;
  final String emoji;
  final List<String> sowingMonths;
  final List<String> harvestMonths;
  final String soilType;
  final String wateringFrequency;
  final String sunlight;
  final List<SeasonTip> seasonalTips;

  const CropCalendarInfo({
    required this.cropName,
    required this.emoji,
    required this.sowingMonths,
    required this.harvestMonths,
    required this.soilType,
    required this.wateringFrequency,
    required this.sunlight,
    required this.seasonalTips,
  });
}

const List<CropCalendarInfo> kCropCalendar = [
  CropCalendarInfo(
    cropName: 'Apple',
    emoji: '🍎',
    sowingMonths: ['Nov', 'Dec', 'Jan'],
    harvestMonths: ['Aug', 'Sep', 'Oct'],
    soilType: 'Loamy, well-drained, pH 6.0–7.0',
    wateringFrequency: 'Weekly deep watering during growing season; less in winter',
    sunlight: 'Full sun (6–8 hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Prune dormant trees in late winter. Apply dormant oil spray to control overwintering pests.'),
      SeasonTip('Spring', 'Monitor for scab and rust. Thin fruit clusters to 6-inch spacing after petal fall.'),
      SeasonTip('Summer', 'Maintain irrigation during dry spells. Watch for codling moth and fire blight.'),
      SeasonTip('Autumn', 'Harvest when fruit colours and separates easily. Remove mummified fruit and fallen leaves to reduce disease carry-over.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Bell Pepper',
    emoji: '🫑',
    sowingMonths: ['Feb', 'Mar', 'Apr'],
    harvestMonths: ['Jul', 'Aug', 'Sep'],
    soilType: 'Sandy loam, rich in organic matter, pH 6.0–6.8',
    wateringFrequency: 'Daily light watering; avoid waterlogging',
    sunlight: 'Full sun (8+ hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Start seeds indoors 8–10 weeks before last frost. Maintain soil temperature above 70°F for germination.'),
      SeasonTip('Spring', 'Transplant after last frost. Use plastic mulch to warm soil and conserve moisture.'),
      SeasonTip('Summer', 'Watch for aphids and bacterial spot during wet periods. Harvest green or allow to ripen red/yellow.'),
      SeasonTip('Autumn', 'Harvest all peppers before first frost. Pull and compost healthy plants; bag and dispose of diseased ones.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Cherry',
    emoji: '🍒',
    sowingMonths: ['Oct', 'Nov'],
    harvestMonths: ['May', 'Jun', 'Jul'],
    soilType: 'Well-drained loam to sandy loam, pH 6.0–7.5',
    wateringFrequency: 'Deep watering every 10–14 days; avoid standing water',
    sunlight: 'Full sun (6–8 hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Prune during dormancy to open the canopy for light and airflow.'),
      SeasonTip('Spring', 'Apply protective copper spray at green tip. Thin crop if heavy set threatens branch breakage.'),
      SeasonTip('Summer', 'Harvest at full colour. Use bird netting to protect ripening fruit.'),
      SeasonTip('Autumn', 'Remove fallen leaves to reduce powdery mildew and brown rot carry-over.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Corn / Maize',
    emoji: '🌽',
    sowingMonths: ['Apr', 'May', 'Jun'],
    harvestMonths: ['Aug', 'Sep', 'Oct'],
    soilType: 'Deep, well-drained loam, pH 5.8–6.8',
    wateringFrequency: '1 inch per week; critical at silking stage',
    sunlight: 'Full sun (8+ hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Till fields and incorporate corn residue to reduce inoculum levels for next season.'),
      SeasonTip('Spring', 'Plant when soil temperature reaches 50°F. Use treated seed with fungicide seed treatment to protect seedlings.'),
      SeasonTip('Summer', 'Scout for gray leaf spot and rust at tasseling. Apply foliar fungicide if warranted.'),
      SeasonTip('Autumn', 'Harvest at 25–30% grain moisture. Dry promptly to 15% for storage.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Grape',
    emoji: '🍇',
    sowingMonths: ['Feb', 'Mar'],
    harvestMonths: ['Aug', 'Sep', 'Oct'],
    soilType: 'Well-drained loamy or sandy soil, pH 5.5–6.5',
    wateringFrequency: 'Deep watering weekly; reduce in late summer to concentrate sugars',
    sunlight: 'Full sun (7–8 hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Prune vines aggressively during full dormancy to manage size and fruiting wood.'),
      SeasonTip('Spring', 'Apply copper spray at bud swell. Train new shoots to trellis. Scout for black rot and downy mildew.'),
      SeasonTip('Summer', 'Remove leaves around fruit clusters to improve air circulation and reduce disease. Monitor brix levels.'),
      SeasonTip('Autumn', 'Harvest based on sugar (brix) and flavour. Remove all mummified berries after harvest.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Peach',
    emoji: '🍑',
    sowingMonths: ['Oct', 'Nov'],
    harvestMonths: ['Jun', 'Jul', 'Aug'],
    soilType: 'Well-drained sandy loam, pH 6.0–6.5',
    wateringFrequency: 'Weekly deep watering; increase during fruit fill',
    sunlight: 'Full sun (8 hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Prune to open vase shape. Apply dormant copper spray to prevent bacterial spot and shot-hole.'),
      SeasonTip('Spring', 'Thin fruit to 4–6 inches apart at marble size to improve fruit quality.'),
      SeasonTip('Summer', 'Monitor for oriental fruit moth and bacterial spot. Harvest when background colour turns yellow.'),
      SeasonTip('Autumn', 'Clean up all fallen fruit and leaves to remove disease inoculum.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Potato',
    emoji: '🥔',
    sowingMonths: ['Mar', 'Apr', 'May'],
    harvestMonths: ['Jul', 'Aug', 'Sep'],
    soilType: 'Loose, well-drained sandy loam, pH 4.8–5.5',
    wateringFrequency: '1–2 inches per week; critical during tuber bulking',
    sunlight: 'Full sun (6–8 hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Source certified seed tubers. Cure them in a cool, dark location before planting.'),
      SeasonTip('Spring', 'Plant after last hard frost. Hill soil around stems as plants grow to protect tubers from greening.'),
      SeasonTip('Summer', 'Scout weekly for late blight — act immediately. Colorado potato beetle can defoliate plants quickly.'),
      SeasonTip('Autumn', 'Cure harvested potatoes at 50–60°F for 2 weeks before storing in cool dark conditions.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Strawberry',
    emoji: '🍓',
    sowingMonths: ['Mar', 'Apr'],
    harvestMonths: ['May', 'Jun', 'Jul'],
    soilType: 'Well-drained sandy loam, rich in organic matter, pH 5.5–6.5',
    wateringFrequency: '1–1.5 inches per week; drip irrigation preferred',
    sunlight: 'Full sun (6–8 hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Apply straw mulch over crowns after a hard freeze to prevent frost heaving.'),
      SeasonTip('Spring', 'Remove mulch as plants emerge. Apply row cover if late frost threatens blossoms.'),
      SeasonTip('Summer', 'Harvest every 2–3 days. Remove runners unless establishing new plants. Watch for botrytis gray mould.'),
      SeasonTip('Autumn', 'Renovate beds after harvest — mow foliage, narrow rows, and fertilise to stimulate new growth.'),
    ],
  ),
  CropCalendarInfo(
    cropName: 'Tomato',
    emoji: '🍅',
    sowingMonths: ['Mar', 'Apr', 'May'],
    harvestMonths: ['Jul', 'Aug', 'Sep', 'Oct'],
    soilType: 'Well-drained, fertile loam, pH 6.0–6.8',
    wateringFrequency: '1–2 inches per week; consistent and even',
    sunlight: 'Full sun (8 hours/day)',
    seasonalTips: [
      SeasonTip('Winter', 'Plan crop rotation. Order disease-resistant seed varieties. Prepare raised beds.'),
      SeasonTip('Spring', 'Transplant after last frost. Stake or cage immediately. Apply mulch to retain moisture and prevent splash.'),
      SeasonTip('Summer', 'Remove suckers for indeterminate varieties. Scout weekly for early/late blight, spider mites, and hornworms.'),
      SeasonTip('Autumn', 'Pick green tomatoes before first frost and ripen indoors. Remove and destroy all crop debris.'),
    ],
  ),
];

/// Find a crop by name (case-insensitive partial match).
CropCalendarInfo? lookupCropCalendar(String cropName) {
  final key = cropName.trim().toLowerCase();
  for (final crop in kCropCalendar) {
    if (crop.cropName.toLowerCase() == key || crop.cropName.toLowerCase().contains(key) || key.contains(crop.cropName.toLowerCase())) {
      return crop;
    }
  }
  return null;
}
