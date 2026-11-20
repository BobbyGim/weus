import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:weus/src/domain/domain.dart";

import "../supabase/supabase.dart";

part "profile_repository_impl.g.dart";

/// Supabase profiles 테이블. RLS로 본인 행만 읽힌다.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  // 로그인 안 했으면 라우터가 로그인 화면으로 보내서, 여기서는 항상 currentUser가 있다.
  @override
  Future<Profile> fetchMine() async {
    final row = await _supabase
        .from("profiles")
        .select("name, email, nickname")
        .eq("id", _supabase.auth.currentUser!.id)
        .single();

    return (
      name: row["name"] as String,
      email: row["email"] as String,
      nickname: row["nickname"] as String,
    );
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepositoryImpl(ref.watch(supabaseProvider));
