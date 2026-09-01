import 'package:flutter/material.dart';

class EntitySelection<T> extends StatelessWidget {
  const EntitySelection({
    required this.label,
    required this.items,
    required this.selectedIds,
    required this.idOf,
    required this.nameOf,
    required this.emptyMessage,
    required this.onToggle,
    super.key,
  });

  final String label;
  final List<T> items;
  final Set<String> selectedIds;
  final String Function(T item) idOf;
  final String Function(T item) nameOf;
  final String emptyMessage;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(emptyMessage)
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView(
              shrinkWrap: true,
              children: items.map((item) {
                final id = idOf(item);
                final name = nameOf(item);
                final selected = selectedIds.contains(id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(name),
                  trailing: IconButton(
                    tooltip: selected ? 'Remove $name' : 'Add $name',
                    onPressed: () => onToggle(id),
                    icon: Icon(selected ? Icons.delete_outline : Icons.add),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class EntitySelectionField<T> extends StatelessWidget {
  const EntitySelectionField({
    required this.manageLabel,
    required this.icon,
    required this.dialogTitle,
    required this.selectionLabel,
    required this.items,
    required this.selectedIds,
    required this.idOf,
    required this.nameOf,
    required this.emptyMessage,
    required this.onChanged,
    super.key,
  });

  final String manageLabel;
  final IconData icon;
  final String dialogTitle;
  final String selectionLabel;
  final List<T> items;
  final Set<String> selectedIds;
  final String Function(T item) idOf;
  final String Function(T item) nameOf;
  final String emptyMessage;
  final ValueChanged<Set<String>> onChanged;

  Future<void> _manage(BuildContext context) async {
    final savedIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => EntitySelectionDialog<T>(
        title: dialogTitle,
        label: selectionLabel,
        items: items,
        initialIds: selectedIds,
        idOf: idOf,
        nameOf: nameOf,
        emptyMessage: emptyMessage,
      ),
    );
    if (savedIds != null) onChanged(savedIds.toSet());
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _manage(context),
      icon: Icon(icon),
      label: Text(manageLabel),
    );
  }
}

class EntitySelectionDialog<T> extends StatefulWidget {
  const EntitySelectionDialog({
    required this.title,
    required this.label,
    required this.items,
    required this.initialIds,
    required this.idOf,
    required this.nameOf,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final String label;
  final List<T> items;
  final Iterable<String> initialIds;
  final String Function(T item) idOf;
  final String Function(T item) nameOf;
  final String emptyMessage;

  @override
  State<EntitySelectionDialog<T>> createState() =>
      _EntitySelectionDialogState<T>();
}

class _EntitySelectionDialogState<T> extends State<EntitySelectionDialog<T>> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialIds.toSet();
  }

  void _toggle(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) _selectedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: EntitySelection<T>(
          label: widget.label,
          items: widget.items,
          selectedIds: _selectedIds,
          idOf: widget.idOf,
          nameOf: widget.nameOf,
          emptyMessage: widget.emptyMessage,
          onToggle: _toggle,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedIds.toList()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
