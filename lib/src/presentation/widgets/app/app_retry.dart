import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 불러오기 실패 안내: [message]와 그 아래 다시 시도 버튼 ([onRetry]가 null이면
/// 버튼 없이 안내만, 예: 삭제된 글). 화면 가운데에 놓을 때는 [Center]로 감싼다.
class AppRetry extends StatelessWidget {
  const AppRetry({super.key, required this.message, required this.onRetry});

  final String message;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),

        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.sm),

          TextButton(onPressed: onRetry, child: const Text("다시 시도")),
        ],
      ],
    );
  }
}
