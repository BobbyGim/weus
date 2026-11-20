import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

part "my_view_model.g.dart";

/// 프로필 카드에 보여줄 로그인한 사람의 이름과 이메일.
@riverpod
class MyViewModel extends _$MyViewModel {
  @override
  Future<Profile> build() => ref.watch(profileRepositoryProvider).fetchMine();
}
