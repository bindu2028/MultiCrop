import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/history_service.dart';
import '../services/growth_diary_service.dart';
import '../services/auth_service.dart';
import 'growth_diary_screen.dart';
import '../widgets/fade_slide.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onOpenScan;
  final VoidCallback onOpenDiary;
  final Future<void> Function() onLogout;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onNavigateToTab,
    required this.onOpenScan,
    required this.onOpenDiary,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NotificationService _notificationService = NotificationService.instance;

  late String _displayName;
  late String _displayEmail;
  String _phone = '';
  String _address = '';

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _displayEmail = widget.userEmail;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _displayName = prefs.getString('auth_name') ?? widget.userName;
          _displayEmail = prefs.getString('auth_email') ?? widget.userEmail;
          _phone = prefs.getString('auth_phone') ?? '';
          _address = prefs.getString('auth_address') ?? '';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 🪪 HOLOGRAPHIC PROFILE CARD
                FadeSlide(
                  delay: const Duration(milliseconds: 0),
                  child: _ProfileTopCard(
                    userName: _displayName,
                    userEmail: _displayEmail,
                    onTap: _openEditProfile,
                  ),
                ),
                const SizedBox(height: 18),

                // 2. 📊 STATS MATRIX DASHBOARD
                FadeSlide(
                  delay: const Duration(milliseconds: 80),
                  child: const _ProfileStatsRow(),
                ),
                const SizedBox(height: 18),

                // 4. ⚙️ SETTINGS GROUPS (GLASSY CARDS)
                FadeSlide(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Profile & Records'),
                      _MenuGroup(
                        items: [
                          _MenuItemData(
                            icon: Icons.person_rounded,
                            iconColor: const Color(0xFF1E88E5),
                            title: 'My Profile Details',
                            onTap: _openEditProfile,
                          ),
                          _MenuItemData(
                            icon: Icons.menu_book_rounded,
                            iconColor: const Color(0xFF43A047),
                            title: 'Crop Growth Diary',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GrowthDiaryScreen()),
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      _buildSectionTitle('App Preferences'),
                      _MenuGroup(
                        items: [
                          _MenuItemData(
                            icon: Icons.notifications_active_rounded,
                            iconColor: const Color(0xFFFFB300),
                            title: 'Message & Scan Alerts',
                            onTap: _showNotificationsSheet,
                          ),
                          _MenuItemData(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFF8E24AA),
                            title: 'System Language',
                            onTap: _showLanguageSheet,
                          ),
                          _MenuItemData(
                            icon: Icons.lock_rounded,
                            iconColor: const Color(0xFFE53935),
                            title: 'Reset Login Password',
                            onTap: _showResetPasswordDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      _buildSectionTitle('Support & Legal'),
                      _MenuGroup(
                        items: [
                          _MenuItemData(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF00ACC1),
                            title: 'Contact Agronomy Support',
                            onTap: _showSupportDialog,
                          ),
                          _MenuItemData(
                            icon: Icons.rate_review_rounded,
                            iconColor: const Color(0xFFD81B60),
                            title: 'Give Feedback & Rating',
                            onTap: _showFeedbackDialog,
                          ),
                          _MenuItemData(
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFF546E7A),
                            title: 'About PlantLens Software',
                            onTap: () => showAboutDialog(
                              context: context,
                              applicationName: 'PlantLens',
                              applicationVersion: '1.2.0',
                              applicationLegalese: 'Real-time agricultural scan engine and pharmaceutical database catalog.',
                            ),
                          ),
                          _MenuItemData(
                            icon: Icons.logout_rounded,
                            iconColor: const Color(0xFFC62828),
                            title: 'Sign Out Account',
                            onTap: widget.onLogout,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: isDark ? const Color(0xFF81C784) : const Color(0xFF558B2F),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final nameParts = _splitName(_displayName);
    final result = await Navigator.of(context).push<_ProfileEditResult>(
      MaterialPageRoute(
        builder: (context) => _EditProfilePage(
          firstName: nameParts.$1,
          lastName: nameParts.$2,
          email: _displayEmail,
          phone: _phone,
          address: _address,
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    final newName = '${result.firstName} ${result.lastName}'.trim();

    setState(() {
      _displayName = newName;
      _displayEmail = result.email;
      _phone = result.phone;
      _address = result.address;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_name', newName);
      await prefs.setString('auth_email', result.email);
      await prefs.setString('auth_phone', result.phone);
      await prefs.setString('auth_address', result.address);
    } catch (_) {}

    _showToast('Profile saved successfully');
  }

  Future<void> _showNotificationsSheet() async {
    bool reminders = await _notificationService.followUpRemindersEnabled();
    bool updates = await _notificationService.appUpdatesEnabled();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications & Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Control app system messages and local crop reminders.'),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: reminders,
                    onChanged: (value) => setModalState(() => reminders = value),
                    title: const Text('Local Scan Reminders'),
                    subtitle: const Text('Periodic notifications to re-scan infected leaves'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: updates,
                    onChanged: (value) => setModalState(() => updates = value),
                    title: const Text('App Feature Updates'),
                    subtitle: const Text('News and announcements for new crop parameters'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await _notificationService.setNotificationPreferences(
                          followUpsEnabled: reminders,
                          appUpdatesEnabled: updates,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        _showToast('Alert preferences saved');
                      },
                      child: const Text('Apply Changes'),
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

  Future<void> _showLanguageSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('System Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('English (US)', style: TextStyle(fontWeight: FontWeight.bold)),
                leading: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Hindi (India) / हिंदी'),
                leading: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () {
                  context.setLocale(const Locale('hi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Spanish / Español'),
                leading: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () {
                  context.setLocale(const Locale('es'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSupportDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agronomy Support'),
        content: const Text('PlantLens help desk is active 24/7. Tap continue to start a live support ticket with our specialist.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Support ticket #5820 registered');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetPasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirm = true;
    bool isSaving = false;
    String? localError;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: Color(0xFF1E88E5), size: 28),
                  SizedBox(width: 10),
                  Text('Change Password', style: TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update your login password in real-time. Password must be at least 6 characters.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: confirmController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter new password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                      ),
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        localError!,
                        style: const TextStyle(color: Color(0xFFC62828), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final pass = passwordController.text.trim();
                          final conf = confirmController.text.trim();

                          if (pass.isEmpty) {
                            setState(() => localError = 'Password cannot be empty.');
                            return;
                          }
                          if (pass.length < 6) {
                            setState(() => localError = 'Password must be at least 6 characters.');
                            return;
                          }
                          if (pass != conf) {
                            setState(() => localError = 'Passwords do not match.');
                            return;
                          }

                          setState(() {
                            isSaving = true;
                            localError = null;
                          });

                          try {
                            await AuthService().changePassword(newPassword: pass);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showToast('Password updated successfully in real-time!');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() {
                                isSaving = false;
                                localError = e.toString().replaceAll('Exception:', '').trim();
                              });
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showFeedbackDialog() async {
    final feedbackController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('We are dedicated to crop diagnostics quality. Send us your feedback:'),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience or suggestions...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Thank you for supporting PlantLens!');
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  (String, String) _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return ('', '');
    }
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }
}

// 🪪 1. HOLOGRAPHIC GLASSMORPHIC TOP PROFILE CARD
class _ProfileTopCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onTap;

  const _ProfileTopCard({
    required this.userName,
    required this.userEmail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF0F4D12)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4D12).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient vector layout backgrounds
          Positioned(
            right: -30,
            top: -20,
            child: Icon(
              Icons.spa_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Elite Pro',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                userName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Edit Profile Information ➔',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 📊 2. AGRONOMY ACTIVITY DASHBOARD STATS ROW
class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        HistoryService().loadHistory(),
        GrowthDiaryService().loadEntries(),
      ]),
      builder: (context, snapshot) {
        final scans = (snapshot.data?[0] as List?)?.length ?? 0;
        final diaryLogs = (snapshot.data?[1] as List?)?.length ?? 0;

        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context: context,
                icon: Icons.scanner_rounded,
                color: isDark ? const Color(0xFF1E281F) : const Color(0xFFE8F5E9),
                iconColor: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                value: scans.toString(),
                label: 'Leaf Scans',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatItem(
                context: context,
                icon: Icons.menu_book_rounded,
                color: isDark ? const Color(0xFF2D2214) : const Color(0xFFFFF3E0),
                iconColor: isDark ? const Color(0xFFFFB74D) : const Color(0xFFEF6C00),
                value: diaryLogs.toString(),
                label: 'Diary Logs',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2320) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A312B) : const Color(0xFFECEFF1)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF253627),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}



// ⚙️ 4. GLASSY GROUPED MENU GROUP CONTAINER
class _MenuGroup extends StatelessWidget {
  final List<_MenuItemData> items;

  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2320) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? const Color(0xFF2A312B) : const Color(0xFFECEFF1)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _MenuTile(
              icon: items[i].icon,
              iconColor: items[i].iconColor,
              title: items[i].title,
              onTap: items[i].onTap,
            ),
            if (i != items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 14,
                endIndent: 14,
                color: isDark ? const Color(0xFF2A312B) : const Color(0xFFECEFF1),
              ),
          ],
        ],
      ),
    );
  }
}

// INDIVIDUAL MENU TILE CARD
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF253627),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });
}

// PROFILE EDIT PAGE WIDGET
class _EditProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;

  const _EditProfilePage({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121613) : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF253627)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF253627),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Field(
              label: 'First name',
              controller: _firstNameController,
              prefixIcon: Icons.person_outline_rounded,
              hintText: 'Enter your first name',
            ),
            const SizedBox(height: 18),
            _Field(
              label: 'Last name',
              controller: _lastNameController,
              prefixIcon: Icons.person_outline_rounded,
              hintText: 'Enter your last name',
            ),
            const SizedBox(height: 18),
            _Field(
              label: 'Email Address',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              hintText: 'Enter your email address',
            ),
            const SizedBox(height: 18),
            _Field(
              label: 'Phone number',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              hintText: 'Enter your phone number (e.g. +91 98765 43210)',
            ),
            const SizedBox(height: 18),
            _Field(
              label: 'Geographical Address',
              controller: _addressController,
              prefixIcon: Icons.location_on_outlined,
              hintText: 'Enter geographical address',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    Navigator.of(context).pop(
      _ProfileEditResult(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final IconData prefixIcon;
  final String hintText;

  const _Field({
    required this.label,
    required this.controller,
    required this.prefixIcon,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF81C784) : const Color(0xFF558B2F),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF253627),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 20,
              color: isDark ? const Color(0xFF81C784) : const Color(0xFF558B2F),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2320) : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2A312B) : const Color(0xFFECEFF1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileEditResult {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;

  const _ProfileEditResult({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
  });
}
