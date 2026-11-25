import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";

/// 그룹 홈의 글쓰기 버튼으로 여는 글쓰기. 제목(100자까지)과 본문(5000자까지, 없어도
/// 됨)을 쓰고 올리면 true를 돌려주며 닫는다 (그룹 홈이 다시 불러온다).
class GroupPostNewPage extends HookConsumerWidget {
  const GroupPostNewPage({super.key, required this.groupId});

  final int groupId;

  static const _titleMaxLength = 100;

  static const _descriptionMaxLength = 5000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useGroupPostNewPage(ref, groupId);

    // 제목 칸 아래 본문 칸이 남는 높이를 다 쓰고, 버튼은 맨 아래(키보드가 올라오면 키보드 바로 위).
    return AppLoadingOverlay(
      loading: form.sending,
      label: "올리는 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: AppBackButton(fallback: "/group/$groupId"),
          title: const Text("글쓰기"),
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: form.titleInput,
                  autofocus: true,
                  maxLength: _titleMaxLength,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: const InputDecoration(
                    hintText: "제목",
                    counterText: "",
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Expanded(
                  child: TextField(
                    controller: form.descriptionInput,
                    expands: true,
                    maxLines: null,
                    maxLength: _descriptionMaxLength,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: "그룹 멤버에게 나누고 싶은 이야기를 적어 주세요",
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                FilledButton(onPressed: form.send, child: const Text("올리기")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
