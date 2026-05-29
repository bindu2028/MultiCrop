import 'package:flutter/material.dart';

import 'module_selector_screen.dart';
import 'scan_screen.dart';
import '../services/api_service.dart';

import 'profile_screen.dart';

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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    ApiService().checkHealth(); // Trigger asynchronous non-blocking cold-start wake up
  }

  void _openScanScreen([String? crop]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ScanScreen(initialCrop: crop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF81C784).withValues(alpha: 0.03),
              const Color(0xFF42A5F5).withValues(alpha: 0.03),
            ],
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            ModuleSelectorScreen(
              userName: widget.userName,
              userEmail: widget.userEmail,
              onScanRequested: _openScanScreen,
              onLogout: widget.onLogout,
            ),
            ProfileScreen(
              userName: widget.userName,
              userEmail: widget.userEmail,
              onNavigateToTab: (index) {
                setState(() => _currentIndex = index);
              },
              onOpenScan: () => _openScanScreen(),
              onOpenDiary: () {},
              onLogout: widget.onLogout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? const Color(0xFF151916) : Colors.white,
          indicatorColor: isDark
              ? const Color(0xFF81C784).withValues(alpha: 0.15)
              : const Color(0xFFC8E6C9),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
