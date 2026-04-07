import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/community_repository_impl.dart';
import '../../domain/models/community_post.dart';

part 'community_provider.g.dart';

@riverpod
Stream<List<CommunityPost>> communityPosts(Ref ref) {
  return ref.watch(communityRepositoryProvider).postsStream;
}

@riverpod
Future<String> authorNickname(Ref ref, String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.doc('users/$uid').get();
    final nick = doc.data()?['nickname'] as String?;
    return (nick != null && nick.isNotEmpty) ? nick : '';
  } catch (_) {
    return '';
  }
}
