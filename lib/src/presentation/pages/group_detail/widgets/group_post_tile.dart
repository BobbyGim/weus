import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/utils/utils.dart";

/// 게시판 한 줄 (카페 게시판처럼): 왼쪽에 제목(2줄)과 "작성자 · 작성 시각",
/// 오른쪽에 댓글 수 상자. 누르면 [onTap] (글 상세).
class GroupPostTile extends StatelessWidget {
  const GroupPostTile({super.key, required this.post, required this.onTap});

  final GroupPostSummary post;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final meta = text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: text.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.authorName,
                          style: meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Text("  ${formatAgo(post.createdAt)}", style: meta),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${post.commentCount}",
                    style: text.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  Text(
                    "댓글",
                    style: text.labelSmall!.copyWith(
                      color: scheme.onSurfaceVariant,
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
