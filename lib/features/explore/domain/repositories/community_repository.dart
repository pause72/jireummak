import '../models/community_post.dart';

abstract class CommunityRepository {
  Stream<List<CommunityPost>> get postsStream;
  Future<void> addPost(CommunityPost post);
  Future<void> toggleLike(String postId, String currentUid);
}
