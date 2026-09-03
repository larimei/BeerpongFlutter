import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onClearLocalData,
    this.onSignOut,
    this.onOpenLogin,
  });

  final Future<void> Function() onClearLocalData;
  final Future<void> Function()? onSignOut;
  final VoidCallback? onOpenLogin;

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete data?'),
        content: const Text(
          'All players, teams and competitions will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await onClearLocalData();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete data'),
            subtitle: const Text('Remove all players, teams and competitions'),
            onTap: () => _confirmClear(context),
          ),
          if (onSignOut != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: onSignOut,
            ),
          if (onOpenLogin != null)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in'),
              subtitle: const Text('Store data permanently in an account'),
              onTap: onOpenLogin,
            ),
        ],
      ),
    );
  }
}
