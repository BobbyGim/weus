import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_settings_view_model.g.dart";

/// 그룹 설정: 그룹 상세(초대 코드·멤버)와 (owner면) 들어온 가입 신청.
/// 요청이 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
@riverpod
class GroupSettingsViewModel extends _$GroupSettingsViewModel {
  @override
  Future<({GroupDetail detail, List<JoinRequest> requests})> build(
    int groupId,
  ) async {
    final repository = ref.watch(groupRepositoryProvider);

    final detail = await repository.fetchDetail(groupId);

    final requests = detail.isOwner
        ? await repository.fetchJoinRequests(groupId)
        : const <JoinRequest>[];

    return (detail: detail, requests: requests);
  }

  GroupRepository get _repository => ref.read(groupRepositoryProvider);

  Future<void> refresh() async {
    ref.invalidateSelf();

    await future;
  }

  Future<void> setPublic(bool isPublic) async {
    await _repository.setPublic(groupId, isPublic);

    ref.invalidateSelf();
  }

  Future<void> approve(int requestId) async {
    await _repository.approveJoinRequest(requestId);

    _membersChanged();
  }

  Future<void> reject(int requestId) async {
    await _repository.rejectJoinRequest(requestId);

    ref.invalidateSelf();
  }

  Future<void> removeMember(String userId) async {
    await _repository.removeMember(groupId, userId);

    _membersChanged();
  }

  // 나가면 이 그룹은 더 못 읽으니 다시 불러오지 않는다 (화면이 모임 탭으로 돌아간다).
  Future<void> leave() async {
    await _repository.leave(groupId);

    ref.invalidate(myGroupsProvider);
  }

  // 멤버 목록과 모임 탭의 인원 수를 다시 불러온다 (그룹 홈은 돌아오면 다시 불러온다).
  void _membersChanged() {
    ref.invalidateSelf();

    ref.invalidate(myGroupsProvider);
  }
}
