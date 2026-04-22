import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'growth_diary_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';

class AppShell extends StatefulWidget {
  final String userName;
  final String userEmail;
  final Future<void> Function() onLogout;

  const AppShell({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _titles = [
    'Explore',
    'History',
    'Profile',
  ];

  void _openScanScreen([String? crop]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ScanScreen(initialCrop: crop)),
    );
  }

  void _openGrowthDiary() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GrowthDiaryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        userName: widget.userName,
        onScanRequested: _openScanScreen,
        onNavigateToTab: (index) => setState(() => _selectedIndex = index),
      ),
      const HistoryScreen(),
      ProfileScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onNavigateToTab: (index) => setState(() => _selectedIndex = index),
        onOpenScan: _openScanScreen,
        onOpenDiary: _openGrowthDiary,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (_selectedIndex == 0)
              const Text(
                'Real-time plant disease detection',
                style: TextStyle(fontSize: 12, color: Color(0xFF6D7B6F)),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          PopupMenuButton<_ShellMenuAction>(
            tooltip: 'Settings',
            icon: const Icon(Icons.tune_rounded),
            onSelected: (action) {
              switch (action) {
                case _ShellMenuAction.preferences:
                  _showPreferencesSheet(context);
                  break;
                case _ShellMenuAction.about:
                  showAboutDialog(
                    context: context,
                    applicationName: 'PlantLens',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'PlantLens is a real-time plant disease detection app.',
                  );
                  break;
                case _ShellMenuAction.logout:
                  widget.onLogout();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ShellMenuAction.preferences,
                child: Text('Preferences'),
              ),
              PopupMenuItem(
                value: _ShellMenuAction.about,
                child: Text('About app'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _ShellMenuAction.logout,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'scan-fab',
        onPressed: _openScanScreen,
        backgroundColor: const Color(0xFF66B051),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.document_scanner_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.history_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  void _showPreferencesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        bool smartAlerts = true;
        bool compactCards = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                    'Preferences',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tune the look and alerts for the dashboard.',
                    style: TextStyle(color: Color(0xFF6D7B6F)),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: smartAlerts,
                    onChanged: (value) => setModalState(() => smartAlerts = value),
                    title: const Text('Smart alerts'),
                    subtitle: const Text('Show low-confidence and follow-up prompts.'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: compactCards,
                    onChanged: (value) => setModalState(() => compactCards = value),
                    title: const Text('Compact cards'),
                    subtitle: const Text('Use denser cards on wide screens.'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

enum _ShellMenuAction { preferences, about, logout }
