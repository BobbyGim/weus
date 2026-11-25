import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";

import "../view_models/view_models.dart";

/// 글 상세의 글 ([data], 삭제됐거나 없는 글이면 null). [refresh]는 다시 불러온다.
({AsyncValue<GroupPost?> data, VoidCallback refresh}) useGroupPostPage(
  WidgetRef ref,
  int groupId,
  int postId,
) {
  final provider = groupPostViewModelProvider(groupId, postId);

  return (
    data: ref.watch(provider),
    refresh: ref.read(provider.notifier).refresh,
  );
}
