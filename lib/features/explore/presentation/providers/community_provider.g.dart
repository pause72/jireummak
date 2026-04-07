// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityPostsHash() => r'be52ed78a904455f6f49ce123fbb855654e39f20';

/// See also [communityPosts].
@ProviderFor(communityPosts)
final communityPostsProvider =
    AutoDisposeStreamProvider<List<CommunityPost>>.internal(
      communityPosts,
      name: r'communityPostsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityPostsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityPostsRef = AutoDisposeStreamProviderRef<List<CommunityPost>>;
String _$authorNicknameHash() => r'dc0a89fda97d25eed668b76535738eaf195d3272';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [authorNickname].
@ProviderFor(authorNickname)
const authorNicknameProvider = AuthorNicknameFamily();

/// See also [authorNickname].
class AuthorNicknameFamily extends Family<AsyncValue<String>> {
  /// See also [authorNickname].
  const AuthorNicknameFamily();

  /// See also [authorNickname].
  AuthorNicknameProvider call(String uid) {
    return AuthorNicknameProvider(uid);
  }

  @override
  AuthorNicknameProvider getProviderOverride(
    covariant AuthorNicknameProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'authorNicknameProvider';
}

/// See also [authorNickname].
class AuthorNicknameProvider extends AutoDisposeFutureProvider<String> {
  /// See also [authorNickname].
  AuthorNicknameProvider(String uid)
    : this._internal(
        (ref) => authorNickname(ref as AuthorNicknameRef, uid),
        from: authorNicknameProvider,
        name: r'authorNicknameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$authorNicknameHash,
        dependencies: AuthorNicknameFamily._dependencies,
        allTransitiveDependencies:
            AuthorNicknameFamily._allTransitiveDependencies,
        uid: uid,
      );

  AuthorNicknameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    FutureOr<String> Function(AuthorNicknameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AuthorNicknameProvider._internal(
        (ref) => create(ref as AuthorNicknameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _AuthorNicknameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthorNicknameProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AuthorNicknameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _AuthorNicknameProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with AuthorNicknameRef {
  _AuthorNicknameProviderElement(super.provider);

  @override
  String get uid => (origin as AuthorNicknameProvider).uid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
