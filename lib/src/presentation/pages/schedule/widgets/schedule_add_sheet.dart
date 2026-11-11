import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "package:weus/src/data/data.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/use_schedule_add_sheet.dart";

/// Bottom sheet body that registers a schedule: title, period (today to
/// today at first) and an optional description. As tall as its form, and it
/// moves up with the keyboard.
class ScheduleAddSheet extends HookConsumerWidget {
  const ScheduleAddSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useScheduleAddSheet();

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final labelStyle = text.labelMedium!.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget dateTile(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),

          const SizedBox(height: AppSpacing.xs),

          Text(value, style: text.titleMedium),
        ],
      ),
    );

    return Padding(
      // Keeps the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("일정 등록", style: text.titleLarge),

              const SizedBox(height: AppSpacing.xl),

              Text("제목", style: labelStyle),

              const SizedBox(height: AppSpacing.sm),

              TextField(
                controller: form.title,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: "예) 주일 예배"),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text("기간", style: labelStyle),

              const SizedBox(height: AppSpacing.sm),

              // One tap target: start and end are picked together.
              Semantics(
                button: true,
                label: "기간 선택",
                child: Material(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: form.pickDates,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          dateTile("시작", form.startLabel),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Icon(
                              LucideIcons.arrowRight,
                              size: 18,
                              color: AppColors.gray400,
                            ),
                          ),

                          dateTile("종료", form.endLabel),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text("설명 (선택)", style: labelStyle),

              const SizedBox(height: AppSpacing.sm),

              TextField(
                controller: form.description,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(hintText: "시간, 장소, 준비물 등"),
              ),

              const SizedBox(height: AppSpacing.xxl),

              FilledButton(
                onPressed: !form.canSave
                    ? null
                    : () {
                        ref
                            .read(schedulesProvider.notifier)
                            .add(form.schedule());

                        showAppSnackBar(
                          context,
                          "일정을 등록했어요",
                          icon: LucideIcons.circleCheck,
                          top: true,
                        );

                        Navigator.of(context).pop();
                      },
                child: const Text("저장"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
