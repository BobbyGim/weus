import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:weus/src/presentation/hooks/hooks.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

/// 그룹 상세의 요청 처리 ([useRequestRunner])와 초대 코드 복사.
({
  bool busy,
  Future<bool> Function(Future<void> Function() action) run,
  void Function(String code) copyCode,
})
useGroupDetailPage() {
  final context = useContext();

  final (:busy, :run) = useRequestRunner();

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));

    showAppSnackBar(context, "초대 코드를 복사했어요", icon: LucideIcons.circleCheck);
  }

  return (busy: busy, run: run, copyCode: copyCode);
}
