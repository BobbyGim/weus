import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

const showcaseChips = ["전체", "예배", "소그룹", "봉사", "행사"];

({
  String selectedChip,
  ValueChanged<String> selectChip,
  TextEditingController nameController,
  String? nameError,
  VoidCallback showSnackBar,
  VoidCallback showSuccess,
  VoidCallback showFailure,
  VoidCallback showInfo,
  VoidCallback showTop,
  VoidCallback showSheet,
  VoidCallback showConfirmDialog,
})
useDesignShowcase() {
  final context = useContext();

  final selectedChip = useState(showcaseChips.first);

  final nameController = useTextEditingController();

  // Rebuild on typing so the error text updates live.
  final name = useValueListenable(nameController).text;

  final nameError = name.isNotEmpty && name.trim().length < 2
      ? "이름은 2자 이상 입력해 주세요"
      : null;

  void showSnackBar() => showAppSnackBar(context, "일정이 저장되었어요");

  void showSuccess() =>
      showAppSnackBar(context, "일정이 등록되었어요", icon: Icons.check_circle_outline);

  void showFailure() => showAppSnackBar(
    context,
    "일정을 등록하지 못했어요. 다시 시도해 주세요",
    icon: Icons.error_outline,
  );

  void showInfo() =>
      showAppSnackBar(context, "모임 시작 10분 전에 알려드릴게요", icon: Icons.info_outline);

  void showTop() => showAppSnackBar(
    context,
    "위쪽에 뜨는 스낵바예요",
    icon: Icons.arrow_upward,
    top: true,
  );

  // Root navigator: the tab's own navigator sits under the bottom nav.
  void showSheet() => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("바텀시트", style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 8),

          Text(
            "상단 모서리 20, 드래그 핸들이 기본으로 붙어요.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    ),
  );

  void showConfirmDialog() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("모임에서 나갈까요?"),
      content: const Text("나가면 이 모임의 일정 알림을 더 이상 받지 않아요."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소"),
        ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text("나가기"),
        ),
      ],
    ),
  );

  return (
    selectedChip: selectedChip.value,
    selectChip: (chip) => selectedChip.value = chip,
    nameController: nameController,
    nameError: nameError,
    showSnackBar: showSnackBar,
    showSuccess: showSuccess,
    showFailure: showFailure,
    showInfo: showInfo,
    showTop: showTop,
    showSheet: showSheet,
    showConfirmDialog: showConfirmDialog,
  );
}
