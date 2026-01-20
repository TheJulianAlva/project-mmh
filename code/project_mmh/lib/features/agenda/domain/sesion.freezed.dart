// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sesion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Sesion {

@JsonKey(name: 'id_sesion') int? get idSesion;@JsonKey(name: 'id_tratamiento') int get idTratamiento;@JsonKey(name: 'fecha_inicio') String get fechaInicio;@JsonKey(name: 'fecha_fin') String get fechaFin;@JsonKey(name: 'estado_asistencia') String? get estadoAsistencia;
/// Create a copy of Sesion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SesionCopyWith<Sesion> get copyWith => _$SesionCopyWithImpl<Sesion>(this as Sesion, _$identity);

  /// Serializes this Sesion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sesion&&(identical(other.idSesion, idSesion) || other.idSesion == idSesion)&&(identical(other.idTratamiento, idTratamiento) || other.idTratamiento == idTratamiento)&&(identical(other.fechaInicio, fechaInicio) || other.fechaInicio == fechaInicio)&&(identical(other.fechaFin, fechaFin) || other.fechaFin == fechaFin)&&(identical(other.estadoAsistencia, estadoAsistencia) || other.estadoAsistencia == estadoAsistencia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idSesion,idTratamiento,fechaInicio,fechaFin,estadoAsistencia);

@override
String toString() {
  return 'Sesion(idSesion: $idSesion, idTratamiento: $idTratamiento, fechaInicio: $fechaInicio, fechaFin: $fechaFin, estadoAsistencia: $estadoAsistencia)';
}


}

/// @nodoc
abstract mixin class $SesionCopyWith<$Res>  {
  factory $SesionCopyWith(Sesion value, $Res Function(Sesion) _then) = _$SesionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_sesion') int? idSesion,@JsonKey(name: 'id_tratamiento') int idTratamiento,@JsonKey(name: 'fecha_inicio') String fechaInicio,@JsonKey(name: 'fecha_fin') String fechaFin,@JsonKey(name: 'estado_asistencia') String? estadoAsistencia
});




}
/// @nodoc
class _$SesionCopyWithImpl<$Res>
    implements $SesionCopyWith<$Res> {
  _$SesionCopyWithImpl(this._self, this._then);

  final Sesion _self;
  final $Res Function(Sesion) _then;

/// Create a copy of Sesion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idSesion = freezed,Object? idTratamiento = null,Object? fechaInicio = null,Object? fechaFin = null,Object? estadoAsistencia = freezed,}) {
  return _then(_self.copyWith(
idSesion: freezed == idSesion ? _self.idSesion : idSesion // ignore: cast_nullable_to_non_nullable
as int?,idTratamiento: null == idTratamiento ? _self.idTratamiento : idTratamiento // ignore: cast_nullable_to_non_nullable
as int,fechaInicio: null == fechaInicio ? _self.fechaInicio : fechaInicio // ignore: cast_nullable_to_non_nullable
as String,fechaFin: null == fechaFin ? _self.fechaFin : fechaFin // ignore: cast_nullable_to_non_nullable
as String,estadoAsistencia: freezed == estadoAsistencia ? _self.estadoAsistencia : estadoAsistencia // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Sesion].
extension SesionPatterns on Sesion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sesion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sesion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sesion value)  $default,){
final _that = this;
switch (_that) {
case _Sesion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sesion value)?  $default,){
final _that = this;
switch (_that) {
case _Sesion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_sesion')  int? idSesion, @JsonKey(name: 'id_tratamiento')  int idTratamiento, @JsonKey(name: 'fecha_inicio')  String fechaInicio, @JsonKey(name: 'fecha_fin')  String fechaFin, @JsonKey(name: 'estado_asistencia')  String? estadoAsistencia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sesion() when $default != null:
return $default(_that.idSesion,_that.idTratamiento,_that.fechaInicio,_that.fechaFin,_that.estadoAsistencia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_sesion')  int? idSesion, @JsonKey(name: 'id_tratamiento')  int idTratamiento, @JsonKey(name: 'fecha_inicio')  String fechaInicio, @JsonKey(name: 'fecha_fin')  String fechaFin, @JsonKey(name: 'estado_asistencia')  String? estadoAsistencia)  $default,) {final _that = this;
switch (_that) {
case _Sesion():
return $default(_that.idSesion,_that.idTratamiento,_that.fechaInicio,_that.fechaFin,_that.estadoAsistencia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_sesion')  int? idSesion, @JsonKey(name: 'id_tratamiento')  int idTratamiento, @JsonKey(name: 'fecha_inicio')  String fechaInicio, @JsonKey(name: 'fecha_fin')  String fechaFin, @JsonKey(name: 'estado_asistencia')  String? estadoAsistencia)?  $default,) {final _that = this;
switch (_that) {
case _Sesion() when $default != null:
return $default(_that.idSesion,_that.idTratamiento,_that.fechaInicio,_that.fechaFin,_that.estadoAsistencia);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sesion implements Sesion {
  const _Sesion({@JsonKey(name: 'id_sesion') this.idSesion, @JsonKey(name: 'id_tratamiento') required this.idTratamiento, @JsonKey(name: 'fecha_inicio') required this.fechaInicio, @JsonKey(name: 'fecha_fin') required this.fechaFin, @JsonKey(name: 'estado_asistencia') this.estadoAsistencia});
  factory _Sesion.fromJson(Map<String, dynamic> json) => _$SesionFromJson(json);

@override@JsonKey(name: 'id_sesion') final  int? idSesion;
@override@JsonKey(name: 'id_tratamiento') final  int idTratamiento;
@override@JsonKey(name: 'fecha_inicio') final  String fechaInicio;
@override@JsonKey(name: 'fecha_fin') final  String fechaFin;
@override@JsonKey(name: 'estado_asistencia') final  String? estadoAsistencia;

/// Create a copy of Sesion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SesionCopyWith<_Sesion> get copyWith => __$SesionCopyWithImpl<_Sesion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SesionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sesion&&(identical(other.idSesion, idSesion) || other.idSesion == idSesion)&&(identical(other.idTratamiento, idTratamiento) || other.idTratamiento == idTratamiento)&&(identical(other.fechaInicio, fechaInicio) || other.fechaInicio == fechaInicio)&&(identical(other.fechaFin, fechaFin) || other.fechaFin == fechaFin)&&(identical(other.estadoAsistencia, estadoAsistencia) || other.estadoAsistencia == estadoAsistencia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idSesion,idTratamiento,fechaInicio,fechaFin,estadoAsistencia);

@override
String toString() {
  return 'Sesion(idSesion: $idSesion, idTratamiento: $idTratamiento, fechaInicio: $fechaInicio, fechaFin: $fechaFin, estadoAsistencia: $estadoAsistencia)';
}


}

/// @nodoc
abstract mixin class _$SesionCopyWith<$Res> implements $SesionCopyWith<$Res> {
  factory _$SesionCopyWith(_Sesion value, $Res Function(_Sesion) _then) = __$SesionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_sesion') int? idSesion,@JsonKey(name: 'id_tratamiento') int idTratamiento,@JsonKey(name: 'fecha_inicio') String fechaInicio,@JsonKey(name: 'fecha_fin') String fechaFin,@JsonKey(name: 'estado_asistencia') String? estadoAsistencia
});




}
/// @nodoc
class __$SesionCopyWithImpl<$Res>
    implements _$SesionCopyWith<$Res> {
  __$SesionCopyWithImpl(this._self, this._then);

  final _Sesion _self;
  final $Res Function(_Sesion) _then;

/// Create a copy of Sesion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idSesion = freezed,Object? idTratamiento = null,Object? fechaInicio = null,Object? fechaFin = null,Object? estadoAsistencia = freezed,}) {
  return _then(_Sesion(
idSesion: freezed == idSesion ? _self.idSesion : idSesion // ignore: cast_nullable_to_non_nullable
as int?,idTratamiento: null == idTratamiento ? _self.idTratamiento : idTratamiento // ignore: cast_nullable_to_non_nullable
as int,fechaInicio: null == fechaInicio ? _self.fechaInicio : fechaInicio // ignore: cast_nullable_to_non_nullable
as String,fechaFin: null == fechaFin ? _self.fechaFin : fechaFin // ignore: cast_nullable_to_non_nullable
as String,estadoAsistencia: freezed == estadoAsistencia ? _self.estadoAsistencia : estadoAsistencia // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
