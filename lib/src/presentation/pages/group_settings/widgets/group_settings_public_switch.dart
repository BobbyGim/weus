import "package:material_ui/material_ui.dart";

/// 공개 그룹 스위치 카드 (owner만). 켜고 끌 때마다 [onChanged].
class GroupSettingsPublicSwitch extends StatelessWidget {
  const GroupSettingsPublicSwitch({
    super.key,
    required this.isPublic,
    required this.onChanged,
  });

  final bool isPublic;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Card(
      child: SwitchListTile(
        value: isPublic,
        onChanged: onChanged,
        title: Text("공개 그룹", style: text.titleMedium),
        subtitle: Text(
          isPublic
              ? "그룹 찾기에서 누구나 찾고 가입 신청할 수 있어요"
              : "초대 코드를 받은 사람만 가입 신청할 수 있어요",
          style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
