import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";

import "../view_models/view_models.dart";

/// 내 정보: [nickname] (불러오는 동안은 빈 값, 실패하면 안내)과 [signOut].
({String nickname, VoidCallback signOut}) useMyInfoPage(WidgetRef ref) {
  final profile = ref.watch(myInfoViewModelProvider);

  return (
    nickname: profile.value?.nickname ?? (profile.hasError ? "불러오지 못했어요" : ""),
    signOut: () => ref.read(myInfoViewModelProvider.notifier).signOut(),
  );
}
