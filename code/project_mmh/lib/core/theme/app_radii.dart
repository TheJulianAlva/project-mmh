import 'package:flutter/widgets.dart';

/// Los 4 radios del sistema. Nada en pantalla usa otro valor.
abstract final class AppRadii {
  static const double sm = 8; // chips, campos
  static const double md = 12; // tarjetas, hojas
  static const double lg = 20; // contenedores destacados
  static const double pill = 999; // CTAs y chips de filtro

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
