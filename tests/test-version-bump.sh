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

# 주: 이전엔 여기서 전체 테스트 스위트를 재실행하는 메타-러너(Check 6)가 있었으나 제거함.
# 스위트 오케스트레이션은 tests/run.sh 의 책임이며, version-bump 은 버전 일관성만 검증한다.
# (메타-러너는 run.sh 역할 중복 + set -e 하 첫 실패 시 침묵 종료 + 재귀의 취약 구조였음)

printf "\n=== 결과: PASS=%d FAIL=%d ===\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
