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
            padding: EdgeInsets.all(additionalContent == null ? 16 : 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40),
                SizedBox(height: additionalContent == null ? 12 : 6),
                Expanded(child: EntityCardText(text: name)),
                if (additionalContent != null) ...[
                  const SizedBox(height: 4),
                  Expanded(flex: 2, child: additionalContent!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EntityCardText extends StatelessWidget {
  const EntityCardText({
    required this.text,
    this.fontSize = 16,
    this.maxLines = 2,
    this.style,
    super.key,
  });

  final String text;
  final double fontSize;
  final int maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.titleLarge;
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    final locale = Localizations.maybeLocaleOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final style = baseStyle?.copyWith(fontSize: fontSize);
        final lineHeight = _lineHeight(
          style: style,
          textScaler: textScaler,
          textDirection: textDirection,
          locale: locale,
        );
        final fittingLines = constraints.maxHeight.isFinite
            ? (constraints.maxHeight / lineHeight).floor().clamp(1, maxLines)
            : maxLines;
        final isTruncated = !_fits(
          style: style,
          textScaler: textScaler,
          textDirection: textDirection,
          locale: locale,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          maxLines: fittingLines,
        );
        final textWidget = Text(
          text,
          maxLines: fittingLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: style,
        );

        return Semantics(
          label: text,
          excludeSemantics: true,
          child: isTruncated
              ? Tooltip(
                  message: text,
                  excludeFromSemantics: true,
                  child: textWidget,
                )
              : textWidget,
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
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines ?? this.maxLines,
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
