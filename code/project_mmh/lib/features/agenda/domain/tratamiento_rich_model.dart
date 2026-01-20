import 'package:project_mmh/features/agenda/domain/tratamiento.dart';

class TratamientoRichModel {
  final Tratamiento tratamiento;
  final String nombreClinica;
  final String colorClinica; // Hex string
  final String nombrePaciente;
  final String idExpediente;
  final DateTime? proximaSesion;

  TratamientoRichModel({
    required this.tratamiento,
    required this.nombreClinica,
    required this.colorClinica,
    required this.nombrePaciente,
    required this.idExpediente,
    this.proximaSesion,
  });
}
