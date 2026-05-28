import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

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

    final qualityIssue = await _validateImageQuality(_imageBytes!);
    if (qualityIssue != null) {
      if (!mounted) {
        return;
      }
      final proceed = await _showQualityWarningDialog(qualityIssue);
      if (!proceed) {
        setState(() => _message = 'Capture a clearer leaf image and try again.');
        return;
      }
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
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            imageBytes: _imageBytes,
          ),
        ),
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

  Future<String?> _validateImageQuality(Uint8List bytes) async {
    if (bytes.lengthInBytes < 40000) {
      return 'Image quality seems too low. Try capturing a sharper photo with better lighting.';
    }

    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;

      if (width < 500 || height < 500) {
        return 'The image resolution is low. Please capture a closer and clearer leaf image.';
      }

      final ratio = width / height;
      if (ratio > 2.2 || ratio < 0.45) {
        return 'Framing looks unusual. Center a single leaf and avoid extreme zoom/crop.';
      }
    } catch (_) {
      return 'Could not read the image properly. Please select or capture the photo again.';
    }

    return null;
  }

  Future<bool> _showQualityWarningDialog(String issue) async {
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Retake Recommended'),
          content: Text(issue),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Retake'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Analyze Anyway'),
            ),
          ],
        );
      },
    );

    return choice ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Plant Leaf'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1B5E20),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF81C784).withValues(alpha: 0.08),
              Color(0xFF42A5F5).withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // API Health Status Bar (Only shown if offline/error)
                if (!_apiHealthy)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEF9A9A),
                          Color(0xFFE57373),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF9A9A).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '✗ Backend Offline',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                // Crop Selector with Glassmorphism
                if (_loadingCrops)
                  SizedBox(
                    height: 56,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.92),
                          Colors.white.withValues(alpha: 0.88),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1B5E20).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCrop,
                          items: (_selectedCrop == null ? _crops : [_selectedCrop!])
                              .map((crop) => DropdownMenuItem(
                                    value: crop,
                                    child: Row(
                                      children: [
                                        Icon(Icons.eco_rounded,
                                            size: 16, color: Color(0xFF81C784)),
                                        SizedBox(width: 8),
                                        Text(
                                          crop.replaceAll('_', ' ').toUpperCase(),
                                          style: TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedCrop = value),
                          decoration: InputDecoration(
                            labelText: 'Select Crop',
                            labelStyle: TextStyle(
                              color: Color(0xFF558B2F),
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: Icon(
                              Icons.local_florist_outlined,
                              color: Color(0xFF81C784),
                            ),
                            suffixIcon: _selectedCrop != null
                                ? IconButton(
                                    icon: const Icon(Icons.cancel_rounded, color: Colors.black38),
                                    onPressed: () {
                                      setState(() {
                                        _selectedCrop = null;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 16),

                // Image Preview Area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _imageBytes == null
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF81C784).withValues(alpha: 0.1),
                                Color(0xFF66BB6A).withValues(alpha: 0.1),
                              ],
                            )
                          : null,
                      border: Border.all(
                        color: Color(0xFF81C784).withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1B5E20).withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imageBytes == null
                        ? _ScanPreviewGuide()
                        : Image.memory(_imageBytes!, fit: BoxFit.cover),
                  ),
                ),

                SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onPressed: _predicting ? null : () => _pickImage(ImageSource.gallery),
                        color: Color(0xFF42A5F5),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.photo_camera_outlined,
                        label: 'Camera',
                        onPressed: _predicting ? null : _showCaptureTipsAndOpenCamera,
                        color: Color(0xFF66BB6A),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Analyze Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF81C784).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _predicting ? null : _predict,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: _predicting
                            ? SizedBox(
                                height: 24,
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Analyze Leaf',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Status Message
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _message.toLowerCase().contains('error')
                        ? Color(0xFFFFEBEE)
                        : Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _message.toLowerCase().contains('error')
                          ? Color(0xFFEF5350)
                          : Color(0xFFA5D6A7),
                    ),
                  ),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _message.toLowerCase().contains('error')
                          ? Color(0xFFD32F2F)
                          : Color(0xFF558B2F),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
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

class _ScanPreviewGuide extends StatelessWidget {
  const _ScanPreviewGuide();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7FBF5), Color(0xFFEEF6EC)],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFBFD6BF), width: 2),
              color: Colors.white.withValues(alpha: 0.36),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_center_focus_rounded, size: 54, color: Color(0xFF4D8754)),
                SizedBox(height: 10),
                Text(
                  'Center one leaf',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3B6640)),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep background simple',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5F7363)),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 14,
          right: 14,
          bottom: 12,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _GuideChip(icon: Icons.wb_sunny_outlined, label: 'Good Light'),
              _GuideChip(icon: Icons.blur_on_outlined, label: 'No Blur'),
              _GuideChip(icon: Icons.eco_outlined, label: 'Single Leaf'),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GuideChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD5E3D5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4B8A54)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF47644B)),
          ),
        ],
      ),
    );
  }
}
