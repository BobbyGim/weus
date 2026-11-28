#!/bin/bash
# Stop: 이번 세션에서 고친 .dart 파일만 dart analyze한다. 에러·경고가 있으면 턴을 끝내지 못하게 돌려보낸다.
input=$(cat)
sid=$(jq -r '.session_id // "default"' <<<"$input")
active=$(jq -r '.stop_hook_active // false' <<<"$input")

list="$CLAUDE_PROJECT_DIR/.dart_tool/claude-edited-$sid.txt"
[ -s "$list" ] || exit 0

# 지워진 파일은 빼고 중복 제거
files=()
while IFS= read -r f; do
  [ -f "$f" ] && files+=("$f")
done < <(sort -u "$list")

if [ ${#files[@]} -eq 0 ]; then
  rm -f "$list"
  exit 0
fi

dart=$(command -v dart || echo "$HOME/fvm/default/bin/dart")

cd "$CLAUDE_PROJECT_DIR" || exit 0

out=$("$dart" analyze "${files[@]}" 2>&1)
code=$?

if [ $code -eq 0 ]; then
  rm -f "$list"
  exit 0
fi

# 한 번 돌려보낸 뒤에도 남아 있으면 무한 반복을 막으려고 사용자에게 넘긴다.
if [ "$active" = "true" ]; then
  rm -f "$list"
  echo "{\"systemMessage\": \"dart analyze에 아직 문제가 남아 있습니다. flutter analyze로 확인하세요.\"}"
  exit 0
fi

echo "이번에 고친 파일에서 dart analyze 문제가 나왔습니다. 고친 뒤 끝내세요:" >&2
echo "$out" | grep -E '^\s*(error|warning)' >&2 || echo "$out" >&2
exit 2
