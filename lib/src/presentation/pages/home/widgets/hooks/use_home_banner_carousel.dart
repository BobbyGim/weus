import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:url_launcher/url_launcher.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

const _sidePadding = 16.0;

const _imageAspectRatio = 2.0;

/// [banners]는 불러오는 중이면 null, 실패하면 빈 목록 (배너 자리를 숨긴다).
/// 시스템의 "동작 줄이기"가 켜져 있으면 자동 넘김을 끈다.
({
  List<HomeBanner>? banners,
  CarouselSliderController controller,
  int current,
  double sidePadding,
  double imageAspectRatio,
  CarouselOptions options,
  void Function(HomeBanner banner) onTap,
})
useHomeBannerCarousel(WidgetRef ref) {
  final async = ref.watch(homeBannersProvider);

  // dispose 없음: CarouselSliderController는 정리할 자원이 없다.
  final controller = useMemoized(CarouselSliderController.new);

  final current = useState(0);

  final context = useContext();

  final reduceMotion = MediaQuery.disableAnimationsOf(context);

  // aspectRatio는 좌우 16px 여백까지 포함한 슬라이드 전체 비율이라,
  // 화면 너비로 계산해서 이미지 자체가 정확히 2:1(잘림 없음)이 되게 한다.
  final width = MediaQuery.sizeOf(context).width;

  final slideAspectRatio =
      width / ((width - _sidePadding * 2) / _imageAspectRatio);

  // '/'로 시작하면 앱 안 경로라 홈 위에 쌓고(push), 그 밖은 외부 브라우저로 연다.
  void onTap(HomeBanner banner) {
    final link = banner.linkUrl;

    if (link == null || link.isEmpty) return;

    if (link.startsWith("/")) {
      context.push(link);

      return;
    }

    final uri = Uri.tryParse(link);

    if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  return (
    banners: async.hasError ? const [] : async.value,
    controller: controller,
    current: current.value,
    sidePadding: _sidePadding,
    imageAspectRatio: _imageAspectRatio,
    options: CarouselOptions(
      aspectRatio: slideAspectRatio,
      viewportFraction: 1,
      autoPlay: !reduceMotion,
      autoPlayInterval: const Duration(seconds: 4),
      autoPlayCurve: Curves.easeOutCubic,
      onPageChanged: (i, _) => current.value = i,
    ),
    onTap: onTap,
  );
}
