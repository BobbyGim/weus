import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_view_model.g.dart";

/// 모임 탭에 보여줄 내가 속한 그룹(20개씩, [loadMore]로 다음 페이지)과
/// 승인 대기 중인 가입 신청.
@riverpod
class GroupViewModel extends _$GroupViewModel {
  @override
  Future<({MyGroupsPage mine, List<MyJoinRequest> requests})> build() async {
    final (mine, requests) = await (
      ref.watch(myGroupsProvider.future),
      ref.watch(myJoinRequestsProvider.future),
    ).wait;

    return (mine: mine, requests: requests);
  }

  Future<void> refresh() => Future.wait([
    ref.refresh(myGroupsProvider.future),
    ref.refresh(myJoinRequestsProvider.future),
  ]);

  Future<void> loadMore() => ref.read(myGroupsProvider.notifier).loadMore();

  /// 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> cancelRequest(int requestId) async {
    await ref.read(groupRepositoryProvider).cancelJoinRequest(requestId);

    ref.invalidate(myJoinRequestsProvider);
  }
}
