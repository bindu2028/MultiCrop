import 'package:flutter/material.dart';
import '../models/diary_model.dart';
import '../services/diary_service.dart';

class DiaryDetailScreen extends StatefulWidget {
  final PlantTracker plant;

  const DiaryDetailScreen({super.key, required this.plant});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final DiaryService _diaryService = DiaryService();
  late PlantTracker _plant;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }

  Future<void> _refreshPlant() async {
    final plants = await _diaryService.getPlants();
    final updated = plants.where((p) => p.id == _plant.id).firstOrNull;
    if (updated != null && mounted) {
      setState(() => _plant = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.plantName, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete Plant?'),
                  content: const Text('Are you sure you want to remove this plant and all its logs?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await _diaryService.deletePlant(_plant.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plant.logs.length,
        itemBuilder: (context, index) {
          final log = _plant.logs[index];
          return _TimelineTile(log: log, isLast: index == _plant.logs.length - 1);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C7C44),
        foregroundColor: Colors.white,
        onPressed: _showAddLogSheet,
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }

  void _showAddLogSheet() {
    String action = 'Note';
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Add new log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Note', icon: Icon(Icons.notes)),
                      ButtonSegment(value: 'Watered', icon: Icon(Icons.water_drop_outlined)),
                      ButtonSegment(value: 'Fertilized', icon: Icon(Icons.science_outlined)),
                    ],
                    selected: {action},
                    onSelectionChanged: (val) => setModalState(() => action = val.first),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final newLog = DiaryLog(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: DateTime.now(),
                        note: noteCtrl.text.trim(),
                        actionType: action,
                      );
                      await _diaryService.addLogToPlant(_plant.id, newLog);
                      if (context.mounted) Navigator.pop(context);
                      _refreshPlant();
                    },
                    child: const Text('Save Log'),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final DiaryLog log;
  final bool isLast;

  const _TimelineTile({required this.log, required this.isLast});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (log.actionType) {
      case 'Watered':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'Fertilized':
        icon = Icons.science;
        color = Colors.purple;
        break;
      case 'Started':
        icon = Icons.flag;
        color = Colors.green;
        break;
      default:
        icon = Icons.edit_note;
        color = Colors.grey.shade700;
    }

    final dateStr = '${log.date.day.toString().padLeft(2, '0')}/${log.date.month.toString().padLeft(2, '0')}/${log.date.year}';
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.actionType, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (log.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(log.note),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
