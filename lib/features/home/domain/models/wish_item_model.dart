import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/app_strings.dart';
import 'wish_item_status.dart';

part 'wish_item_model.freezed.dart';
part 'wish_item_model.g.dart';

@freezed
abstract class WishItem with _$WishItem {
  const factory WishItem({
    required String id,
    required String name,
    double? price,
    String? category,
    String? reason,
    required DateTime createdAt,
    @Default(WishItemStatus.waiting) WishItemStatus status,
  }) = _WishItem;

  factory WishItem.fromJson(Map<String, dynamic> json) =>
      _$WishItemFromJson(json);
}

extension WishItemX on WishItem {
  static const _duration = Duration(hours: 72);

  DateTime get expiresAt => createdAt.add(_duration);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  double get progressRatio {
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (elapsed / _duration.inSeconds).clamp(0.0, 1.0);
  }

  Duration get remainingDuration {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get remainingText {
    if (isExpired) return AppStrings.wishExpiredText;
    final d = remainingDuration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h >= 48) {
      final days = h ~/ 24;
      final remH = h % 24;
      return remH > 0 ? '$days일 $remH시간 남음' : '$days일 남음';
    }
    if (h >= 24) return '내일만 버티면 끝이에요';
    if (h >= 6) return '거의 다 왔어요';
    if (h > 0) return AppStrings.wishRemainingHours(h, m);
    return AppStrings.wishRemainingMinutes(m);
  }

  String get formattedPrice {
    if (price == null) return '';
    final str = price!.toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '₩ $buffer원';
  }
}
