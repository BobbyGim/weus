import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "widgets/widgets.dart";

/// 모임 수정 (모임장만, 그룹 설정의 수정 버튼에서). 이름·카테고리·소개를 바꾼다.
/// 일정 등록처럼 아래에서 올라오는 화면 70% 높이의 바텀시트 (닫기는 아래로 끌거나 바깥을
/// 누른다). 지금 값을 불러온 뒤 폼을 채운다.
/// 키보드가 올라오면 저장 버튼이 키보드 바로 위에 온다.
class GroupEditPage extends HookConsumerWidget {
  const GroupEditPage({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupEditPage(ref, groupId);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Padding(
        // 저장 버튼이 키보드에 가리지 않게.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            Expanded(
              child: switch (page.data) {
                AsyncData(:final value) => GroupEditForm(detail: value),

                AsyncError(:final error) => Center(
                  child: AppRetry(
                    message: error is GroupFailure
                        ? error.message
                        : "그룹을 불러오지 못했어요",
                    onRetry: page.retry,
                  ),
                ),

                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}
