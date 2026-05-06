import '../models/community_post.dart';

abstract class CommunityRepository {
  Stream<List<CommunityPost>> get postsStream;
  Future<void> addPost(CommunityPost post);
  Future<void> updatePost(
    String postId, {
    required PostType type,
    required String content,
    String? itemName,
    required bool resisted,
  });
  Future<void> toggleLike(String postId, String currentUid);
  Future<void> deletePost(String postId);
}
