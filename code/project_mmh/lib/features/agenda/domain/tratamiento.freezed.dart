// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tratamiento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tratamiento {

@JsonKey(name: 'id_tratamiento') int? get idTratamiento;@JsonKey(name: 'id_clinica') int get idClinica;@JsonKey(name: 'id_expediente') String get idExpediente;@JsonKey(name: 'id_objetivo') int? get idObjetivo;@JsonKey(name: 'nombre_tratamiento') String get nombreTratamiento;@JsonKey(name: 'fecha_creacion') String get fechaCreacion;@JsonKey(name: 'estado') String get estado;
/// Create a copy of Tratamiento
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TratamientoCopyWith<Tratamiento> get copyWith => _$TratamientoCopyWithImpl<Tratamiento>(this as Tratamiento, _$identity);

  /// Serializes this Tratamiento to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tratamiento&&(identical(other.idTratamiento, idTratamiento) || other.idTratamiento == idTratamiento)&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.idExpediente, idExpediente) || other.idExpediente == idExpediente)&&(identical(other.idObjetivo, idObjetivo) || other.idObjetivo == idObjetivo)&&(identical(other.nombreTratamiento, nombreTratamiento) || other.nombreTratamiento == nombreTratamiento)&&(identical(other.fechaCreacion, fechaCreacion) || other.fechaCreacion == fechaCreacion)&&(identical(other.estado, estado) || other.estado == estado));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idTratamiento,idClinica,idExpediente,idObjetivo,nombreTratamiento,fechaCreacion,estado);

@override
String toString() {
  return 'Tratamiento(idTratamiento: $idTratamiento, idClinica: $idClinica, idExpediente: $idExpediente, idObjetivo: $idObjetivo, nombreTratamiento: $nombreTratamiento, fechaCreacion: $fechaCreacion, estado: $estado)';
}


}

/// @nodoc
abstract mixin class $TratamientoCopyWith<$Res>  {
  factory $TratamientoCopyWith(Tratamiento value, $Res Function(Tratamiento) _then) = _$TratamientoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_tratamiento') int? idTratamiento,@JsonKey(name: 'id_clinica') int idClinica,@JsonKey(name: 'id_expediente') String idExpediente,@JsonKey(name: 'id_objetivo') int? idObjetivo,@JsonKey(name: 'nombre_tratamiento') String nombreTratamiento,@JsonKey(name: 'fecha_creacion') String fechaCreacion,@JsonKey(name: 'estado') String estado
});




}
/// @nodoc
class _$TratamientoCopyWithImpl<$Res>
    implements $TratamientoCopyWith<$Res> {
  _$TratamientoCopyWithImpl(this._self, this._then);

  final Tratamiento _self;
  final $Res Function(Tratamiento) _then;

/// Create a copy of Tratamiento
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idTratamiento = freezed,Object? idClinica = null,Object? idExpediente = null,Object? idObjetivo = freezed,Object? nombreTratamiento = null,Object? fechaCreacion = null,Object? estado = null,}) {
  return _then(_self.copyWith(
idTratamiento: freezed == idTratamiento ? _self.idTratamiento : idTratamiento // ignore: cast_nullable_to_non_nullable
as int?,idClinica: null == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int,idExpediente: null == idExpediente ? _self.idExpediente : idExpediente // ignore: cast_nullable_to_non_nullable
as String,idObjetivo: freezed == idObjetivo ? _self.idObjetivo : idObjetivo // ignore: cast_nullable_to_non_nullable
as int?,nombreTratamiento: null == nombreTratamiento ? _self.nombreTratamiento : nombreTratamiento // ignore: cast_nullable_to_non_nullable
as String,fechaCreacion: null == fechaCreacion ? _self.fechaCreacion : fechaCreacion // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Tratamiento].
extension TratamientoPatterns on Tratamiento {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tratamiento value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tratamiento() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tratamiento value)  $default,){
final _that = this;
switch (_that) {
case _Tratamiento():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tratamiento value)?  $default,){
final _that = this;
switch (_that) {
case _Tratamiento() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_tratamiento')  int? idTratamiento, @JsonKey(name: 'id_clinica')  int idClinica, @JsonKey(name: 'id_expediente')  String idExpediente, @JsonKey(name: 'id_objetivo')  int? idObjetivo, @JsonKey(name: 'nombre_tratamiento')  String nombreTratamiento, @JsonKey(name: 'fecha_creacion')  String fechaCreacion, @JsonKey(name: 'estado')  String estado)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tratamiento() when $default != null:
return $default(_that.idTratamiento,_that.idClinica,_that.idExpediente,_that.idObjetivo,_that.nombreTratamiento,_that.fechaCreacion,_that.estado);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_tratamiento')  int? idTratamiento, @JsonKey(name: 'id_clinica')  int idClinica, @JsonKey(name: 'id_expediente')  String idExpediente, @JsonKey(name: 'id_objetivo')  int? idObjetivo, @JsonKey(name: 'nombre_tratamiento')  String nombreTratamiento, @JsonKey(name: 'fecha_creacion')  String fechaCreacion, @JsonKey(name: 'estado')  String estado)  $default,) {final _that = this;
switch (_that) {
case _Tratamiento():
return $default(_that.idTratamiento,_that.idClinica,_that.idExpediente,_that.idObjetivo,_that.nombreTratamiento,_that.fechaCreacion,_that.estado);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_tratamiento')  int? idTratamiento, @JsonKey(name: 'id_clinica')  int idClinica, @JsonKey(name: 'id_expediente')  String idExpediente, @JsonKey(name: 'id_objetivo')  int? idObjetivo, @JsonKey(name: 'nombre_tratamiento')  String nombreTratamiento, @JsonKey(name: 'fecha_creacion')  String fechaCreacion, @JsonKey(name: 'estado')  String estado)?  $default,) {final _that = this;
switch (_that) {
case _Tratamiento() when $default != null:
return $default(_that.idTratamiento,_that.idClinica,_that.idExpediente,_that.idObjetivo,_that.nombreTratamiento,_that.fechaCreacion,_that.estado);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tratamiento implements Tratamiento {
  const _Tratamiento({@JsonKey(name: 'id_tratamiento') this.idTratamiento, @JsonKey(name: 'id_clinica') required this.idClinica, @JsonKey(name: 'id_expediente') required this.idExpediente, @JsonKey(name: 'id_objetivo') this.idObjetivo, @JsonKey(name: 'nombre_tratamiento') required this.nombreTratamiento, @JsonKey(name: 'fecha_creacion') required this.fechaCreacion, @JsonKey(name: 'estado') required this.estado});
  factory _Tratamiento.fromJson(Map<String, dynamic> json) => _$TratamientoFromJson(json);

@override@JsonKey(name: 'id_tratamiento') final  int? idTratamiento;
@override@JsonKey(name: 'id_clinica') final  int idClinica;
@override@JsonKey(name: 'id_expediente') final  String idExpediente;
@override@JsonKey(name: 'id_objetivo') final  int? idObjetivo;
@override@JsonKey(name: 'nombre_tratamiento') final  String nombreTratamiento;
@override@JsonKey(name: 'fecha_creacion') final  String fechaCreacion;
@override@JsonKey(name: 'estado') final  String estado;

/// Create a copy of Tratamiento
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TratamientoCopyWith<_Tratamiento> get copyWith => __$TratamientoCopyWithImpl<_Tratamiento>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TratamientoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tratamiento&&(identical(other.idTratamiento, idTratamiento) || other.idTratamiento == idTratamiento)&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.idExpediente, idExpediente) || other.idExpediente == idExpediente)&&(identical(other.idObjetivo, idObjetivo) || other.idObjetivo == idObjetivo)&&(identical(other.nombreTratamiento, nombreTratamiento) || other.nombreTratamiento == nombreTratamiento)&&(identical(other.fechaCreacion, fechaCreacion) || other.fechaCreacion == fechaCreacion)&&(identical(other.estado, estado) || other.estado == estado));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idTratamiento,idClinica,idExpediente,idObjetivo,nombreTratamiento,fechaCreacion,estado);

@override
String toString() {
  return 'Tratamiento(idTratamiento: $idTratamiento, idClinica: $idClinica, idExpediente: $idExpediente, idObjetivo: $idObjetivo, nombreTratamiento: $nombreTratamiento, fechaCreacion: $fechaCreacion, estado: $estado)';
}


}

/// @nodoc
abstract mixin class _$TratamientoCopyWith<$Res> implements $TratamientoCopyWith<$Res> {
  factory _$TratamientoCopyWith(_Tratamiento value, $Res Function(_Tratamiento) _then) = __$TratamientoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_tratamiento') int? idTratamiento,@JsonKey(name: 'id_clinica') int idClinica,@JsonKey(name: 'id_expediente') String idExpediente,@JsonKey(name: 'id_objetivo') int? idObjetivo,@JsonKey(name: 'nombre_tratamiento') String nombreTratamiento,@JsonKey(name: 'fecha_creacion') String fechaCreacion,@JsonKey(name: 'estado') String estado
});




}
/// @nodoc
class __$TratamientoCopyWithImpl<$Res>
    implements _$TratamientoCopyWith<$Res> {
  __$TratamientoCopyWithImpl(this._self, this._then);

  final _Tratamiento _self;
  final $Res Function(_Tratamiento) _then;

/// Create a copy of Tratamiento
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idTratamiento = freezed,Object? idClinica = null,Object? idExpediente = null,Object? idObjetivo = freezed,Object? nombreTratamiento = null,Object? fechaCreacion = null,Object? estado = null,}) {
  return _then(_Tratamiento(
idTratamiento: freezed == idTratamiento ? _self.idTratamiento : idTratamiento // ignore: cast_nullable_to_non_nullable
as int?,idClinica: null == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int,idExpediente: null == idExpediente ? _self.idExpediente : idExpediente // ignore: cast_nullable_to_non_nullable
as String,idObjetivo: freezed == idObjetivo ? _self.idObjetivo : idObjetivo // ignore: cast_nullable_to_non_nullable
as int?,nombreTratamiento: null == nombreTratamiento ? _self.nombreTratamiento : nombreTratamiento // ignore: cast_nullable_to_non_nullable
as String,fechaCreacion: null == fechaCreacion ? _self.fechaCreacion : fechaCreacion // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
