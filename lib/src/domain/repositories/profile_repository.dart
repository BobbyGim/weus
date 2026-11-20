import "../entities/entities.dart";

abstract interface class ProfileRepository {
  /// 로그인한 사람의 프로필.
  Future<Profile> fetchMine();
}
