#!/usr/bin/env bash
# tests/test-plan-accept-parity.sh
#
# phase-30 phase-FF plan-accept-shared-fn (F3):
# Plan Accept 전 허용 경로(whitelist)가 pre-commit.sh 와 check-plan-accept.sh 에서
# 한 곳(_plan_accept_paths.sh)에만 정의되고, 두 게이트의 판정이 항상 같음을 고정한다.
#   1. 경로 표: edit 훅(check-plan-accept)과 git pre-commit 의 허용/차단 판정이 일치하고 기대값과 같다
#   2. 단일 출처: 두 스크립트에 whitelist 리터럴이 없고 공유 파일이 존재한다
#
# throwaway fixture. bash 3.2+ compatible.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS="$ROOT/sources/hooks"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$((FAIL + 1)); }

REPO="$TMP_ROOT/repo"
mkdir -p "$REPO/.claude/state" "$REPO/.harness-kit/hooks"
git -C "$REPO" init -q
git -C "$REPO" config user.email t@t; git -C "$REPO" config user.name t
printf '{"planAccepted":false,"spec":"spec-x-active","mode":"governed"}' > "$REPO/.claude/state/current.json"
for f in _lib.sh check-plan-accept.sh check-staged-lint.sh pre-commit.sh _plan_accept_paths.sh; do
  [ -f "$HOOKS/$f" ] && cp "$HOOKS/$f" "$REPO/.harness-kit/hooks/$f"
done

# edit 훅 판정: 0=허용 / 2=차단
edit_verdict() {
  (cd "$REPO" && CLAUDE_TOOL_INPUT_file_path="$1" HARNESS_HOOK_MODE_PLAN_ACCEPT=block \
    bash .harness-kit/hooks/check-plan-accept.sh >/dev/null 2>&1; echo $?)
}
# pre-commit 판정: 0=허용 / 1=차단
commit_verdict() {
  mkdir -p "$REPO/$(dirname "$1")"; echo x > "$REPO/$1"
  git -C "$REPO" add -f "$1" 2>/dev/null
  local rc
  rc=$(cd "$REPO" && HARNESS_ROOT="$REPO" bash .harness-kit/hooks/pre-commit.sh >/dev/null 2>&1; echo $?)
  git -C "$REPO" reset -q 2>/dev/null; rm -f "$REPO/$1"
  echo "$rc"
}

echo "Test: plan-accept whitelist parity"

# <경로>|<기대: allow|deny>
while IFS='|' read -r path expect; do
  [ -z "$path" ] && continue
  e=$(edit_verdict "$path"); c=$(commit_verdict "$path")
  ev=deny; [ "$e" = "0" ] && ev=allow
  cv=deny; [ "$c" = "0" ] && cv=allow
  if [ "$ev" = "$expect" ] && [ "$cv" = "$expect" ]; then
    ok "$path → $expect (edit=$ev, commit=$cv)"
  else
    fail "$path 기대=$expect edit=$ev commit=$cv"
  fi
done <<'TABLE'
src/app.ts|deny
lib/util.sh|deny
tests/t.sh|deny
package.json|deny
docs/note.txt|allow
README.md|allow
CHANGELOG.md|allow
notes/readme.md|allow
backlog/phase-1.md|allow
specs/s/spec.md|allow
.claude/settings.json|allow
.harness-kit/bin/sdd|allow
version.json|allow
.gitignore|allow
TABLE

# 단일 출처
if [ -f "$HOOKS/_plan_accept_paths.sh" ]; then ok "공유 파일 _plan_accept_paths.sh 존재"; else fail "공유 파일 _plan_accept_paths.sh 없음"; fi
dups=$(grep -l 'version\.json' "$HOOKS/pre-commit.sh" "$HOOKS/check-plan-accept.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$dups" = "0" ]; then ok "두 스크립트에 whitelist 리터럴 없음"; else fail "whitelist 리터럴이 $dups 개 스크립트에 중복"; fi

echo ""
echo "결과: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
