import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "repositories/repositories.dart";

part "home_banners_provider.g.dart";

/// 홈 배너 목록. 홈 탭이 떠 있는 동안 유지된다.
@riverpod
Future<List<HomeBanner>> homeBanners(Ref ref) =>
    ref.watch(bannerRepositoryProvider).fetchHomeBanners();
