import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<Color?> showEntityColorPicker(
  BuildContext context, {
  required Color initialColor,
  required String entityName,
  required IconData icon,
  Key? iconKey,
  Key? wheelKey,
}) {
  return showDialog<Color>(
    context: context,
    builder: (context) => _EntityColorPickerDialog(
      initialColor: initialColor,
      entityName: entityName,
      icon: icon,
      iconKey: iconKey,
      wheelKey: wheelKey,
    ),
  );
}

class _EntityColorPickerDialog extends StatefulWidget {
  const _EntityColorPickerDialog({
    required this.initialColor,
    required this.entityName,
    required this.icon,
    this.iconKey,
    this.wheelKey,
  });

  final Color initialColor;
  final String entityName;
  final IconData icon;
  final Key? iconKey;
  final Key? wheelKey;

  @override
  State<_EntityColorPickerDialog> createState() =>
      _EntityColorPickerDialogState();
}

class _EntityColorPickerDialogState extends State<_EntityColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose ${widget.entityName} color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                key: widget.iconKey,
                size: 44,
                color: _selectedColor,
              ),
            ),
            const SizedBox(height: 16),
            HueRingPicker(
              key: widget.wheelKey,
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() => _selectedColor = color);
              },
              colorPickerHeight: 260,
              hueRingStrokeWidth: 24,
              enableAlpha: false,
              displayThumbColor: true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Selected color'),
                const SizedBox(width: 12),
                Container(
                  key: const Key('color-picker-preview'),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          child: const Text('Use color'),
        ),
      ],
    );
  }
}
