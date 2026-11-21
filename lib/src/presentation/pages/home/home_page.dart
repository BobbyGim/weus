import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "widgets/widgets.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          SizedBox(height: 8),

          HomeBannerCarousel(),

          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: HomeExploreButton(),
          ),
        ],
      ),
    );
  }
}
