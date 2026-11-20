import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";

part "sign_up_view_model.g.dart";

/// 가입 요청 상태. 가입하면 바로 로그인되고 라우터가 홈으로 보낸다.
@riverpod
class SignUpViewModel extends _$SignUpViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // 버튼이 다시 그려지기 전에 한 번 더 눌려도 요청은 한 번만.
    if (state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signUp(name: name, email: email, password: password),
    );

    // 성공하면 이 화면이 닫히면서 먼저 dispose될 수 있다.
    if (ref.mounted) state = result;
  }
}
