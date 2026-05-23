import 'package:flutter/material.dart';
import '../services/compound_api.dart';
import 'compound_detail_screen.dart';

class CompoundScreen extends StatefulWidget {
  const CompoundScreen({Key? key}) : super(key: key);

  @override
  State<CompoundScreen> createState() => _CompoundScreenState();
}

class _CompoundScreenState extends State<CompoundScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a compound name')),
      );
      return;
    }
    
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final result = await CompoundApi.getCompoundFull(query);
      
      if (!mounted) return;
      
      setState(() => _loading = false);
      
      if (result != null && (result['found_in_pubchem'] == true || result['found_in_knowledge_base'] == true)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompoundDetailScreen(data: result),
          ),
        );
      } else {
        setState(() {
          _error = 'Compound "$query" not found in knowledge base or PubChem.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error connecting to server. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Compound Encyclopedia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search for natural drug compounds to see their chemical properties, source plants, and medicinal uses.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              
              // Search input
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'e.g., Quercetin, Curcumin, Caffeine',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 16),
              
              // Search button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Search Compound', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
              
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFC62828)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFB71C1C)),
                        ),
                      ),
                    ],
                  ),
                ),
                
              const SizedBox(height: 24),
              const Text('Popular Compounds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 12,
                children: [
                  _buildPopularChip('Quercetin'),
                  _buildPopularChip('Curcumin'),
                  _buildPopularChip('Berberine'),
                  _buildPopularChip('Caffeine'),
                  _buildPopularChip('Lycopene'),
                  _buildPopularChip('Resveratrol'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPopularChip(String name) {
    return ActionChip(
      label: Text(name),
      backgroundColor: const Color(0xFFF1F8E9),
      labelStyle: const TextStyle(color: Color(0xFF33691E), fontWeight: FontWeight.w500),
      side: const BorderSide(color: Color(0xFFDCEDC8)),
      onPressed: () {
        _controller.text = name;
        _search();
      },
    );
  }
}
