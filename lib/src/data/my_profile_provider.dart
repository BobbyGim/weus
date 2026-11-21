import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "repositories/repositories.dart";

part "my_profile_provider.g.dart";

/// 로그인 여부. 토큰 갱신처럼 로그인 상태가 그대로인 이벤트는 거른다.
@Riverpod(keepAlive: true)
Stream<bool> signedIn(Ref ref) =>
    ref.watch(authRepositoryProvider).watchSignedIn().distinct();

/// 로그인한 사람의 프로필, 로그아웃 상태면 null. 마이페이지·내 정보가 같이 쓴다.
/// MyApp이 앱을 켤 때 읽어서 미리 불러오고, 로그인·로그아웃하면 다시 불러온다.
@Riverpod(keepAlive: true)
Future<Profile?> myProfile(Ref ref) async {
  if (!await ref.watch(signedInProvider.future)) return null;

  return ref.watch(profileRepositoryProvider).fetchMine();
}
