import "package:flutter/material.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// The top snackbar now showing, if any, so the next one can replace it.
OverlayEntry? _topEntry;

/// Shows [message] in the app's snackbar, replacing one that is already up.
/// Its look (floating, ink background, 12 radius) comes from `snackBarTheme`.
///
/// [icon] (e.g. `LucideIcons.circleCheck`) goes left of the message.
/// [top] shows it under the status bar instead of at the bottom.
void showAppSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  bool top = false,
}) {
  final theme = Theme.of(context);

  final content = Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 20, color: theme.colorScheme.onInverseSurface),

        const SizedBox(width: AppSpacing.sm),
      ],

      Expanded(child: Text(message)),
    ],
  );

  if (!top) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: content));

    return;
  }

  // Flutter's SnackBar only sits at the bottom, so the top one is drawn in
  // the overlay with the same look and the same 4 seconds on screen.
  _topEntry?.remove();

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Material(
          color: theme.snackBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          textStyle: theme.snackBarTheme.contentTextStyle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + 2,
            ),
            child: content,
          ),
        ),
      ),
    ),
  );

  _topEntry = entry;

  Overlay.of(context, rootOverlay: true).insert(entry);

  Future.delayed(const Duration(seconds: 4), () {
    // Already gone if a newer top snackbar replaced it.
    if (_topEntry != entry) return;

    entry.remove();

    _topEntry = null;
  });
}
