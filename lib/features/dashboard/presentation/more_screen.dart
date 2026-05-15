import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  String _name = 'User Name';
  String _email = 'user@example.com';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? 'User Name';
      _email = prefs.getString('profile_email') ?? 'user@example.com';
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh profile when screen is built (in case user just navigated back from profile edit)
    _loadProfile();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildMenuGroup([
              _MenuData(
                icon: Icons.people_alt_outlined,
                title: 'People',
                color: AppColors.primaryLight,
                bgColor: AppColors.primaryLight.withOpacity(0.1),
                onTap: () => context.push('/people'),
              ),
              _MenuData(
                icon: Icons.calendar_today_outlined,
                title: 'Calendar',
                color: const Color(0xFFD81B60),
                bgColor: const Color(0xFFFCE4EC),
                onTap: () => context.push('/calendar'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildMenuGroup([
              _MenuData(
                icon: Icons.bar_chart_rounded,
                title: 'Reports & Stats',
                color: const Color(0xFF3949AB),
                bgColor: const Color(0xFFEDE7F6),
                onTap: () => context.push('/stats'),
              ),
              _MenuData(
                icon: Icons.history_rounded,
                title: 'Activity Log',
                color: AppColors.info,
                bgColor: AppColors.info.withOpacity(0.1),
                onTap: () => context.push('/timeline'),
              ),
              _MenuData(
                icon: Icons.archive_outlined,
                title: 'Archive',
                color: AppColors.textSecondary,
                bgColor: AppColors.textSecondary.withOpacity(0.1),
                onTap: () => context.push('/archive'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildMenuGroup([
              _MenuData(
                icon: Icons.settings_outlined,
                title: 'Settings',
                color: AppColors.textSecondary,
                bgColor: AppColors.textSecondary.withOpacity(0.1),
                onTap: () => context.push('/settings'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildMenuGroup([
              _MenuData(
                icon: Icons.help_outline_rounded,
                title: 'How to Use',
                color: const Color(0xFF00897B),
                bgColor: const Color(0xFFE0F2F1),
                onTap: () => _launchUrl('https://sooubh.github.io/pactora/how-to-use.html'),
              ),
              _MenuData(
                icon: Icons.gavel_rounded,
                title: 'Terms of Service',
                color: const Color(0xFFFB8C00),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () => _launchUrl('https://sooubh.github.io/pactora/terms.html'),
              ),
              _MenuData(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                color: const Color(0xFF5E35B1),
                bgColor: const Color(0xFFEDE7F6),
                onTap: () => _launchUrl('https://sooubh.github.io/pactora/privacy.html'),
              ),
            ]),
            const SizedBox(height: 140), // padding for floating nav
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<_MenuData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(36),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final int index = entry.key;
          final _MenuData data = entry.value;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                onTap: data.onTap,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: data.bgColor,
                  child: Icon(data.icon, color: data.color, size: 20),
                ),
                title: Text(
                  data.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 24,
                  endIndent: 24,
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person_rounded, size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String title;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  _MenuData({
    required this.icon,
    required this.title,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}
