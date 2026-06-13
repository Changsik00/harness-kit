#!/usr/bin/env bash
# tests/run.sh
# 전체 테스트 실행 — 모든 test-*.sh 를 순서대로 실행하고 결과 요약 출력
#
# 사용: bash tests/run.sh [--fast]
#   --fast: 느린 통합 테스트 제외 (test-turbo-mode.sh, test-phase*-integration.sh)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PASS=0; FAIL=0; SKIP=0
FAILED_TESTS=()

FAST=false
for arg in "$@"; do
  [ "$arg" = "--fast" ] && FAST=true
done

SLOW_PATTERNS="test-turbo-mode test-phase16-integration test-phase17-integration"

echo "=== tests/run.sh — harness-kit 전체 테스트 ==="
[ "$FAST" = "true" ] && echo "  (--fast: 통합 테스트 제외)"
echo ""

for f in "$SCRIPT_DIR"/test-*.sh; do
  name="$(basename "$f" .sh)"

  # --fast 모드에서 느린 테스트 건너뜀
  if [ "$FAST" = "true" ]; then
    skip=false
    for pat in $SLOW_PATTERNS; do
      case "$name" in
        *"$pat"*) skip=true ;;
      esac
    done
    if [ "$skip" = "true" ]; then
      echo "  ⏭ SKIP: $name (--fast)"
      SKIP=$(( SKIP + 1 ))
      continue
    fi
  fi

  printf "  ▶ %s ... " "$name"
  if out=$(bash "$f" 2>&1); then
    echo "✅ PASS"
    PASS=$(( PASS + 1 ))
  else
    echo "❌ FAIL"
    FAIL=$(( FAIL + 1 ))
    FAILED_TESTS+=("$name")
    echo "$out" | sed 's/^/      /'
  fi
done

echo ""
echo "=== 결과 ==="
echo "  PASS: $PASS  FAIL: $FAIL  SKIP: $SKIP"

if [ "${#FAILED_TESTS[@]}" -gt 0 ]; then
  echo ""
  echo "  실패한 테스트:"
  for t in "${FAILED_TESTS[@]}"; do
    echo "    - $t"
  done
fi

echo ""
[ "$FAIL" -eq 0 ]
