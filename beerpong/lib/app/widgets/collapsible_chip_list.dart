import 'package:flutter/material.dart';

class CollapsibleChipList extends StatefulWidget {
  const CollapsibleChipList({
    required this.children,
    this.maxVisible = 4,
    super.key,
  });

  final List<Widget> children;
  final int maxVisible;

  @override
  State<CollapsibleChipList> createState() => _CollapsibleChipListState();
}

class _CollapsibleChipListState extends State<CollapsibleChipList> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isCollapsible = widget.children.length > widget.maxVisible;
    final visibleChildren = isCollapsible && !_isExpanded
        ? widget.children.take(widget.maxVisible)
        : widget.children;
    final hiddenCount = widget.children.length - widget.maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: visibleChildren.toList()),
        if (isCollapsible)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(_isExpanded ? 'Show less' : 'Show $hiddenCount more'),
            ),
          ),
      ],
    );
  }
}
