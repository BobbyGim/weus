import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "hooks/use_design_showcase.dart";

// ponytail: design-system demo on the home tab; delete once real home content lands.
const _swatches = [
  (name: "Primary", color: AppColors.primary),
  (name: "Pressed", color: AppColors.primaryPressed),
  (name: "Soft", color: AppColors.primarySoft),
  (name: "Ink", color: AppColors.ink),
  (name: "Gray 600", color: AppColors.gray600),
  (name: "Gray 300", color: AppColors.gray300),
  (name: "Gray 100", color: AppColors.gray100),
  (name: "Error", color: AppColors.error),
];

/// Every theme token and component in one scrollable column.
class DesignShowcase extends HookWidget {
  const DesignShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final showcase = useDesignShowcase();

    final theme = Theme.of(context);

    final text = theme.textTheme;

    final scheme = theme.colorScheme;

    final typeScale = [
      ("Display L 40", text.displayLarge),
      ("Display M 32", text.displayMedium),
      ("Headline L 24", text.headlineLarge),
      ("Headline S 20", text.headlineSmall),
      ("Title L 18", text.titleLarge),
      ("Title M 16", text.titleMedium),
      ("Body L 16", text.bodyLarge),
      ("Body M 15", text.bodyMedium),
      ("Body S 13", text.bodySmall),
      ("Label M 13", text.labelMedium),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Section("Color"),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.8,
            children: [
              for (final s in _swatches)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: s.color,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(s.name, style: text.labelSmall),
                  ],
                ),
            ],
          ),

          const _Section("Typography"),

          for (final (label, style) in typeScale)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      label,
                      style: text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      "함께라서 좋은 우리",
                      style: style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const _Section("Button"),

          FilledButton(onPressed: () {}, child: const Text("모임 참여하기")),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("나중에"),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              const Expanded(
                child: FilledButton(onPressed: null, child: Text("비활성")),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () {}, child: const Text("전체 보기")),
          ),

          const _Section("Input"),

          Text("이름", style: text.titleSmall),

          const SizedBox(height: AppSpacing.sm),

          TextField(
            controller: showcase.nameController,
            decoration: InputDecoration(
              hintText: "이름을 입력해 주세요",
              helperText: "1자를 입력하면 에러 상태가 보여요",
              errorText: showcase.nameError,
            ),
          ),

          const _Section("Chip"),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final chip in showcaseChips)
                ChoiceChip(
                  label: Text(chip),
                  selected: chip == showcase.selectedChip,
                  onSelected: (_) => showcase.selectChip(chip),
                ),
            ],
          ),

          const _Section("Card"),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      LucideIcons.calendar,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("청년부 금요 기도회", style: text.titleMedium),

                        const SizedBox(height: 2),

                        Text(
                          "11월 14일 (금) 오후 8:00 · 본당 2층",
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(LucideIcons.chevronRight, color: scheme.outline),
                ],
              ),
            ),
          ),

          const _Section("Divider"),

          const Divider(),

          const _Section("Feedback"),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showSnackBar,
                  child: const Text("스낵바"),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showSheet,
                  child: const Text("바텀시트"),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showConfirmDialog,
                  child: const Text("다이얼로그"),
                ),
              ),
            ],
          ),

          const _Section("Snackbar"),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showSuccess,
                  child: const Text("성공"),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showFailure,
                  child: const Text("실패"),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showInfo,
                  child: const Text("안내"),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showSnackBar,
                  child: const Text("아이콘 없이"),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton(
                  onPressed: showcase.showTop,
                  child: const Text("위쪽에 띄우기"),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xxxl,
        bottom: AppSpacing.md,
      ),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
