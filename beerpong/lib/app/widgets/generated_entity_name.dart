import 'package:flutter/material.dart';

import '../data/entity_name_generator.dart';

class GeneratedEntityName extends StatefulWidget {
  const GeneratedEntityName({
    required this.type,
    required this.builder,
    super.key,
  });

  final EntityNameType type;
  final Widget Function(BuildContext context, String initialName) builder;

  @override
  State<GeneratedEntityName> createState() => _GeneratedEntityNameState();
}

class _GeneratedEntityNameState extends State<GeneratedEntityName> {
  late final Future<String> _initialName;

  @override
  void initState() {
    super.initState();
    _initialName = EntityNameGenerator().randomName(widget.type);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _initialName,
    builder: (context, snapshot) {
      if (!snapshot.hasData && !snapshot.hasError) {
        return const Center(child: CircularProgressIndicator());
      }
      return widget.builder(context, snapshot.data ?? '');
    },
  );
}
