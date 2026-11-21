import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/data/data.dart";

part "group_create_view_model.g.dart";

/// 모임 만들기 요청 상태. 만들면 만든 그룹 id, 그 전에는 null.
@riverpod
class GroupCreateViewModel extends _$GroupCreateViewModel {
  @override
  AsyncValue<int?> build() => const AsyncData(null);

  Future<void> create({
    required String name,
    required String description,
    required List<String> categories,
    required bool isPublic,
    required String clientId,
  }) async {
    // 버튼이 다시 그려지기 전에 한 번 더 눌려도 요청은 한 번만.
    if (state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final id = await ref
          .read(groupRepositoryProvider)
          .create(
            name: name,
            description: description,
            categories: categories,
            isPublic: isPublic,
            clientId: clientId,
          );

      // 모임 탭 목록에 새 그룹이 보이게.
      ref.invalidate(myGroupsProvider);

      return id;
    });

    // 성공하면 이 화면이 닫히면서 먼저 dispose될 수 있다.
    if (ref.mounted) state = result;
  }
}
