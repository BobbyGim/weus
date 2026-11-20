import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";

/// 일정 등록 시트를 연다. [schedule]을 넘기면 그 일정을 수정한다.
/// 하루 시트 안에서 열면 그 시트를 먼저 닫는다 (저장 후 목록이 낡기 때문).
void showScheduleAddSheet(BuildContext context, {Schedule? schedule}) {
  // 하단 내비 위로 띄우고, 하루 시트가 닫혀도 남는 context를 쓴다.
  final root = Navigator.of(context, rootNavigator: true);

  if (ModalRoute.of(context) is PopupRoute) root.pop();

  showModalBottomSheet<void>(
    context: root.context,
    // 시트 높이(화면의 90%)를 ScheduleAddSheet가 정하게 한다.
    isScrollControlled: true,
    builder: (_) => ScheduleAddSheet(schedule: schedule),
  );
}

/// Bottom sheet body that registers a schedule, laid out like a mail
/// composer: close on top, then the title, the start and end date rows (today
/// at first), a description that takes the rest and the save button. 90% of the
/// screen; the sheet stays put when the keyboard opens, only the description
/// shrinks and the save button sits right above the keyboard.
/// [schedule]이 있으면 그 일정을 채워서 수정 모드로 연다.
class ScheduleAddSheet extends HookConsumerWidget {
  const ScheduleAddSheet({super.key, this.schedule});

  final Schedule? schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useScheduleAddSheet(schedule);

    final editing = schedule;

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

    // 시작일·종료일 행. 누르면 그 날짜만 고르는 달력이 열린다.
    Widget dateRow(String label, String value, VoidCallback onTap) => Semantics(
      button: true,
      label: "$label 선택",
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          // 라벨은 왼쪽, 날짜는 오른쪽 끝 (iOS 설정 화면처럼).
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: text.bodyLarge!.copyWith(color: scheme.onSurfaceVariant),
              ),

              const SizedBox(width: AppSpacing.lg),

              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: text.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    void save() {
      final schedules = ref.read(schedulesProvider.notifier);

      if (editing == null) {
        schedules.add(form.schedule());
      } else {
        schedules.edit(editing.id, form.schedule());
      }

      showAppSnackBar(
        context,
        editing == null ? "일정을 등록했어요" : "일정을 수정했어요",
        icon: LucideIcons.circleCheck,
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
                    middle: Text(
                      editing == null ? "일정 등록" : "일정 수정",
                      style: text.titleMedium,
                    ),
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

              dateRow("시작일", form.startLabel, form.pickStart),

              const Divider(height: 1),

              dateRow("종료일", form.endLabel, form.pickEnd),

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
