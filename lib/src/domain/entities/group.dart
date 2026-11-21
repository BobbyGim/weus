/// 모임 카테고리 (운동, 독서 …). [id]가 그룹에 저장되는 값이다.
typedef GroupCategory = ({String id, String name});

/// 내가 속한 그룹(모임). [memberCount]는 멤버 수 (owner 포함).
/// [categories]는 [GroupCategory.id] 목록.
typedef Group = ({
  int id,
  String name,
  String description,
  List<String> categories,
  int memberCount,
});

/// 그룹 멤버. 이름과 닉네임은 같은 그룹 멤버에게만 보인다.
typedef GroupMember = ({
  String userId,
  String name,
  String nickname,
  bool isOwner,
  bool isMe,
});

/// 그룹 상세. [inviteCode]는 멤버 누구나 보고 공유할 수 있다.
/// [categories]는 [GroupCategory.id] 목록 (최대 3개).
/// [members]는 owner가 맨 앞. [isPublic]이면 모임 찾기에 보인다.
typedef GroupDetail = ({
  int id,
  String name,
  String description,
  String inviteCode,
  List<String> categories,
  bool isPublic,
  bool isOwner,
  List<GroupMember> members,
});

/// 모임 찾기에서 찾은 공개 그룹. [isMember]면 이미 멤버, [isPending]이면 신청 대기 중.
typedef GroupSearchResult = ({
  int id,
  String name,
  String description,
  List<String> categories,
  int memberCount,
  bool isMember,
  bool isPending,
});

/// 초대 코드로 미리 본 그룹.
typedef GroupPreview = ({String name, String description, int memberCount});

/// 내가 넣은, 대기 중인 가입 신청.
typedef MyJoinRequest = ({int id, String groupName, DateTime createdAt});

/// owner에게 들어온, 대기 중인 가입 신청.
typedef JoinRequest = ({
  int id,
  String name,
  String nickname,
  DateTime createdAt,
});
