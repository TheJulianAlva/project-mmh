import 'package:flutter/material.dart';

class AppEntityCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AppEntityCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.onTap,
    this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 5),
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border:
              isDark
                  ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                  : null,
        ),
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Indicator (Color Dot/Bar)
            Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
