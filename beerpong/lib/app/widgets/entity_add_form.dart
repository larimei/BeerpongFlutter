import 'package:flutter/material.dart';

import 'entity_color_picker.dart';

class NewEntity {
  const NewEntity({required this.name, required this.color});

  final String name;
  final Color color;
}

class EntityAddForm extends StatefulWidget {
  const EntityAddForm({
    required this.entityName,
    required this.icon,
    required this.onSubmit,
    required this.onCancel,
    this.initialColor = const Color(0xFFFFD95A),
    this.initialName = '',
    this.backgroundKey,
    this.avatarKey,
    this.iconKey,
    this.colorPickerIconKey,
    this.colorPickerWheelKey,
    this.additionalFields,
    super.key,
  });

  final String entityName;
  final IconData icon;
  final ValueChanged<NewEntity> onSubmit;
  final VoidCallback onCancel;
  final Color initialColor;
  final String initialName;
  final Key? backgroundKey;
  final Key? avatarKey;
  final Key? iconKey;
  final Key? colorPickerIconKey;
  final Key? colorPickerWheelKey;
  final Widget? additionalFields;

  @override
  State<EntityAddForm> createState() => _EntityAddFormState();
}

class _EntityAddFormState extends State<EntityAddForm> {
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(
      NewEntity(name: _nameController.text.trim(), color: _selectedColor),
    );
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Container(
        key: widget.backgroundKey,
        width: 468,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_selectedColor, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: Container(
                    key: widget.avatarKey,
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      key: widget.iconKey,
                      size: 52,
                      color: _selectedColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add ${widget.entityName}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: '$_capitalizedEntityName name',
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a ${widget.entityName} name'
                      : null,
                ),
                if (widget.additionalFields != null) ...[
                  const SizedBox(height: 24),
                  widget.additionalFields!,
                ],
                const SizedBox(height: 24),
                Text(
                  'Card color',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      key: const Key('selected-color-preview'),
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
                    OutlinedButton.icon(
                      onPressed: _pickColor,
                      icon: const Icon(Icons.palette_outlined),
                      label: const Text('Choose color'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _capitalizedEntityName =>
      '${widget.entityName[0].toUpperCase()}${widget.entityName.substring(1)}';
}
