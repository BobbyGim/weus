import "../entities/entities.dart";

abstract interface class BannerRepository {
  /// 지금 노출 기간인 홈 배너 (앞에 보일 것부터).
  Future<List<HomeBanner>> fetchHomeBanners();
}
