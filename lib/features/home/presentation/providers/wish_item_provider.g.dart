// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$waitingItemsHash() => r'4fb7b842d6115f18818a990cda6b47e1f09f9591';

/// See also [waitingItems].
@ProviderFor(waitingItems)
final waitingItemsProvider = AutoDisposeProvider<List<WishItem>>.internal(
  waitingItems,
  name: r'waitingItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$waitingItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WaitingItemsRef = AutoDisposeProviderRef<List<WishItem>>;
String _$allItemsHash() => r'bccea518bb3b0d5811e32c70b366e059342f0611';

/// See also [allItems].
@ProviderFor(allItems)
final allItemsProvider = AutoDisposeProvider<List<WishItem>>.internal(
  allItems,
  name: r'allItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllItemsRef = AutoDisposeProviderRef<List<WishItem>>;
String _$wishStatsHash() => r'f9ea60942ec98e5b4166a7605ef9fec67b9ff0e9';

/// See also [wishStats].
@ProviderFor(wishStats)
final wishStatsProvider = AutoDisposeProvider<WishStats>.internal(
  wishStats,
  name: r'wishStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishStatsRef = AutoDisposeProviderRef<WishStats>;
String _$clockTickHash() => r'93252ef83b2838c23cb01d17dc013ed6903cb019';

/// See also [clockTick].
@ProviderFor(clockTick)
final clockTickProvider = AutoDisposeStreamProvider<DateTime>.internal(
  clockTick,
  name: r'clockTickProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clockTickHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClockTickRef = AutoDisposeStreamProviderRef<DateTime>;
String _$wishItemNotifierHash() => r'5dc71cc26ba02ecda13e6ce6bd84864e741a51f2';

/// See also [WishItemNotifier].
@ProviderFor(WishItemNotifier)
final wishItemNotifierProvider =
    AutoDisposeNotifierProvider<
      WishItemNotifier,
      AsyncValue<List<WishItem>>
    >.internal(
      WishItemNotifier.new,
      name: r'wishItemNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishItemNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WishItemNotifier = AutoDisposeNotifier<AsyncValue<List<WishItem>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
