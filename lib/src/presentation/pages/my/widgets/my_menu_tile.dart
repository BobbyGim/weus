import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// One row of the my page menu: icon, label, chevron.
class MyMenuTile extends StatelessWidget {
  const MyMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;

  final String label;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Icon(icon, size: 20, color: scheme.onSurface),
      title: Text(label, style: text.bodyLarge),
      trailing: const Icon(
        LucideIcons.chevronRight,
        size: 20,
        color: AppColors.gray400,
      ),
      onTap: onTap,
    );
  }
}
