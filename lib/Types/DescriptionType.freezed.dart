// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'DescriptionType.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
DescriptionType _$DescriptionTypeFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'string':
          return _String.fromJson(
            json
          );
                case 'map':
          return _Map.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'DescriptionType',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$DescriptionType {

 Object get value;

  /// Serializes this DescriptionType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DescriptionType&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'DescriptionType(value: $value)';
}


}

/// @nodoc
class $DescriptionTypeCopyWith<$Res>  {
$DescriptionTypeCopyWith(DescriptionType _, $Res Function(DescriptionType) __);
}


/// Adds pattern-matching-related methods to [DescriptionType].
extension DescriptionTypePatterns on DescriptionType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _String value)?  string,TResult Function( _Map value)?  map,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _String() when string != null:
return string(_that);case _Map() when map != null:
return map(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _String value)  string,required TResult Function( _Map value)  map,}){
final _that = this;
switch (_that) {
case _String():
return string(_that);case _Map():
return map(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _String value)?  string,TResult? Function( _Map value)?  map,}){
final _that = this;
switch (_that) {
case _String() when string != null:
return string(_that);case _Map() when map != null:
return map(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String value)?  string,TResult Function( Map<String, String> value)?  map,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _String() when string != null:
return string(_that.value);case _Map() when map != null:
return map(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String value)  string,required TResult Function( Map<String, String> value)  map,}) {final _that = this;
switch (_that) {
case _String():
return string(_that.value);case _Map():
return map(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String value)?  string,TResult? Function( Map<String, String> value)?  map,}) {final _that = this;
switch (_that) {
case _String() when string != null:
return string(_that.value);case _Map() when map != null:
return map(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _String implements DescriptionType {
  const _String(this.value, {final  String? $type}): $type = $type ?? 'string';
  factory _String.fromJson(Map<String, dynamic> json) => _$StringFromJson(json);

@override final  String value;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DescriptionType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StringCopyWith<_String> get copyWith => __$StringCopyWithImpl<_String>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StringToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _String&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'DescriptionType.string(value: $value)';
}


}

/// @nodoc
abstract mixin class _$StringCopyWith<$Res> implements $DescriptionTypeCopyWith<$Res> {
  factory _$StringCopyWith(_String value, $Res Function(_String) _then) = __$StringCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class __$StringCopyWithImpl<$Res>
    implements _$StringCopyWith<$Res> {
  __$StringCopyWithImpl(this._self, this._then);

  final _String _self;
  final $Res Function(_String) _then;

/// Create a copy of DescriptionType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_String(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _Map implements DescriptionType {
  const _Map(final  Map<String, String> value, {final  String? $type}): _value = value,$type = $type ?? 'map';
  factory _Map.fromJson(Map<String, dynamic> json) => _$MapFromJson(json);

 final  Map<String, String> _value;
@override Map<String, String> get value {
  if (_value is EqualUnmodifiableMapView) return _value;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_value);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DescriptionType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapCopyWith<_Map> get copyWith => __$MapCopyWithImpl<_Map>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MapToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Map&&const DeepCollectionEquality().equals(other._value, _value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_value));

@override
String toString() {
  return 'DescriptionType.map(value: $value)';
}


}

/// @nodoc
abstract mixin class _$MapCopyWith<$Res> implements $DescriptionTypeCopyWith<$Res> {
  factory _$MapCopyWith(_Map value, $Res Function(_Map) _then) = __$MapCopyWithImpl;
@useResult
$Res call({
 Map<String, String> value
});




}
/// @nodoc
class __$MapCopyWithImpl<$Res>
    implements _$MapCopyWith<$Res> {
  __$MapCopyWithImpl(this._self, this._then);

  final _Map _self;
  final $Res Function(_Map) _then;

/// Create a copy of DescriptionType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_Map(
null == value ? _self._value : value // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
