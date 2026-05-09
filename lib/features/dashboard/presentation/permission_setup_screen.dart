import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionSetupScreen extends StatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  bool _notificationsGranted = false;
  bool _storageGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final storageStatus = await Permission.storage.status;

    setState(() {
      _notificationsGranted = notificationStatus.isGranted;
      _storageGranted = storageStatus.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Permissions')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Pactora needs a few permissions to work its magic.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            _PermissionTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              subtitle: 'Reminders for due promises and overdue items',
              isGranted: _notificationsGranted,
              onTap: () async {
                final status = await Permission.notification.request();
                setState(() => _notificationsGranted = status.isGranted);
              },
            ),
            const Gap(16),
            _PermissionTile(
              icon: Icons.image_outlined,
              title: 'Storage / Media',
              subtitle: 'Attach photos to borrow items and receipts',
              isGranted: _storageGranted,
              onTap: () async {
                // On Android 13+, we might need photo permission instead of storage
                final status = await Permission.storage.request();
                setState(() => _storageGranted = status.isGranted);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: isGranted ? Colors.green : null),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: isGranted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(onPressed: onTap, child: const Text('Grant')),
      ),
    );
  }
}
