import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 승인 대기 중인 내 가입 신청 한 줄과 신청 취소 버튼.
class GroupRequestCard extends StatelessWidget {
  const GroupRequestCard({
    super.key,
    required this.request,
    required this.onCancel,
  });

  final MyJoinRequest request;

  final VoidCallback onCancel;

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
        leading: CircleAvatar(
          backgroundColor: scheme.surfaceContainerHighest,
          foregroundColor: scheme.onSurfaceVariant,
          child: const Icon(LucideIcons.hourglass, size: 20),
        ),
        title: Text(
          request.groupName,
          style: text.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "모임장의 수락을 기다리고 있어요",
          style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
        ),
        trailing: TextButton(onPressed: onCancel, child: const Text("신청 취소")),
      ),
    );
  }
}
