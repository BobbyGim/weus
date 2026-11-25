import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_post_view_model.g.dart";

/// 글 상세. 삭제됐거나 없는 글이면 null, 멤버가 아니면 네트워크 오류처럼 실패한다.
@riverpod
class GroupPostViewModel extends _$GroupPostViewModel {
  @override
  Future<GroupPost?> build(int groupId, int postId) =>
      ref.watch(groupRepositoryProvider).fetchPost(groupId, postId);

  Future<void> refresh() async {
    ref.invalidateSelf();

    await future;
  }
}
