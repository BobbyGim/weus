import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'hooks/use_home_banner_carousel.dart';

// ponytail: static asset banners; move to a repository + ViewModel once banners come from the API.
const _banners = [
  'assets/image/banner/banner_1.png',
  'assets/image/banner/banner_2.png',
  'assets/image/banner/banner_3.png',
];

/// Auto-playing 2:1 home banner with a "1 / 3" counter over the image.
class HomeBannerCarousel extends HookWidget {
  const HomeBannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final banner = useHomeBannerCarousel();

    return Stack(
      children: [
        CarouselSlider(
          carouselController: banner.controller,
          options: banner.options,
          items: [
            for (final src in _banners)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: banner.sidePadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(src, fit: BoxFit.cover, width: .infinity),
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
                text: '${banner.current + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: ' / ${_banners.length}',
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
