import "package:material_ui/material_ui.dart";

/// 아래에서 내용만큼 올라오는 바텀시트 페이지 (일정 등록 시트와 같은 모양: 위 손잡이,
/// 아래로 끌거나 바깥을 누르면 닫힘). 높이는 [builder]가 정한다.
class BottomSheetPage<T> extends Page<T> {
  const BottomSheetPage({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute<T>(
    settings: this,
    builder: builder,
    isScrollControlled: true,
  );
}
