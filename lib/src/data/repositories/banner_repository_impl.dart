import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:weus/src/domain/domain.dart";

import "../supabase/supabase.dart";

part "banner_repository_impl.g.dart";

/// Supabase banners 테이블. 노출 기간 밖의 배너는 RLS가 거른다.
class BannerRepositoryImpl implements BannerRepository {
  const BannerRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<HomeBanner>> fetchHomeBanners() async => [
    for (final row
        in await _supabase
            .from("banners")
            .select("image_url, link_url")
            .order("sort_order", ascending: true))
      (
        imageUrl: row["image_url"] as String,
        linkUrl: row["link_url"] as String?,
      ),
  ];
}

@Riverpod(keepAlive: true)
BannerRepository bannerRepository(Ref ref) =>
    BannerRepositoryImpl(ref.watch(supabaseProvider));
