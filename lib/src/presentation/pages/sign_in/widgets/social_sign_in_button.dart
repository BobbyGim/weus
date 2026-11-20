import "package:flutter_svg/flutter_svg.dart";
import "package:material_ui/material_ui.dart";

/// 카카오·애플 로그인 버튼. 색과 로고는 각 회사 로그인 버튼 가이드를 따른다
/// (카카오: #FEE500 바탕에 검은 말풍선, 애플: 검은 바탕에 흰 로고).
class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton.kakao({super.key, required this.onPressed})
    : label = "카카오 로그인",
      logo = "assets/image/kakao_symbol.svg",
      background = const Color(0xFFFEE500),
      foreground = const Color(0xD9000000);

  const SocialSignInButton.apple({super.key, required this.onPressed})
    : label = "애플 로그인",
      logo = "assets/image/apple_logo.svg",
      background = Colors.black,
      foreground = Colors.white;

  final String label;

  final String logo;

  final Color background;

  final Color foreground;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // 로고는 왼쪽 같은 자리, 글자는 가운데: 라벨 길이가 달라도 두 버튼이 맞는다.
    const logoBox = 20.0;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            logo,
            width: logoBox,
            height: logoBox,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),

          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          // 로고 폭만큼 오른쪽도 비워서 글자가 버튼의 정가운데에 온다.
          const SizedBox(width: logoBox),
        ],
      ),
    );
  }
}
