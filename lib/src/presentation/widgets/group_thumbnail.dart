import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "group_image.dart";

/// 모임 썸네일 ([GroupImage]: 모든 모임이 같은 그라데이션과 아이콘).
class GroupThumbnail extends StatelessWidget {
  const GroupThumbnail({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: GroupImage.gradient,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: Container(
          width: size * 0.56,
          height: size * 0.56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            GroupImage.icon,
            size: size * 0.28,
            color: GroupImage.iconColor,
          ),
        ),
      ),
    );
  }
}
