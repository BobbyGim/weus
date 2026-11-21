import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_join_view_model.g.dart";

/// 초대 코드로 찾은 모임, 찾기 전에는 null. [code]는 찾을 때 쓴 코드라
/// 입력이 바뀌면 화면이 결과를 숨긴다.
@riverpod
class GroupJoinViewModel extends _$GroupJoinViewModel {
  @override
  AsyncValue<({String code, GroupPreview preview})?> build() =>
      const AsyncData(null);

  Future<void> find(String code) async {
    if (state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final preview = await ref.read(groupRepositoryProvider).preview(code);

      if (preview == null) throw const GroupFailure("초대 코드에 맞는 그룹이 없어요");

      return (code: code, preview: preview);
    });

    if (ref.mounted) state = result;
  }

  /// 가입 신청. 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> request(String code) async {
    await ref.read(groupRepositoryProvider).requestJoin(code);

    // 모임 탭의 승인 대기 목록에 보이게.
    ref.invalidate(myJoinRequestsProvider);
  }
}
