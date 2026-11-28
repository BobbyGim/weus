import "package:cached_network_image/cached_network_image.dart";
import "package:carousel_slider/carousel_slider.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";

import "hooks/hooks.dart";

/// DB(banners)에서 불러온 2:1 홈 배너. 자동으로 넘어가고 이미지 위에 "1 / 3"이 보인다.
/// 누르면 배너의 링크로 이동한다. 배너가 없거나 못 불러오면 자리를 차지하지 않는다.
class HomeBannerCarousel extends HookConsumerWidget {
  const HomeBannerCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = useHomeBannerCarousel(ref);

    final banners = banner.banners;

    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
    );

    if (banners == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: banner.sidePadding),
        child: AspectRatio(
          aspectRatio: banner.imageAspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: placeholder,
          ),
        ),
      );
    }

    if (banners.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        CarouselSlider(
          carouselController: banner.controller,
          options: banner.options,
          items: [
            for (final b in banners)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: banner.sidePadding),
                child: GestureDetector(
                  onTap: () => banner.onTap(b),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: b.imageUrl,
                      fit: BoxFit.cover,
                      width: .infinity,
                      placeholder: (_, _) => placeholder,
                      errorWidget: (_, _, _) => placeholder,
                    ),
                  ),
                ),
              ),
          ],
        ),

        Positioned(
          right: banner.sidePadding + 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text.rich(
              TextSpan(
                text: "${banner.current + 1}",
                style: const TextStyle(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: " / ${banners.length}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
