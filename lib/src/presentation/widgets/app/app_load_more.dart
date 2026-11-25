import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 페이지로 나눠 불러오는 목록 끝의 한 칸: 불러오는 중이면 로딩(+[label]),
/// 실패했으면([failed]) 누르면 [onRetry]하는 다시 시도 버튼.
class AppLoadMore extends StatelessWidget {
  const AppLoadMore({
    super.key,
    required this.failed,
    required this.onRetry,
    this.label,
  });

  final bool failed;

  final VoidCallback onRetry;

  /// 로딩 아래 작은 안내 (예: "그룹을 더 불러오는 중").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 96,
      child: Center(
        child: failed
            ? TextButton(
                onPressed: onRetry,
                child: const Text("더 불러오지 못했어요 · 다시 시도"),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),

                  if (label != null) ...[
                    const SizedBox(height: AppSpacing.md),

                    Text(
                      label!,
                      style: text.bodyMedium!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
