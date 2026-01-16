// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinica.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Clinica {

@JsonKey(name: 'id_clinica') int? get idClinica;@JsonKey(name: 'id_periodo') int get idPeriodo;@JsonKey(name: 'nombre_clinica') String get nombreClinica; String get color; String? get horarios;
/// Create a copy of Clinica
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicaCopyWith<Clinica> get copyWith => _$ClinicaCopyWithImpl<Clinica>(this as Clinica, _$identity);

  /// Serializes this Clinica to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Clinica&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.idPeriodo, idPeriodo) || other.idPeriodo == idPeriodo)&&(identical(other.nombreClinica, nombreClinica) || other.nombreClinica == nombreClinica)&&(identical(other.color, color) || other.color == color)&&(identical(other.horarios, horarios) || other.horarios == horarios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idClinica,idPeriodo,nombreClinica,color,horarios);

@override
String toString() {
  return 'Clinica(idClinica: $idClinica, idPeriodo: $idPeriodo, nombreClinica: $nombreClinica, color: $color, horarios: $horarios)';
}


}

/// @nodoc
abstract mixin class $ClinicaCopyWith<$Res>  {
  factory $ClinicaCopyWith(Clinica value, $Res Function(Clinica) _then) = _$ClinicaCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_clinica') int? idClinica,@JsonKey(name: 'id_periodo') int idPeriodo,@JsonKey(name: 'nombre_clinica') String nombreClinica, String color, String? horarios
});




}
/// @nodoc
class _$ClinicaCopyWithImpl<$Res>
    implements $ClinicaCopyWith<$Res> {
  _$ClinicaCopyWithImpl(this._self, this._then);

  final Clinica _self;
  final $Res Function(Clinica) _then;

/// Create a copy of Clinica
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idClinica = freezed,Object? idPeriodo = null,Object? nombreClinica = null,Object? color = null,Object? horarios = freezed,}) {
  return _then(_self.copyWith(
idClinica: freezed == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int?,idPeriodo: null == idPeriodo ? _self.idPeriodo : idPeriodo // ignore: cast_nullable_to_non_nullable
as int,nombreClinica: null == nombreClinica ? _self.nombreClinica : nombreClinica // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,horarios: freezed == horarios ? _self.horarios : horarios // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Clinica].
extension ClinicaPatterns on Clinica {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Clinica value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Clinica() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Clinica value)  $default,){
final _that = this;
switch (_that) {
case _Clinica():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Clinica value)?  $default,){
final _that = this;
switch (_that) {
case _Clinica() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_clinica')  int? idClinica, @JsonKey(name: 'id_periodo')  int idPeriodo, @JsonKey(name: 'nombre_clinica')  String nombreClinica,  String color,  String? horarios)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Clinica() when $default != null:
return $default(_that.idClinica,_that.idPeriodo,_that.nombreClinica,_that.color,_that.horarios);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_clinica')  int? idClinica, @JsonKey(name: 'id_periodo')  int idPeriodo, @JsonKey(name: 'nombre_clinica')  String nombreClinica,  String color,  String? horarios)  $default,) {final _that = this;
switch (_that) {
case _Clinica():
return $default(_that.idClinica,_that.idPeriodo,_that.nombreClinica,_that.color,_that.horarios);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_clinica')  int? idClinica, @JsonKey(name: 'id_periodo')  int idPeriodo, @JsonKey(name: 'nombre_clinica')  String nombreClinica,  String color,  String? horarios)?  $default,) {final _that = this;
switch (_that) {
case _Clinica() when $default != null:
return $default(_that.idClinica,_that.idPeriodo,_that.nombreClinica,_that.color,_that.horarios);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Clinica implements Clinica {
  const _Clinica({@JsonKey(name: 'id_clinica') this.idClinica, @JsonKey(name: 'id_periodo') required this.idPeriodo, @JsonKey(name: 'nombre_clinica') required this.nombreClinica, required this.color, this.horarios});
  factory _Clinica.fromJson(Map<String, dynamic> json) => _$ClinicaFromJson(json);

@override@JsonKey(name: 'id_clinica') final  int? idClinica;
@override@JsonKey(name: 'id_periodo') final  int idPeriodo;
@override@JsonKey(name: 'nombre_clinica') final  String nombreClinica;
@override final  String color;
@override final  String? horarios;

/// Create a copy of Clinica
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicaCopyWith<_Clinica> get copyWith => __$ClinicaCopyWithImpl<_Clinica>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Clinica&&(identical(other.idClinica, idClinica) || other.idClinica == idClinica)&&(identical(other.idPeriodo, idPeriodo) || other.idPeriodo == idPeriodo)&&(identical(other.nombreClinica, nombreClinica) || other.nombreClinica == nombreClinica)&&(identical(other.color, color) || other.color == color)&&(identical(other.horarios, horarios) || other.horarios == horarios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idClinica,idPeriodo,nombreClinica,color,horarios);

@override
String toString() {
  return 'Clinica(idClinica: $idClinica, idPeriodo: $idPeriodo, nombreClinica: $nombreClinica, color: $color, horarios: $horarios)';
}


}

/// @nodoc
abstract mixin class _$ClinicaCopyWith<$Res> implements $ClinicaCopyWith<$Res> {
  factory _$ClinicaCopyWith(_Clinica value, $Res Function(_Clinica) _then) = __$ClinicaCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_clinica') int? idClinica,@JsonKey(name: 'id_periodo') int idPeriodo,@JsonKey(name: 'nombre_clinica') String nombreClinica, String color, String? horarios
});




}
/// @nodoc
class __$ClinicaCopyWithImpl<$Res>
    implements _$ClinicaCopyWith<$Res> {
  __$ClinicaCopyWithImpl(this._self, this._then);

  final _Clinica _self;
  final $Res Function(_Clinica) _then;

/// Create a copy of Clinica
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idClinica = freezed,Object? idPeriodo = null,Object? nombreClinica = null,Object? color = null,Object? horarios = freezed,}) {
  return _then(_Clinica(
idClinica: freezed == idClinica ? _self.idClinica : idClinica // ignore: cast_nullable_to_non_nullable
as int?,idPeriodo: null == idPeriodo ? _self.idPeriodo : idPeriodo // ignore: cast_nullable_to_non_nullable
as int,nombreClinica: null == nombreClinica ? _self.nombreClinica : nombreClinica // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,horarios: freezed == horarios ? _self.horarios : horarios // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
