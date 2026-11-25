import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "group_thumbnail.dart";

/// 모임 목록 한 줄 (내 모임, 모임 찾기). 왼쪽에 썸네일, 오른쪽에 제목·소개·인원 (카테고리는 상세에서만). [badge]가 있으면 인원 옆에 붙인다 (예: 참여 중).
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.onTap,
    this.badge,
    this.badgeHighlighted = false,
  });

  final String name;

  final String description;

  final int memberCount;

  final VoidCallback onTap;

  final String? badge;

  /// true면 [badge]를 파란색으로 (참여 중), false면 회색 (신청 중).
  final bool badgeHighlighted;

  static const _thumbnailSize = 88.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final meta = text.labelMedium!.copyWith(color: scheme.onSurfaceVariant);

    // 상자 없이 목록 한 줄로 둔다 (썸네일이 줄을 구분). 눌림 효과만 둥글게.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        // 글 영역을 이미지 높이에 맞춘다: 제목은 이미지 위끝, 인원 줄은 아래끝.
        // 글자를 키워 글이 더 길면 줄이 늘어나고 이미지는 위에 붙는다.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.topCenter,
                child: GroupThumbnail(size: _thumbnailSize),
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _thumbnailSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: text.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          if (description.isNotEmpty)
                            Text(
                              description,
                              style: text.bodyMedium!.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.user,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),

                            const SizedBox(width: 2),

                            Text("$memberCount", style: meta),

                            if (badge != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                child: Container(
                                  width: 1,
                                  height: 10,
                                  color: scheme.outlineVariant,
                                ),
                              ),

                              Text(
                                badge!,
                                style: meta.copyWith(
                                  color: badgeHighlighted
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
