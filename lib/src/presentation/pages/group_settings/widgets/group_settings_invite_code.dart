import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 초대 코드 카드: 코드와 안내, 오른쪽에 복사 버튼 ([onCopy]).
class GroupSettingsInviteCode extends StatelessWidget {
  const GroupSettingsInviteCode({
    super.key,
    required this.code,
    required this.onCopy,
  });

  final String code;

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.sm,
        ),
        title: Text(code, style: text.titleLarge!.copyWith(letterSpacing: 2)),
        subtitle: Text(
          "이 코드로 가입 신청할 수 있어요",
          style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
        ),
        trailing: TextButton(onPressed: onCopy, child: const Text("복사")),
      ),
    );
  }
}
