// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WishItem _$WishItemFromJson(Map<String, dynamic> json) => _WishItem(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num?)?.toDouble(),
  category: json['category'] as String?,
  reason: json['reason'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  decidedAt: json['decidedAt'] == null
      ? null
      : DateTime.parse(json['decidedAt'] as String),
  status:
      $enumDecodeNullable(_$WishItemStatusEnumMap, json['status']) ??
      WishItemStatus.waiting,
);

Map<String, dynamic> _$WishItemToJson(_WishItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'category': instance.category,
  'reason': instance.reason,
  'createdAt': instance.createdAt.toIso8601String(),
  'decidedAt': instance.decidedAt?.toIso8601String(),
  'status': _$WishItemStatusEnumMap[instance.status]!,
};

const _$WishItemStatusEnumMap = {
  WishItemStatus.waiting: 'waiting',
  WishItemStatus.passed: 'passed',
  WishItemStatus.purchased: 'purchased',
  WishItemStatus.cancelled: 'cancelled',
};
