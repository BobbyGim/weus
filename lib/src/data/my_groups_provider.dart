import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "my_profile_provider.dart";
import "repositories/repositories.dart";

part "my_groups_provider.g.dart";

const _pageSize = 20;

/// 내가 속한 그룹을 20개씩. [hasMore]: 더 불러올 게 남았는지.
/// [loadingMore]·[failed]: 다음 페이지 상태.
typedef MyGroupsPage = ({
  List<Group> groups,
  bool hasMore,
  bool loadingMore,
  bool failed,
});

/// 내가 속한 그룹, 로그아웃 상태면 빈 목록. 모임 탭과 모임 화면들이 같이 쓴다
/// (만들기·나가기·수락하면 invalidate해서 첫 페이지부터 다시 불러온다).
/// 로그인·로그아웃하면 다시 불러온다.
@Riverpod(keepAlive: true)
class MyGroups extends _$MyGroups {
  @override
  Future<MyGroupsPage> build() async {
    if (!await ref.watch(signedInProvider.future)) {
      return (
        groups: const <Group>[],
        hasMore: false,
        loadingMore: false,
        failed: false,
      );
    }

    final groups = await ref
        .watch(groupRepositoryProvider)
        .fetchMine(limit: _pageSize);

    return (
      groups: groups,
      hasMore: groups.length == _pageSize,
      loadingMore: false,
      failed: false,
    );
  }

  // 스크롤할 때마다 불려서, 이미 불러오는 중이거나 끝이면 아무 일 없음.
  Future<void> loadMore() async {
    final current = state.value;

    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData((
      groups: current.groups,
      hasMore: true,
      loadingMore: true,
      failed: false,
    ));

    try {
      final next = await ref
          .read(groupRepositoryProvider)
          .fetchMine(afterId: current.groups.last.id, limit: _pageSize);

      if (!ref.mounted) return;

      state = AsyncData((
        groups: [...current.groups, ...next],
        hasMore: next.length == _pageSize,
        loadingMore: false,
        failed: false,
      ));
    } catch (_) {
      if (!ref.mounted) return;

      // 목록은 그대로 두고 끝에 다시 시도 버튼을 보여준다.
      state = AsyncData((
        groups: current.groups,
        hasMore: true,
        loadingMore: false,
        failed: true,
      ));
    }
  }
}

/// 내가 넣은 대기 중인 가입 신청, 로그아웃 상태면 빈 목록. 모임 탭과 초대 코드 참여가 같이 쓴다.
@Riverpod(keepAlive: true)
Future<List<MyJoinRequest>> myJoinRequests(Ref ref) async {
  if (!await ref.watch(signedInProvider.future)) return const [];

  return ref.watch(groupRepositoryProvider).fetchMyJoinRequests();
}
