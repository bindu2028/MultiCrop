import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scan_history_item.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/notification_service.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  final String? initialCrop;

  const ScanScreen({super.key, this.initialCrop});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _api = ApiService();
  final _historyService = HistoryService();
  final _picker = ImagePicker();

  static const List<String> _fallbackCrops = [
    'tomato',
    'apple',
    'potato',
    'grape',
    'corn_maize',
  ];

  Uint8List? _imageBytes;
  String? _imageName;
  List<String> _crops = const [];
  String? _selectedCrop;
  bool _apiHealthy = false;
  bool _loadingCrops = true;
  bool _predicting = false;
  String _message = 'Pick a crop and choose an image.';

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final health = await _api.checkHealth();

    List<String> crops;
    try {
      crops = await _api.fetchCrops();
      if (crops.isEmpty) {
        crops = List<String>.from(_fallbackCrops);
      }
    } catch (_) {
      crops = List<String>.from(_fallbackCrops);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _apiHealthy = health;
      _crops = crops;
      final requestedCrop = widget.initialCrop?.trim().toLowerCase();
      _selectedCrop = requestedCrop != null && crops.contains(requestedCrop)
          ? requestedCrop
          : crops.isNotEmpty
              ? crops.first
              : null;
      _loadingCrops = false;
      if (!health) {
        _message = 'Backend offline. Start API server on port 5000.';
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 1600,
    );
    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _imageBytes = bytes;
      _imageName = picked.name;
      _message = 'Image selected. Tap Analyze to get diagnosis.';
    });
  }

  Future<void> _showCaptureTipsAndOpenCamera() async {
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan Tips',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For best accuracy, follow this camera guide before capture.',
                  style: TextStyle(color: Color(0xFF607365)),
                ),
                const SizedBox(height: 14),
                const _ScanTipRow(
                  icon: Icons.filter_1_rounded,
                  title: 'Single leaf only',
                  subtitle: 'Keep one clear leaf in the center of the frame.',
                ),
                const SizedBox(height: 10),
                const _ScanTipRow(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Good lighting',
                  subtitle: 'Use natural light and avoid heavy shadows.',
                ),
                const SizedBox(height: 10),
                const _ScanTipRow(
                  icon: Icons.center_focus_strong_outlined,
                  title: 'No blur',
                  subtitle: 'Hold steady and wait for a sharp focus.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Open Camera'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (proceed == true && mounted) {
      await _pickImage(ImageSource.camera);
    }
  }

  Future<void> _predict() async {
    if (_imageBytes == null) {
      setState(() => _message = 'Please select an image first.');
      return;
    }
    if (_selectedCrop == null || _selectedCrop!.isEmpty) {
      setState(() => _message = 'Please select a crop.');
      return;
    }

    setState(() {
      _predicting = true;
      _message = 'Analyzing image...';
    });

    try {
      final result = await _api.predictDisease(
        _imageBytes!,
        crop: _selectedCrop!,
        filename: (_imageName == null || _imageName!.trim().isEmpty)
            ? 'leaf.jpg'
            : _imageName!,
      );

      await _historyService.saveScan(
        ScanHistoryItem(
          crop: result.crop,
          disease: result.disease,
          confidence: result.confidence,
          scannedAt: DateTime.now(),
        ),
      );

      await NotificationService.instance.showPredictionNotification(
        crop: result.crop,
        disease: result.disease,
        confidence: result.confidence,
        isUncertain: result.isUncertain,
      );

      await NotificationService.instance.scheduleFollowUpReminder(
        crop: result.crop,
        disease: result.disease,
        daysLater: 2,
      );

      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _predicting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Plant'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _apiHealthy ? const Color(0xFFEAF8EC) : const Color(0xFFFFF3E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _apiHealthy ? const Color(0xFFCDE6D2) : const Color(0xFFF5D4AA),
                  ),
                ),
                child: Text(_apiHealthy ? 'API connected' : 'API disconnected'),
              ),
              const SizedBox(height: 10),
              if (_loadingCrops)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedCrop,
                  items: _crops
                      .map((crop) => DropdownMenuItem(value: crop, child: Text(crop.replaceAll('_', ' ').toUpperCase())))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCrop = value),
                  decoration: const InputDecoration(labelText: 'Crop Type'),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDDE8DB)),
                  ),
                  child: _imageBytes == null
                      ? const Center(child: Text('Image preview area'))
                      : Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _predicting ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from Gallery'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _predicting ? null : _showCaptureTipsAndOpenCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Capture with Camera'),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _predicting ? null : _predict,
                child: _predicting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Analyze Leaf'),
              ),
              const SizedBox(height: 10),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF5C7362)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanTipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ScanTipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF66B051).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF3F8447)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF637766), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
