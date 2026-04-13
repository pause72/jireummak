class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    this.emoji = '🎯',
  });

  final String id;
  final String title;
  final int targetAmount;
  final int currentAmount;
  final String emoji;

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  SavingsGoal copyWith({
    String? title,
    int? targetAmount,
    int? currentAmount,
    String? emoji,
  }) {
    return SavingsGoal(
      id: id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'emoji': emoji,
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'] as String,
    title: json['title'] as String,
    targetAmount: json['targetAmount'] as int,
    currentAmount: (json['currentAmount'] as int?) ?? 0,
    emoji: (json['emoji'] as String?) ?? '🎯',
  );
}
