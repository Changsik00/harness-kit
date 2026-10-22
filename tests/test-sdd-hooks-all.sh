#!/usr/bin/env bash
# tests/test-sdd-hooks-all.sh
#
# phase-30 phase-FF sdd-hooks-all (F4): `sdd hooks` 가 모드를 가진 hook 전부를,
# 하드코딩 목록이 아니라 hook 파일의 `hook_resolve_mode` 선언에서 읽어 표시한다.
#   1. fixture: 새 hook(check-foo.sh)을 추가하면 목록에 나타난다 (하드코딩이면 누락)
#   2. 환경변수 override 가 '현재' 열에 반영된다
#   3. 모드가 변수인 hook(check-irreversible류)은 '모드별'로 표시된다
#   4. 본 저장소: hook_resolve_mode 를 가진 모든 hook 이 표시된다
#
# bash 3.2+ compatible.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$((FAIL + 1)); echo "     output: $2"; }

F="$TMP_ROOT/f"
mkdir -p "$F/.harness-kit/hooks" "$F/backlog" "$F/specs"
echo '{"kitVersion":"0.0.0"}' > "$F/.harness-kit/installed.json"
echo '# Backlog Queue' > "$F/backlog/queue.md"
printf '#!/usr/bin/env bash\nhook_resolve_mode "FOO" "block"\n' > "$F/.harness-kit/hooks/check-foo.sh"
printf '#!/usr/bin/env bash\nhook_resolve_mode "BAR" "warn"\n'  > "$F/.harness-kit/hooks/check-bar.sh"
printf '#!/usr/bin/env bash\n_d=warn\nhook_resolve_mode "DYN" "$_d"\n' > "$F/.harness-kit/hooks/check-dyn.sh"
printf '#!/usr/bin/env bash\necho no mode here\n' > "$F/.harness-kit/hooks/check-nomode.sh"
(cd "$F" && git init -q)

echo "Test: sdd hooks lists all hooks"

out=$(cd "$F" && bash "$SDD" hooks 2>&1)
echo "$out" | grep -q "check-foo.sh" && echo "$out" | grep -q "check-bar.sh" \
  && ok "case 1: fixture hooks listed" || fail "case 1: fixture hooks missing" "$out"
echo "$out" | grep -q "check-nomode.sh" \
  && fail "case 1b: hook without mode must not be listed" "$out" || ok "case 1b: modeless hook not listed"

out=$(cd "$F" && HARNESS_HOOK_MODE_BAR=block bash "$SDD" hooks 2>&1)
echo "$out" | grep "check-bar.sh" | grep -q "block" \
  && ok "case 2: env override reflected" || fail "case 2: env override not reflected" "$out"

out=$(cd "$F" && bash "$SDD" hooks 2>&1)
echo "$out" | grep "check-dyn.sh" | grep -q "모드별" \
  && ok "case 3: variable default shown as 모드별" || fail "case 3: variable default" "$out"

out=$(cd "$ROOT" && bash "$SDD" hooks 2>&1)
missing=""
for f in "$ROOT"/sources/hooks/check-*.sh; do
  grep -q 'hook_resolve_mode' "$f" || continue
  b=$(basename "$f")
  echo "$out" | grep -q "$b" || missing="$missing $b"
done
[ -z "$missing" ] && ok "case 4: every repo hook with a mode is listed" || fail "case 4: missing:$missing" "$out"

echo ""
echo "결과: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
