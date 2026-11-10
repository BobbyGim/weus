import "package:flutter/material.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// Covers the whole app while the internet is down. Not a route: `MyApp`
/// lays it over the router, so the page underneath keeps its state.
class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 40,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    Text(
                      "인터넷 연결이 끊겼어요",
                      style: text.headlineSmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      "Wi-Fi 또는 모바일 데이터를 확인해 주세요.\n연결되면 보던 화면으로 바로 돌아가요.",
                      style: text.bodyMedium!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onRetry,
                  child: const Text("다시 시도"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
