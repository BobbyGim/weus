import "package:flutter_hooks/flutter_hooks.dart";

/// On/off of each notification switch.
// shortcut: local state only, lost on leaving the page; move it to a
// NotificationSettingsViewModel once there is somewhere to save it.
({
  bool push,
  bool schedule,
  void Function(bool value) onPushChanged,
  void Function(bool value) onScheduleChanged,
})
useNotificationSettingsPage() {
  final push = useState(true);

  final schedule = useState(true);

  return (
    push: push.value,
    schedule: schedule.value,
    onPushChanged: (value) => push.value = value,
    onScheduleChanged: (value) => schedule.value = value,
  );
}
