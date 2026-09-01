// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nota_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotaItem {

 String get nombre; num get cantidad; String? get unidad;@JsonKey(name: 'precio_unitario') double? get precioUnitario;
/// Create a copy of NotaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotaItemCopyWith<NotaItem> get copyWith => _$NotaItemCopyWithImpl<NotaItem>(this as NotaItem, _$identity);

  /// Serializes this NotaItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotaItem&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.unidad, unidad) || other.unidad == unidad)&&(identical(other.precioUnitario, precioUnitario) || other.precioUnitario == precioUnitario));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nombre,cantidad,unidad,precioUnitario);

@override
String toString() {
  return 'NotaItem(nombre: $nombre, cantidad: $cantidad, unidad: $unidad, precioUnitario: $precioUnitario)';
}


}

/// @nodoc
abstract mixin class $NotaItemCopyWith<$Res>  {
  factory $NotaItemCopyWith(NotaItem value, $Res Function(NotaItem) _then) = _$NotaItemCopyWithImpl;
@useResult
$Res call({
 String nombre, num cantidad, String? unidad,@JsonKey(name: 'precio_unitario') double? precioUnitario
});




}
/// @nodoc
class _$NotaItemCopyWithImpl<$Res>
    implements $NotaItemCopyWith<$Res> {
  _$NotaItemCopyWithImpl(this._self, this._then);

  final NotaItem _self;
  final $Res Function(NotaItem) _then;

/// Create a copy of NotaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nombre = null,Object? cantidad = null,Object? unidad = freezed,Object? precioUnitario = freezed,}) {
  return _then(_self.copyWith(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as num,unidad: freezed == unidad ? _self.unidad : unidad // ignore: cast_nullable_to_non_nullable
as String?,precioUnitario: freezed == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotaItem].
extension NotaItemPatterns on NotaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotaItem value)  $default,){
final _that = this;
switch (_that) {
case _NotaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotaItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nombre,  num cantidad,  String? unidad, @JsonKey(name: 'precio_unitario')  double? precioUnitario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotaItem() when $default != null:
return $default(_that.nombre,_that.cantidad,_that.unidad,_that.precioUnitario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nombre,  num cantidad,  String? unidad, @JsonKey(name: 'precio_unitario')  double? precioUnitario)  $default,) {final _that = this;
switch (_that) {
case _NotaItem():
return $default(_that.nombre,_that.cantidad,_that.unidad,_that.precioUnitario);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nombre,  num cantidad,  String? unidad, @JsonKey(name: 'precio_unitario')  double? precioUnitario)?  $default,) {final _that = this;
switch (_that) {
case _NotaItem() when $default != null:
return $default(_that.nombre,_that.cantidad,_that.unidad,_that.precioUnitario);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotaItem implements NotaItem {
  const _NotaItem({required this.nombre, required this.cantidad, this.unidad, @JsonKey(name: 'precio_unitario') this.precioUnitario});
  factory _NotaItem.fromJson(Map<String, dynamic> json) => _$NotaItemFromJson(json);

@override final  String nombre;
@override final  num cantidad;
@override final  String? unidad;
@override@JsonKey(name: 'precio_unitario') final  double? precioUnitario;

/// Create a copy of NotaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotaItemCopyWith<_NotaItem> get copyWith => __$NotaItemCopyWithImpl<_NotaItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotaItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotaItem&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.unidad, unidad) || other.unidad == unidad)&&(identical(other.precioUnitario, precioUnitario) || other.precioUnitario == precioUnitario));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nombre,cantidad,unidad,precioUnitario);

@override
String toString() {
  return 'NotaItem(nombre: $nombre, cantidad: $cantidad, unidad: $unidad, precioUnitario: $precioUnitario)';
}


}

/// @nodoc
abstract mixin class _$NotaItemCopyWith<$Res> implements $NotaItemCopyWith<$Res> {
  factory _$NotaItemCopyWith(_NotaItem value, $Res Function(_NotaItem) _then) = __$NotaItemCopyWithImpl;
@override @useResult
$Res call({
 String nombre, num cantidad, String? unidad,@JsonKey(name: 'precio_unitario') double? precioUnitario
});




}
/// @nodoc
class __$NotaItemCopyWithImpl<$Res>
    implements _$NotaItemCopyWith<$Res> {
  __$NotaItemCopyWithImpl(this._self, this._then);

  final _NotaItem _self;
  final $Res Function(_NotaItem) _then;

/// Create a copy of NotaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nombre = null,Object? cantidad = null,Object? unidad = freezed,Object? precioUnitario = freezed,}) {
  return _then(_NotaItem(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as num,unidad: freezed == unidad ? _self.unidad : unidad // ignore: cast_nullable_to_non_nullable
as String?,precioUnitario: freezed == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
