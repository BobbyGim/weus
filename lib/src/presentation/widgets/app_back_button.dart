import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

/// Header back button of a full-screen page pushed over the tabs.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.fallback});

  /// Where to go when the page was opened by deep link, with nothing to pop.
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(LucideIcons.chevronLeft),
      onPressed: () => context.canPop() ? context.pop() : context.go(fallback),
    );
  }
}
