import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/herb_library_data.dart';
import '../screens/herb_detail_screen.dart';
import '../screens/interaction_checker_screen.dart';
import '../services/compound_api.dart';
import 'compound_detail_screen.dart';

class CompoundScreen extends StatefulWidget {
  const CompoundScreen({super.key});

  @override
  State<CompoundScreen> createState() => _CompoundScreenState();
}

class _CompoundScreenState extends State<CompoundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  
  bool _loading = false;
  String? _error;

  // Molecular Simulator States
  String? _selectedClass;
  String? _selectedWeight; // Light, Medium, Heavy
  String? _selectedBio;
  List<Map<String, dynamic>> _filteredCompounds = [];

  final List<String> _compoundClasses = [
    'Polyphenol',
    'Alkaloid',
    'Terpene',
    'Antibiotic',
    'Capsaicinoid'
  ];

  final List<String> _bioactivities = [
    'Antioxidant',
    'Anti-inflammatory',
    'Antimicrobial',
    'Analgesic',
    'Antiviral',
    'Cardioprotective'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _runSimulation(); // Init simulator
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Action Handlers
  // ---------------------------------------------------------------------------

  void _searchCompound(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
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
      final result = await CompoundApi.getCompoundFull(trimmed);
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
          _error = 'Compound "$trimmed" not found in knowledge base or PubChem.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error connecting to database. Please check connection.';
      });
    }
  }

  void _runSimulation() {
    // Curated local list of compounds to search dynamically in the simulator
    final List<Map<String, dynamic>> localRegistry = [
      {
        'name': 'Quercetin',
        'class': 'Polyphenol',
        'weight': 'Medium',
        'bio': 'Antioxidant',
        'desc': 'Commonly found in capers, onions, and red apples.'
      },
      {
        'name': 'Curcumin',
        'class': 'Polyphenol',
        'weight': 'Heavy',
        'bio': 'Anti-inflammatory',
        'desc': 'Active element in Turmeric rhizome.'
      },
      {
        'name': 'Berberine',
        'class': 'Alkaloid',
        'weight': 'Medium',
        'bio': 'Antimicrobial',
        'desc': 'Derived from Goldenseal and Barberry root.'
      },
      {
        'name': 'Caffeine',
        'class': 'Alkaloid',
        'weight': 'Light',
        'bio': 'Stimulant',
        'desc': 'Popular metabolic stimulant in Coffee and Tea.'
      },
      {
        'name': 'Lycopene',
        'class': 'Terpene',
        'weight': 'Heavy',
        'bio': 'Antioxidant',
        'desc': 'Powerful pigment carotenoid in Tomatoes.'
      },
      {
        'name': 'Capsaicin',
        'class': 'Capsaicinoid',
        'weight': 'Medium',
        'bio': 'Analgesic',
        'desc': 'Active heat element in Chili Peppers.'
      },
      {
        'name': 'Resveratrol',
        'class': 'Polyphenol',
        'weight': 'Medium',
        'bio': 'Cardioprotective',
        'desc': 'Powerful polyphenol found in Red Grapes skin.'
      },
      {
        'name': 'Menthol',
        'class': 'Terpene',
        'weight': 'Light',
        'bio': 'Analgesic',
        'desc': 'Cooling volatile monoterpene in Peppermint.'
      },
      {
        'name': 'Gingerol',
        'class': 'Polyphenol',
        'weight': 'Medium',
        'bio': 'Anti-inflammatory',
        'desc': 'Anti-nausea rhizome active in Fresh Ginger.'
      },
      {
        'name': 'Penicillin G',
        'class': 'Antibiotic',
        'weight': 'Heavy',
        'bio': 'Antimicrobial',
        'desc': 'Fungal-derived beta-lactam antibacterial.'
      },
    ];

    setState(() {
      _filteredCompounds = localRegistry.where((c) {
        if (_selectedClass != null && c['class'] != _selectedClass) return false;
        if (_selectedWeight != null && c['weight'] != _selectedWeight) return false;
        if (_selectedBio != null && !c['bio'].toString().contains(_selectedBio!)) return false;
        return true;
      }).toList();
    });
  }

  void _resetSimulation() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedClass = null;
      _selectedWeight = null;
      _selectedBio = null;
    });
    _runSimulation();
  }

  // ---------------------------------------------------------------------------
  // Build Methods
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Natural Apothecary',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3.5,
          tabs: const [
            Tab(icon: Icon(Icons.search_rounded), text: 'Search'),
            Tab(icon: Icon(Icons.eco_rounded), text: 'Botanical Explorer'),
            Tab(icon: Icon(Icons.shield_outlined), text: 'Safety Checker'),
            Tab(icon: Icon(Icons.science_outlined), text: 'Molecular Simulator'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildSearchTab(),
              _buildBotanicalExplorerTab(),
              const InteractionCheckerScreen(),
              _buildMolecularSimulatorTab(),
            ],
          ),
          
          if (_loading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: Color(0xFF2196F3)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Chemical Search
  // ---------------------------------------------------------------------------

  Widget _buildSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          'Compound Encyclopedia',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Query chemical formulas to view structures, companion organisms, and medical safety profiles.',
          style: TextStyle(fontSize: 13.5, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        
        // Search text field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'e.g., Curcumin, Berberine, Caffeine...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD1E3F8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
          onSubmitted: _searchCompound,
        ),
        const SizedBox(height: 14),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _searchCompound(_searchController.text),
            child: const Text('Search Database', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        
        const SizedBox(height: 24),

        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFC62828)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        const Text('Popular Curations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            'Quercetin',
            'Curcumin',
            'Berberine',
            'Caffeine',
            'Lycopene',
            'Resveratrol',
            'Menthol',
            'Gingerol',
          ].map((c) {
            return ActionChip(
              label: Text(c),
              backgroundColor: Colors.white,
              labelStyle: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
              side: const BorderSide(color: Color(0xFFBBDEFB)),
              onPressed: () {
                _searchController.text = c;
                _searchCompound(c);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Botanical Grid Explorer
  // ---------------------------------------------------------------------------

  Widget _buildBotanicalExplorerTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: kHerbLibraryData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.84,
      ),
      itemBuilder: (context, idx) {
        final herb = kHerbLibraryData[idx];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD1E3F8)),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HerbDetailScreen(herb: herb),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE3F2FD),
                    child: Text(herb.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const Spacer(),
                  Text(
                    herb.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    herb.scientificName,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: herb.activeCompounds.map((comp) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F5FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          comp,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Molecular Simulator Dashboard
  // ---------------------------------------------------------------------------

  Widget _buildMolecularSimulatorTab() {
    return Column(
      children: [
        // Filter Toolbar
        Container(
          padding: const EdgeInsets.all(18),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.science, color: Color(0xFF1976D2), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Molecular Feature Filter',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 1. Compound Class Row Selector
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('All Classes'),
                      selected: _selectedClass == null,
                      selectedColor: const Color(0xFF1976D2),
                      labelStyle: TextStyle(
                        color: _selectedClass == null ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (sel) {
                        if (sel) {
                          setState(() => _selectedClass = null);
                          _runSimulation();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._compoundClasses.map((cl) {
                      final isSelected = _selectedClass == cl;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cl),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1976D2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (sel) {
                            setState(() => _selectedClass = sel ? cl : null);
                            _runSimulation();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),

              // 2. Weight Choices & Bio Filter
              Row(
                children: [
                  // Weight Selector
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedWeight,
                          hint: const Text('Mol Weight', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 13),
                          items: const [
                            DropdownMenuItem(value: 'Light', child: Text('Light (<200g)')),
                            DropdownMenuItem(value: 'Medium', child: Text('Medium (200-400g)')),
                            DropdownMenuItem(value: 'Heavy', child: Text('Heavy (>400g)')),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedWeight = val);
                            _runSimulation();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Bioactivity Selector
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBio,
                          hint: const Text('Bioactivity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 13),
                          items: _bioactivities.map((bio) {
                            return DropdownMenuItem(value: bio, child: Text(bio));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedBio = val);
                            _runSimulation();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Reset Button
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFC62828)),
                    onPressed: _resetSimulation,
                    tooltip: 'Reset Filters',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Sim Results Grid
        Expanded(
          child: _filteredCompounds.isEmpty
              ? _buildEmptySimulatorState()
              : GridView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: _filteredCompounds.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.90,
                  ),
                  itemBuilder: (context, idx) {
                    final comp = _filteredCompounds[idx];
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFD1E3F8)),
                      ),
                      child: InkWell(
                        onTap: () => _searchCompound(comp['name']),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.science_outlined, color: Color(0xFF1976D2), size: 16),
                              ),
                              const Spacer(),
                              Text(
                                comp['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                comp['desc'],
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECEFF1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      comp['weight'],
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    comp['bio'],
                                    style: const TextStyle(fontSize: 9, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildEmptySimulatorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.science_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Compounds Found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try relaxing your filter criteria or tap the reset icon to explore all natural blueprints.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              onPressed: _resetSimulation,
              child: const Text('Reset Simulator'),
            ),
          ],
        ),
      ),
    );
  }
}
