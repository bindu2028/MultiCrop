import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'diary_list_screen.dart';

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
    'Plant AI',
    'History',
    'Growth Diary',
    'Profile',
  ];

  void _openScanScreen([String? crop]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ScanScreen(initialCrop: crop)),
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
      const DiaryListScreen(),
      ProfileScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onNavigateToTab: (index) => setState(() => _selectedIndex = index),
        onOpenScan: _openScanScreen,
        onOpenDiary: () => setState(() => _selectedIndex = 2),
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      extendBody: false, // User requested non-floating intact bar
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
      body: pages[_selectedIndex],
      floatingActionButton: _PulsingFab(onPressed: _openScanScreen),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 16,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TabItem(
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore,
              label: 'Explore',
              isSelected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _TabItem(
              icon: Icons.history_outlined,
              selectedIcon: Icons.history,
              label: 'History',
              isSelected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 48), // Space for centered FAB
            _TabItem(
              icon: Icons.menu_book_outlined,
              selectedIcon: Icons.menu_book,
              label: 'Diary',
              isSelected: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            _TabItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
              isSelected: _selectedIndex == 3,
              onTap: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
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

class _PulsingFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _PulsingFab({required this.onPressed});

  @override
  State<_PulsingFab> createState() => _PulsingFabState();
}

class _PulsingFabState extends State<_PulsingFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.document_scanner_rounded, size: 28),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF869287),
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF869287),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
