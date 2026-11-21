import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 홈에서 모임 찾기로 가는 카드 한 줄.
class HomeExploreButton extends StatelessWidget {
  const HomeExploreButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.primary,
          child: const Icon(LucideIcons.search, size: 20),
        ),
        title: Text(
          "그룹 찾기",
          style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          "관심 있는 그룹을 찾아 참여해 보세요",
          style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 20,
          color: AppColors.gray400,
        ),
        // 모임 탭으로 바꾸지 않고 홈 위에 쌓아서(push), 닫으면 홈으로 돌아온다.
        // 주소는 모임 탭 아래 그대로라 딥링크로 열면 모임 탭 위에 열린다.
        onTap: () => context.push("/group/explore"),
      ),
    );
  }
}
