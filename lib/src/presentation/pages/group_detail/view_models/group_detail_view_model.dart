import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "group_detail_view_model.g.dart";

const _pageSize = 20;

/// 그룹 홈: 그룹 이름·카테고리·멤버 수와 게시글 20개씩 ([loadMore]로 다음 페이지).
/// [hasMore]: 더 불러올 글이 남았는지, [loadingMore]·[failed]: 다음 페이지 상태.
typedef GroupHome = ({
  GroupHeader header,
  List<GroupPostSummary> posts,
  bool hasMore,
  bool loadingMore,
  bool failed,
});

/// 요청 한 번(group_home)으로 불러온다. 멤버가 아니거나 없는 그룹이면
/// [GroupFailure], 그 밖의 실패는 네트워크 오류를 던진다.
@riverpod
class GroupDetailViewModel extends _$GroupDetailViewModel {
  @override
  Future<GroupHome> build(int groupId) async {
    final (:header, :posts) = await ref
        .watch(groupRepositoryProvider)
        .fetchGroupHome(groupId, limit: _pageSize);

    return (
      header: header!,
      posts: posts,
      hasMore: posts.length == _pageSize,
      loadingMore: false,
      failed: false,
    );
  }

  /// 글을 올리거나 그룹 설정에서 돌아온 뒤: 첫 페이지부터 다시 불러온다.
  Future<void> refresh() async {
    ref.invalidateSelf();

    await future;
  }

  // 스크롤할 때마다 불려서, 이미 불러오는 중이거나 끝이면 아무 일 없음.
  Future<void> loadMore() async {
    final current = state.value;

    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData((
      header: current.header,
      posts: current.posts,
      hasMore: true,
      loadingMore: true,
      failed: false,
    ));

    try {
      final (header: _, posts: next) = await ref
          .read(groupRepositoryProvider)
          .fetchGroupHome(
            groupId,
            beforeId: current.posts.last.id,
            limit: _pageSize,
          );

      if (!ref.mounted) return;

      state = AsyncData((
        header: current.header,
        posts: [...current.posts, ...next],
        hasMore: next.length == _pageSize,
        loadingMore: false,
        failed: false,
      ));
    } catch (_) {
      if (!ref.mounted) return;

      // 목록은 그대로 두고 끝에 다시 시도 버튼을 보여준다.
      state = AsyncData((
        header: current.header,
        posts: current.posts,
        hasMore: true,
        loadingMore: false,
        failed: true,
      ));
    }
  }
}
