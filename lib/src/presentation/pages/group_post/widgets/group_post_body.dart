import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "group_post_author.dart";

/// 글 상세 본문 (스크롤): 작성자·작성 시각, 제목, 본문 전체. 제목과 본문은
/// 길게 눌러 복사할 수 있다.
class GroupPostBody extends StatelessWidget {
  const GroupPostBody({super.key, required this.post});

  final GroupPost post;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        GroupPostAuthor(post: post, radius: 18),

        const SizedBox(height: AppSpacing.xl),

        SelectableText(post.title, style: text.headlineSmall),

        if (post.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),

          SelectableText(
            post.description,
            style: text.bodyLarge!.copyWith(height: 1.65),
          ),
        ],
      ],
    );
  }
}
