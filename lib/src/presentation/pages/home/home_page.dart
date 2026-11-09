import 'package:flutter/material.dart';

import 'widgets/home_banner_carousel.dart';

// ponytail: static asset banners; move to a repository + ViewModel once banners come from the API.
const _banners = [
  'assets/image/banner/banner_1.png',
  'assets/image/banner/banner_2.png',
  'assets/image/banner/banner_3.png',
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          SizedBox(height: 8),

          HomeBannerCarousel(images: _banners),
        ],
      ),
    );
  }
}
