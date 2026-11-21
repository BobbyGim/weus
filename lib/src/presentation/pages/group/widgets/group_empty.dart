import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 속한 모임도, 대기 중인 신청도 없을 때.
class GroupEmpty extends StatelessWidget {
  const GroupEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: const Icon(LucideIcons.users, size: 32),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text("아직 참여한 모임이 없어요", style: text.titleMedium),

          const SizedBox(height: AppSpacing.sm),

          Text(
            "공개 모임을 찾아 참여하거나\n+ 버튼으로 첫 모임을 만들어 보세요",
            textAlign: TextAlign.center,
            style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
          ),

          const SizedBox(height: AppSpacing.xl),

          FilledButton(
            onPressed: () => context.go("/group/explore"),
            child: const Text("모임 찾아보기"),
          ),

          const SizedBox(height: AppSpacing.sm),

          TextButton(
            onPressed: () => context.go("/group/join"),
            child: const Text("초대 코드로 참여"),
          ),
        ],
      ),
    );
  }
}
