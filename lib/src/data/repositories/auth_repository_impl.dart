import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:weus/src/domain/domain.dart";

import "../supabase/supabase.dart";

part "auth_repository_impl.g.dart";

/// Supabase Auth. 가입할 때 넘긴 name으로 DB 트리거가 profiles 행을 만든다.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._auth);

  final GoTrueClient _auth;

  @override
  bool get signedIn => _auth.currentSession != null;

  @override
  Stream<bool> watchSignedIn() =>
      _auth.onAuthStateChange.map((state) => state.session != null);

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guard(
    () => _auth.signUp(email: email, password: password, data: {"name": name}),
  );

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> signOut() => _auth.signOut();
}

/// Supabase 에러를 사용자에게 보여줄 [AuthFailure]로 바꾼다.
Future<void> _guard(Future<void> Function() call) async {
  try {
    await call();
  } on AuthException catch (e) {
    throw AuthFailure(switch (e.code) {
      "invalid_credentials" => "이메일 또는 비밀번호가 맞지 않아요",
      "user_already_exists" || "email_exists" => "이미 가입된 이메일이에요",
      "email_address_invalid" || "validation_failed" => "이메일 형식이 맞지 않아요",
      "weak_password" => "비밀번호는 6자 이상이어야 해요",
      _ => "잠시 후 다시 시도해 주세요",
    });
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(supabaseProvider).auth);
