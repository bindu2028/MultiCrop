import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/molecular_3d_viewer.dart';
import '../services/compound_api.dart';
import '../data/herb_library_data.dart';

class CompoundDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const CompoundDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final pubchem = data['pubchem'] as Map<String, dynamic>?;
    final hasPubchem = pubchem != null;
    final hasKnowledge = data['found_in_knowledge_base'] == true;

    // Look up matching HerbItem
    final herb = kHerbLibraryData.firstWhere(
      (h) => h.activeCompounds.any((c) => c.toLowerCase() == data['name'].toString().toLowerCase()),
      orElse: () => const HerbItem(
        name: '',
        scientificName: '',
        emoji: '🌿',
        description: '',
        soilPh: 6.5,
        waterNeeds: 'Medium',
        sunExposure: 'Partial Shade',
        tempRange: '18°C - 28°C',
        harvestTime: '90 Days',
        geographicalRegion: 'Temperate Regions Globally',
        activeCompounds: [],
        traditionalRemedies: [],
      ),
    );

    // Let's refine fallback cultivation stats dynamically if herb name is empty
    HerbItem displayHerb = herb;
    if (herb.name.isEmpty) {
      final name = data['name'].toString().toLowerCase();
      if (name.contains('resveratrol')) {
        displayHerb = const HerbItem(
          name: 'Grape Skin',
          scientificName: 'Vitis vinifera',
          emoji: '🍇',
          description: '',
          soilPh: 6.5,
          waterNeeds: 'Medium',
          sunExposure: 'Full Sun',
          tempRange: '15°C - 28°C',
          harvestTime: '120 - 150 Days',
          geographicalRegion: 'Native to Mediterranean region',
          activeCompounds: [],
          traditionalRemedies: [],
        );
      } else if (name.contains('berberine')) {
        displayHerb = const HerbItem(
          name: 'Goldenseal / Barberry',
          scientificName: 'Hydrastis canadensis',
          emoji: '🌿',
          description: '',
          soilPh: 5.5,
          waterNeeds: 'High',
          sunExposure: 'Full Shade',
          tempRange: '10°C - 22°C',
          harvestTime: '3 - 5 Years',
          geographicalRegion: 'Native to Eastern North America',
          activeCompounds: [],
          traditionalRemedies: [],
        );
      } else if (name.contains('quercetin')) {
        displayHerb = const HerbItem(
          name: 'Capers / Red Onions',
          scientificName: 'Capparis spinosa',
          emoji: '🧅',
          description: '',
          soilPh: 7.0,
          waterNeeds: 'Low',
          sunExposure: 'Full Sun',
          tempRange: '18°C - 35°C',
          harvestTime: '90 - 120 Days',
          geographicalRegion: 'Native to Mediterranean region',
          activeCompounds: [],
          traditionalRemedies: [],
        );
      } else if (name.contains('lycopene')) {
        displayHerb = const HerbItem(
          name: 'Tomatoes',
          scientificName: 'Solanum lycopersicum',
          emoji: '🍅',
          description: '',
          soilPh: 6.5,
          waterNeeds: 'Medium',
          sunExposure: 'Full Sun',
          tempRange: '21°C - 29°C',
          harvestTime: '60 - 80 Days',
          geographicalRegion: 'Native to South America',
          activeCompounds: [],
          traditionalRemedies: [],
        );
      } else if (name.contains('lovastatin')) {
        displayHerb = const HerbItem(
          name: 'Oyster Mushrooms',
          scientificName: 'Pleurotus ostreatus',
          emoji: '🍄',
          description: '',
          soilPh: 6.5,
          waterNeeds: 'Medium',
          sunExposure: 'Full Shade',
          tempRange: '15°C - 20°C',
          harvestTime: '20 - 30 Days',
          geographicalRegion: 'Native to Temperate Regions Globally',
          activeCompounds: [],
          traditionalRemedies: [],
        );
      }
    }

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Times New Roman',
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            data['name'].toString().toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _shareCompound(context),
              tooltip: 'Share Compound Summary',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Header Card (Class & Tags)
            if (hasKnowledge) _buildHeaderCard(context),

            const SizedBox(height: 16),

            // 2. Overview (Traditional Use)
            if (hasKnowledge && data['traditional_use'] != null)
              _buildSectionCard(
                title: 'Overview',
                icon: Icons.lightbulb_outline,
                backgroundColor: const Color(0xFFFFF8E1), // Light amber
                content: Text(
                  data['traditional_use'],
                  style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF4E342E)),
                ),
              ),

            const SizedBox(height: 16),

            // 3. Technical Description (Expandable)
            if (data['description'] != null)
              _buildExpandableDescription(data['description']),

            const SizedBox(height: 16),

            // 4. Structure Image (3D or 2D)
            if (hasPubchem && pubchem['cid'] != null && data['render_3d'] == true)
              _build3DImageCard(pubchem['cid'])
            else if (data['structure_image'] != null)
              _buildImageCard(isTooComplex: data['render_3d'] == false),

            const SizedBox(height: 16),

            // 5. Source Organisms
            if (hasKnowledge && data['source_organisms'] != null)
              _buildSourceCard(context),

            const SizedBox(height: 16),

            // 5.5. Habitat & Cultivation Matrix
            if (hasKnowledge)
              _buildCultivationMatrix(context, displayHerb),

            const SizedBox(height: 16),

            // 6. Medicinal Remedy & Safety Guide
            if (hasKnowledge && data['medicinal_remedy'] != null)
              _buildRemedyCard(context),

            const SizedBox(height: 16),

            // 7. Chemical Properties
            if (hasPubchem) _buildPropertiesCard(context, pubchem),

            const SizedBox(height: 16),

            // 8. SMILES
            if (hasPubchem && (pubchem['canonical_smiles'] != null || pubchem['isomeric_smiles'] != null))
              _buildSmilesCard(context, pubchem['canonical_smiles'] ?? pubchem['isomeric_smiles']),

            const SizedBox(height: 16),

            // 9. Synonyms
            if (data['synonyms'] != null && (data['synonyms'] as List).isNotEmpty)
              _buildSynonymsCard(context, data['synonyms'] as List),
              
            const SizedBox(height: 16),

            // 9.5. Academic & Research Portals
            _buildAcademicSearchCard(context),

            const SizedBox(height: 16),
              
            // 10. Similar Compounds
            if (data['similar_compounds'] != null && (data['similar_compounds'] as List).isNotEmpty)
              _buildSimilarCompoundsList(context, data['similar_compounds'] as List),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      color: const Color(0xFFF0F4F8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD1E3F8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['compound_class'] ?? 'Natural Compound',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (data['source_type'] != null)
                  Chip(
                    label: Text(data['source_type'].toString().toUpperCase()),
                    backgroundColor: const Color(0xFFE3F2FD),
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                    side: BorderSide.none,
                  ),
                if (data['bioactivity'] != null)
                  ...(data['bioactivity'] as List).map((b) => Chip(
                        label: Text(b.toString()),
                        backgroundColor: Colors.white,
                        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                      )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard({bool isTooComplex = false}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.image_outlined, size: 20, color: Color(0xFF616161)),
                SizedBox(width: 8),
                Text('Molecular Structure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            if (isTooComplex) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE65100)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Structure too complex for mobile 3D rendering to prevent battery drain. Showing 2D model.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Image.network(
                  data['structure_image'],
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 100,
                    child: Center(child: Text('Image not available')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DImageCard(int cid) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.threed_rotation, size: 20, color: Color(0xFF616161)),
                SizedBox(width: 8),
                Text('3D Molecular Structure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Molecular3DViewer(cid: cid),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(String description) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.science, color: Color(0xFF616161)),
        title: const Text('Technical Description (PubChem)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            description,
            style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF616161)),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(BuildContext context) {
    final sources = data['source_organisms'] as List;
    return _buildSectionCard(
      title: 'Source Organisms',
      icon: Icons.eco_outlined,
      backgroundColor: const Color(0xFFE1F5FE), // Light green tint
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sources
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18, color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                      Expanded(child: Text(s.toString(), style: const TextStyle(fontSize: 14, color: Color(0xFF1565C0)))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRemedyCard(BuildContext context) {
    final rem = data['medicinal_remedy'] as Map<String, dynamic>;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services_outlined, size: 20, color: Color(0xFF424242)),
                SizedBox(width: 8),
                Text('Medicinal Remedy & Safety Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            
            // 1. Primary Use
            _buildRemedyField('Primary Application', rem['primary_use'] ?? 'N/A', Colors.indigo.shade800),
            
            // 2. Conditions Treated as Chips
            if (rem['conditions_treated'] != null) ...[
              const SizedBox(height: 12),
              const Text('Conditions Addressed', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (rem['conditions_treated'] as List).map((c) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC5CAE9)),
                  ),
                  child: Text(c.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            ],
            
            // 3. How Used / Dosage
            if (rem['how_used'] != null) ...[
              const SizedBox(height: 16),
              const Text('Safe Usage & Dosage Guidance', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rem['how_used'],
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1565C0), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Research Notes
            if (rem['research_notes'] != null) ...[
              const SizedBox(height: 16),
              _buildRemedyField('Scientific Insights', rem['research_notes'], Colors.black87),
            ],
            
            // 5. Caution / Drug Interactions (Alert Banner)
            if (rem['caution'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFE65100)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DRUG INTERACTIONS & CAUTION',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rem['caution'],
                            style: const TextStyle(fontSize: 13, color: Color(0xFFBF360C), height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemedyField(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: textColor, height: 1.4, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _shareCompound(BuildContext context) {
    final name = data['name'].toString().toUpperCase();
    final clazz = data['compound_class'] ?? 'Natural Compound';
    final sourceList = data['source_organisms'] != null
        ? (data['source_organisms'] as List).join('\n• ')
        : 'N/A';
    final remedy = data['medicinal_remedy'] as Map<String, dynamic>?;
    final primaryUse = remedy != null ? remedy['primary_use'] : 'N/A';
    final caution = remedy != null ? remedy['caution'] : null;

    final summary = '🌿 NATURAL COMPOUND PROFILE: $name\n'
        '🧪 Class: $clazz\n'
        '🌱 Source Organisms:\n• $sourceList\n\n'
        '🩺 Primary Use: $primaryUse\n'
        '${caution != null ? "⚠️ Caution: $caution\n" : ""}'
        '🔬 Decoded using Compound Encyclopedia';

    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formatted Compound Summary copied to clipboard!'),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildAcademicSearchCard(BuildContext context) {
    final pubchem = data['pubchem'] as Map<String, dynamic>?;
    final cid = pubchem != null ? pubchem['cid'] : null;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 20, color: Color(0xFF424242)),
                SizedBox(width: 8),
                Text('Academic & Research Portals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Quickly search global scientific databases for detailed chemical studies, journals, and clinical trials:',
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSearchChip(
                  context, 
                  'PubMed', 
                  'https://pubmed.ncbi.nlm.nih.gov/?term=${Uri.encodeComponent(data['name'])}',
                  Colors.blue.shade50,
                  Colors.blue.shade800,
                ),
                _buildSearchChip(
                  context, 
                  'Google Scholar', 
                  'https://scholar.google.com/scholar?q=${Uri.encodeComponent(data['name'])}',
                  Colors.orange.shade50,
                  Colors.orange.shade900,
                ),
                _buildSearchChip(
                  context, 
                  'PubChem Portal', 
                  cid != null 
                      ? 'https://pubchem.ncbi.nlm.nih.gov/compound/$cid' 
                      : 'https://pubchem.ncbi.nlm.nih.gov/#query=${Uri.encodeComponent(data['name'])}',
                  Colors.teal.shade50,
                  Colors.teal.shade800,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(BuildContext context, String label, String url, Color bgColor, Color textColor) {
    return ActionChip(
      label: Text(label),
      backgroundColor: bgColor,
      labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      side: BorderSide(color: textColor.withValues(alpha: 0.2)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppWebViewScreen(title: label, url: url),
          ),
        );
      },
    );
  }

  Widget _buildPropertiesCard(BuildContext context, Map<String, dynamic> pubchem) {
    return _buildSectionCard(
      title: 'Chemical Properties',
      icon: Icons.science_outlined,
      backgroundColor: const Color(0xFFF3E5F5), // Light purple/blue tint
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Formula', pubchem['molecular_formula'] ?? 'N/A'),
          _buildInfoRow('Weight', '${pubchem['molecular_weight'] ?? 'N/A'} g/mol'),
          _buildInfoRow('PubChem CID', pubchem['cid']?.toString() ?? 'N/A'),
          _buildInfoRow('InChIKey', pubchem['inchikey'] ?? 'N/A'),
          if (pubchem['iupac_name'] != null)
            _buildInfoRow('IUPAC', pubchem['iupac_name']),
        ],
      ),
    );
  }

  Widget _buildSmilesCard(BuildContext context, String smiles) {
    return _buildSectionCard(
      title: 'SMILES',
      icon: Icons.link,
      backgroundColor: const Color(0xFFFAFAFA),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              smiles,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF424242)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20, color: Color(0xFF1565C0)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: smiles));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SMILES copied to clipboard')),
              );
            },
            tooltip: 'Copy SMILES',
          ),
        ],
      ),
    );
  }

  Widget _buildSynonymsCard(BuildContext context, List<dynamic> synonyms) {
    return _buildSectionCard(
      title: 'Also Known As',
      icon: Icons.label_outline,
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: synonyms.take(15).map((s) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE), // Soft light blue
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              s.toString(), 
              style: const TextStyle(fontSize: 12, color: Color(0xFF0277BD), fontWeight: FontWeight.w500)
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget content, Color backgroundColor = Colors.white}) {
    return Card(
      elevation: 1,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF424242)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarCompoundsList(BuildContext context, List<dynamic> similar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.hub, size: 20, color: Color(0xFF424242)),
            SizedBox(width: 8),
            Text('Structurally Similar Compounds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            itemBuilder: (context, index) {
              final comp = similar[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      // Navigate to this compound
                      final name = comp['name'] as String;
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (c) => const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        final result = await CompoundApi.getCompoundFull(name);
                        Navigator.pop(context); // hide loading
                        if (result != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CompoundDetailScreen(data: result)),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load compound')));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.science, color: Color(0xFF1976D2), size: 24),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            comp['name'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 13,
                              color: Color(0xFF1565C0)
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCultivationMatrix(BuildContext context, HerbItem herb) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD1E3F8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.terrain_outlined, size: 20, color: Color(0xFF1976D2)),
                SizedBox(width: 8),
                Text(
                  'Habitat & Cultivation Matrix',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1565C0)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildMatrixColumn(
                    icon: Icons.science_outlined,
                    label: 'Soil pH Range',
                    value: '${herb.soilPh} pH',
                    color: const Color(0xFF00838F),
                  ),
                ),
                Expanded(
                  child: _buildMatrixColumn(
                    icon: Icons.water_drop_outlined,
                    label: 'Water Needs',
                    value: herb.waterNeeds,
                    color: const Color(0xFF1565C0),
                  ),
                ),
                Expanded(
                  child: _buildMatrixColumn(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Sun Exposure',
                    value: herb.sunExposure,
                    color: const Color(0xFFFF8F00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.thermostat_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Temp: ${herb.tempRange}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.hourglass_empty_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Cycle: ${herb.harvestTime}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, color: Color(0xFF1565C0), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      herb.geographicalRegion,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF1565C0))),
      ],
    );
  }
}

class AppWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const AppWebViewScreen({super.key, required this.title, required this.url});

  @override
  State<AppWebViewScreen> createState() => _AppWebViewScreenState();
}

class _AppWebViewScreenState extends State<AppWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
