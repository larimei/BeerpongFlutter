import 'package:flutter/material.dart';

Future<bool> showEntityDeleteDialog(
  BuildContext context, {
  required String entityName,
  required String displayName,
  required int assignmentCount,
  required String assignmentSingular,
  required String assignmentPlural,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => EntityDeleteDialog(
          entityName: entityName,
          displayName: displayName,
          assignmentCount: assignmentCount,
          assignmentSingular: assignmentSingular,
          assignmentPlural: assignmentPlural,
        ),
      ) ??
      false;
}

class EntityDeleteDialog extends StatelessWidget {
  const EntityDeleteDialog({
    required this.entityName,
    required this.displayName,
    required this.assignmentCount,
    required this.assignmentSingular,
    required this.assignmentPlural,
    super.key,
  });

  final String entityName;
  final String displayName;
  final int assignmentCount;
  final String assignmentSingular;
  final String assignmentPlural;

  @override
  Widget build(BuildContext context) {
    final assignmentName = assignmentCount == 1
        ? assignmentSingular
        : assignmentPlural;
    final message = assignmentCount == 0
        ? 'Are you sure you want to delete $displayName?'
        : '$displayName is assigned to $assignmentCount $assignmentName. '
              'Deleting it will remove it from '
              '${assignmentCount == 1 ? 'that $assignmentSingular' : 'those $assignmentPlural'}.';

    return AlertDialog(
      title: Text('Delete $entityName?'),
      content: Text(message),
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
    );
  }
}
