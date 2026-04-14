import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/community_post.dart';
import '../../domain/repositories/community_repository.dart';

part 'community_repository_impl.g.dart';

@riverpod
CommunityRepository communityRepository(Ref ref) {
  return FirestoreCommunityRepository();
}

class FirestoreCommunityRepository implements CommunityRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('posts');

  @override
  Stream<List<CommunityPost>> get postsStream => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(_fromDoc).toList());

  @override
  Future<void> addPost(CommunityPost post) async {
    await _col.add({
      'uid': post.uid,
      'nickname': post.nickname,
      'type': post.type.name,
      'content': post.content,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'likesCount': 0,
      'likedBy': <String>[],
      'itemName': post.itemName,
      'resisted': post.resisted,
    });
  }

  @override
  Future<void> updatePost(
    String postId, {
    required PostType type,
    required String content,
    String? itemName,
    required bool resisted,
  }) async {
    await _col.doc(postId).update({
      'type': type.name,
      'content': content,
      'itemName': itemName,
      'resisted': resisted,
    });
  }

  @override
  Future<void> toggleLike(String postId, String currentUid) async {
    final doc = _col.doc(postId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
    if (likedBy.contains(currentUid)) {
      await doc.update({
        'likedBy': FieldValue.arrayRemove([currentUid]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await doc.update({
        'likedBy': FieldValue.arrayUnion([currentUid]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await _col.doc(postId).delete();
  }

  static CommunityPost _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final typeStr = data['type'] as String? ?? 'tip';
    final type = PostType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => PostType.tip,
    );
    return CommunityPost(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      nickname: data['nickname'] as String? ?? '익명',
      type: type,
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      itemName: data['itemName'] as String?,
      resisted: data['resisted'] as bool? ?? true,
    );
  }
}
