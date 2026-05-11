import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          _buildProfileHeader(context),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('People'),
            onTap: () => context.push('/people'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
            onTap: () => context.push('/calendar'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => context.push('/stats'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Activity'),
            onTap: () => context.push('/timeline'),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archive'),
            onTap: () => context.push('/archive'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person, size: 40, color: Colors.grey),
      ),
      title: const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('View and edit profile'),
      onTap: () => context.push('/profile'),
    );
  }
}
