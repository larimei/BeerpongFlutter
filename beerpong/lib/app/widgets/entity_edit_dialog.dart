import 'package:flutter/material.dart';

import 'entity_color_picker.dart';

class EntityEdits {
  const EntityEdits({required this.name, required this.color});

  final String name;
  final Color color;
}

class EntityEditDialog extends StatefulWidget {
  const EntityEditDialog({
    required this.entityName,
    required this.initialName,
    required this.initialColor,
    required this.icon,
    this.colorPickerIconKey,
    this.colorPickerWheelKey,
    super.key,
  });

  final String entityName;
  final String initialName;
  final Color initialColor;
  final IconData icon;
  final Key? colorPickerIconKey;
  final Key? colorPickerWheelKey;

  @override
  State<EntityEditDialog> createState() => _EntityEditDialogState();
}

class _EntityEditDialogState extends State<EntityEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final color = await showEntityColorPicker(
      context,
      initialColor: _selectedColor,
      entityName: widget.entityName,
      icon: widget.icon,
      iconKey: widget.colorPickerIconKey,
      wheelKey: widget.colorPickerWheelKey,
    );
    if (color != null) setState(() => _selectedColor = color);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      EntityEdits(name: _nameController.text.trim(), color: _selectedColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capitalizedName =
        '${widget.entityName[0].toUpperCase()}${widget.entityName.substring(1)}';
    return AlertDialog(
      title: Text('Edit ${widget.entityName}'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: '$capitalizedName name',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a ${widget.entityName} name'
                    : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              Text(
                '$capitalizedName color',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    key: const Key('edit-color-preview'),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _pickColor,
                    icon: const Icon(Icons.palette_outlined),
                    label: const Text('Choose color'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
