import 'package:flutter/material.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({
    required this.name,
    required this.color,
    required this.icon,
    required this.onTap,
    this.additionalContent,
    super.key,
  });

  final String name;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? additionalContent;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, Colors.white],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 52),
                const SizedBox(height: 16),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (additionalContent != null) ...[
                  const SizedBox(height: 12),
                  additionalContent!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
