import 'package:flutter/material.dart';

import 'module_selector_screen.dart';
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
  void _openScanScreen([String? crop]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ScanScreen(initialCrop: crop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModuleSelectorScreen(
        userName: widget.userName,
        onScanRequested: _openScanScreen,
        onLogout: widget.onLogout,
      ),
    );
  }
}
