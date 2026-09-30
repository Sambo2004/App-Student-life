import 'package:flutter/material.dart';

class DepthCard extends StatelessWidget {
  const DepthCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: margin,
      color: color,
      elevation: 2,
      shadowColor: scheme.primary.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: padding == null
          ? child
          : Padding(padding: padding!, child: child),
    );
  }
}
