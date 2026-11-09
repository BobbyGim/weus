import "package:flutter/material.dart";

import "widgets/home_banner_carousel.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          SizedBox(height: 8),

          HomeBannerCarousel(),

          SizedBox(height: 8),

          Text("홈페이지"),

          Text("홈페이지"),
        ],
      ),
    );
  }
}
