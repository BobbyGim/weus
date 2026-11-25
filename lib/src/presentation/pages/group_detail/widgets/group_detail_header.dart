import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

/// 그룹 홈 맨 위 그라데이션 띠: 닫기·설정 버튼, 그룹 아이콘, 이름,
/// "카테고리 · 멤버 N명". 상태 표시줄 아래까지 채운다.
class GroupDetailHeader extends StatelessWidget {
  const GroupDetailHeader({
    super.key,
    required this.header,
    required this.categoryNames,
    required this.onClose,
    required this.onSettings,
  });

  final GroupHeader header;

  final List<String> categoryNames;

  final VoidCallback onClose;

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final top = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: GroupImage.gradient),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          top + AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GroupHeroButton(
                  icon: LucideIcons.x,
                  tooltip: "닫기",
                  onPressed: onClose,
                ),

                const Spacer(),

                GroupHeroButton(
                  icon: LucideIcons.settings,
                  tooltip: "그룹 설정",
                  onPressed: onSettings,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      GroupImage.icon,
                      size: 28,
                      color: GroupImage.iconColor,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          header.name,
                          style: text.headlineSmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text(
                          [
                            ...categoryNames,
                            "멤버 ${header.memberCount}명",
                          ].join(" · "),
                          style: text.bodyMedium!.copyWith(
                            color: const Color(0xE6FFFFFF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
