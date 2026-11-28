import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 그룹 만들기의 한 단계: 위에 질문과 설명, 아래에 고르는 칸.
/// [fill]이면 [child]가 남은 높이를 다 차지하고, 모자라면 스크롤된다.
class GroupCreateStep extends StatelessWidget {
  const GroupCreateStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.fill = false,
  });

  final String title;

  final String subtitle;

  final Widget child;

  final bool fill;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return CustomScrollView(
      // 화면에 다 들어가면 스크롤·바운스 없음.
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: text.headlineSmall),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  subtitle,
                  style: text.bodyMedium!.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                fill ? Expanded(child: child) : child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
