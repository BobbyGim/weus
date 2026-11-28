#!/bin/bash
# PreToolUse(Edit|Write): lib/ 의 .dart 파일에 Material Icons.* / CupertinoIcons.* 가 들어가면 막는다 (Lucide만 사용).
input=$(cat)
f=$(jq -r '.tool_input.file_path // empty' <<<"$input")

case "$f" in
  */lib/*.dart) ;;
  *) exit 0 ;;
esac

# Write는 content, Edit는 new_string에 새 코드가 들어 있다.
text=$(jq -r '.tool_input.content // .tool_input.new_string // empty' <<<"$input")

# LucideIcons. 는 통과시키려고 앞 글자가 식별자 문자가 아닌 경우만 잡는다.
if grep -nE '(^|[^A-Za-z0-9_])(Icons|CupertinoIcons)\.' <<<"$text" >/dev/null; then
  echo "Material Icons.* / CupertinoIcons.* 는 쓰지 않습니다. LucideIcons.* (lucide_icons_flutter)로 바꿔 다시 쓰세요: $f" >&2
  exit 2
fi

exit 0
