#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

ok()   { printf "  ✅ PASS: %s\n" "$1"; PASS=$(( PASS + 1 )); }
fail() { printf "  ❌ FAIL: %s\n" "$1"; FAIL=$(( FAIL + 1 )); }

printf "=== test-version-bump ===\n"

# Check 1: version.json 에 현재 버전 포함
TARGET=$(jq -r '.version' "$REPO_ROOT/version.json" 2>/dev/null || echo "unknown")
version_file="$REPO_ROOT/version.json"
if [ "$TARGET" != "unknown" ] && [ -f "$version_file" ]; then
  ok "version.json 존재 + version=$TARGET"
else
  fail "version.json 없음 또는 version 필드 누락"
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

# Check 4: README.md 가 dynamic version badge(version.json 참조)를 사용 — 리터럴 버전 하드코딩 불필요
# README 는 version.json 을 읽는 shields.io dynamic badge 로 버전을 자동 반영한다.
# 따라서 릴리스마다 README 를 수동 sync 할 필요가 없어야 하며, 검사는 badge 의 version.json 참조 존재를 확인한다.
readme="$REPO_ROOT/README.md"
if grep -q "version.json" "$readme" 2>/dev/null; then
  ok "README.md 가 version.json 기반 dynamic version badge 사용"
else
  fail "README.md 에 version.json dynamic badge 참조 없음"
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
