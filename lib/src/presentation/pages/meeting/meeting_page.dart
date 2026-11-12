import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "package:weus/src/presentation/theme/theme.dart";

// shortcut: hardcoded meetings with no-op taps, read them from a
// MeetingViewModel (and open a detail page) once the meeting data exists.
const _meetings = [
  (name: "주말 러닝 크루", members: 12, next: "11월 15일 (토) 오전 7:00"),
  (name: "독서 모임", members: 6, next: "11월 19일 (수) 오후 8:00"),
  (name: "대학 동기 모임", members: 8, next: null),
];

class MeetingPage extends StatelessWidget {
  const MeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _meetings.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final m = _meetings[i];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: const Icon(LucideIcons.users, size: 20),
            ),
            title: Text(m.name, style: text.titleMedium),
            subtitle: Text(
              "${m.members}명 · ${m.next ?? "예정된 일정 없음"}",
              style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
            ),
            trailing: const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.gray400,
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
