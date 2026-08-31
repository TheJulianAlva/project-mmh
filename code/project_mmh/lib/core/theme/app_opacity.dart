/// Opacidades nombradas por intención. Sustituye los `withValues(alpha:)`
/// crudos repartidos por la app.
abstract final class AppOpacity {
  static const double hairline = 0.08; // bordes muy sutiles
  static const double subtle = 0.12; // fondos de badge, indicadores
  static const double muted = 0.40; // texto / iconos deshabilitados
  static const double strong = 0.70; // overlays
}
