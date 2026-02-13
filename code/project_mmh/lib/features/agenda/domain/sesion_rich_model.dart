import 'package:project_mmh/features/agenda/domain/sesion.dart';

/// Enriched session model that includes the treatment name, patient name,
/// clinic name, and clinic color for display in the agenda timeline.
class SesionRichModel {
  final Sesion sesion;
  final String nombreTratamiento;
  final String nombrePaciente;
  final String nombreClinica;
  final String colorClinica; // Hex string for accent bar

  SesionRichModel({
    required this.sesion,
    required this.nombreTratamiento,
    required this.nombrePaciente,
    required this.nombreClinica,
    required this.colorClinica,
  });
}
