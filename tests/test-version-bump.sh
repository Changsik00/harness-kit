#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

ok()   { printf "  ✅ PASS: %s\n" "$1"; PASS=$(( PASS + 1 )); }
fail() { printf "  ❌ FAIL: %s\n" "$1"; FAIL=$(( FAIL + 1 )); }

printf "=== test-version-bump ===\n"

# Check 1: VERSION 파일에 0.6.1 포함
TARGET="0.6.1"
version_file="$REPO_ROOT/VERSION"
if grep -qF "$TARGET" "$version_file" 2>/dev/null; then
  ok "VERSION 파일에 $TARGET 포함"
else
  fail "VERSION 파일에 $TARGET 없음 (현재: $(cat "$version_file" 2>/dev/null || echo '없음'))"
fi

# Check 2: sdd version → 0.6.0 출력
sdd_out=$("$REPO_ROOT/.harness-kit/bin/sdd" version 2>/dev/null || true)
if printf '%s' "$sdd_out" | grep -qF "$TARGET"; then
  ok "sdd version → $TARGET"
else
  fail "sdd version 출력에 $TARGET 없음 (출력: $sdd_out)"
fi

# Check 3: CHANGELOG.md 존재 + 0.6.0 포함
changelog="$REPO_ROOT/CHANGELOG.md"
if [ -f "$changelog" ] && grep -qF "$TARGET" "$changelog"; then
  ok "CHANGELOG.md 존재 + $TARGET 포함"
else
  fail "CHANGELOG.md 없음 또는 $TARGET 미포함"
fi

# Check 4: README.md 버전 배지 0.6.0 반영
readme="$REPO_ROOT/README.md"
if grep -qF "$TARGET" "$readme" 2>/dev/null; then
  ok "README.md에 $TARGET 포함"
else
  fail "README.md에 $TARGET 없음"
fi

# Check 5: .harness-kit/installed.json kitVersion → 0.6.0
installed="$REPO_ROOT/.harness-kit/installed.json"
if grep -qF "\"$TARGET\"" "$installed" 2>/dev/null; then
  ok "installed.json kitVersion = $TARGET"
else
  fail "installed.json kitVersion ≠ $TARGET"
fi

# Check 6: 전체 테스트 스위트 FAIL=0
printf "\n--- 전체 테스트 스위트 실행 (자기 자신 제외) ---\n"
suite_fail=0
for t in "$REPO_ROOT/tests"/test-*.sh; do
  [[ "$t" == *"test-version-bump.sh" ]] && continue
  output=$(bash "$t" 2>&1)
  exit_code=$?
  if [ "$exit_code" -eq 0 ]; then
    : # pass
  else
    summary=$(printf '%s' "$output" | grep -E '(FAIL|PASS|ALL.*PASS|결과)' | tail -1)
    printf "  ⚠️  %s → %s\n" "$(basename "$t")" "${summary:-exit=$exit_code}"
    suite_fail=$(( suite_fail + 1 ))
  fi
done
if [ "$suite_fail" -eq 0 ]; then
  ok "전체 테스트 스위트 FAIL=0"
else
  fail "전체 테스트 스위트 ${suite_fail}개 실패"
fi

printf "\n=== 결과: PASS=%d FAIL=%d ===\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
