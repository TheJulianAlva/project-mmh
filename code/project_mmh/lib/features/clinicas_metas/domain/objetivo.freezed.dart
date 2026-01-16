// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'objetivo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Objetivo {

@JsonKey(name: 'id_objetivo') int? get idObjetivo;@JsonKey(name: 'id_clinica') int get idClinica;@JsonKey(name: 'nombre_tratamiento') String get nombreTratamiento;@JsonKey(name: 'cantidad_meta') int get cantidadMeta;@JsonKey(name: 'cantidad_actual') int get cantidadActual;
/// Create a copy of Objetivo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObjetivoCopyWith<Objetivo> get copyWith => _$ObjetivoCopyWithImpl<Objetivo>(this as Objetivo, _$identity);

  /// Serializes this Objetivo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Objetivo&&(identical(other.idObjetivo, idObjetivo) || other.idObjetivo == idObjetivo)&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.nombreTratamiento, nombreTratamiento) || other.nombreTratamiento == nombreTratamiento)&&(identical(other.cantidadMeta, cantidadMeta) || other.cantidadMeta == cantidadMeta)&&(identical(other.cantidadActual, cantidadActual) || other.cantidadActual == cantidadActual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idObjetivo,idClinica,nombreTratamiento,cantidadMeta,cantidadActual);

@override
String toString() {
  return 'Objetivo(idObjetivo: $idObjetivo, idClinica: $idClinica, nombreTratamiento: $nombreTratamiento, cantidadMeta: $cantidadMeta, cantidadActual: $cantidadActual)';
}


}

/// @nodoc
abstract mixin class $ObjetivoCopyWith<$Res>  {
  factory $ObjetivoCopyWith(Objetivo value, $Res Function(Objetivo) _then) = _$ObjetivoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_objetivo') int? idObjetivo,@JsonKey(name: 'id_clinica') int idClinica,@JsonKey(name: 'nombre_tratamiento') String nombreTratamiento,@JsonKey(name: 'cantidad_meta') int cantidadMeta,@JsonKey(name: 'cantidad_actual') int cantidadActual
});




}
/// @nodoc
class _$ObjetivoCopyWithImpl<$Res>
    implements $ObjetivoCopyWith<$Res> {
  _$ObjetivoCopyWithImpl(this._self, this._then);

  final Objetivo _self;
  final $Res Function(Objetivo) _then;

/// Create a copy of Objetivo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idObjetivo = freezed,Object? idClinica = null,Object? nombreTratamiento = null,Object? cantidadMeta = null,Object? cantidadActual = null,}) {
  return _then(_self.copyWith(
idObjetivo: freezed == idObjetivo ? _self.idObjetivo : idObjetivo // ignore: cast_nullable_to_non_nullable
as int?,idClinica: null == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int,nombreTratamiento: null == nombreTratamiento ? _self.nombreTratamiento : nombreTratamiento // ignore: cast_nullable_to_non_nullable
as String,cantidadMeta: null == cantidadMeta ? _self.cantidadMeta : cantidadMeta // ignore: cast_nullable_to_non_nullable
as int,cantidadActual: null == cantidadActual ? _self.cantidadActual : cantidadActual // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Objetivo].
extension ObjetivoPatterns on Objetivo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Objetivo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Objetivo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Objetivo value)  $default,){
final _that = this;
switch (_that) {
case _Objetivo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Objetivo value)?  $default,){
final _that = this;
switch (_that) {
case _Objetivo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_objetivo')  int? idObjetivo, @JsonKey(name: 'id_clinica')  int idClinica, @JsonKey(name: 'nombre_tratamiento')  String nombreTratamiento, @JsonKey(name: 'cantidad_meta')  int cantidadMeta, @JsonKey(name: 'cantidad_actual')  int cantidadActual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Objetivo() when $default != null:
return $default(_that.idObjetivo,_that.idClinica,_that.nombreTratamiento,_that.cantidadMeta,_that.cantidadActual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_objetivo')  int? idObjetivo, @JsonKey(name: 'id_clinica')  int idClinica, @JsonKey(name: 'nombre_tratamiento')  String nombreTratamiento, @JsonKey(name: 'cantidad_meta')  int cantidadMeta, @JsonKey(name: 'cantidad_actual')  int cantidadActual)  $default,) {final _that = this;
switch (_that) {
case _Objetivo():
return $default(_that.idObjetivo,_that.idClinica,_that.nombreTratamiento,_that.cantidadMeta,_that.cantidadActual);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_objetivo')  int? idObjetivo, @JsonKey(name: 'id_clinica')  int idClinica, @JsonKey(name: 'nombre_tratamiento')  String nombreTratamiento, @JsonKey(name: 'cantidad_meta')  int cantidadMeta, @JsonKey(name: 'cantidad_actual')  int cantidadActual)?  $default,) {final _that = this;
switch (_that) {
case _Objetivo() when $default != null:
return $default(_that.idObjetivo,_that.idClinica,_that.nombreTratamiento,_that.cantidadMeta,_that.cantidadActual);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Objetivo implements Objetivo {
  const _Objetivo({@JsonKey(name: 'id_objetivo') this.idObjetivo, @JsonKey(name: 'id_clinica') required this.idClinica, @JsonKey(name: 'nombre_tratamiento') required this.nombreTratamiento, @JsonKey(name: 'cantidad_meta') required this.cantidadMeta, @JsonKey(name: 'cantidad_actual') this.cantidadActual = 0});
  factory _Objetivo.fromJson(Map<String, dynamic> json) => _$ObjetivoFromJson(json);

@override@JsonKey(name: 'id_objetivo') final  int? idObjetivo;
@override@JsonKey(name: 'id_clinica') final  int idClinica;
@override@JsonKey(name: 'nombre_tratamiento') final  String nombreTratamiento;
@override@JsonKey(name: 'cantidad_meta') final  int cantidadMeta;
@override@JsonKey(name: 'cantidad_actual') final  int cantidadActual;

/// Create a copy of Objetivo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObjetivoCopyWith<_Objetivo> get copyWith => __$ObjetivoCopyWithImpl<_Objetivo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObjetivoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Objetivo&&(identical(other.idObjetivo, idObjetivo) || other.idObjetivo == idObjetivo)&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.nombreTratamiento, nombreTratamiento) || other.nombreTratamiento == nombreTratamiento)&&(identical(other.cantidadMeta, cantidadMeta) || other.cantidadMeta == cantidadMeta)&&(identical(other.cantidadActual, cantidadActual) || other.cantidadActual == cantidadActual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idObjetivo,idClinica,nombreTratamiento,cantidadMeta,cantidadActual);

@override
String toString() {
  return 'Objetivo(idObjetivo: $idObjetivo, idClinica: $idClinica, nombreTratamiento: $nombreTratamiento, cantidadMeta: $cantidadMeta, cantidadActual: $cantidadActual)';
}


}

/// @nodoc
abstract mixin class _$ObjetivoCopyWith<$Res> implements $ObjetivoCopyWith<$Res> {
  factory _$ObjetivoCopyWith(_Objetivo value, $Res Function(_Objetivo) _then) = __$ObjetivoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_objetivo') int? idObjetivo,@JsonKey(name: 'id_clinica') int idClinica,@JsonKey(name: 'nombre_tratamiento') String nombreTratamiento,@JsonKey(name: 'cantidad_meta') int cantidadMeta,@JsonKey(name: 'cantidad_actual') int cantidadActual
});




}
/// @nodoc
class __$ObjetivoCopyWithImpl<$Res>
    implements _$ObjetivoCopyWith<$Res> {
  __$ObjetivoCopyWithImpl(this._self, this._then);

  final _Objetivo _self;
  final $Res Function(_Objetivo) _then;

/// Create a copy of Objetivo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idObjetivo = freezed,Object? idClinica = null,Object? nombreTratamiento = null,Object? cantidadMeta = null,Object? cantidadActual = null,}) {
  return _then(_Objetivo(
idObjetivo: freezed == idObjetivo ? _self.idObjetivo : idObjetivo // ignore: cast_nullable_to_non_nullable
as int?,idClinica: null == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int,nombreTratamiento: null == nombreTratamiento ? _self.nombreTratamiento : nombreTratamiento // ignore: cast_nullable_to_non_nullable
as String,cantidadMeta: null == cantidadMeta ? _self.cantidadMeta : cantidadMeta // ignore: cast_nullable_to_non_nullable
as int,cantidadActual: null == cantidadActual ? _self.cantidadActual : cantidadActual // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
