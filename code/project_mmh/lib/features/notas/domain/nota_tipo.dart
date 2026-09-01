import 'package:freezed_annotation/freezed_annotation.dart';

enum NotaTipo {
  @JsonValue('general')
  general,
  @JsonValue('prepaciente')
  prepaciente,
  @JsonValue('lista_materiales')
  listaMateriales,
  @JsonValue('cotizacion')
  cotizacion;

  String get dbValue => switch (this) {
    NotaTipo.general => 'general',
    NotaTipo.prepaciente => 'prepaciente',
    NotaTipo.listaMateriales => 'lista_materiales',
    NotaTipo.cotizacion => 'cotizacion',
  };

  String get label => switch (this) {
    NotaTipo.general => 'General',
    NotaTipo.prepaciente => 'Prepaciente',
    NotaTipo.listaMateriales => 'Lista de materiales',
    NotaTipo.cotizacion => 'Cotización',
  };
}

enum NotaOrigen {
  @JsonValue('manual')
  manual,
  @JsonValue('imagen')
  imagen,
  @JsonValue('pdf')
  pdf;

  String get dbValue => switch (this) {
    NotaOrigen.manual => 'manual',
    NotaOrigen.imagen => 'imagen',
    NotaOrigen.pdf => 'pdf',
  };

  String get label => switch (this) {
    NotaOrigen.manual => 'Manual',
    NotaOrigen.imagen => 'Imagen',
    NotaOrigen.pdf => 'PDF',
  };
}
