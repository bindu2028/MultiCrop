import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/molecular_3d_viewer.dart';
import '../services/compound_api.dart';
import 'compound_screen.dart';

class CompoundDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const CompoundDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final pubchem = data['pubchem'] as Map<String, dynamic>?;
    final hasPubchem = pubchem != null;
    final hasKnowledge = data['found_in_knowledge_base'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'].toString().toUpperCase()),
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

          // 6. Medicinal Remedy
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
            
          // 10. Similar Compounds
          if (data['similar_compounds'] != null && (data['similar_compounds'] as List).isNotEmpty)
            _buildSimilarCompoundsList(context, data['similar_compounds'] as List),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      color: const Color(0xFFF0F7F2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFC8E6C9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['compound_class'] ?? 'Natural Compound',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
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
                    backgroundColor: const Color(0xFFE8F5E9),
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
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
      backgroundColor: const Color(0xFFF1F8E9), // Light green tint
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sources
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18, color: Color(0xFF388E3C), fontWeight: FontWeight.bold)),
                      Expanded(child: Text(s.toString(), style: const TextStyle(fontSize: 14, color: Color(0xFF1B5E20)))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRemedyCard(BuildContext context) {
    final rem = data['medicinal_remedy'] as Map<String, dynamic>;
    return _buildSectionCard(
      title: 'Medicinal Remedy',
      icon: Icons.medical_services_outlined,
      backgroundColor: const Color(0xFFE8EAF6), // Light indigo tint
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Primary Use', rem['primary_use']),
          if (rem['conditions_treated'] != null)
            _buildInfoRow('Conditions', (rem['conditions_treated'] as List).join(', ')),
          _buildInfoRow('How Used', rem['how_used']),
          if (rem['research_notes'] != null)
            _buildInfoRow('Research', rem['research_notes']),
          if (rem['caution'] != null) ...[
            const SizedBox(height: 12),
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
                    child: Text(
                      'Caution: ${rem['caution']}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFBF360C), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
            icon: const Icon(Icons.copy, size: 20, color: Color(0xFF1B5E20)),
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
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.science, color: Color(0xFF2E7D32), size: 24),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            comp['name'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 13,
                              color: Color(0xFF1B5E20)
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
}

