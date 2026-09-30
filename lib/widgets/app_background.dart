import 'package:flutter/material.dart';

import '../data/app_settings.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundImage = AppSettings.instance.backgroundImage;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (backgroundImage != null &&
                  AppSettings.instance.backgroundImageEnabled)
                Positioned.fill(
                  child: Opacity(
                    opacity: isDark ? 0.10 : 0.18,
                    child: Image.memory(backgroundImage, fit: BoxFit.cover),
                  ),
                ),
              if (isDark) ...[
                Positioned(
                  top: -100,
                  right: -70,
                  child: _Glow(
                    color: scheme.primary.withValues(alpha: 0.12),
                    size: 240,
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -80,
                  child: _Glow(
                    color: scheme.secondary.withValues(alpha: 0.10),
                    size: 280,
                  ),
                ),
              ],
              child,
            ],
          ),
        );
      },
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
