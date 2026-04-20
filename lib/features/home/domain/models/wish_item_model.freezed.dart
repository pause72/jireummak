// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wish_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WishItem {

 String get id; String get name; double? get price; String? get category; String? get reason; DateTime get createdAt; DateTime? get decidedAt; WishItemStatus get status; List<String> get buyReasons; List<String> get resistReasons;
/// Create a copy of WishItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishItemCopyWith<WishItem> get copyWith => _$WishItemCopyWithImpl<WishItem>(this as WishItem, _$identity);

  /// Serializes this WishItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.category, category) || other.category == category)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.buyReasons, buyReasons) || other.buyReasons == buyReasons)&&(identical(other.resistReasons, resistReasons) || other.resistReasons == resistReasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,category,reason,createdAt,decidedAt,status,buyReasons,resistReasons);

@override
String toString() {
  return 'WishItem(id: $id, name: $name, price: $price, category: $category, reason: $reason, createdAt: $createdAt, decidedAt: $decidedAt, status: $status, buyReasons: $buyReasons, resistReasons: $resistReasons)';
}


}

/// @nodoc
abstract mixin class $WishItemCopyWith<$Res>  {
  factory $WishItemCopyWith(WishItem value, $Res Function(WishItem) _then) = _$WishItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, double? price, String? category, String? reason, DateTime createdAt, DateTime? decidedAt, WishItemStatus status, List<String> buyReasons, List<String> resistReasons
});




}
/// @nodoc
class _$WishItemCopyWithImpl<$Res>
    implements $WishItemCopyWith<$Res> {
  _$WishItemCopyWithImpl(this._self, this._then);

  final WishItem _self;
  final $Res Function(WishItem) _then;

/// Create a copy of WishItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = freezed,Object? category = freezed,Object? reason = freezed,Object? createdAt = null,Object? decidedAt = freezed,Object? status = null,Object? buyReasons = null,Object? resistReasons = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WishItemStatus,buyReasons: null == buyReasons ? _self.buyReasons : buyReasons // ignore: cast_nullable_to_non_nullable
as List<String>,resistReasons: null == resistReasons ? _self.resistReasons : resistReasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [WishItem].
extension WishItemPatterns on WishItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishItem value)  $default,){
final _that = this;
switch (_that) {
case _WishItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishItem value)?  $default,){
final _that = this;
switch (_that) {
case _WishItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double? price,  String? category,  String? reason,  DateTime createdAt,  DateTime? decidedAt,  WishItemStatus status,  List<String> buyReasons,  List<String> resistReasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishItem() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.category,_that.reason,_that.createdAt,_that.decidedAt,_that.status,_that.buyReasons,_that.resistReasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double? price,  String? category,  String? reason,  DateTime createdAt,  DateTime? decidedAt,  WishItemStatus status,  List<String> buyReasons,  List<String> resistReasons)  $default,) {final _that = this;
switch (_that) {
case _WishItem():
return $default(_that.id,_that.name,_that.price,_that.category,_that.reason,_that.createdAt,_that.decidedAt,_that.status,_that.buyReasons,_that.resistReasons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double? price,  String? category,  String? reason,  DateTime createdAt,  DateTime? decidedAt,  WishItemStatus status,  List<String> buyReasons,  List<String> resistReasons)?  $default,) {final _that = this;
switch (_that) {
case _WishItem() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.category,_that.reason,_that.createdAt,_that.decidedAt,_that.status,_that.buyReasons,_that.resistReasons);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WishItem implements WishItem {
  const _WishItem({required this.id, required this.name, this.price, this.category, this.reason, required this.createdAt, this.decidedAt, this.status = WishItemStatus.waiting, this.buyReasons = const [], this.resistReasons = const []});
  factory _WishItem.fromJson(Map<String, dynamic> json) => _$WishItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  double? price;
@override final  String? category;
@override final  String? reason;
@override final  DateTime createdAt;
@override final  DateTime? decidedAt;
@override@JsonKey() final  WishItemStatus status;
@override@JsonKey() final  List<String> buyReasons;
@override@JsonKey() final  List<String> resistReasons;

/// Create a copy of WishItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishItemCopyWith<_WishItem> get copyWith => __$WishItemCopyWithImpl<_WishItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WishItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.category, category) || other.category == category)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.buyReasons, buyReasons) || other.buyReasons == buyReasons)&&(identical(other.resistReasons, resistReasons) || other.resistReasons == resistReasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,category,reason,createdAt,decidedAt,status,buyReasons,resistReasons);

@override
String toString() {
  return 'WishItem(id: $id, name: $name, price: $price, category: $category, reason: $reason, createdAt: $createdAt, decidedAt: $decidedAt, status: $status, buyReasons: $buyReasons, resistReasons: $resistReasons)';
}


}

/// @nodoc
abstract mixin class _$WishItemCopyWith<$Res> implements $WishItemCopyWith<$Res> {
  factory _$WishItemCopyWith(_WishItem value, $Res Function(_WishItem) _then) = __$WishItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double? price, String? category, String? reason, DateTime createdAt, DateTime? decidedAt, WishItemStatus status, List<String> buyReasons, List<String> resistReasons
});




}
/// @nodoc
class __$WishItemCopyWithImpl<$Res>
    implements _$WishItemCopyWith<$Res> {
  __$WishItemCopyWithImpl(this._self, this._then);

  final _WishItem _self;
  final $Res Function(_WishItem) _then;

/// Create a copy of WishItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = freezed,Object? category = freezed,Object? reason = freezed,Object? createdAt = null,Object? decidedAt = freezed,Object? status = null,Object? buyReasons = null,Object? resistReasons = null,}) {
  return _then(_WishItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WishItemStatus,buyReasons: null == buyReasons ? _self.buyReasons : buyReasons // ignore: cast_nullable_to_non_nullable
as List<String>,resistReasons: null == resistReasons ? _self.resistReasons : resistReasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
