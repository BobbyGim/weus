import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// Who is signed in: avatar, then name over email. Tapping opens my info.
class MyProfileCard extends StatelessWidget {
  const MyProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String name;

  final String email;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Icon(LucideIcons.user),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleLarge),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      email,
                      style: text.bodyMedium!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
