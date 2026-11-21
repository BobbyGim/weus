import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 모든 모임이 같이 쓰는 이미지 (사진 대신): 브랜드 파란색 그라데이션 위의 사람 아이콘.
/// 목록 썸네일과 상세 위쪽이 같은 모양이다.
abstract final class GroupImage {
  static const icon = LucideIcons.users;

  static const iconColor = AppColors.primary;

  /// 위에서 아래로 연해지는 파란색 (primary → primarySoft 쪽으로 25%, 75%).
  static const gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5E9EF8), Color(0xFFB8D7FD)],
  );
}
