import 'package:flutter/material.dart';

class EntityOverviewScaffold extends StatelessWidget {
  const EntityOverviewScaffold({
    required this.title,
    required this.body,
    this.onOpenSettings,
    super.key,
  });

  final String title;
  final Widget body;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF0FAF9),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF0FAF9),
      title: Text(title),
      actions: [
        IconButton(
          onPressed: onOpenSettings,
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
    body: body,
  );
}

class EntityGrid extends StatelessWidget {
  const EntityGrid({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
    ),
    itemCount: itemCount,
    itemBuilder: itemBuilder,
  );
}

class EmptyEntityState extends StatelessWidget {
  const EmptyEntityState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
