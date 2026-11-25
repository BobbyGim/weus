import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:weus/src/domain/domain.dart";

import "../supabase/supabase.dart";

part "group_repository_impl.g.dart";

/// Supabase 그룹 테이블과 RPC. RLS로 내가 멤버인 그룹만 읽힌다.
class GroupRepositoryImpl implements GroupRepository {
  const GroupRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  /// RPC가 `raise exception '<코드>'`로 거절하면 이 문구로 바꿔 [GroupFailure]를 던진다.
  static const _failures = {
    "group_not_found": "초대 코드에 맞는 그룹이 없어요",
    "already_member": "이미 참여한 그룹이에요",
    "owner_has_members": "다른 멤버가 있으면 그룹장은 나갈 수 없어요",
    "request_already_decided": "이미 처리된 신청이에요",
    "request_not_found": "신청을 찾을 수 없어요",
    "not_owner": "그룹장만 할 수 있어요",
    "cannot_remove_self": "자기 자신은 내보낼 수 없어요",
    "invalid_category": "없는 카테고리예요",
    "duplicate_category": "같은 카테고리를 두 번 고를 수 없어요",
    "not_group_member": "그룹을 찾을 수 없어요",
  };

  Future<dynamic> _rpc(String fn, [Map<String, dynamic>? params]) =>
      _guard(() => _supabase.rpc(fn, params: params));

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on PostgrestException catch (e) {
      final message = _failures[e.message];

      if (message == null) rethrow;

      throw GroupFailure(message);
    }
  }

  @override
  Future<List<GroupCategory>> fetchCategories() async => [
    for (final row
        in await _supabase
            .from("group_categories")
            .select("id, name")
            // order()는 기본이 내림차순이라 오름차순을 적어 준다.
            .order("sort_order", ascending: true))
      (id: row["id"] as String, name: row["name"] as String),
  ];

  // 그룹 전체를 RLS로 훑지 않고 내 멤버십에서 출발하는 RPC. id 커서로 다음 페이지.
  @override
  Future<List<Group>> fetchMine({int? afterId, required int limit}) async => [
    for (final row in await _rpc("my_groups", {
      "p_after_id": afterId,
      "p_limit": limit,
    }) as List)
      (
        id: row["id"] as int,
        name: row["name"] as String,
        description: row["description"] as String,
        categories: (row["categories"] as List).cast<String>(),
        memberCount: row["member_count"] as int,
      ),
  ];

  // 멤버의 역할은 group_members, 이름·닉네임은 group_member_profiles에서.
  @override
  Future<GroupDetail> fetchDetail(int groupId) async {
    final row = await _supabase
        .from("groups")
        .select(
          "id, name, description, invite_code, categories, is_public, "
          "group_members(user_id, role)",
        )
        .eq("id", groupId)
        .maybeSingle();

    if (row == null) throw const GroupFailure("그룹을 찾을 수 없어요");

    final profiles = {
      for (final p in await _rpc("group_member_profiles", {
        "p_group_id": groupId,
      }) as List)
        p["user_id"] as String: p,
    };

    final me = _supabase.auth.currentUser!.id;

    final members = [
      for (final m in row["group_members"] as List)
        (
          userId: m["user_id"] as String,
          name: profiles[m["user_id"]]?["name"] as String? ?? "알 수 없음",
          nickname: profiles[m["user_id"]]?["nickname"] as String? ?? "",
          isOwner: m["role"] == "owner",
          isMe: m["user_id"] == me,
        ),
    ]..sort((a, b) => a.isOwner == b.isOwner ? 0 : (a.isOwner ? -1 : 1));

    return (
      id: row["id"] as int,
      name: row["name"] as String,
      description: row["description"] as String,
      inviteCode: row["invite_code"] as String,
      categories: (row["categories"] as List).cast<String>(),
      isPublic: row["is_public"] as bool,
      isOwner: members.any((m) => m.isMe && m.isOwner),
      members: members,
    );
  }

  @override
  Future<int> create({
    required String name,
    required String description,
    required List<String> categories,
    required bool isPublic,
    required String clientId,
  }) async => await _rpc("create_group", {
    "p_name": name,
    "p_description": description,
    "p_client_id": clientId,
    "p_is_public": isPublic,
    "p_categories": categories,
  }) as int;

  // RLS·컬럼 권한으로 owner만 바뀐다. 아니면 에러 없이 아무 행도 안 바뀌어서,
  // 바뀐 행을 돌려받아 비어 있으면 거절로 본다.
  @override
  Future<void> update(
    int groupId, {
    required String name,
    required String description,
    required List<String> categories,
  }) async {
    final rows = await _guard(
      () => _supabase
          .from("groups")
          .update({
            "name": name,
            "description": description,
            "categories": categories,
          })
          .eq("id", groupId)
          .select("id"),
    );

    if (rows.isEmpty) throw const GroupFailure("그룹장만 수정할 수 있어요");
  }

  // RLS·컬럼 권한으로 owner만 바뀐다 (아니면 아무 행도 안 바뀐다).
  @override
  Future<void> setPublic(int groupId, bool isPublic) => _supabase
      .from("groups")
      .update({"is_public": isPublic})
      .eq("id", groupId);

  @override
  Future<List<GroupSearchResult>> search(
    String query, {
    String? category,
    GroupSearchResult? after,
    required int limit,
  }) async => [
    // 커서 방식: 마지막 그룹의 (인원, id) 다음부터 인덱스로 읽는다.
    for (final row in await _rpc("search_groups", {
      "p_query": query,
      "p_category": category,
      "p_after_count": after?.memberCount,
      "p_after_id": after?.id,
      "p_limit": limit,
    }) as List)
      (
        id: row["id"] as int,
        name: row["name"] as String,
        description: row["description"] as String,
        categories: (row["categories"] as List).cast<String>(),
        memberCount: row["member_count"] as int,
        isMember: row["is_member"] as bool,
        isPending: row["is_pending"] as bool,
      ),
  ];

  @override
  Future<GroupPreview?> preview(String code) async {
    final rows = await _rpc("preview_group", {"p_code": code}) as List;

    if (rows.isEmpty) return null;

    final row = rows.first;

    return (
      name: row["name"] as String,
      description: row["description"] as String,
      memberCount: row["member_count"] as int,
    );
  }

  @override
  Future<void> requestJoin(String code) =>
      _rpc("request_join", {"p_code": code});

  @override
  Future<GroupSearchResult?> fetchPublicGroup(int groupId) async {
    final rows =
        await _rpc("preview_public_group", {"p_group_id": groupId}) as List;

    if (rows.isEmpty) return null;

    final row = rows.first;

    return (
      id: row["id"] as int,
      name: row["name"] as String,
      description: row["description"] as String,
      categories: (row["categories"] as List).cast<String>(),
      memberCount: row["member_count"] as int,
      isMember: row["is_member"] as bool,
      isPending: row["is_pending"] as bool,
    );
  }

  @override
  Future<void> requestJoinPublic(int groupId) =>
      _rpc("request_join_public", {"p_group_id": groupId});

  @override
  Future<List<MyJoinRequest>> fetchMyJoinRequests() async => [
    for (final row in await _rpc("my_join_requests") as List)
      (
        id: row["id"] as int,
        groupName: row["group_name"] as String,
        createdAt: DateTime.parse(row["created_at"] as String),
      ),
  ];

  @override
  Future<void> cancelJoinRequestForGroup(int groupId) =>
      _rpc("cancel_join_request_for_group", {"p_group_id": groupId});

  @override
  Future<void> cancelJoinRequest(int requestId) =>
      _rpc("cancel_join_request", {"p_request_id": requestId});

  @override
  Future<List<JoinRequest>> fetchJoinRequests(int groupId) async => [
    for (final row
        in await _rpc("pending_join_requests", {"p_group_id": groupId}) as List)
      (
        id: row["id"] as int,
        name: row["name"] as String,
        nickname: row["nickname"] as String,
        createdAt: DateTime.parse(row["created_at"] as String),
      ),
  ];

  @override
  Future<void> approveJoinRequest(int requestId) =>
      _rpc("approve_join_request", {"p_request_id": requestId});

  @override
  Future<void> rejectJoinRequest(int requestId) =>
      _rpc("reject_join_request", {"p_request_id": requestId});

  @override
  Future<void> leave(int groupId) =>
      _rpc("leave_group", {"p_group_id": groupId});

  @override
  Future<void> removeMember(int groupId, String userId) =>
      _rpc("remove_group_member", {"p_group_id": groupId, "p_user_id": userId});

  // groups·profiles·댓글 수를 RPC 안에서 join해 요청 한 번으로.
  @override
  Future<({GroupHeader? header, List<GroupPostSummary> posts})> fetchGroupHome(
    int groupId, {
    int? beforeId,
    required int limit,
  }) async {
    final data = await _rpc("group_home", {
      "p_group_id": groupId,
      "p_before_id": beforeId,
      "p_limit": limit,
    }) as Map<String, dynamic>;

    final group = data["group"] as Map<String, dynamic>?;

    return (
      header: group == null
          ? null
          : (
              name: group["name"] as String,
              categories: (group["categories"] as List).cast<String>(),
              memberCount: group["member_count"] as int,
            ),
      posts: [
        for (final row in data["posts"] as List)
          (
            id: row["id"] as int,
            title: row["title"] as String,
            authorName: row["author_name"] as String? ?? "알 수 없음",
            isMine: row["is_mine"] as bool? ?? false,
            commentCount: row["comment_count"] as int,
            createdAt: DateTime.parse(row["created_at"] as String),
          ),
      ],
    );
  }

  @override
  Future<GroupPost?> fetchPost(int groupId, int postId) async {
    final posts = await _withAuthors(
      groupId,
      _supabase
          .from("group_posts")
          .select("id, author_id, title, description, created_at")
          .eq("group_id", groupId)
          .eq("id", postId),
    );

    return posts.firstOrNull;
  }

  // 글 행에 작성자 이름을 붙인다. 이름은 group_member_profiles (나간 멤버도 들어 있다)에서.
  Future<List<GroupPost>> _withAuthors(
    int groupId,
    Future<List<Map<String, dynamic>>> query,
  ) async {
    final (rows, people) = await (
      query,
      _rpc("group_member_profiles", {"p_group_id": groupId}),
    ).wait;

    final names = {
      for (final p in people as List)
        p["user_id"] as String: p["name"] as String,
    };

    final me = _supabase.auth.currentUser!.id;

    return [
      for (final row in rows)
        (
          id: row["id"] as int,
          authorName: names[row["author_id"]] ?? "알 수 없음",
          isMine: row["author_id"] == me,
          title: row["title"] as String,
          description: row["description"] as String,
          createdAt: DateTime.parse(row["created_at"] as String),
        ),
    ];
  }

  @override
  Future<void> createPost(
    int groupId, {
    required String title,
    required String description,
    required String clientId,
  }) => _rpc("create_post", {
    "p_group_id": groupId,
    "p_title": title,
    "p_description": description,
    "p_client_id": clientId,
  });
}

@Riverpod(keepAlive: true)
GroupRepository groupRepository(Ref ref) =>
    GroupRepositoryImpl(ref.watch(supabaseProvider));
