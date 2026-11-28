#!/bin/bash
# PostToolUse(Edit|Write): 고친 .dart 파일을 dart format하고, 턴 종료 시 analyze할 목록에 적어 둔다.
input=$(cat)
f=$(jq -r '.tool_input.file_path // empty' <<<"$input")
sid=$(jq -r '.session_id // "default"' <<<"$input")

case "$f" in
  *.g.dart | *.freezed.dart | *.config.dart | *.gen.dart) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac

[ -f "$f" ] || exit 0

# fvm Flutter는 PATH에 없을 수 있어 기본 설치 경로로 대신한다.
dart=$(command -v dart || echo "$HOME/fvm/default/bin/dart")

"$dart" format "$f" >/dev/null 2>&1

dir="$CLAUDE_PROJECT_DIR/.dart_tool"
mkdir -p "$dir"
echo "$f" >>"$dir/claude-edited-$sid.txt"

exit 0
