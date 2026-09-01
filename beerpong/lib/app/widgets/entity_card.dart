import 'package:flutter/material.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({
    required this.name,
    required this.color,
    required this.icon,
    this.onTap,
    this.additionalContent,
    super.key,
  });

  final String name;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
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
                Icon(icon, size: 40),
                const SizedBox(height: 12),
                Flexible(child: _ResponsiveEntityName(name: name)),
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

class _ResponsiveEntityName extends StatelessWidget {
  const _ResponsiveEntityName({required this.name});

  static const double _preferredFontSize = 18;
  static const double _minimumFontSize = 14;

  final String name;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.titleLarge;
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    final locale = Localizations.maybeLocaleOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        var fontSize = _preferredFontSize;
        while (fontSize > _minimumFontSize &&
            !_fits(
              style: baseStyle?.copyWith(fontSize: fontSize),
              textScaler: textScaler,
              textDirection: textDirection,
              locale: locale,
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
            )) {
          fontSize--;
        }

        final style = baseStyle?.copyWith(fontSize: fontSize);
        final lineHeight = _lineHeight(
          style: style,
          textScaler: textScaler,
          textDirection: textDirection,
          locale: locale,
        );
        final maxLines = (constraints.maxHeight / lineHeight).floor().clamp(
          1,
          2,
        );
        final isTruncated = !_fits(
          style: style,
          textScaler: textScaler,
          textDirection: textDirection,
          locale: locale,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          maxLines: maxLines,
        );
        final text = Text(
          name,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: style,
        );

        return Semantics(
          label: name,
          excludeSemantics: true,
          child: isTruncated
              ? Tooltip(message: name, excludeFromSemantics: true, child: text)
              : text,
        );
      },
    );
  }

  bool _fits({
    required TextStyle? style,
    required TextScaler textScaler,
    required TextDirection textDirection,
    required Locale? locale,
    required double maxWidth,
    required double maxHeight,
    int maxLines = 2,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: name, style: style),
      maxLines: maxLines,
      textDirection: textDirection,
      textScaler: textScaler,
      locale: locale,
    )..layout(maxWidth: maxWidth);

    return !painter.didExceedMaxLines && painter.height <= maxHeight;
  }

  double _lineHeight({
    required TextStyle? style,
    required TextScaler textScaler,
    required TextDirection textDirection,
    required Locale? locale,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: 'Ag', style: style),
      maxLines: 1,
      textDirection: textDirection,
      textScaler: textScaler,
      locale: locale,
    )..layout();

    return painter.height;
  }
}
