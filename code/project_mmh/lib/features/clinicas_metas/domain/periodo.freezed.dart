// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'periodo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Periodo {

@JsonKey(name: 'id_periodo') int? get idPeriodo;@JsonKey(name: 'nombre_periodo') String get nombrePeriodo;
/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodoCopyWith<Periodo> get copyWith => _$PeriodoCopyWithImpl<Periodo>(this as Periodo, _$identity);

  /// Serializes this Periodo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Periodo&&(identical(other.idPeriodo, idPeriodo) || other.idPeriodo == idPeriodo)&&(identical(other.nombrePeriodo, nombrePeriodo) || other.nombrePeriodo == nombrePeriodo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idPeriodo,nombrePeriodo);

@override
String toString() {
  return 'Periodo(idPeriodo: $idPeriodo, nombrePeriodo: $nombrePeriodo)';
}


}

/// @nodoc
abstract mixin class $PeriodoCopyWith<$Res>  {
  factory $PeriodoCopyWith(Periodo value, $Res Function(Periodo) _then) = _$PeriodoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_periodo') int? idPeriodo,@JsonKey(name: 'nombre_periodo') String nombrePeriodo
});




}
/// @nodoc
class _$PeriodoCopyWithImpl<$Res>
    implements $PeriodoCopyWith<$Res> {
  _$PeriodoCopyWithImpl(this._self, this._then);

  final Periodo _self;
  final $Res Function(Periodo) _then;

/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idPeriodo = freezed,Object? nombrePeriodo = null,}) {
  return _then(_self.copyWith(
idPeriodo: freezed == idPeriodo ? _self.idPeriodo : idPeriodo // ignore: cast_nullable_to_non_nullable
as int?,nombrePeriodo: null == nombrePeriodo ? _self.nombrePeriodo : nombrePeriodo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Periodo].
extension PeriodoPatterns on Periodo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Periodo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Periodo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Periodo value)  $default,){
final _that = this;
switch (_that) {
case _Periodo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Periodo value)?  $default,){
final _that = this;
switch (_that) {
case _Periodo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_periodo')  int? idPeriodo, @JsonKey(name: 'nombre_periodo')  String nombrePeriodo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Periodo() when $default != null:
return $default(_that.idPeriodo,_that.nombrePeriodo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_periodo')  int? idPeriodo, @JsonKey(name: 'nombre_periodo')  String nombrePeriodo)  $default,) {final _that = this;
switch (_that) {
case _Periodo():
return $default(_that.idPeriodo,_that.nombrePeriodo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_periodo')  int? idPeriodo, @JsonKey(name: 'nombre_periodo')  String nombrePeriodo)?  $default,) {final _that = this;
switch (_that) {
case _Periodo() when $default != null:
return $default(_that.idPeriodo,_that.nombrePeriodo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Periodo implements Periodo {
  const _Periodo({@JsonKey(name: 'id_periodo') this.idPeriodo, @JsonKey(name: 'nombre_periodo') required this.nombrePeriodo});
  factory _Periodo.fromJson(Map<String, dynamic> json) => _$PeriodoFromJson(json);

@override@JsonKey(name: 'id_periodo') final  int? idPeriodo;
@override@JsonKey(name: 'nombre_periodo') final  String nombrePeriodo;

/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodoCopyWith<_Periodo> get copyWith => __$PeriodoCopyWithImpl<_Periodo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeriodoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Periodo&&(identical(other.idPeriodo, idPeriodo) || other.idPeriodo == idPeriodo)&&(identical(other.nombrePeriodo, nombrePeriodo) || other.nombrePeriodo == nombrePeriodo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idPeriodo,nombrePeriodo);

@override
String toString() {
  return 'Periodo(idPeriodo: $idPeriodo, nombrePeriodo: $nombrePeriodo)';
}


}

/// @nodoc
abstract mixin class _$PeriodoCopyWith<$Res> implements $PeriodoCopyWith<$Res> {
  factory _$PeriodoCopyWith(_Periodo value, $Res Function(_Periodo) _then) = __$PeriodoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_periodo') int? idPeriodo,@JsonKey(name: 'nombre_periodo') String nombrePeriodo
});




}
/// @nodoc
class __$PeriodoCopyWithImpl<$Res>
    implements _$PeriodoCopyWith<$Res> {
  __$PeriodoCopyWithImpl(this._self, this._then);

  final _Periodo _self;
  final $Res Function(_Periodo) _then;

/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idPeriodo = freezed,Object? nombrePeriodo = null,}) {
  return _then(_Periodo(
idPeriodo: freezed == idPeriodo ? _self.idPeriodo : idPeriodo // ignore: cast_nullable_to_non_nullable
as int?,nombrePeriodo: null == nombrePeriodo ? _self.nombrePeriodo : nombrePeriodo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
