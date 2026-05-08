#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

ok()   { printf "  ✅ PASS: %s\n" "$1"; PASS=$(( PASS + 1 )); }
fail() { printf "  ❌ FAIL: %s\n" "$1"; FAIL=$(( FAIL + 1 )); }

printf "=== test-get-sh ===\n"

GET_SH="$REPO_ROOT/get.sh"

# Check 1: get.sh 존재
if [ -f "$GET_SH" ]; then
  ok "get.sh 존재"
else
  fail "get.sh 없음"
fi

# Check 2: 실행 권한
if [ -x "$GET_SH" ]; then
  ok "get.sh 실행 권한 있음"
else
  fail "get.sh 실행 권한 없음"
fi

# Check 3: --help 출력에 Usage 포함
if bash "$GET_SH" --help 2>&1 | grep -qi "usage"; then
  ok "--help 출력에 Usage 포함"
else
  fail "--help 출력에 Usage 없음"
fi

# Check 4: shebang + set -euo pipefail 포함
if head -5 "$GET_SH" | grep -q "set -euo pipefail"; then
  ok "set -euo pipefail 포함"
else
  fail "set -euo pipefail 없음"
fi

# Check 5: bash 3.2+ 금지 패턴 없음 (declare -A, readarray, mapfile)
if grep -qE '(declare -A|readarray|mapfile)' "$GET_SH"; then
  fail "bash 4+ 전용 구문 감지"
else
  ok "bash 3.2+ 호환 구문"
fi

# Check 6: trap EXIT 포함 (임시 디렉토리 정리)
if grep -q "trap" "$GET_SH"; then
  ok "trap EXIT 존재 (임시 디렉토리 정리)"
else
  fail "trap EXIT 없음"
fi

# Check 7: --version 플래그 파싱 (dry-run: VERSION 변수 설정 확인)
if grep -q "\-\-version" "$GET_SH"; then
  ok "--version 플래그 처리 코드 존재"
else
  fail "--version 플래그 처리 없음"
fi

# Check 8: --update 플래그 처리
if grep -q "\-\-update" "$GET_SH"; then
  ok "--update 플래그 처리 코드 존재"
else
  fail "--update 플래그 처리 없음"
fi

# Check 9: --yes 플래그 전달 처리
if grep -q "\-\-yes" "$GET_SH"; then
  ok "--yes 플래그 전달 처리 존재"
else
  fail "--yes 플래그 전달 없음"
fi

# Check 10: GitHub URL 패턴 포함
if grep -q "github.com/Changsik00/harness-kit" "$GET_SH"; then
  ok "GitHub URL 패턴 존재"
else
  fail "GitHub URL 패턴 없음"
fi

printf "\n=== 결과: PASS=%d FAIL=%d ===\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
