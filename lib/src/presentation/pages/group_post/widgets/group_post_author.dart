import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/utils/utils.dart";

/// 글 작성자 한 줄: 이니셜 원, 이름, 작성 시각. 내 글은 이니셜이 파란색.
/// [radius]는 이니셜 원 크기.
class GroupPostAuthor extends StatelessWidget {
  const GroupPostAuthor({super.key, required this.post, this.radius = 14});

  final GroupPost post;

  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: post.isMine
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          foregroundColor: post.isMine
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant,
          child: Text(
            post.authorName.characters.first,
            style: text.labelMedium!.copyWith(
              fontSize: radius * 0.85,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Flexible(
          child: Text(
            post.authorName,
            style: text.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Text(
          formatAgo(post.createdAt),
          style: text.labelMedium!.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
