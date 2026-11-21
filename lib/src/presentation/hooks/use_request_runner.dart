import "package:flutter_hooks/flutter_hooks.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

/// 서버 요청 실행기. [run]은 요청하는 동안 [busy]를 켜고(로딩 오버레이용), 실패하면
/// 스낵바로 알린 뒤 false를 돌려준다 ([GroupFailure]면 그 문구, 아니면 일반 문구).
({bool busy, Future<bool> Function(Future<void> Function() action) run})
useRequestRunner() {
  final context = useContext();

  final busy = useState(false);

  Future<bool> run(Future<void> Function() action) async {
    busy.value = true;

    try {
      await action();

      return true;
    } on GroupFailure catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    } catch (_) {
      if (context.mounted) showAppSnackBar(context, "잠시 후 다시 시도해 주세요");
    } finally {
      if (context.mounted) busy.value = false;
    }

    return false;
  }

  return (busy: busy.value, run: run);
}
