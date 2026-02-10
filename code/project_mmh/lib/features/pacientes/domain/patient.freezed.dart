// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Patient {

@JsonKey(name: 'id_expediente') String get idExpediente;@JsonKey(name: 'nombre') String get nombre;@JsonKey(name: 'primer_apellido') String get primerApellido;@JsonKey(name: 'segundo_apellido') String? get segundoApellido;@JsonKey(name: 'edad') int get edad;@JsonKey(name: 'sexo') String get sexo;@JsonKey(name: 'telefono') String? get telefono;@JsonKey(name: 'padecimiento_relevante') String? get padecimientoRelevante;@JsonKey(name: 'informacion_adicional') String? get informacionAdicional;@JsonKey(name: 'imagenes_paths', fromJson: _parseImages) List<String> get imagenesPaths;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;
/// Create a copy of Patient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientCopyWith<Patient> get copyWith => _$PatientCopyWithImpl<Patient>(this as Patient, _$identity);

  /// Serializes this Patient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Patient&&(identical(other.idExpediente, idExpediente) || other.idExpediente == idExpediente)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.primerApellido, primerApellido) || other.primerApellido == primerApellido)&&(identical(other.segundoApellido, segundoApellido) || other.segundoApellido == segundoApellido)&&(identical(other.edad, edad) || other.edad == edad)&&(identical(other.sexo, sexo) || other.sexo == sexo)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.padecimientoRelevante, padecimientoRelevante) || other.padecimientoRelevante == padecimientoRelevante)&&(identical(other.informacionAdicional, informacionAdicional) || other.informacionAdicional == informacionAdicional)&&const DeepCollectionEquality().equals(other.imagenesPaths, imagenesPaths)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idExpediente,nombre,primerApellido,segundoApellido,edad,sexo,telefono,padecimientoRelevante,informacionAdicional,const DeepCollectionEquality().hash(imagenesPaths),deletedAt);

@override
String toString() {
  return 'Patient(idExpediente: $idExpediente, nombre: $nombre, primerApellido: $primerApellido, segundoApellido: $segundoApellido, edad: $edad, sexo: $sexo, telefono: $telefono, padecimientoRelevante: $padecimientoRelevante, informacionAdicional: $informacionAdicional, imagenesPaths: $imagenesPaths, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $PatientCopyWith<$Res>  {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) _then) = _$PatientCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_expediente') String idExpediente,@JsonKey(name: 'nombre') String nombre,@JsonKey(name: 'primer_apellido') String primerApellido,@JsonKey(name: 'segundo_apellido') String? segundoApellido,@JsonKey(name: 'edad') int edad,@JsonKey(name: 'sexo') String sexo,@JsonKey(name: 'telefono') String? telefono,@JsonKey(name: 'padecimiento_relevante') String? padecimientoRelevante,@JsonKey(name: 'informacion_adicional') String? informacionAdicional,@JsonKey(name: 'imagenes_paths', fromJson: _parseImages) List<String> imagenesPaths,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});




}
/// @nodoc
class _$PatientCopyWithImpl<$Res>
    implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._self, this._then);

  final Patient _self;
  final $Res Function(Patient) _then;

/// Create a copy of Patient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idExpediente = null,Object? nombre = null,Object? primerApellido = null,Object? segundoApellido = freezed,Object? edad = null,Object? sexo = null,Object? telefono = freezed,Object? padecimientoRelevante = freezed,Object? informacionAdicional = freezed,Object? imagenesPaths = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
idExpediente: null == idExpediente ? _self.idExpediente : idExpediente // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,primerApellido: null == primerApellido ? _self.primerApellido : primerApellido // ignore: cast_nullable_to_non_nullable
as String,segundoApellido: freezed == segundoApellido ? _self.segundoApellido : segundoApellido // ignore: cast_nullable_to_non_nullable
as String?,edad: null == edad ? _self.edad : edad // ignore: cast_nullable_to_non_nullable
as int,sexo: null == sexo ? _self.sexo : sexo // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,padecimientoRelevante: freezed == padecimientoRelevante ? _self.padecimientoRelevante : padecimientoRelevante // ignore: cast_nullable_to_non_nullable
as String?,informacionAdicional: freezed == informacionAdicional ? _self.informacionAdicional : informacionAdicional // ignore: cast_nullable_to_non_nullable
as String?,imagenesPaths: null == imagenesPaths ? _self.imagenesPaths : imagenesPaths // ignore: cast_nullable_to_non_nullable
as List<String>,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Patient].
extension PatientPatterns on Patient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Patient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Patient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Patient value)  $default,){
final _that = this;
switch (_that) {
case _Patient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Patient value)?  $default,){
final _that = this;
switch (_that) {
case _Patient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_expediente')  String idExpediente, @JsonKey(name: 'nombre')  String nombre, @JsonKey(name: 'primer_apellido')  String primerApellido, @JsonKey(name: 'segundo_apellido')  String? segundoApellido, @JsonKey(name: 'edad')  int edad, @JsonKey(name: 'sexo')  String sexo, @JsonKey(name: 'telefono')  String? telefono, @JsonKey(name: 'padecimiento_relevante')  String? padecimientoRelevante, @JsonKey(name: 'informacion_adicional')  String? informacionAdicional, @JsonKey(name: 'imagenes_paths', fromJson: _parseImages)  List<String> imagenesPaths, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Patient() when $default != null:
return $default(_that.idExpediente,_that.nombre,_that.primerApellido,_that.segundoApellido,_that.edad,_that.sexo,_that.telefono,_that.padecimientoRelevante,_that.informacionAdicional,_that.imagenesPaths,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_expediente')  String idExpediente, @JsonKey(name: 'nombre')  String nombre, @JsonKey(name: 'primer_apellido')  String primerApellido, @JsonKey(name: 'segundo_apellido')  String? segundoApellido, @JsonKey(name: 'edad')  int edad, @JsonKey(name: 'sexo')  String sexo, @JsonKey(name: 'telefono')  String? telefono, @JsonKey(name: 'padecimiento_relevante')  String? padecimientoRelevante, @JsonKey(name: 'informacion_adicional')  String? informacionAdicional, @JsonKey(name: 'imagenes_paths', fromJson: _parseImages)  List<String> imagenesPaths, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Patient():
return $default(_that.idExpediente,_that.nombre,_that.primerApellido,_that.segundoApellido,_that.edad,_that.sexo,_that.telefono,_that.padecimientoRelevante,_that.informacionAdicional,_that.imagenesPaths,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_expediente')  String idExpediente, @JsonKey(name: 'nombre')  String nombre, @JsonKey(name: 'primer_apellido')  String primerApellido, @JsonKey(name: 'segundo_apellido')  String? segundoApellido, @JsonKey(name: 'edad')  int edad, @JsonKey(name: 'sexo')  String sexo, @JsonKey(name: 'telefono')  String? telefono, @JsonKey(name: 'padecimiento_relevante')  String? padecimientoRelevante, @JsonKey(name: 'informacion_adicional')  String? informacionAdicional, @JsonKey(name: 'imagenes_paths', fromJson: _parseImages)  List<String> imagenesPaths, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Patient() when $default != null:
return $default(_that.idExpediente,_that.nombre,_that.primerApellido,_that.segundoApellido,_that.edad,_that.sexo,_that.telefono,_that.padecimientoRelevante,_that.informacionAdicional,_that.imagenesPaths,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Patient implements Patient {
  const _Patient({@JsonKey(name: 'id_expediente') required this.idExpediente, @JsonKey(name: 'nombre') required this.nombre, @JsonKey(name: 'primer_apellido') required this.primerApellido, @JsonKey(name: 'segundo_apellido') this.segundoApellido, @JsonKey(name: 'edad') required this.edad, @JsonKey(name: 'sexo') required this.sexo, @JsonKey(name: 'telefono') this.telefono, @JsonKey(name: 'padecimiento_relevante') this.padecimientoRelevante, @JsonKey(name: 'informacion_adicional') this.informacionAdicional, @JsonKey(name: 'imagenes_paths', fromJson: _parseImages) final  List<String> imagenesPaths = const [], @JsonKey(name: 'deleted_at') this.deletedAt}): _imagenesPaths = imagenesPaths;
  factory _Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);

@override@JsonKey(name: 'id_expediente') final  String idExpediente;
@override@JsonKey(name: 'nombre') final  String nombre;
@override@JsonKey(name: 'primer_apellido') final  String primerApellido;
@override@JsonKey(name: 'segundo_apellido') final  String? segundoApellido;
@override@JsonKey(name: 'edad') final  int edad;
@override@JsonKey(name: 'sexo') final  String sexo;
@override@JsonKey(name: 'telefono') final  String? telefono;
@override@JsonKey(name: 'padecimiento_relevante') final  String? padecimientoRelevante;
@override@JsonKey(name: 'informacion_adicional') final  String? informacionAdicional;
 final  List<String> _imagenesPaths;
@override@JsonKey(name: 'imagenes_paths', fromJson: _parseImages) List<String> get imagenesPaths {
  if (_imagenesPaths is EqualUnmodifiableListView) return _imagenesPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagenesPaths);
}

@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;

/// Create a copy of Patient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientCopyWith<_Patient> get copyWith => __$PatientCopyWithImpl<_Patient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Patient&&(identical(other.idExpediente, idExpediente) || other.idExpediente == idExpediente)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.primerApellido, primerApellido) || other.primerApellido == primerApellido)&&(identical(other.segundoApellido, segundoApellido) || other.segundoApellido == segundoApellido)&&(identical(other.edad, edad) || other.edad == edad)&&(identical(other.sexo, sexo) || other.sexo == sexo)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.padecimientoRelevante, padecimientoRelevante) || other.padecimientoRelevante == padecimientoRelevante)&&(identical(other.informacionAdicional, informacionAdicional) || other.informacionAdicional == informacionAdicional)&&const DeepCollectionEquality().equals(other._imagenesPaths, _imagenesPaths)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idExpediente,nombre,primerApellido,segundoApellido,edad,sexo,telefono,padecimientoRelevante,informacionAdicional,const DeepCollectionEquality().hash(_imagenesPaths),deletedAt);

@override
String toString() {
  return 'Patient(idExpediente: $idExpediente, nombre: $nombre, primerApellido: $primerApellido, segundoApellido: $segundoApellido, edad: $edad, sexo: $sexo, telefono: $telefono, padecimientoRelevante: $padecimientoRelevante, informacionAdicional: $informacionAdicional, imagenesPaths: $imagenesPaths, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$PatientCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$PatientCopyWith(_Patient value, $Res Function(_Patient) _then) = __$PatientCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_expediente') String idExpediente,@JsonKey(name: 'nombre') String nombre,@JsonKey(name: 'primer_apellido') String primerApellido,@JsonKey(name: 'segundo_apellido') String? segundoApellido,@JsonKey(name: 'edad') int edad,@JsonKey(name: 'sexo') String sexo,@JsonKey(name: 'telefono') String? telefono,@JsonKey(name: 'padecimiento_relevante') String? padecimientoRelevante,@JsonKey(name: 'informacion_adicional') String? informacionAdicional,@JsonKey(name: 'imagenes_paths', fromJson: _parseImages) List<String> imagenesPaths,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});




}
/// @nodoc
class __$PatientCopyWithImpl<$Res>
    implements _$PatientCopyWith<$Res> {
  __$PatientCopyWithImpl(this._self, this._then);

  final _Patient _self;
  final $Res Function(_Patient) _then;

/// Create a copy of Patient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idExpediente = null,Object? nombre = null,Object? primerApellido = null,Object? segundoApellido = freezed,Object? edad = null,Object? sexo = null,Object? telefono = freezed,Object? padecimientoRelevante = freezed,Object? informacionAdicional = freezed,Object? imagenesPaths = null,Object? deletedAt = freezed,}) {
  return _then(_Patient(
idExpediente: null == idExpediente ? _self.idExpediente : idExpediente // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,primerApellido: null == primerApellido ? _self.primerApellido : primerApellido // ignore: cast_nullable_to_non_nullable
as String,segundoApellido: freezed == segundoApellido ? _self.segundoApellido : segundoApellido // ignore: cast_nullable_to_non_nullable
as String?,edad: null == edad ? _self.edad : edad // ignore: cast_nullable_to_non_nullable
as int,sexo: null == sexo ? _self.sexo : sexo // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,padecimientoRelevante: freezed == padecimientoRelevante ? _self.padecimientoRelevante : padecimientoRelevante // ignore: cast_nullable_to_non_nullable
as String?,informacionAdicional: freezed == informacionAdicional ? _self.informacionAdicional : informacionAdicional // ignore: cast_nullable_to_non_nullable
as String?,imagenesPaths: null == imagenesPaths ? _self._imagenesPaths : imagenesPaths // ignore: cast_nullable_to_non_nullable
as List<String>,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
