import 'package:flutter/material.dart';
import '../services/compound_api.dart';

class PubChemCard extends StatelessWidget {
  final Map<String, dynamic> pubchem;

  const PubChemCard({required this.pubchem});

  @override
  Widget build(BuildContext context) {
    final p = pubchem['pubchem'] as Map<String, dynamic>?;
    if (p == null) {
      return const Text('No PubChem data available');
    }
    final props = p['properties'] as Map<String, dynamic>?;
    final syns = (p['synonyms'] as List?)?.cast<String>() ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CID: ${p['cid']}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('SMILES', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            SelectableText(props?['smiles'] ?? 'N/A', style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 8),
            Text('Molecular weight: ${props?['molecular_weight'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Synonyms (${syns.length}):', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: syns.take(10).map((s) => Chip(label: Text(s))).toList()),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final payload = {
                    'query': pubchem['alias']?['query'] ?? pubchem['pubchem']?['cid']?.toString(),
                    'smiles': props?['smiles'],
                    'synonyms': syns,
                    'local_compound_id': null,
                  };
                  final res = await CompoundApi.saveAlias(payload);
                  if (res != null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved mapping')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save mapping')));
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save mapping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
