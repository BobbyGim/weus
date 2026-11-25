import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";

import "../view_models/view_models.dart";

/// 마이페이지: 프로필 카드에 쓸 [name]·[email] (불러오는 동안은 빈 값, 실패하면
/// 이름 자리에 안내), [openInfo]는 내 정보, [openMenu]는 메뉴의 화면으로 (경로가
/// null이면 아무 일 없음).
({
  String name,
  String email,
  VoidCallback openInfo,
  void Function(String? path) openMenu,
})
useMyPage(WidgetRef ref) {
  final context = useContext();

  final profile = ref.watch(myViewModelProvider);

  return (
    name: profile.value?.name ?? (profile.hasError ? "정보를 불러오지 못했어요" : ""),
    email: profile.value?.email ?? "",
    openInfo: () => context.go("/mypage/info"),
    openMenu: (path) {
      if (path != null) context.go(path);
    },
  );
}
