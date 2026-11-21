import "package:cupertino_ui/cupertino_ui.dart";

/// 아래에서 올라와 화면을 다 덮는 iOS 시트 페이지. 스크롤이 맨 위일 때 아래로 끌면
/// 닫힌다. [builder]가 받는 컨트롤러를 화면의 스크롤에 넘겨야 스크롤과 끌어서
/// 닫기가 이어진다.
class SheetPage<T> extends Page<T> {
  const SheetPage({super.key, required this.builder});

  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  @override
  Route<T> createRoute(BuildContext context) => CupertinoSheetRoute<T>(
    settings: this,
    topGap: 0,
    scrollableBuilder: (context, controller) {
      // 시트는 위에 틈이 있다고 보고 상태 표시줄 여백을 지우는데, 화면을 다 덮으니
      // 기기 값으로 되살린다 (안 그러면 닫기 버튼이 상태 표시줄 밑에 깔린다).
      final view = View.of(context);

      final top = view.padding.top / view.devicePixelRatio;

      final media = MediaQuery.of(context);

      return MediaQuery(
        data: media.copyWith(
          padding: media.padding.copyWith(top: top),
          viewPadding: media.viewPadding.copyWith(top: top),
        ),
        child: builder(context, controller),
      );
    },
  );
}
