import "../entities/entities.dart";

/// 그룹 RPC가 거절한 요청은 [GroupFailure]로 던진다.
abstract interface class GroupRepository {
  /// 카테고리 목록, 보여주는 순서대로.
  Future<List<GroupCategory>> fetchCategories();

  /// 내가 속한 그룹, 최근에 만든 것부터 [limit]개. 다음 페이지는 마지막으로 받은
  /// 그룹의 id를 [afterId]로 넘긴다.
  Future<List<Group>> fetchMine({int? afterId, required int limit});

  /// 내가 멤버가 아니거나 없는 그룹이면 [GroupFailure].
  Future<GroupDetail> fetchDetail(int groupId);

  /// 그룹을 만들고 만든 사람을 owner로 넣는다. 같은 [clientId]로 다시 부르면
  /// 새로 만들지 않고 처음 만든 그룹 id를 돌려준다 (두 번 탭, 재시도).
  /// [isPublic]이면 모임 찾기에 보인다. [categories]는 카테고리 id (최대 3개).
  Future<int> create({
    required String name,
    required String description,
    required List<String> categories,
    required bool isPublic,
    required String clientId,
  });

  /// owner만. 이름·소개·카테고리를 바꾼다. owner가 아니면 [GroupFailure].
  Future<void> update(
    int groupId, {
    required String name,
    required String description,
    required List<String> categories,
  });

  /// owner만. 공개 여부를 바꾼다.
  Future<void> setPublic(int groupId, bool isPublic);

  /// 이름에 [query]가 들어간 공개 그룹 (빈 검색어면 전부, [category]가 있으면 그
  /// 카테고리만), 인원 많은 순으로 [limit]개. 다음 페이지는 마지막으로 받은 그룹을
  /// [after]로 넘긴다.
  Future<List<GroupSearchResult>> search(
    String query, {
    String? category,
    GroupSearchResult? after,
    required int limit,
  });

  /// 초대 코드에 맞는 그룹, 없으면 null.
  Future<GroupPreview?> preview(String code);

  /// 가입 신청. 이미 대기 중이면 그 신청을 그대로 둔다. 나갔던 그룹도 다시 신청할 수 있다.
  Future<void> requestJoin(String code);

  /// 공개 그룹 하나의 미리보기 (멤버가 아니어도 된다). 비공개·삭제된 그룹이면 null.
  Future<GroupSearchResult?> fetchPublicGroup(int groupId);

  /// 모임 찾기에서 공개 그룹에 가입 신청. 이미 대기 중이면 그 신청을 그대로 둔다.
  Future<void> requestJoinPublic(int groupId);

  /// 내가 넣은 대기 중인 신청.
  Future<List<MyJoinRequest>> fetchMyJoinRequests();

  Future<void> cancelJoinRequest(int requestId);

  /// 그 그룹에 낸 내 대기 중 신청을 취소한다 (미리보기에서). 없으면 아무 일 없음.
  Future<void> cancelJoinRequestForGroup(int groupId);

  /// owner만. 그 그룹에 들어온 대기 중인 신청.
  Future<List<JoinRequest>> fetchJoinRequests(int groupId);

  Future<void> approveJoinRequest(int requestId);

  Future<void> rejectJoinRequest(int requestId);

  /// owner는 다른 멤버가 있으면 [GroupFailure], 혼자면 그룹도 삭제된다.
  Future<void> leave(int groupId);

  /// owner만. [userId]를 내보낸다.
  Future<void> removeMember(int groupId, String userId);

  /// 그룹 홈 한 번에: 그룹 [header]와 게시글, 최근 글부터 [limit]개. 다음 페이지는
  /// 마지막으로 받은 글의 id를 [beforeId]로 넘기고, 그때 [header]는 null.
  /// 멤버가 아니면 [GroupFailure].
  Future<({GroupHeader? header, List<GroupPostSummary> posts})> fetchGroupHome(
    int groupId, {
    int? beforeId,
    required int limit,
  });

  /// 글 하나. 삭제됐거나 없으면 null.
  Future<GroupPost?> fetchPost(int groupId, int postId);

  /// 글을 올린다. 같은 [clientId]로 다시 부르면 새로 만들지 않는다 (두 번 탭, 재시도).
  Future<void> createPost(
    int groupId, {
    required String title,
    required String description,
    required String clientId,
  });
}

/// 그룹 요청 거절. [message]는 사용자에게 그대로 보여줄 문구다.
class GroupFailure implements Exception {
  const GroupFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
