import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "repositories/repositories.dart";

part "public_group_provider.g.dart";

/// 공개 그룹 하나의 미리보기 (비공개·삭제면 null). 모임 찾기가 카드를 누를 때 새로
/// 불러오고(refresh) 다 받은 뒤 미리보기를 열어서, 미리보기는 로딩 없이 바로 그린다.
/// 딥링크로 미리보기를 바로 열면 미리보기가 직접 불러온다.
@Riverpod(keepAlive: true)
Future<GroupSearchResult?> publicGroup(Ref ref, int groupId) =>
    ref.watch(groupRepositoryProvider).fetchPublicGroup(groupId);
