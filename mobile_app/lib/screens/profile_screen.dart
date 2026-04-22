import 'package:flutter/material.dart';

import '../services/notification_service.dart';

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
              _ProfileTopCard(
                userName: _displayName,
                userEmail: _displayEmail,
                onTap: _openEditProfile,
              ),
              const SizedBox(height: 12),
              _MenuGroup(
                items: [
                  _MenuItemData(
                    icon: Icons.person_outline,
                    title: 'My profile',
                    onTap: _openEditProfile,
                  ),
                  _MenuItemData(
                    icon: Icons.document_scanner_outlined,
                    title: 'Scan plant now',
                    onTap: widget.onOpenScan,
                  ),
                  _MenuItemData(
                    icon: Icons.history_outlined,
                    title: 'History',
                    onTap: () => widget.onNavigateToTab(1),
                  ),
                  _MenuItemData(
                    icon: Icons.menu_book_outlined,
                    title: 'Growth diary',
                    onTap: widget.onOpenDiary,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _MenuGroup(
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
                    onTap: () => _showToast('Password reset flow can be connected here.'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _MenuGroup(
                items: [
                  _MenuItemData(
                    icon: Icons.support_agent_outlined,
                    title: 'Contact us',
                    onTap: _showSupportDialog,
                  ),
                  _MenuItemData(
                    icon: Icons.feedback_outlined,
                    title: 'Give us feedback',
                    onTap: () => _showToast('Feedback flow can be connected next.'),
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
              const SizedBox(height: 18),
              Container(
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
              const SizedBox(height: 12),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E8E7)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF56C5C),
                child: Text(
                  _initials(userName),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6C7271)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF353838)),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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
        border: Border.all(color: const Color(0xFFE5E8E7)),
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
