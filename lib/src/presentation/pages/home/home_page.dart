import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "widgets/widgets.dart";

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final (:menus) = useHomePage();

    return Scaffold(
      body: TabScrollReset(
        path: "/",
        child: ListView(
          children: [
            const SizedBox(height: 8),

            const HomeBannerCarousel(),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: HomeQuickMenu(
                items: [
                  for (final m in menus)
                    HomeQuickMenuItem(
                      icon: m.icon,
                      label: m.label,
                      onTap: m.onTap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
