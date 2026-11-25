import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "widgets/widgets.dart";

/// 게시글 카드를 누르면 여는 글 상세: 작성자·작성 시각, 제목, 본문 전체
/// (길게 눌러 복사할 수 있다). 링크(`/group/<id>/post/<postId>`)로도 연다.
class GroupPostPage extends HookConsumerWidget {
  const GroupPostPage({super.key, required this.groupId, required this.postId});

  final int groupId;

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupPostPage(ref, groupId, postId);

    final data = page.data;

    final post = data.value;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: AppBackButton(fallback: "/group/$groupId"),
        title: const Text("게시글"),
      ),
      body: post != null
          ? GroupPostBody(post: post)
          : Center(
              child: data.isLoading
                  ? const CircularProgressIndicator()
                  // 불러오지 못했거나(오류, 다시 시도) 삭제된 글(null, 안내만).
                  : AppRetry(
                      message: data.hasError ? "글을 불러오지 못했어요" : "삭제됐거나 없는 글이에요",
                      onRetry: data.hasError ? page.refresh : null,
                    ),
            ),
    );
  }
}
