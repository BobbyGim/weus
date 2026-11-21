import "dart:async";

import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_explore_view_model.g.dart";

const _pageSize = 20;

/// 이름에 [query]가 들어간 공개 그룹 (빈 검색어면 전부, [category]가 있으면 그
/// 카테고리만). 거르기는 DB에서 하고 20개씩 불러오며,
/// 목록 끝에 가까워지면 [loadMore]로 다음 20개를 붙인다.
/// [hasMore]: 더 불러올 게 남았는지. [loadingMore]·[failed]: 다음 페이지 상태.
@riverpod
class GroupExploreViewModel extends _$GroupExploreViewModel {
  @override
  Future<
    ({
      List<GroupSearchResult> groups,
      bool hasMore,
      bool loadingMore,
      bool failed,
    })
  >
  build(String query, String? category) async {
    // 화면을 닫아도 5분은 결과를 기억해, 다시 열면 로딩 없이 바로 보인다.
    final link = ref.keepAlive();

    Timer? timer;

    ref.onCancel(() => timer = Timer(const Duration(minutes: 5), link.close));

    ref.onResume(() => timer?.cancel());

    ref.onDispose(() => timer?.cancel());

    final groups = await ref
        .watch(groupRepositoryProvider)
        .search(query, category: category, limit: _pageSize);

    return (
      groups: groups,
      hasMore: groups.length == _pageSize,
      loadingMore: false,
      failed: false,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();

    await future;
  }

  // 스크롤할 때마다 불려서, 이미 불러오는 중이거나 끝이면 아무 일 없음.
  // 보는 중에 인원이 바뀌어 순서가 밀린 그룹이 다시 오면 id로 거른다.
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
          .search(
            query,
            category: category,
            after: current.groups.last,
            limit: _pageSize,
          );

      if (!ref.mounted) return;

      final seen = {for (final g in current.groups) g.id};

      state = AsyncData((
        groups: [...current.groups, ...next.where((g) => !seen.contains(g.id))],
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

  /// 미리보기에 보여줄 그룹을 준비한다 (다 받은 뒤 미리보기를 연다). 이미 불러온
  /// 그룹이면 기다리지 않고(바로 열림) 뒤에서 최신으로 다시 받는다.
  /// 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> loadPreview(int groupId) async {
    final provider = publicGroupProvider(groupId);

    if (ref.read(provider).hasValue) return ref.invalidate(provider);

    await ref.read(provider.future);
  }

  /// 가입 신청. 실패하면 [GroupFailure] 또는 네트워크 오류를 던진다.
  Future<void> request(int groupId) async {
    await ref.read(groupRepositoryProvider).requestJoinPublic(groupId);

    // 처음부터 다시 불러오면 스크롤이 맨 위로 가서, 그 모임만 "신청 중"으로 바꾼다.
    if (state.value case final current?) {
      state = AsyncData((
        groups: [
          for (final g in current.groups)
            g.id == groupId
                ? (
                    id: g.id,
                    name: g.name,
                    description: g.description,
                    categories: g.categories,
                    memberCount: g.memberCount,
                    isMember: g.isMember,
                    isPending: true,
                  )
                : g,
        ],
        hasMore: current.hasMore,
        loadingMore: current.loadingMore,
        failed: current.failed,
      ));
    }

    // 모임 탭의 승인 대기 목록에 보이게.
    ref.invalidate(myJoinRequestsProvider);
  }
}
