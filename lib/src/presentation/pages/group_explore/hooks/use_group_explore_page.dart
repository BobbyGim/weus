import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/hooks/hooks.dart";

import "../view_models/view_models.dart";

/// 모임 찾기. [input]은 주소의 검색어([query])로 시작하는 검색창 (치는 동안은 검색하지
/// 않고, [search](키보드의 검색 키)를 눌러야 주소가 바뀌며 검색된다). [category]는 고른
/// 카테고리 id, 전체면 null. [busy]는 카드를 눌러 미리보기를 불러오는 동안 true.
/// [results]는 검색어·카테고리에 맞는 결과, [onScroll]은 끝에 가까워지면 다음 20개.
({
  TextEditingController input,
  String? category,
  ValueChanged<String?> selectCategory,
  bool busy,
  List<GroupCategory> categories,
  AsyncValue<
    ({
      List<GroupSearchResult> groups,
      bool hasMore,
      bool loadingMore,
      bool failed,
    })
  >
  results,
  VoidCallback search,
  void Function(GroupSearchResult group) open,
  bool Function(ScrollNotification notification) onScroll,
  VoidCallback loadMore,
  VoidCallback refresh,
})
useGroupExplorePage(WidgetRef ref, String query) {
  final context = useContext();

  final input = useTextEditingController(text: query);

  final category = useState<String?>(null);

  final (:busy, :run) = useRequestRunner();

  final provider = groupExploreViewModelProvider(query, category.value);

  final categories = ref.watch(groupCategoriesProvider).value ?? const [];

  final results = ref.watch(provider);

  final viewModel = ref.read(provider.notifier);

  // 검색: 검색어를 주소에 넣어 바꾼다. replace라 검색을 여러 번 해도 뒤로가기는 그 탭으로.
  void search() {
    final q = input.text.trim();

    FocusScope.of(context).unfocus();

    context.replace(
      Uri(
        path: "/group/explore",
        queryParameters: q.isEmpty ? null : {"q": q},
      ).toString(),
    );
  }

  // 멤버면 상세, 아니면 미리보기를 먼저 불러온 뒤(이 화면에 로딩) 위에 올려서,
  // 미리보기가 로딩 없이 바로 그려진다. 못 불러오면 열지 않고 스낵바만.
  Future<void> open(GroupSearchResult group) async {
    if (group.isMember) return context.go("/group/${group.id}");

    if (await run(() => viewModel.loadPreview(group.id)) && context.mounted) {
      // 이 화면 위에 쌓아서(push), 닫으면 검색 결과 그대로 모임 찾기로 돌아온다.
      // go면 홈에서 연 모임 찾기 아래가 모임 탭으로 바뀌어 버린다.
      context.push("/group/explore/${group.id}");
    }
  }

  bool onScroll(ScrollNotification n) {
    final failed = results.value?.failed ?? false;

    if (n.metrics.extentAfter < 600 && !failed) viewModel.loadMore();

    return false;
  }

  return (
    input: input,
    category: category.value,
    selectCategory: (id) => category.value = id,
    busy: busy,
    categories: categories,
    results: results,
    search: search,
    open: open,
    onScroll: onScroll,
    loadMore: viewModel.loadMore,
    refresh: viewModel.refresh,
  );
}
