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
  });

  final int totalCount;
  final int cancelledCount;
  final int purchasedCount;
  final int waitingCount;
  final double savedAmount;
  final double spentAmount;

  int get decidedCount => cancelledCount + purchasedCount;

  double get saveRate =>
      decidedCount == 0 ? 0 : cancelledCount / decidedCount;

  factory WishStats.fromItems(List<WishItem> items) {
    final cancelled =
        items.where((i) => i.status == WishItemStatus.cancelled).toList();
    final purchased =
        items.where((i) => i.status == WishItemStatus.purchased).toList();
    final waiting =
        items.where((i) => i.status == WishItemStatus.waiting).toList();

    return WishStats(
      totalCount: items.length,
      cancelledCount: cancelled.length,
      purchasedCount: purchased.length,
      waitingCount: waiting.length,
      savedAmount: cancelled.fold(0.0, (sum, i) => sum + (i.price ?? 0)),
      spentAmount: purchased.fold(0.0, (sum, i) => sum + (i.price ?? 0)),
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
