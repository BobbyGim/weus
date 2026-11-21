import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 멤버 한 줄: 이름, 닉네임, 모임장·나 표시. [onRemove]가 있으면 내보내기 버튼.
class GroupDetailMemberTile extends StatelessWidget {
  const GroupDetailMemberTile({super.key, required this.member, this.onRemove});

  final GroupMember member;

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.sm,
      ),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Text(member.name.characters.first),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              member.isMe ? "${member.name} (나)" : member.name,
              style: text.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (member.isOwner) ...[
            const SizedBox(width: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                "모임장",
                style: text.labelSmall!.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        member.nickname,
        style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
      ),
      trailing: onRemove == null
          ? null
          : TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              child: const Text("내보내기"),
            ),
    );
  }
}
