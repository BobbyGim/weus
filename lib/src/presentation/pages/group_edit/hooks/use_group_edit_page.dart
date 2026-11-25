import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";

import "../view_models/view_models.dart";

/// 모임 수정 화면이 채울 지금 값 ([data]). [retry]는 불러오기에 실패했을 때 다시 불러온다.
({AsyncValue<GroupDetail> data, VoidCallback retry}) useGroupEditPage(
  WidgetRef ref,
  int groupId,
) {
  final provider = groupEditViewModelProvider(groupId);

  return (data: ref.watch(provider), retry: () => ref.invalidate(provider));
}
