import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/notification_service.dart';
import 'diary_list_screen.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeSlide(
                delay: const Duration(milliseconds: 0),
                child: _ProfileTopCard(
                  userName: _displayName,
                  userEmail: _displayEmail,
                  onTap: _openEditProfile,
                ),
              ),
              const SizedBox(height: 12),
              FadeSlide(
                delay: const Duration(milliseconds: 100),
                child: _MenuGroup(
                  items: [
                    _MenuItemData(
                      icon: Icons.person_outline,
                      title: 'My profile',
                      onTap: _openEditProfile,
                    ),
                    _MenuItemData(
                      icon: Icons.menu_book_outlined,
                      title: 'Growth diary',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryListScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FadeSlide(
                delay: const Duration(milliseconds: 200),
                child: _MenuGroup(
                  items: [
                    _MenuItemData(
                      icon: Icons.notifications_none_rounded,
                      title: 'Message notifications',
                      onTap: _showNotificationsSheet,
                    ),
                    _MenuItemData(
                      icon: Icons.tune_rounded,
                      title: 'App settings',
                      onTap: _showSettingsSheet,
                    ),
                    _MenuItemData(
                      icon: Icons.lock_outline_rounded,
                      title: 'Reset password',
                      onTap: _showResetPasswordDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FadeSlide(
                delay: const Duration(milliseconds: 300),
                child: _MenuGroup(
                  items: [
                    _MenuItemData(
                      icon: Icons.support_agent_outlined,
                      title: 'Contact us',
                      onTap: _showSupportDialog,
                    ),
                    _MenuItemData(
                      icon: Icons.feedback_outlined,
                      title: 'Give us feedback',
                      onTap: _showFeedbackDialog,
                    ),
                    _MenuItemData(
                      icon: Icons.info_outline,
                      title: 'About PlantLens',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'PlantLens',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Real-time plant disease detection app',
                      ),
                    ),
                    _MenuItemData(
                      icon: Icons.logout_rounded,
                      title: 'Sign out',
                      onTap: widget.onLogout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FadeSlide(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Text(
                      'Want better scan quality?',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF253627)),
                    ),
                    TextButton(
                      onPressed: widget.onOpenScan,
                      child: const Text('Open scan and retake now'),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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

    setState(() {
      _displayName = '${result.firstName} ${result.lastName}'.trim();
      _displayEmail = result.email;
      _phone = result.phone;
      _address = result.address;
    });

    _showToast('Profile saved');
  }

  Future<void> _showNotificationsSheet() async {
    bool reminders = await _notificationService.followUpRemindersEnabled();
    bool updates = await _notificationService.appUpdatesEnabled();

    if (!mounted) {
      return;
    }

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
                  const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Control app messages and reminders.'),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: reminders,
                    onChanged: (value) => setModalState(() => reminders = value),
                    title: const Text('Scan reminders'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: updates,
                    onChanged: (value) => setModalState(() => updates = value),
                    title: const Text('App updates'),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await _notificationService.setNotificationPreferences(
                          followUpsEnabled: reminders,
                          appUpdatesEnabled: updates,
                        );
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context);
                        _showToast('Notification settings saved');
                      },
                      child: const Text('Save'),
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
              const Text('Select Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('English (US)'),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Hindi (India) / हिंदी'),
                onTap: () {
                  context.setLocale(const Locale('hi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Spanish / Español'),
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

  Future<void> _showSettingsSheet() async {
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
              const Text('App settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit profile'),
                onTap: () {
                  Navigator.pop(context);
                  _openEditProfile();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.language_rounded),
                title: const Text('Language'),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageSheet();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_rounded),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  _showNotificationsSheet();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy'),
                onTap: () {
                  Navigator.pop(context);
                  _showToast('Privacy settings can be connected here.');
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
        title: const Text('Contact support'),
        content: const Text('You can connect this to email, chat, or an FAQ page.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Support request started');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetPasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password'),
        content: const Text('A password reset link will be sent to your email. Do you want to proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Reset link sent to $_displayEmail');
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedbackDialog() async {
    final feedbackController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us how we can improve...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Thank you for your feedback!');
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            image: const DecorationImage(
              image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
              opacity: 0.1,
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 18),
                        SizedBox(width: 6),
                        Text('Elite', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                userName,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItemData> items;

  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0F4EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _MenuTile(
              icon: items[i].icon,
              title: items[i].title,
              onTap: items[i].onTap,
            ),
            if (i != items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 14,
                endIndent: 14,
                color: Color(0xFFF0F1F1),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 19, color: const Color(0xFF2A2F2E)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF2F3534)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItemData({required this.icon, required this.title, required this.onTap});
}

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Field(label: 'First name', controller: _firstNameController),
            const SizedBox(height: 10),
            _Field(label: 'Last name', controller: _lastNameController),
            const SizedBox(height: 10),
            _Field(label: 'Email', controller: _emailController),
            const SizedBox(height: 10),
            _Field(label: 'Phone', controller: _phoneController),
            const SizedBox(height: 10),
            _Field(label: 'Address', controller: _addressController, maxLines: 2),
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

  const _Field({required this.label, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF616867), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(isDense: true),
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
