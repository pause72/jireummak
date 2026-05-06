enum PostType { review, tip }

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.uid,
    required this.nickname,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.likedBy,
    this.itemName,
    this.resisted = true,
  });

  final String id;
  final String uid;
  final String nickname;
  final PostType type;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final List<String> likedBy;
  final String? itemName;
  final bool resisted;

  bool isLikedBy(String uid) => likedBy.contains(uid);

  String get relativeDate {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${(diff.inDays / 7).floor()}주 전';
  }
}
