import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/growth_diary_entry.dart';
import '../services/growth_diary_service.dart';

class GrowthDiaryScreen extends StatefulWidget {
  const GrowthDiaryScreen({super.key});

  @override
  State<GrowthDiaryScreen> createState() => _GrowthDiaryScreenState();
}

class _GrowthDiaryScreenState extends State<GrowthDiaryScreen> {
  final _service = GrowthDiaryService();
  late Future<List<GrowthDiaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _service.loadEntries();
  }

  Future<void> _refresh() async {
    setState(() {
      _entriesFuture = _service.loadEntries();
    });
  }

  Future<void> _openAddEntrySheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _AddDiaryEntrySheet(),
    );

    if (created == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Diary'),
        actions: [
          IconButton(
            tooltip: 'Add entry',
            onPressed: _openAddEntrySheet,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<GrowthDiaryEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_outlined, size: 48, color: Color(0xFF5A8D5C)),
                    const SizedBox(height: 12),
                    const Text(
                      'No diary entries yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add notes and photos after each treatment to compare plant progress over time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF647265)),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _openAddEntrySheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Create first entry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DiaryImagePreview(base64Image: entry.imageBase64),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.crop.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(entry.observation),
                              if (entry.disease != null && entry.disease!.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Disease: ${entry.disease}',
                                  style: const TextStyle(color: Color(0xFF5C7362), fontWeight: FontWeight.w600),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                _formatTimestamp(entry.createdAt),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF778278)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntrySheet,
        backgroundColor: const Color(0xFF66B051),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Add entry'),
      ),
    );
  }

  String _formatTimestamp(DateTime value) {
    final local = value.toLocal();
    final date = '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$date, $hour:$minute $suffix';
  }
}

class _DiaryImagePreview extends StatelessWidget {
  final String? base64Image;

  const _DiaryImagePreview({required this.base64Image});

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeImage(base64Image);

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5EE),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? const Icon(Icons.image_outlined, color: Color(0xFF8DA393))
          : Image.memory(bytes, fit: BoxFit.cover),
    );
  }

  Uint8List? _decodeImage(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return null;
    }
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }
}

class _AddDiaryEntrySheet extends StatefulWidget {
  const _AddDiaryEntrySheet();

  @override
  State<_AddDiaryEntrySheet> createState() => _AddDiaryEntrySheetState();
}

class _AddDiaryEntrySheetState extends State<_AddDiaryEntrySheet> {
  final _service = GrowthDiaryService();
  final _picker = ImagePicker();
  final _cropController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _observationController = TextEditingController();

  String? _imageBase64;
  bool _saving = false;

  @override
  void dispose() {
    _cropController.dispose();
    _diseaseController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _save() async {
    final crop = _cropController.text.trim().toLowerCase();
    final disease = _diseaseController.text.trim();
    final observation = _observationController.text.trim();

    if (crop.isEmpty || observation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter crop and observation.')),
      );
      return;
    }

    setState(() => _saving = true);
    await _service.addEntry(
      GrowthDiaryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        crop: crop,
        observation: observation,
        disease: disease.isEmpty ? null : disease,
        imageBase64: _imageBase64,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add diary entry',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cropController,
              decoration: const InputDecoration(labelText: 'Crop (e.g. tomato)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _diseaseController,
              decoration: const InputDecoration(labelText: 'Disease (optional)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _observationController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Observation',
                hintText: 'What changed today? Any improvement after treatment?',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            if (_imageBase64 != null) ...[
              const SizedBox(height: 10),
              const Text(
                'Image attached',
                style: TextStyle(color: Color(0xFF4F6254), fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
