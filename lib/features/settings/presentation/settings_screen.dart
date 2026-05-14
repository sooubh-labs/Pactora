import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/isar_service.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/providers/user_preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SettingsHeader(title: 'Subscription'),
          ListTile(
            leading: Icon(
              Icons.stars_rounded,
              color: prefs.isPremium ? Colors.amber : Theme.of(context).primaryColor,
            ),
            title: Text(prefs.isPremium ? 'Pactora Premium (Active)' : 'Upgrade to Premium'),
            subtitle: Text(prefs.isPremium ? 'Thank you for your support!' : 'Remove ads and unlock all features'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/premium'),
          ),
          const Divider(),
          const _SettingsHeader(title: 'Data & Backup'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Backup'),
            onTap: () async {
              try {
                await BackupService.exportBackup();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Backup'),
            onTap: () async {
              try {
                final success = await BackupService.importBackup();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup restored successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: $e')),
                  );
                }
              }
            },
          ),
          const Divider(),
          const _SettingsHeader(title: 'Preferences'),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Currency'),
            trailing: Text(
              '${prefs.currencySymbol} ${prefs.currencyCode}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => _showCurrencyDialog(context, ref),
          ),
          const Divider(),
          const _SettingsHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            trailing: const Text('System'),
            onTap: () {},
          ),
          const Divider(),
          const _SettingsHeader(title: 'Danger Zone', color: Colors.red),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencyOptions.length,
            itemBuilder: (context, index) {
              final opt = currencyOptions[index];
              return ListTile(
                title: Text('${opt.symbol} ${opt.code}'),
                subtitle: Text(opt.name),
                onTap: () {
                  ref.read(userPreferencesProvider.notifier).updateCurrency(opt.symbol, opt.code);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all your promises, people, and records. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await IsarService.db.writeTxn(() => IsarService.db.clear());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SettingsHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
