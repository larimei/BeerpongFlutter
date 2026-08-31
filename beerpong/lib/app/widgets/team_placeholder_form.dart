import 'package:flutter/material.dart';

class TeamPlaceholderForm extends StatelessWidget {
  const TeamPlaceholderForm({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _PlaceholderForm(
      icon: Icons.groups_outlined,
      title: 'Add Team',
      onBack: onBack,
    );
  }
}

class _PlaceholderForm extends StatelessWidget {
  const _PlaceholderForm({
    required this.icon,
    required this.title,
    required this.onBack,
  });

  final IconData icon;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const Text('This form will be implemented in a future step.'),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
