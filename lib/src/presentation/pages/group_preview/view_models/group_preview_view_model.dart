import "dart:async";

import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_preview_view_model.g.dart";

/// 모임 찾기에서 누른 공개 그룹의 미리보기. 비공개·삭제된 그룹이면 null.
@riverpod
class GroupPreviewViewModel extends _$GroupPreviewViewModel {
  @override
  FutureOr<GroupSearchResult?> build(int groupId) {
    final loaded = ref.watch(publicGroupProvider(groupId));

    // 모임 찾기가 미리 불러왔으면 첫 프레임부터 그 값으로 (로딩 깜빡임 없이).
    // 뒤에서 다시 받는 중이어도 이전 값을 먼저 보여주고, 다 받으면 바뀐다.
    if (loaded.hasValue) return loaded.value;

    return ref.watch(publicGroupProvider(groupId).future);
  }

  /// 가입 신청. 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> request() async {
    await ref.read(groupRepositoryProvider).requestJoinPublic(groupId);

    // 버튼이 "신청 취소"로 바뀌고, 모임 탭의 승인 대기 목록에 보이게.
    ref.invalidate(publicGroupProvider(groupId));

    ref.invalidate(myJoinRequestsProvider);
  }

  /// 가입 신청 취소. 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> cancel() async {
    await ref.read(groupRepositoryProvider).cancelJoinRequestForGroup(groupId);

    // 버튼이 다시 "가입 신청"으로, 모임 탭의 승인 대기 목록에서도 빠지게.
    ref.invalidate(publicGroupProvider(groupId));

    ref.invalidate(myJoinRequestsProvider);
  }
}
