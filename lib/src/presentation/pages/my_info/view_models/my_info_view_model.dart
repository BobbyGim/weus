import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "my_info_view_model.g.dart";

/// 내 정보에 보여줄 프로필 (앱을 켤 때 미리 불러온 것). 로그아웃하면 라우터가 로그인 화면으로 보낸다.
@riverpod
class MyInfoViewModel extends _$MyInfoViewModel {
  @override
  Future<Profile?> build() => ref.watch(myProfileProvider.future);

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}
