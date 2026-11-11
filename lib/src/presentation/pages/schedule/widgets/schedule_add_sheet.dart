import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "package:weus/src/data/data.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/use_schedule_add_sheet.dart";

/// Bottom sheet body that registers a schedule, laid out like a mail
/// composer: close on top, then the title, the period (today to today at
/// first), a description that takes the rest and the save button. 90% of the
/// screen; the sheet stays put when the keyboard opens, only the description
/// shrinks and the save button sits right above the keyboard.
class ScheduleAddSheet extends HookConsumerWidget {
  const ScheduleAddSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useScheduleAddSheet();

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    // Borderless fields: the dividers separate the rows instead.
    InputDecoration plain(String hint, TextStyle style) => InputDecoration(
      hintText: hint,
      hintStyle: style.copyWith(color: AppColors.gray400),
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    );

    void save() {
      ref.read(schedulesProvider.notifier).add(form.schedule());

      showAppSnackBar(
        context,
        "일정을 등록했어요",
        icon: LucideIcons.circleCheck,
        top: true,
      );

      Navigator.of(context).pop();
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Padding(
        // Keeps the description and the save button above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SizedBox(
                  height: 48,
                  child: NavigationToolbar(
                    leading: IconButton(
                      tooltip: "닫기",
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(LucideIcons.x),
                    ),
                    middle: Text("일정 등록", style: text.titleMedium),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: TextField(
                  controller: form.title,
                  textInputAction: TextInputAction.next,
                  style: text.titleLarge,
                  decoration: plain("제목", text.titleLarge!),
                ),
              ),

              const Divider(height: 1),

              // One tap target: start and end are picked together.
              Semantics(
                button: true,
                label: "기간 선택",
                child: InkWell(
                  onTap: form.pickDates,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "기간",
                          style: text.bodyLarge!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.lg),

                        Flexible(
                          child: Text(form.startLabel, style: text.bodyLarge),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Icon(
                            LucideIcons.arrowRight,
                            size: 16,
                            color: AppColors.gray400,
                          ),
                        ),

                        Flexible(
                          child: Text(form.endLabel, style: text.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Fills the rest and scrolls inside itself, like a mail body.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: TextField(
                    controller: form.description,
                    expands: true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    style: text.bodyLarge,
                    decoration: plain("시간, 장소, 준비물 등", text.bodyLarge!),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: FilledButton(
                  onPressed: form.canSave ? save : null,
                  child: const Text("저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
