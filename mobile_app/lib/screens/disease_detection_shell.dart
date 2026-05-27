import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'profile_screen.dart';

class DiseaseDetectionShell extends StatefulWidget {
  final String userName;
  final String userEmail;
  final void Function([String? crop]) onScanRequested;
  final Future<void> Function() onLogout;

  const DiseaseDetectionShell({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onScanRequested,
    required this.onLogout,
  });

  @override
  State<DiseaseDetectionShell> createState() => _DiseaseDetectionShellState();
}

class _DiseaseDetectionShellState extends State<DiseaseDetectionShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Plant Disease Detection' : 'Account Settings',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B5E20),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1B5E20),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF81C784).withValues(alpha: 0.04),
              const Color(0xFF42A5F5).withValues(alpha: 0.04),
            ],
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(
              userName: widget.userName,
              onScanRequested: widget.onScanRequested,
              onNavigateToTab: (index) {
                setState(() => _currentIndex = index);
              },
            ),
            ProfileScreen(
              userName: widget.userName,
              userEmail: widget.userEmail,
              onNavigateToTab: (index) {
                setState(() => _currentIndex = index);
              },
              onOpenScan: () => widget.onScanRequested(),
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
              color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
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
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFC8E6C9), // Light green indicator
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: Color(0xFF388E3C)),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF1B5E20)),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Color(0xFF388E3C)),
              selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF1B5E20)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
