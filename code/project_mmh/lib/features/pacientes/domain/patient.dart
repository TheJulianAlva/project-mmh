// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    @JsonKey(name: 'id_expediente') required String idExpediente,
    @JsonKey(name: 'nombre') required String nombre,
    @JsonKey(name: 'primer_apellido') required String primerApellido,
    @JsonKey(name: 'segundo_apellido') String? segundoApellido,
    @JsonKey(name: 'edad') required int edad,
    @JsonKey(name: 'sexo') required String sexo,
    @JsonKey(name: 'telefono') String? telefono,
    @JsonKey(name: 'padecimiento_relevante') String? padecimientoRelevante,
    @JsonKey(name: 'informacion_adicional') String? informacionAdicional,
    @JsonKey(name: 'imagenes_paths', fromJson: _parseImages)
    @Default([])
    List<String> imagenesPaths,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt, // Soft Delete support
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}

List<String> _parseImages(Object? value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  } else if (value is String) {
    if (value.trim().isEmpty) return [];
    return value.split('|');
  }
  return [];
}
