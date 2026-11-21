import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// owner에게 보이는 가입 신청 한 줄과 거절·수락 버튼.
class GroupDetailRequestTile extends StatelessWidget {
  const GroupDetailRequestTile({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final JoinRequest request;

  final VoidCallback onApprove;

  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.sm,
      ),
      title: Text(
        request.name,
        style: text.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        request.nickname,
        style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: onReject, child: const Text("거절")),

          const SizedBox(width: AppSpacing.xs),

          // 목록 줄 안이라 기본 버튼(52 높이)보다 작게.
          FilledButton.tonal(
            onPressed: onApprove,
            style: FilledButton.styleFrom(
              minimumSize: const Size(56, 40),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            child: const Text("수락"),
          ),
        ],
      ),
    );
  }
}
