// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pieza_dental.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PiezaDental {

 String? get id;// maps to id_pieza
 int get odontogramaId;// maps to id_odontograma
 int get iso;// maps to numero_pieza
 String get estadoGeneral;// maps to estado_general
 bool get tieneSellador;// Stored in JSON
// Virtual fields (mapped from/to 'superficies' JSON column)
 String get estadoMesial; String get estadoDistal; String get estadoVestibular; String get estadoLingual; String get estadoOclusal;
/// Create a copy of PiezaDental
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PiezaDentalCopyWith<PiezaDental> get copyWith => _$PiezaDentalCopyWithImpl<PiezaDental>(this as PiezaDental, _$identity);

  /// Serializes this PiezaDental to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PiezaDental&&(identical(other.id, id) || other.id == id)&&(identical(other.odontogramaId, odontogramaId) || other.odontogramaId == odontogramaId)&&(identical(other.iso, iso) || other.iso == iso)&&(identical(other.estadoGeneral, estadoGeneral) || other.estadoGeneral == estadoGeneral)&&(identical(other.tieneSellador, tieneSellador) || other.tieneSellador == tieneSellador)&&(identical(other.estadoMesial, estadoMesial) || other.estadoMesial == estadoMesial)&&(identical(other.estadoDistal, estadoDistal) || other.estadoDistal == estadoDistal)&&(identical(other.estadoVestibular, estadoVestibular) || other.estadoVestibular == estadoVestibular)&&(identical(other.estadoLingual, estadoLingual) || other.estadoLingual == estadoLingual)&&(identical(other.estadoOclusal, estadoOclusal) || other.estadoOclusal == estadoOclusal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,odontogramaId,iso,estadoGeneral,tieneSellador,estadoMesial,estadoDistal,estadoVestibular,estadoLingual,estadoOclusal);

@override
String toString() {
  return 'PiezaDental(id: $id, odontogramaId: $odontogramaId, iso: $iso, estadoGeneral: $estadoGeneral, tieneSellador: $tieneSellador, estadoMesial: $estadoMesial, estadoDistal: $estadoDistal, estadoVestibular: $estadoVestibular, estadoLingual: $estadoLingual, estadoOclusal: $estadoOclusal)';
}


}

/// @nodoc
abstract mixin class $PiezaDentalCopyWith<$Res>  {
  factory $PiezaDentalCopyWith(PiezaDental value, $Res Function(PiezaDental) _then) = _$PiezaDentalCopyWithImpl;
@useResult
$Res call({
 String? id, int odontogramaId, int iso, String estadoGeneral, bool tieneSellador, String estadoMesial, String estadoDistal, String estadoVestibular, String estadoLingual, String estadoOclusal
});




}
/// @nodoc
class _$PiezaDentalCopyWithImpl<$Res>
    implements $PiezaDentalCopyWith<$Res> {
  _$PiezaDentalCopyWithImpl(this._self, this._then);

  final PiezaDental _self;
  final $Res Function(PiezaDental) _then;

/// Create a copy of PiezaDental
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? odontogramaId = null,Object? iso = null,Object? estadoGeneral = null,Object? tieneSellador = null,Object? estadoMesial = null,Object? estadoDistal = null,Object? estadoVestibular = null,Object? estadoLingual = null,Object? estadoOclusal = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,odontogramaId: null == odontogramaId ? _self.odontogramaId : odontogramaId // ignore: cast_nullable_to_non_nullable
as int,iso: null == iso ? _self.iso : iso // ignore: cast_nullable_to_non_nullable
as int,estadoGeneral: null == estadoGeneral ? _self.estadoGeneral : estadoGeneral // ignore: cast_nullable_to_non_nullable
as String,tieneSellador: null == tieneSellador ? _self.tieneSellador : tieneSellador // ignore: cast_nullable_to_non_nullable
as bool,estadoMesial: null == estadoMesial ? _self.estadoMesial : estadoMesial // ignore: cast_nullable_to_non_nullable
as String,estadoDistal: null == estadoDistal ? _self.estadoDistal : estadoDistal // ignore: cast_nullable_to_non_nullable
as String,estadoVestibular: null == estadoVestibular ? _self.estadoVestibular : estadoVestibular // ignore: cast_nullable_to_non_nullable
as String,estadoLingual: null == estadoLingual ? _self.estadoLingual : estadoLingual // ignore: cast_nullable_to_non_nullable
as String,estadoOclusal: null == estadoOclusal ? _self.estadoOclusal : estadoOclusal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PiezaDental].
extension PiezaDentalPatterns on PiezaDental {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PiezaDental value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PiezaDental() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PiezaDental value)  $default,){
final _that = this;
switch (_that) {
case _PiezaDental():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PiezaDental value)?  $default,){
final _that = this;
switch (_that) {
case _PiezaDental() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  int odontogramaId,  int iso,  String estadoGeneral,  bool tieneSellador,  String estadoMesial,  String estadoDistal,  String estadoVestibular,  String estadoLingual,  String estadoOclusal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PiezaDental() when $default != null:
return $default(_that.id,_that.odontogramaId,_that.iso,_that.estadoGeneral,_that.tieneSellador,_that.estadoMesial,_that.estadoDistal,_that.estadoVestibular,_that.estadoLingual,_that.estadoOclusal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  int odontogramaId,  int iso,  String estadoGeneral,  bool tieneSellador,  String estadoMesial,  String estadoDistal,  String estadoVestibular,  String estadoLingual,  String estadoOclusal)  $default,) {final _that = this;
switch (_that) {
case _PiezaDental():
return $default(_that.id,_that.odontogramaId,_that.iso,_that.estadoGeneral,_that.tieneSellador,_that.estadoMesial,_that.estadoDistal,_that.estadoVestibular,_that.estadoLingual,_that.estadoOclusal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  int odontogramaId,  int iso,  String estadoGeneral,  bool tieneSellador,  String estadoMesial,  String estadoDistal,  String estadoVestibular,  String estadoLingual,  String estadoOclusal)?  $default,) {final _that = this;
switch (_that) {
case _PiezaDental() when $default != null:
return $default(_that.id,_that.odontogramaId,_that.iso,_that.estadoGeneral,_that.tieneSellador,_that.estadoMesial,_that.estadoDistal,_that.estadoVestibular,_that.estadoLingual,_that.estadoOclusal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PiezaDental extends PiezaDental {
  const _PiezaDental({this.id, required this.odontogramaId, required this.iso, this.estadoGeneral = 'Sano', this.tieneSellador = false, this.estadoMesial = 'Sano', this.estadoDistal = 'Sano', this.estadoVestibular = 'Sano', this.estadoLingual = 'Sano', this.estadoOclusal = 'Sano'}): super._();
  factory _PiezaDental.fromJson(Map<String, dynamic> json) => _$PiezaDentalFromJson(json);

@override final  String? id;
// maps to id_pieza
@override final  int odontogramaId;
// maps to id_odontograma
@override final  int iso;
// maps to numero_pieza
@override@JsonKey() final  String estadoGeneral;
// maps to estado_general
@override@JsonKey() final  bool tieneSellador;
// Stored in JSON
// Virtual fields (mapped from/to 'superficies' JSON column)
@override@JsonKey() final  String estadoMesial;
@override@JsonKey() final  String estadoDistal;
@override@JsonKey() final  String estadoVestibular;
@override@JsonKey() final  String estadoLingual;
@override@JsonKey() final  String estadoOclusal;

/// Create a copy of PiezaDental
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PiezaDentalCopyWith<_PiezaDental> get copyWith => __$PiezaDentalCopyWithImpl<_PiezaDental>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PiezaDentalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PiezaDental&&(identical(other.id, id) || other.id == id)&&(identical(other.odontogramaId, odontogramaId) || other.odontogramaId == odontogramaId)&&(identical(other.iso, iso) || other.iso == iso)&&(identical(other.estadoGeneral, estadoGeneral) || other.estadoGeneral == estadoGeneral)&&(identical(other.tieneSellador, tieneSellador) || other.tieneSellador == tieneSellador)&&(identical(other.estadoMesial, estadoMesial) || other.estadoMesial == estadoMesial)&&(identical(other.estadoDistal, estadoDistal) || other.estadoDistal == estadoDistal)&&(identical(other.estadoVestibular, estadoVestibular) || other.estadoVestibular == estadoVestibular)&&(identical(other.estadoLingual, estadoLingual) || other.estadoLingual == estadoLingual)&&(identical(other.estadoOclusal, estadoOclusal) || other.estadoOclusal == estadoOclusal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,odontogramaId,iso,estadoGeneral,tieneSellador,estadoMesial,estadoDistal,estadoVestibular,estadoLingual,estadoOclusal);

@override
String toString() {
  return 'PiezaDental(id: $id, odontogramaId: $odontogramaId, iso: $iso, estadoGeneral: $estadoGeneral, tieneSellador: $tieneSellador, estadoMesial: $estadoMesial, estadoDistal: $estadoDistal, estadoVestibular: $estadoVestibular, estadoLingual: $estadoLingual, estadoOclusal: $estadoOclusal)';
}


}

/// @nodoc
abstract mixin class _$PiezaDentalCopyWith<$Res> implements $PiezaDentalCopyWith<$Res> {
  factory _$PiezaDentalCopyWith(_PiezaDental value, $Res Function(_PiezaDental) _then) = __$PiezaDentalCopyWithImpl;
@override @useResult
$Res call({
 String? id, int odontogramaId, int iso, String estadoGeneral, bool tieneSellador, String estadoMesial, String estadoDistal, String estadoVestibular, String estadoLingual, String estadoOclusal
});




}
/// @nodoc
class __$PiezaDentalCopyWithImpl<$Res>
    implements _$PiezaDentalCopyWith<$Res> {
  __$PiezaDentalCopyWithImpl(this._self, this._then);

  final _PiezaDental _self;
  final $Res Function(_PiezaDental) _then;

/// Create a copy of PiezaDental
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? odontogramaId = null,Object? iso = null,Object? estadoGeneral = null,Object? tieneSellador = null,Object? estadoMesial = null,Object? estadoDistal = null,Object? estadoVestibular = null,Object? estadoLingual = null,Object? estadoOclusal = null,}) {
  return _then(_PiezaDental(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,odontogramaId: null == odontogramaId ? _self.odontogramaId : odontogramaId // ignore: cast_nullable_to_non_nullable
as int,iso: null == iso ? _self.iso : iso // ignore: cast_nullable_to_non_nullable
as int,estadoGeneral: null == estadoGeneral ? _self.estadoGeneral : estadoGeneral // ignore: cast_nullable_to_non_nullable
as String,tieneSellador: null == tieneSellador ? _self.tieneSellador : tieneSellador // ignore: cast_nullable_to_non_nullable
as bool,estadoMesial: null == estadoMesial ? _self.estadoMesial : estadoMesial // ignore: cast_nullable_to_non_nullable
as String,estadoDistal: null == estadoDistal ? _self.estadoDistal : estadoDistal // ignore: cast_nullable_to_non_nullable
as String,estadoVestibular: null == estadoVestibular ? _self.estadoVestibular : estadoVestibular // ignore: cast_nullable_to_non_nullable
as String,estadoLingual: null == estadoLingual ? _self.estadoLingual : estadoLingual // ignore: cast_nullable_to_non_nullable
as String,estadoOclusal: null == estadoOclusal ? _self.estadoOclusal : estadoOclusal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
