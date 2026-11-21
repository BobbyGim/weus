import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_edit_view_model.g.dart";

/// 수정할 그룹의 지금 값 (모임장만 쓴다).
@riverpod
class GroupEditViewModel extends _$GroupEditViewModel {
  @override
  Future<GroupDetail> build(int groupId) =>
      ref.watch(groupRepositoryProvider).fetchDetail(groupId);

  /// 저장. 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> save({
    required String name,
    required String description,
    required List<String> categories,
  }) async {
    await ref
        .read(groupRepositoryProvider)
        .update(
          groupId,
          name: name,
          description: description,
          categories: categories,
        );

    // 모임 탭 목록과 모임 찾기 미리보기에 바뀐 이름·소개가 보이게.
    ref.invalidate(myGroupsProvider);

    ref.invalidate(publicGroupProvider(groupId));
  }
}
