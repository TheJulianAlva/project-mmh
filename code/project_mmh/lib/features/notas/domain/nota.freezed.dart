// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nota.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Nota {

@JsonKey(name: 'id_nota') int? get idNota;@JsonKey(name: 'tipo') NotaTipo get tipo;@JsonKey(name: 'contenido') String? get contenido;@JsonKey(name: 'fecha') String get fecha;@JsonKey(name: 'id_paciente') String? get idPaciente;@JsonKey(name: 'id_clinica') int? get idClinica;@JsonKey(name: 'id_nota_relacionada') int? get idNotaRelacionada;@JsonKey(name: 'items_json', fromJson: _parseItems) List<NotaItem> get items;@JsonKey(name: 'proveedor') String? get proveedor;@JsonKey(name: 'origen') NotaOrigen get origen;@JsonKey(name: 'nombre_contacto') String? get nombreContacto;@JsonKey(name: 'telefono') String? get telefono;@JsonKey(name: 'tratamiento_probable') String? get tratamientoProbable;@JsonKey(name: 'convertido', fromJson: _boolFromDb) bool get convertido;@JsonKey(name: 'id_paciente_convertido') String? get idPacienteConvertido;
/// Create a copy of Nota
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotaCopyWith<Nota> get copyWith => _$NotaCopyWithImpl<Nota>(this as Nota, _$identity);

  /// Serializes this Nota to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Nota&&(identical(other.idNota, idNota) || other.idNota == idNota)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.contenido, contenido) || other.contenido == contenido)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.idPaciente, idPaciente) || other.idPaciente == idPaciente)&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.idNotaRelacionada, idNotaRelacionada) || other.idNotaRelacionada == idNotaRelacionada)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.proveedor, proveedor) || other.proveedor == proveedor)&&(identical(other.origen, origen) || other.origen == origen)&&(identical(other.nombreContacto, nombreContacto) || other.nombreContacto == nombreContacto)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.tratamientoProbable, tratamientoProbable) || other.tratamientoProbable == tratamientoProbable)&&(identical(other.convertido, convertido) || other.convertido == convertido)&&(identical(other.idPacienteConvertido, idPacienteConvertido) || other.idPacienteConvertido == idPacienteConvertido));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idNota,tipo,contenido,fecha,idPaciente,idClinica,idNotaRelacionada,const DeepCollectionEquality().hash(items),proveedor,origen,nombreContacto,telefono,tratamientoProbable,convertido,idPacienteConvertido);

@override
String toString() {
  return 'Nota(idNota: $idNota, tipo: $tipo, contenido: $contenido, fecha: $fecha, idPaciente: $idPaciente, idClinica: $idClinica, idNotaRelacionada: $idNotaRelacionada, items: $items, proveedor: $proveedor, origen: $origen, nombreContacto: $nombreContacto, telefono: $telefono, tratamientoProbable: $tratamientoProbable, convertido: $convertido, idPacienteConvertido: $idPacienteConvertido)';
}


}

/// @nodoc
abstract mixin class $NotaCopyWith<$Res>  {
  factory $NotaCopyWith(Nota value, $Res Function(Nota) _then) = _$NotaCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_nota') int? idNota,@JsonKey(name: 'tipo') NotaTipo tipo,@JsonKey(name: 'contenido') String? contenido,@JsonKey(name: 'fecha') String fecha,@JsonKey(name: 'id_paciente') String? idPaciente,@JsonKey(name: 'id_clinica') int? idClinica,@JsonKey(name: 'id_nota_relacionada') int? idNotaRelacionada,@JsonKey(name: 'items_json', fromJson: _parseItems) List<NotaItem> items,@JsonKey(name: 'proveedor') String? proveedor,@JsonKey(name: 'origen') NotaOrigen origen,@JsonKey(name: 'nombre_contacto') String? nombreContacto,@JsonKey(name: 'telefono') String? telefono,@JsonKey(name: 'tratamiento_probable') String? tratamientoProbable,@JsonKey(name: 'convertido', fromJson: _boolFromDb) bool convertido,@JsonKey(name: 'id_paciente_convertido') String? idPacienteConvertido
});




}
/// @nodoc
class _$NotaCopyWithImpl<$Res>
    implements $NotaCopyWith<$Res> {
  _$NotaCopyWithImpl(this._self, this._then);

  final Nota _self;
  final $Res Function(Nota) _then;

/// Create a copy of Nota
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idNota = freezed,Object? tipo = null,Object? contenido = freezed,Object? fecha = null,Object? idPaciente = freezed,Object? idClinica = freezed,Object? idNotaRelacionada = freezed,Object? items = null,Object? proveedor = freezed,Object? origen = null,Object? nombreContacto = freezed,Object? telefono = freezed,Object? tratamientoProbable = freezed,Object? convertido = null,Object? idPacienteConvertido = freezed,}) {
  return _then(_self.copyWith(
idNota: freezed == idNota ? _self.idNota : idNota // ignore: cast_nullable_to_non_nullable
as int?,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as NotaTipo,contenido: freezed == contenido ? _self.contenido : contenido // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as String,idPaciente: freezed == idPaciente ? _self.idPaciente : idPaciente // ignore: cast_nullable_to_non_nullable
as String?,idClinica: freezed == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int?,idNotaRelacionada: freezed == idNotaRelacionada ? _self.idNotaRelacionada : idNotaRelacionada // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<NotaItem>,proveedor: freezed == proveedor ? _self.proveedor : proveedor // ignore: cast_nullable_to_non_nullable
as String?,origen: null == origen ? _self.origen : origen // ignore: cast_nullable_to_non_nullable
as NotaOrigen,nombreContacto: freezed == nombreContacto ? _self.nombreContacto : nombreContacto // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,tratamientoProbable: freezed == tratamientoProbable ? _self.tratamientoProbable : tratamientoProbable // ignore: cast_nullable_to_non_nullable
as String?,convertido: null == convertido ? _self.convertido : convertido // ignore: cast_nullable_to_non_nullable
as bool,idPacienteConvertido: freezed == idPacienteConvertido ? _self.idPacienteConvertido : idPacienteConvertido // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Nota].
extension NotaPatterns on Nota {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Nota value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Nota() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Nota value)  $default,){
final _that = this;
switch (_that) {
case _Nota():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Nota value)?  $default,){
final _that = this;
switch (_that) {
case _Nota() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_nota')  int? idNota, @JsonKey(name: 'tipo')  NotaTipo tipo, @JsonKey(name: 'contenido')  String? contenido, @JsonKey(name: 'fecha')  String fecha, @JsonKey(name: 'id_paciente')  String? idPaciente, @JsonKey(name: 'id_clinica')  int? idClinica, @JsonKey(name: 'id_nota_relacionada')  int? idNotaRelacionada, @JsonKey(name: 'items_json', fromJson: _parseItems)  List<NotaItem> items, @JsonKey(name: 'proveedor')  String? proveedor, @JsonKey(name: 'origen')  NotaOrigen origen, @JsonKey(name: 'nombre_contacto')  String? nombreContacto, @JsonKey(name: 'telefono')  String? telefono, @JsonKey(name: 'tratamiento_probable')  String? tratamientoProbable, @JsonKey(name: 'convertido', fromJson: _boolFromDb)  bool convertido, @JsonKey(name: 'id_paciente_convertido')  String? idPacienteConvertido)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Nota() when $default != null:
return $default(_that.idNota,_that.tipo,_that.contenido,_that.fecha,_that.idPaciente,_that.idClinica,_that.idNotaRelacionada,_that.items,_that.proveedor,_that.origen,_that.nombreContacto,_that.telefono,_that.tratamientoProbable,_that.convertido,_that.idPacienteConvertido);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_nota')  int? idNota, @JsonKey(name: 'tipo')  NotaTipo tipo, @JsonKey(name: 'contenido')  String? contenido, @JsonKey(name: 'fecha')  String fecha, @JsonKey(name: 'id_paciente')  String? idPaciente, @JsonKey(name: 'id_clinica')  int? idClinica, @JsonKey(name: 'id_nota_relacionada')  int? idNotaRelacionada, @JsonKey(name: 'items_json', fromJson: _parseItems)  List<NotaItem> items, @JsonKey(name: 'proveedor')  String? proveedor, @JsonKey(name: 'origen')  NotaOrigen origen, @JsonKey(name: 'nombre_contacto')  String? nombreContacto, @JsonKey(name: 'telefono')  String? telefono, @JsonKey(name: 'tratamiento_probable')  String? tratamientoProbable, @JsonKey(name: 'convertido', fromJson: _boolFromDb)  bool convertido, @JsonKey(name: 'id_paciente_convertido')  String? idPacienteConvertido)  $default,) {final _that = this;
switch (_that) {
case _Nota():
return $default(_that.idNota,_that.tipo,_that.contenido,_that.fecha,_that.idPaciente,_that.idClinica,_that.idNotaRelacionada,_that.items,_that.proveedor,_that.origen,_that.nombreContacto,_that.telefono,_that.tratamientoProbable,_that.convertido,_that.idPacienteConvertido);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_nota')  int? idNota, @JsonKey(name: 'tipo')  NotaTipo tipo, @JsonKey(name: 'contenido')  String? contenido, @JsonKey(name: 'fecha')  String fecha, @JsonKey(name: 'id_paciente')  String? idPaciente, @JsonKey(name: 'id_clinica')  int? idClinica, @JsonKey(name: 'id_nota_relacionada')  int? idNotaRelacionada, @JsonKey(name: 'items_json', fromJson: _parseItems)  List<NotaItem> items, @JsonKey(name: 'proveedor')  String? proveedor, @JsonKey(name: 'origen')  NotaOrigen origen, @JsonKey(name: 'nombre_contacto')  String? nombreContacto, @JsonKey(name: 'telefono')  String? telefono, @JsonKey(name: 'tratamiento_probable')  String? tratamientoProbable, @JsonKey(name: 'convertido', fromJson: _boolFromDb)  bool convertido, @JsonKey(name: 'id_paciente_convertido')  String? idPacienteConvertido)?  $default,) {final _that = this;
switch (_that) {
case _Nota() when $default != null:
return $default(_that.idNota,_that.tipo,_that.contenido,_that.fecha,_that.idPaciente,_that.idClinica,_that.idNotaRelacionada,_that.items,_that.proveedor,_that.origen,_that.nombreContacto,_that.telefono,_that.tratamientoProbable,_that.convertido,_that.idPacienteConvertido);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Nota extends Nota {
  const _Nota({@JsonKey(name: 'id_nota') this.idNota, @JsonKey(name: 'tipo') required this.tipo, @JsonKey(name: 'contenido') this.contenido, @JsonKey(name: 'fecha') required this.fecha, @JsonKey(name: 'id_paciente') this.idPaciente, @JsonKey(name: 'id_clinica') this.idClinica, @JsonKey(name: 'id_nota_relacionada') this.idNotaRelacionada, @JsonKey(name: 'items_json', fromJson: _parseItems) final  List<NotaItem> items = const [], @JsonKey(name: 'proveedor') this.proveedor, @JsonKey(name: 'origen') this.origen = NotaOrigen.manual, @JsonKey(name: 'nombre_contacto') this.nombreContacto, @JsonKey(name: 'telefono') this.telefono, @JsonKey(name: 'tratamiento_probable') this.tratamientoProbable, @JsonKey(name: 'convertido', fromJson: _boolFromDb) this.convertido = false, @JsonKey(name: 'id_paciente_convertido') this.idPacienteConvertido}): _items = items,super._();
  factory _Nota.fromJson(Map<String, dynamic> json) => _$NotaFromJson(json);

@override@JsonKey(name: 'id_nota') final  int? idNota;
@override@JsonKey(name: 'tipo') final  NotaTipo tipo;
@override@JsonKey(name: 'contenido') final  String? contenido;
@override@JsonKey(name: 'fecha') final  String fecha;
@override@JsonKey(name: 'id_paciente') final  String? idPaciente;
@override@JsonKey(name: 'id_clinica') final  int? idClinica;
@override@JsonKey(name: 'id_nota_relacionada') final  int? idNotaRelacionada;
 final  List<NotaItem> _items;
@override@JsonKey(name: 'items_json', fromJson: _parseItems) List<NotaItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'proveedor') final  String? proveedor;
@override@JsonKey(name: 'origen') final  NotaOrigen origen;
@override@JsonKey(name: 'nombre_contacto') final  String? nombreContacto;
@override@JsonKey(name: 'telefono') final  String? telefono;
@override@JsonKey(name: 'tratamiento_probable') final  String? tratamientoProbable;
@override@JsonKey(name: 'convertido', fromJson: _boolFromDb) final  bool convertido;
@override@JsonKey(name: 'id_paciente_convertido') final  String? idPacienteConvertido;

/// Create a copy of Nota
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotaCopyWith<_Nota> get copyWith => __$NotaCopyWithImpl<_Nota>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Nota&&(identical(other.idNota, idNota) || other.idNota == idNota)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.contenido, contenido) || other.contenido == contenido)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.idPaciente, idPaciente) || other.idPaciente == idPaciente)&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.idNotaRelacionada, idNotaRelacionada) || other.idNotaRelacionada == idNotaRelacionada)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.proveedor, proveedor) || other.proveedor == proveedor)&&(identical(other.origen, origen) || other.origen == origen)&&(identical(other.nombreContacto, nombreContacto) || other.nombreContacto == nombreContacto)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.tratamientoProbable, tratamientoProbable) || other.tratamientoProbable == tratamientoProbable)&&(identical(other.convertido, convertido) || other.convertido == convertido)&&(identical(other.idPacienteConvertido, idPacienteConvertido) || other.idPacienteConvertido == idPacienteConvertido));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idNota,tipo,contenido,fecha,idPaciente,idClinica,idNotaRelacionada,const DeepCollectionEquality().hash(_items),proveedor,origen,nombreContacto,telefono,tratamientoProbable,convertido,idPacienteConvertido);

@override
String toString() {
  return 'Nota(idNota: $idNota, tipo: $tipo, contenido: $contenido, fecha: $fecha, idPaciente: $idPaciente, idClinica: $idClinica, idNotaRelacionada: $idNotaRelacionada, items: $items, proveedor: $proveedor, origen: $origen, nombreContacto: $nombreContacto, telefono: $telefono, tratamientoProbable: $tratamientoProbable, convertido: $convertido, idPacienteConvertido: $idPacienteConvertido)';
}


}

/// @nodoc
abstract mixin class _$NotaCopyWith<$Res> implements $NotaCopyWith<$Res> {
  factory _$NotaCopyWith(_Nota value, $Res Function(_Nota) _then) = __$NotaCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_nota') int? idNota,@JsonKey(name: 'tipo') NotaTipo tipo,@JsonKey(name: 'contenido') String? contenido,@JsonKey(name: 'fecha') String fecha,@JsonKey(name: 'id_paciente') String? idPaciente,@JsonKey(name: 'id_clinica') int? idClinica,@JsonKey(name: 'id_nota_relacionada') int? idNotaRelacionada,@JsonKey(name: 'items_json', fromJson: _parseItems) List<NotaItem> items,@JsonKey(name: 'proveedor') String? proveedor,@JsonKey(name: 'origen') NotaOrigen origen,@JsonKey(name: 'nombre_contacto') String? nombreContacto,@JsonKey(name: 'telefono') String? telefono,@JsonKey(name: 'tratamiento_probable') String? tratamientoProbable,@JsonKey(name: 'convertido', fromJson: _boolFromDb) bool convertido,@JsonKey(name: 'id_paciente_convertido') String? idPacienteConvertido
});




}
/// @nodoc
class __$NotaCopyWithImpl<$Res>
    implements _$NotaCopyWith<$Res> {
  __$NotaCopyWithImpl(this._self, this._then);

  final _Nota _self;
  final $Res Function(_Nota) _then;

/// Create a copy of Nota
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idNota = freezed,Object? tipo = null,Object? contenido = freezed,Object? fecha = null,Object? idPaciente = freezed,Object? idClinica = freezed,Object? idNotaRelacionada = freezed,Object? items = null,Object? proveedor = freezed,Object? origen = null,Object? nombreContacto = freezed,Object? telefono = freezed,Object? tratamientoProbable = freezed,Object? convertido = null,Object? idPacienteConvertido = freezed,}) {
  return _then(_Nota(
idNota: freezed == idNota ? _self.idNota : idNota // ignore: cast_nullable_to_non_nullable
as int?,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as NotaTipo,contenido: freezed == contenido ? _self.contenido : contenido // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as String,idPaciente: freezed == idPaciente ? _self.idPaciente : idPaciente // ignore: cast_nullable_to_non_nullable
as String?,idClinica: freezed == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int?,idNotaRelacionada: freezed == idNotaRelacionada ? _self.idNotaRelacionada : idNotaRelacionada // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<NotaItem>,proveedor: freezed == proveedor ? _self.proveedor : proveedor // ignore: cast_nullable_to_non_nullable
as String?,origen: null == origen ? _self.origen : origen // ignore: cast_nullable_to_non_nullable
as NotaOrigen,nombreContacto: freezed == nombreContacto ? _self.nombreContacto : nombreContacto // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,tratamientoProbable: freezed == tratamientoProbable ? _self.tratamientoProbable : tratamientoProbable // ignore: cast_nullable_to_non_nullable
as String?,convertido: null == convertido ? _self.convertido : convertido // ignore: cast_nullable_to_non_nullable
as bool,idPacienteConvertido: freezed == idPacienteConvertido ? _self.idPacienteConvertido : idPacienteConvertido // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
