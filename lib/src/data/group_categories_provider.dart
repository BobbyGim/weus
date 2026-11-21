import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "repositories/repositories.dart";

part "group_categories_provider.g.dart";

/// 모임 카테고리 목록. 자주 안 바뀌어서 처음 한 번만 불러온다 (모임 만들기·찾기·상세가 같이 쓴다).
@Riverpod(keepAlive: true)
Future<List<GroupCategory>> groupCategories(Ref ref) =>
    ref.watch(groupRepositoryProvider).fetchCategories();
