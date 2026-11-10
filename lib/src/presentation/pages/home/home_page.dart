import "package:flutter/material.dart";

import "widgets/design_showcase.dart";
import "widgets/home_banner_carousel.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          SizedBox(height: 8),

          HomeBannerCarousel(),

          DesignShowcase(),
        ],
      ),
    );
  }
}
