import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/use_notification_settings_page.dart";

class NotificationSettingsPage extends HookWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = useNotificationSettingsPage();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const AppBackButton(fallback: "/mypage"),
        title: const Text("알림 설정"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("푸시 알림"),
                  value: settings.push,
                  onChanged: settings.onPushChanged,
                ),

                const Divider(),

                SwitchListTile(
                  title: const Text("일정 알림"),
                  value: settings.schedule,
                  onChanged: settings.onScheduleChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
