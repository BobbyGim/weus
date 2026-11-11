import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "package:weus/src/presentation/theme/theme.dart";

import "widgets/my_menu_tile.dart";
import "widgets/my_profile_card.dart";

// shortcut: menus with a null path are placeholders with no-op taps, give
// each its route when the page behind it exists.
const _sections = [
  (
    title: "설정",
    menus: [
      (label: "알림 설정", icon: LucideIcons.bell, path: "/mypage/notifications"),
    ],
  ),
  (
    title: "고객지원",
    menus: [
      (label: "공지사항", icon: LucideIcons.megaphone, path: null),
      (label: "문의하기", icon: LucideIcons.messageCircle, path: null),
      (label: "이용약관", icon: LucideIcons.fileText, path: null),
    ],
  ),
];

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // shortcut: hardcoded user, read it from a MyViewModel once auth lands.
        MyProfileCard(
          name: "위어스",
          email: "weus@example.com",
          onTap: () => context.push("/mypage/info"),
        ),

        for (final s in _sections) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xxl,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Text(
              s.title,
              style: text.titleSmall!.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, m) in s.menus.indexed) ...[
                  if (i > 0) const Divider(),

                  MyMenuTile(
                    icon: m.icon,
                    label: m.label,
                    onTap: () {
                      if (m.path case final path?) context.push(path);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
