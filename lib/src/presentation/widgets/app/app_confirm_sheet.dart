import "package:cupertino_ui/cupertino_ui.dart";

/// 되돌리기 어려운 동작을 아래에서 올라오는 액션시트로 묻는다 (일정 삭제, 모임 나가기,
/// 신청 취소 …). 빨간 [action]을 누르면 true, 취소하거나 바깥을 누르면 false.
Future<bool> showAppConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async =>
    await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        message: Text(message),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("닫기"),
        ),
      ),
    ) ??
    false;
