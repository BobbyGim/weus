import "package:material_ui/material_ui.dart";

/// [loading]이면 [child]를 살짝 어둡게 덮고 가운데에 로딩 표시를 띄운다.
/// 덮인 동안은 뒤 화면(뒤로가기 버튼 포함)을 누를 수 없다.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.loading,
    required this.label,
    required this.child,
  });

  final bool loading;

  /// 스크린리더가 읽는 문구 (예: "로그인 중").
  final String label;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (loading) ...[
          const ModalBarrier(dismissible: false, color: Colors.black26),

          Center(child: CircularProgressIndicator(semanticsLabel: label)),
        ],
      ],
    );
  }
}
