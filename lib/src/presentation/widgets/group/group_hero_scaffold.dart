import "dart:math" as math;

import "package:flutter/gestures.dart" show Drag;
import "package:flutter/services.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "group_image.dart";

/// 아래에서 올라오는 모임 화면 (상세·미리보기). 위는 [GroupImage] 그라데이션에 큰 아이콘과
/// 제목·[subtitle], 아래는 둥근 흰 시트에 [content]. 왼쪽 위 X는 [onClose],
/// 오른쪽 위에는 [action] (예: 메뉴). [bottomBar]가 있으면 맨 아래에 고정한다
/// (보통 [GroupHeroBottomButton]).
///
/// 흰 시트는 두 높이 사이에서만 움직인다: 처음(화면 61% 지점에서 시작)과 최대(화면의
/// 80%). 처음에서 조금이라도 올리면 최대로, 최대에서 조금 내리면 처음으로 붙고, 처음보다
/// 아래로는 안 내려간다. 시트 안 내용은 스크롤되지 않는다.
/// iOS 시트(SheetPage) 안에 띄우고, 시트가 준 [scrollController]를 넘기면 이미지를
/// 아래로 끌어 화면을 닫을 수 있다.
class GroupHeroScaffold extends StatefulWidget {
  const GroupHeroScaffold({
    super.key,
    required this.name,
    required this.subtitle,
    required this.onClose,
    required this.content,
    required this.scrollController,
    this.action,
    this.bottomBar,
  });

  final String name;

  final String subtitle;

  final VoidCallback onClose;

  /// 흰 시트 안에 위에서부터 쌓는다.
  final List<Widget> content;

  final Widget? action;

  /// 화면(iOS 시트)을 끌어 닫는 데 쓰는 컨트롤러. 이미지 영역이 쓴다.
  final ScrollController scrollController;

  final Widget? bottomBar;

  @override
  State<GroupHeroScaffold> createState() => _GroupHeroScaffoldState();
}

class _GroupHeroScaffoldState extends State<GroupHeroScaffold> {
  static const _sheetOverlap = 24.0;

  // 타이틀 블록 위끝이 흰 시트 위끝보다 이만큼 위에 온다.
  static const _titleAboveSheet = 78.0;

  final _sheet = DraggableScrollableController();

  // 손가락을 댄 순간의 시트 높이 (놓을 때 올렸는지 내렸는지 비교).
  double _sizeAtDown = 0;

  @override
  void dispose() {
    _sheet.dispose();

    super.dispose();
  }

  // 놓았을 때 두 높이 사이에 있으면, 올렸으면 최대로 내렸으면 처음으로 붙인다.
  // 시트 자체의 관성 스크롤이 먼저 시작되므로 그 뒤(microtask)에 덮어쓴다.
  void _snap(double min, double max) => Future.microtask(() {
    if (!mounted || !_sheet.isAttached) return;

    final size = _sheet.size;

    if (size <= min + 0.001 || size >= max - 0.001) return;

    _sheet.animateTo(
      size > _sizeAtDown ? max : min,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final scheme = Theme.of(context).colorScheme;

    final top = MediaQuery.paddingOf(context).top;

    final screen = MediaQuery.sizeOf(context);

    // 카카오 오픈채팅처럼 화면 비율로: 흰 시트는 화면 높이의 61% 지점에서 시작한다.
    final heroBottom = screen.height * 0.61 + _sheetOverlap;

    // 이미지 원은 X 버튼 아래부터 타이틀 위까지 공간의 정가운데. 크기는 화면 높이의 30%
    // (너비의 65%, 그 공간에서 위아래 16씩 뺀 높이를 넘지 않게).
    final spaceTop = top + AppSpacing.xs + 44;

    final spaceBottom = heroBottom - _sheetOverlap - _titleAboveSheet;

    final circle = math.min(
      math.min(screen.height * 0.3, screen.width * 0.65),
      spaceBottom - spaceTop - AppSpacing.lg * 2,
    );

    final circleTop = (spaceTop + spaceBottom - circle) / 2;

    // 이미지(그라데이션·아이콘·제목)는 뒤에 고정, 흰 시트가 올라와 덮는다.
    final hero = SizedBox(
      height: heroBottom,
      child: Stack(
        children: [
          Container(
            height: heroBottom,
            decoration: const BoxDecoration(gradient: GroupImage.gradient),
          ),

          // 흰 제목이 밝은 배경에서도 읽히게 아래쪽을 어둡게.
          Positioned(
            left: 0,
            right: 0,
            top: heroBottom - 180,
            height: 180,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x4D000000)],
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: circleTop,
            child: Center(
              child: Container(
                width: circle,
                height: circle,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                // 목록 썸네일과 같은 비율 (아이콘 = 흰 원의 절반).
                child: Icon(
                  GroupImage.icon,
                  size: circle / 2,
                  color: GroupImage.iconColor,
                ),
              ),
            ),
          ),

          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: null,
            top: heroBottom - _sheetOverlap - _titleAboveSheet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: text.headlineSmall!.copyWith(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  widget.subtitle,
                  style: text.bodyMedium!.copyWith(
                    color: const Color(0xE6FFFFFF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // 흰 시트: 처음 높이 ~ 화면 80% 사이. 높이는 본문(아래 버튼을 뺀 영역) 기준 비율.
    final sheet = LayoutBuilder(
      builder: (context, box) {
        final min = ((box.maxHeight - screen.height * 0.61) / box.maxHeight)
            .clamp(0.1, 1.0);

        final max = (screen.height * 0.8 / box.maxHeight).clamp(min, 1.0);

        return Listener(
          onPointerDown: (_) {
            if (_sheet.isAttached) _sizeAtDown = _sheet.size;
          },
          onPointerUp: (_) => _snap(min, max),
          child: DraggableScrollableSheet(
            controller: _sheet,
            initialChildSize: min,
            minChildSize: min,
            maxChildSize: max,
            builder: (context, controller) => DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl + 4),
                ),
              ),
              // 시트 안은 스크롤되지 않게: 내용 높이를 최대 시트 높이로 고정해, 시트가
              // 최대까지 올라오면 더 끌어도 움직일 거리가 없다. 시트 높이 조절은 이
              // 스크롤로 하므로 스크롤 뷰 자체는 남겨 둔다.
              // shortcut: 최대 높이(화면 80%)를 넘는 내용은 잘린다, 멤버가 많아지면
              // 멤버 목록을 따로 여는 화면이나 시트 안 스크롤로.
              child: SingleChildScrollView(
                controller: controller,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  height: max * box.maxHeight,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.md,
                          AppSpacing.xl,
                          AppSpacing.xxxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.gray300,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            ...widget.content,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 상태 표시줄 글자를 흰색으로 (색 배경 위).
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        body: Stack(
          children: [
            // 이미지는 고정. 화면(iOS 시트) 끌기 컨트롤러를 여기에 붙여 두고, 사용자의
            // 끌기는 아래 _HeroDragArea가 아래 방향만 넘긴다 (스크롤로는 안 움직임).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const NeverScrollableScrollPhysics(),
                child: hero,
              ),
            ),

            Positioned.fill(
              child: _HeroDragArea(controller: widget.scrollController),
            ),

            sheet,

            Positioned(
              top: top + AppSpacing.xs,
              left: AppSpacing.lg,
              child: GroupHeroButton(
                icon: LucideIcons.x,
                tooltip: "닫기",
                onPressed: widget.onClose,
              ),
            ),

            if (widget.action != null)
              Positioned(
                top: top + AppSpacing.xs,
                right: AppSpacing.lg,
                child: widget.action!,
              ),
          ],
        ),
        bottomNavigationBar: widget.bottomBar,
      ),
    );
  }
}

/// 모임 화면 맨 아래를 가로 끝까지, 홈 인디케이터 영역까지 채우는 버튼 (예: 가입 신청).
/// [onPressed]가 null이면 회색으로 꺼진다. [secondary]면 회색 배경의 보조 버튼 (예: 신청 취소).
class GroupHeroBottomButton extends StatelessWidget {
  const GroupHeroBottomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
  });

  final String label;

  final VoidCallback? onPressed;

  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final enabled = onPressed != null;

    return Material(
      color: enabled && !secondary ? scheme.primary : AppColors.gray200,
      child: InkWell(
        onTap: onPressed,
        child: SafeArea(
          top: false,
          // 홈 인디케이터 여백(SafeArea) 위로 52: 카카오 참여하기 버튼과 같은 비율.
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: !enabled
                      ? AppColors.gray400
                      : secondary
                      ? AppColors.ink
                      : scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 모임 화면 위쪽의 흰 원형 버튼 (닫기, 메뉴).
class GroupHeroButton extends StatelessWidget {
  const GroupHeroButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;

  final String tooltip;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        fixedSize: const Size(44, 44),
      ),
      icon: Icon(icon, size: 22),
    );
  }
}

/// 이미지 위 끌기를 시트로 넘긴다. 아래 방향만 넘겨서(끌다가 다시 올려도 처음 자리
/// 위로는 안 넘김) 위로 끌면 아무 일 없고, 아래로 끌면 시트 스크롤을 끈 것과 같아
/// iOS 시트가 손가락을 따라 내려오고 놓으면 닫히거나 돌아간다.
class _HeroDragArea extends StatefulWidget {
  const _HeroDragArea({required this.controller});

  final ScrollController controller;

  @override
  State<_HeroDragArea> createState() => _HeroDragAreaState();
}

class _HeroDragAreaState extends State<_HeroDragArea> {
  Drag? _drag;

  // 이번 끌기에서 아래로 넘긴 거리 (0 아래로는 안 내려간다).
  double _pulled = 0;

  void _start(DragStartDetails details) {
    if (!widget.controller.hasClients) return;

    _pulled = 0;

    _drag = widget.controller.position.drag(details, () => _drag = null);
  }

  void _update(DragUpdateDetails details) {
    final next = (_pulled + details.delta.dy).clamp(0.0, double.infinity);

    final applied = next - _pulled;

    _pulled = next;

    if (applied == 0) return;

    _drag?.update(
      DragUpdateDetails(
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
        delta: Offset(0, applied),
        primaryDelta: applied,
        sourceTimeStamp: details.sourceTimeStamp,
      ),
    );
  }

  void _end(DragEndDetails details) {
    // 아래로 끌지 않았으면 위로 튕기는 속도도 넘기지 않는다.
    _drag?.end(_pulled == 0 ? DragEndDetails() : details);
  }

  @override
  void dispose() {
    _drag?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _start,
      onVerticalDragUpdate: _update,
      onVerticalDragEnd: _end,
      onVerticalDragCancel: () => _drag?.cancel(),
    );
  }
}
