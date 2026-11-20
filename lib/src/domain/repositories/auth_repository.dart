abstract interface class AuthRepository {
  /// 지금 로그인돼 있는지.
  bool get signedIn;

  /// 로그인·로그아웃할 때마다 로그인 여부를 내보낸다.
  Stream<bool> watchSignedIn();

  /// 가입하면 바로 로그인된다 (이메일 인증 없음). 실패하면 [AuthFailure].
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// 실패하면 [AuthFailure].
  Future<void> signIn({required String email, required String password});

  Future<void> signOut();
}

/// 로그인·가입 실패. [message]는 사용자에게 그대로 보여줄 문구다.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
