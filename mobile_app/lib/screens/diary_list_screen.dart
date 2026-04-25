import 'package:flutter/material.dart';
import '../models/diary_model.dart';
import '../services/diary_service.dart';
import 'diary_detail_screen.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final DiaryService _diaryService = DiaryService();
  late Future<List<PlantTracker>> _plantsFuture;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  void _loadPlants() {
    setState(() {
      _plantsFuture = _diaryService.getPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Diary', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: FutureBuilder<List<PlantTracker>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data ?? [];

          if (plants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.park_outlined, size: 80, color: Colors.green.shade200),
                  const SizedBox(height: 16),
                  const Text('No plants tracked yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Add a plant to start your growth diary!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F5E2),
                    child: const Icon(Icons.eco, color: Color(0xFF377F4A)),
                  ),
                  title: Text(plant.plantName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  subtitle: Text('${plant.crop} • ${plant.logs.length} logs'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DiaryDetailScreen(plant: plant)),
                    );
                    _loadPlants();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1C7C44),
        foregroundColor: Colors.white,
        onPressed: _showAddPlantDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Plant'),
      ),
    );
  }

  void _showAddPlantDialog() {
    final nameCtrl = TextEditingController();
    String selectedCrop = 'Tomato'; // default

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Plant'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nickname (e.g. Backyard Tomato)'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCrop,
                    decoration: const InputDecoration(labelText: 'Crop Type'),
                    items: const [
                      'Apple', 'Bell Pepper', 'Cherry', 'Corn', 'Grape', 'Peach', 'Potato', 'Strawberry', 'Tomato'
                    ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCrop = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      await _diaryService.addPlant(nameCtrl.text.trim(), selectedCrop);
                      if (context.mounted) Navigator.pop(context);
                      _loadPlants();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
