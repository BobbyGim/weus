import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/utils/utils.dart";

part "group_post_new_view_model.g.dart";

/// 글쓰기. [clientId]는 화면을 열 때 한 번 만들어서, 두 번 탭하거나 다시 시도해도
/// 글이 하나만 올라간다.
@riverpod
class GroupPostNewViewModel extends _$GroupPostNewViewModel {
  @override
  String build(int groupId) => newUuid();

  /// 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> post({required String title, required String description}) => ref
      .read(groupRepositoryProvider)
      .createPost(
        groupId,
        title: title,
        description: description,
        clientId: state,
      );
}
