import "package:flutter/material.dart";

import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              // shortcut: hardcoded user, read it from a MyInfoViewModel once
              // auth lands.
              trailing: Text(
                "위어스",
                style: text.bodyLarge!.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // shortcut: no-op, call the auth sign-out once it exists.
          OutlinedButton(onPressed: () {}, child: const Text("로그아웃")),
        ],
      ),
    );
  }
}
