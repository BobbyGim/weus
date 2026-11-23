import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// Shows [message] in the app's snackbar, replacing one that is already up.
/// Its look (floating, ink background, 12 radius) comes from `snackBarTheme`.
///
/// [icon] (e.g. `LucideIcons.circleCheck`) goes left of the message.
void showAppSnackBar(BuildContext context, String message, {IconData? icon}) {
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

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: content));
}
