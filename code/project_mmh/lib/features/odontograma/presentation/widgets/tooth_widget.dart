import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/features/odontograma/presentation/controllers/odontograma_controller.dart';

/// Paleta del odontograma resuelta desde el tema (para que funcione en claro y
/// oscuro; antes usaba blanco/negro fijos).
class ToothPalette {
  const ToothPalette({
    required this.fill,
    required this.border,
    required this.label,
    required this.caries,
    required this.obturacion,
    required this.global,
  });

  final Color fill;
  final Color border;
  final Color label;
  final Color caries; // rojo clínico
  final Color obturacion; // azul clínico
  final Color global; // trazos de estado global (ausente, puente…)

  factory ToothPalette.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToothPalette(
      fill: scheme.surfaceContainerHighest,
      border: scheme.onSurface.withValues(alpha: 0.45),
      label: scheme.onSurface,
      caries: scheme.error,
      obturacion: context.semantic.info,
      global: scheme.onSurface,
    );
  }
}

class ToothWidget extends StatelessWidget {
  final double size;
  final String isoNumber;
  final bool isUpper; // Needed for Erupcion arrow direction

  // Surface States
  final String stateTop;
  final String stateBottom;
  final String stateLeft;
  final String stateRight;
  final String stateCenter;

  // Global / Extra
  final String globalState;
  final bool hasSellador; // Draws 'S'
  final bool isBridgeStart; // Resalta la pieza elegida como inicio de puente

  // Callbacks
  final VoidCallback? onTapTop;
  final VoidCallback? onTapBottom;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapCenter;

  const ToothWidget({
    super.key,
    required this.size,
    required this.isoNumber,
    required this.isUpper,
    this.stateTop = 'Sano',
    this.stateBottom = 'Sano',
    this.stateLeft = 'Sano',
    this.stateRight = 'Sano',
    this.stateCenter = 'Sano',
    this.globalState = 'Sano',
    this.hasSellador = false,
    this.isBridgeStart = false,
    this.onTapTop,
    this.onTapBottom,
    this.onTapLeft,
    this.onTapRight,
    this.onTapCenter,
  });

  @override
  Widget build(BuildContext context) {
    final palette = ToothPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isoNumber,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: palette.label,
            letterSpacing: 0,
          ),
        ),
        Container(
          width: size,
          height: size,
          decoration:
              isBridgeStart
                  ? BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  )
                  : null,
          child: CustomPaint(
            painter: _ToothPainter(
              stateTop: stateTop,
              stateBottom: stateBottom,
              stateLeft: stateLeft,
              stateRight: stateRight,
              stateCenter: stateCenter,
              globalState: globalState,
              hasSellador: hasSellador,
              isUpper: isUpper,
              palette: palette,
            ),
            child: _TouchDetector(
              width: size,
              height: size,
              onTapTop: onTapTop,
              onTapBottom: onTapBottom,
              onTapLeft: onTapLeft,
              onTapRight: onTapRight,
              onTapCenter: onTapCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _TouchDetector extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTapTop;
  final VoidCallback? onTapBottom;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapCenter;

  const _TouchDetector({
    required this.width,
    required this.height,
    this.onTapTop,
    this.onTapBottom,
    this.onTapLeft,
    this.onTapRight,
    this.onTapCenter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final x = details.localPosition.dx;
        final y = details.localPosition.dy;
        final w = width;
        final h = height;

        // CenterRect (33% of middle)
        final centerRect = Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w / 3,
          height: h / 3,
        );

        if (centerRect.contains(Offset(x, y))) {
          onTapCenter?.call();
          return;
        }

        // Diagonals logic
        bool aboveD1 = y < x;
        bool aboveD2 = y < (h - x);

        if (aboveD1) {
          if (aboveD2) {
            onTapTop?.call();
          } else {
            onTapRight?.call();
          }
        } else {
          if (aboveD2) {
            onTapLeft?.call();
          } else {
            onTapBottom?.call();
          }
        }
      },
    );
  }
}

class _ToothPainter extends CustomPainter {
  final String stateTop;
  final String stateBottom;
  final String stateLeft;
  final String stateRight;
  final String stateCenter;
  final String globalState;
  final bool hasSellador;
  final bool isUpper;
  final ToothPalette palette;

  _ToothPainter({
    required this.stateTop,
    required this.stateBottom,
    required this.stateLeft,
    required this.stateRight,
    required this.stateCenter,
    required this.globalState,
    required this.hasSellador,
    required this.isUpper,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = palette.border
          ..strokeWidth = 1.0;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Define Shapes (Paths)
    final topPath =
        Path()
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(cx, cy)
          ..close();
    final bottomPath =
        Path()
          ..moveTo(0, h)
          ..lineTo(w, h)
          ..lineTo(cx, cy)
          ..close();
    final leftPath =
        Path()
          ..moveTo(0, 0)
          ..lineTo(0, h)
          ..lineTo(cx, cy)
          ..close();
    final rightPath =
        Path()
          ..moveTo(w, 0)
          ..lineTo(w, h)
          ..lineTo(cx, cy)
          ..close();

    final cw = w / 3;
    final ch = h / 3;
    final centerRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: cw,
      height: ch,
    );

    // Helper: Draw Surface
    void drawSurface(Path path, String state, {Rect? rect}) {
      if (state == OdontogramaTools.caries) {
        paint.color = palette.caries;
        paint.style = PaintingStyle.fill;
        if (rect != null) {
          canvas.drawRect(rect, paint);
        } else {
          canvas.drawPath(path, paint);
        }
      } else if (state == OdontogramaTools.obturacion) {
        paint.color = palette.obturacion;
        paint.style = PaintingStyle.fill;
        if (rect != null) {
          canvas.drawRect(rect, paint);
        } else {
          canvas.drawPath(path, paint);
        }
      } else if (state == OdontogramaTools.restauracionFiltrada) {
        // Blue Fill
        paint.color = palette.obturacion;
        paint.style = PaintingStyle.fill;
        if (rect != null) {
          canvas.drawRect(rect, paint);
        } else {
          canvas.drawPath(path, paint);
        }

        // Red Border (on top of normal border, so we draw it separately or just change stroke color?)
        // Requirement: "borde de color rojo".
        // The normal border is drawn below with strokePaint (black54).
        // We probably want to override that or draw a red border on top.
        // Let's draw a Red stroke here specifically for this condition.
        final redBorderPaint =
            Paint()
              ..style = PaintingStyle.stroke
              ..color = palette.caries
              ..strokeWidth = 2.0;

        if (rect != null) {
          canvas.drawRect(rect, redBorderPaint);
        } else {
          canvas.drawPath(path, redBorderPaint);
        }
      } else {
        paint.color = palette.fill; // Sano
        paint.style = PaintingStyle.fill;
        if (rect != null) {
          canvas.drawRect(rect, paint);
        } else {
          canvas.drawPath(path, paint);
        }
      }

      // Draw Border
      paint.color = palette.border;
      paint.style = PaintingStyle.stroke;
      if (rect != null) {
        canvas.drawRect(rect, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }

      // Fractura (Zigzag)
      if (state == OdontogramaTools.fractura) {
        final redStroke =
            Paint()
              ..color = palette.caries
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;

        void drawZigzag(Offset p1, Offset p2) {
          final path = Path();
          path.moveTo(p1.dx, p1.dy);
          final dx = p2.dx - p1.dx;
          final dy = p2.dy - p1.dy;
          const steps = 4;
          for (int i = 0; i < steps; i++) {
            final x = p1.dx + dx * (i + 0.5) / steps;
            final y = p1.dy + dy * (i + 0.5) / steps;
            // Simple approx: wiggle perp to main dir
            const len = 3.0; // Amplitude
            double perpX = 0;
            double perpY = 0;
            if (dx.abs() > dy.abs()) {
              perpY = len;
            } else {
              perpX = len;
            }

            final sign = (i % 2 == 0) ? 1 : -1;
            path.lineTo(x + perpX * sign, y + perpY * sign);
          }
          path.lineTo(p2.dx, p2.dy);
          canvas.drawPath(path, redStroke);
        }

        // Recortar al área de la superficie para que el zigzag no invada
        // piezas/superficies vecinas.
        canvas.save();
        if (rect != null) {
          canvas.clipRect(rect.deflate(1));
          drawZigzag(rect.topLeft, rect.bottomRight);
          drawZigzag(rect.topRight, rect.bottomLeft);
        } else {
          canvas.clipPath(path);
          final bounds = path.getBounds();
          drawZigzag(bounds.topLeft, bounds.bottomRight);
        }
        canvas.restore();
      }
    }

    // Draw all surfaces
    drawSurface(topPath, stateTop);
    drawSurface(bottomPath, stateBottom);
    drawSurface(leftPath, stateLeft);
    drawSurface(rightPath, stateRight);
    drawSurface(
      Path(),
      stateCenter,
      rect: centerRect,
    ); // Special for center rect

    // Global Overlays
    if (globalState == OdontogramaTools.ausente) {
      // Diente ausente: X azul (convención odontológica; se distingue de
      // "por extraer" que es una sola diagonal roja).
      final blueStroke =
          Paint()
            ..color = palette.obturacion
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(w * 0.15, h * 0.15),
        Offset(w * 0.85, h * 0.85),
        blueStroke,
      );
      canvas.drawLine(
        Offset(w * 0.85, h * 0.15),
        Offset(w * 0.15, h * 0.85),
        blueStroke,
      );
    }

    if (globalState == OdontogramaTools.porExtraer) {
      // Red Slash /
      final redStroke =
          Paint()
            ..color = palette.caries
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(w * 0.2, h), Offset(w * 0.8, 0), redStroke);
    }

    if (globalState == OdontogramaTools.erupcion) {
      // Blue Arrow
      final blueStroke =
          Paint()
            ..color = palette.obturacion
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
      // Draw arrow
      // Eruption: Diente saliendo.
      // Upper tooth: erupts downwards. Lower tooth: erupts upwards.
      // Doc says: "Flecha azul apuntando hacia oclusal".
      // Oclusal is the center line.
      // So Upper: Arrow points Down. Lower: Arrow points Up.

      double startY = isUpper ? 0 : h;
      double endY = isUpper ? h / 2 : h / 2; // Point to center

      canvas.drawLine(Offset(w / 2, startY), Offset(w / 2, endY), blueStroke);
      // Arrow head
      if (isUpper) {
        // V shape at endY
        canvas.drawLine(
          Offset(w / 2, endY),
          Offset(w / 2 - 5, endY - 5),
          blueStroke,
        );
        canvas.drawLine(
          Offset(w / 2, endY),
          Offset(w / 2 + 5, endY - 5),
          blueStroke,
        );
      } else {
        // ^ shape at endY
        canvas.drawLine(
          Offset(w / 2, endY),
          Offset(w / 2 - 5, endY + 5),
          blueStroke,
        );
        canvas.drawLine(
          Offset(w / 2, endY),
          Offset(w / 2 + 5, endY + 5),
          blueStroke,
        );
      }
    }

    if (globalState == OdontogramaTools.protesisFija) {
      final stroke =
          Paint()
            ..color = palette.global
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
      // Recuadro de la pieza (pilar/póntico).
      canvas.drawRect(Rect.fromLTWH(1, 1, w - 2, h - 2), stroke);
      // Barra conectora horizontal: las de piezas contiguas se encuentran en el
      // borde compartido y el puente se lee como una unidad.
      final bar =
          Paint()
            ..color = palette.global
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), bar);
    }

    // Sellador (S) — escala con el tamaño de la pieza (antes 36 fijo se salía).
    if (hasSellador) {
      final textStyle = TextStyle(
        color: palette.obturacion,
        fontSize: h * 0.55,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(text: 'S', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ToothPainter oldDelegate) {
    return stateTop != oldDelegate.stateTop ||
        stateBottom != oldDelegate.stateBottom ||
        stateLeft != oldDelegate.stateLeft ||
        stateRight != oldDelegate.stateRight ||
        stateCenter != oldDelegate.stateCenter ||
        globalState != oldDelegate.globalState ||
        hasSellador != oldDelegate.hasSellador ||
        isUpper != oldDelegate.isUpper ||
        palette.fill != oldDelegate.palette.fill ||
        palette.caries != oldDelegate.palette.caries ||
        palette.obturacion != oldDelegate.palette.obturacion ||
        palette.border != oldDelegate.palette.border;
  }
}
