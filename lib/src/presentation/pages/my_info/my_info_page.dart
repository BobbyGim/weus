import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";

import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "view_models/view_models.dart";

class MyInfoPage extends ConsumerWidget {
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myInfoViewModelProvider);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const AppBackButton(fallback: "/mypage"),
        title: const Text("내 정보"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              title: Text("닉네임", style: text.bodyLarge),
              // 불러오는 동안은 비워 둔다.
              trailing: Text(
                profile.value?.nickname ??
                    (profile.hasError ? "불러오지 못했어요" : ""),
                style: text.bodyLarge!.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          OutlinedButton(
            onPressed: () =>
                ref.read(myInfoViewModelProvider.notifier).signOut(),
            child: const Text("로그아웃"),
          ),
        ],
      ),
    );
  }
}
