import "dart:async";

import "package:flutter/widgets.dart";

/// 앱이 화면에 보이고 잠시 뒤에 완료된다: 실행 시에는 첫 프레임 이후,
/// 백그라운드에서 돌아올 때는 resumed 이후.
// shortcut: iOS 앱 열림 애니메이션을 고정 딜레이로 기다림, 시작 작업(auth 체크)이
// 생기면 여기서 함께 기다린다.
Future<void> onScreen() async {
  await WidgetsBinding.instance.endOfFrame;

  final state = WidgetsBinding.instance.lifecycleState;

  if (state != null && state != AppLifecycleState.resumed) {
    final resumed = Completer<void>();

    final listener = AppLifecycleListener(onResume: resumed.complete);

    await resumed.future;

    listener.dispose();
  }

  await Future<void>.delayed(const Duration(milliseconds: 400));
}
