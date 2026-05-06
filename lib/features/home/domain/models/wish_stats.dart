import 'wish_item_model.dart';
import 'wish_item_status.dart';

class WishStats {
  const WishStats({
    required this.totalCount,
    required this.cancelledCount,
    required this.purchasedCount,
    required this.waitingCount,
    required this.savedAmount,
    required this.spentAmount,
    required this.totalResistHours,
  });

  final int totalCount;
  final int cancelledCount;
  final int purchasedCount;
  final int waitingCount;
  final double savedAmount;
  final double spentAmount;
  // 참기 성공 + 현재 참기 중인 아이템의 총 누적 시간 (시간 단위)
  final int totalResistHours;

  int get decidedCount => cancelledCount + purchasedCount;

  double get saveRate =>
      decidedCount == 0 ? 0 : cancelledCount / decidedCount;

  /// "N시간 버텼어요" 형태 메인 텍스트
  String get formattedResistTime => '$totalResistHours시간 버텼어요';

  /// 24시간 이상일 때만 "약 N일" 서브 텍스트, 미만이면 null
  String? get formattedResistSubLabel {
    if (totalResistHours < 24) return null;
    return '약 ${totalResistHours ~/ 24}일';
  }

  factory WishStats.fromItems(List<WishItem> items) {
    final cancelled =
        items.where((i) => i.status == WishItemStatus.cancelled).toList();
    final purchased =
        items.where((i) => i.status == WishItemStatus.purchased).toList();
    final waiting =
        items.where((i) => i.status == WishItemStatus.waiting).toList();

    final now = DateTime.now();

    // 참기 성공: decidedAt - createdAt (없으면 72시간으로 폴백)
    final resistedHours = cancelled.fold<int>(0, (sum, i) {
      final h = i.decidedAt != null
          ? i.decidedAt!.difference(i.createdAt).inHours
          : 72;
      return sum + h;
    });
    // 참기 중: 현재까지 경과 시간
    final waitingHours = waiting.fold<int>(
      0,
      (sum, i) => sum + now.difference(i.createdAt).inHours,
    );

    return WishStats(
      totalCount: items.length,
      cancelledCount: cancelled.length,
      purchasedCount: purchased.length,
      waitingCount: waiting.length,
      savedAmount: cancelled.fold(0.0, (sum, i) => sum + (i.price ?? 0)),
      spentAmount: purchased.fold(0.0, (sum, i) => sum + (i.price ?? 0)),
      totalResistHours: resistedHours + waitingHours,
    );
  }

  String get formattedSaved => _formatPrice(savedAmount);
  String get formattedSpent => _formatPrice(spentAmount);

  static String _formatPrice(double amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '₩ $buffer원';
  }
}
