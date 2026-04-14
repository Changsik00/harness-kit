#!/usr/bin/env bash
set -euo pipefail

# test-governance-dedup.sh
# constitution.md 와 agent.md 사이 중복 문장을 검출한다.
# 5 단어 이상의 동일 문장이 양쪽에 존재하면 FAIL.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONSTITUTION="$ROOT/sources/governance/constitution.md"
AGENT="$ROOT/sources/governance/agent.md"

FAIL=0
TOTAL_CHECKS=0

# --- Helper ---
pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); }

echo "═══════════════════════════════════════════"
echo " Governance Dedup Verification"
echo "═══════════════════════════════════════════"
echo ""

# --- Check 1: 동일 문장 검출 ---
echo "▶ Check 1: 중복 문장 검출 (5단어 이상 동일 라인)"
check

# constitution에서 5단어 이상인 비공백 라인 추출 (마크다운 헤더/표 구분자 제외)
DUPES=$(grep -vE '^\s*$|^\s*#|^\s*\|.*\|.*\||^\s*[-*>]?\s*$|^```|^---' "$CONSTITUTION" | \
  while IFS= read -r line; do
    # 5단어 미만은 건너뛰기
    wc=$(echo "$line" | wc -w | tr -d ' ')
    if [ "$wc" -ge 5 ]; then
      # agent.md에서 동일 라인 존재 여부 확인 (참조 라인 제외)
      if grep -qF "$line" "$AGENT" 2>/dev/null; then
        # "→ constitution" 참조가 포함된 라인이면 무시
        matched=$(grep -F "$line" "$AGENT" 2>/dev/null || true)
        if ! echo "$matched" | grep -q "→ constitution"; then
          echo "  DUPE: $line"
        fi
      fi
    fi
  done)

if [ -z "$DUPES" ]; then
  pass "중복 문장 0건"
else
  fail "중복 문장 발견:"
  echo "$DUPES"
fi

# --- Check 2: sources 와 .harness-kit/agent/ 동기화 ---
echo ""
echo "▶ Check 2: sources/governance/ ↔ .harness-kit/agent/ 동기화"
check

if diff -q "$CONSTITUTION" "$ROOT/.harness-kit/agent/constitution.md" > /dev/null 2>&1; then
  pass "constitution.md 동기화 OK"
else
  fail "constitution.md 불일치"
fi

check
if diff -q "$AGENT" "$ROOT/.harness-kit/agent/agent.md" > /dev/null 2>&1; then
  pass "agent.md 동기화 OK"
else
  fail "agent.md 불일치"
fi

# --- Check 3: 토큰 카운트 (wc -w 근사) — 비대화 방지 ---
echo ""
echo "▶ Check 3: 토큰 카운트 (word count 근사)"
check

CONST_WORDS=$(wc -w < "$CONSTITUTION" | tr -d ' ')
AGENT_WORDS=$(wc -w < "$AGENT" | tr -d ' ')
TOTAL=$((CONST_WORDS + AGENT_WORDS))

echo "  constitution.md: ${CONST_WORDS} words"
echo "  agent.md:        ${AGENT_WORDS} words"
echo "  합계:            ${TOTAL} words"

# 합계 5000w 이하 유지 (비대화 방지 상한선)
LIMIT=5000
if [ "$TOTAL" -le "$LIMIT" ]; then
  pass "합계 ${TOTAL}w — 상한(${LIMIT}w) 이하"
else
  fail "합계 ${TOTAL}w — 상한(${LIMIT}w) 초과 (거버넌스 문서 비대화 경고)"
fi

# --- Check 4: agent.md에서 dead letter 제거 확인 ---
echo ""
echo "▶ Check 4: Dead letter 제거 확인"

check
if grep -q "IDE / LSP" "$AGENT" 2>/dev/null; then
  fail "agent.md에 'IDE / LSP' 항목이 여전히 존재"
else
  pass "Priority 1 (LSP) 제거됨"
fi

check
if grep -q "ast-grep\|ripgrep\|sed.*awk.*grep" "$AGENT" 2>/dev/null; then
  fail "agent.md에 CLI 도구 목록이 여전히 존재"
else
  pass "Priority 3 (CLI 도구) 제거됨"
fi

# --- Check 5: 섹션 번호 중복 확인 ---
echo ""
echo "▶ Check 5: 섹션 번호 중복 확인"
check

DUP_SECTIONS=$(grep -oE '^### [0-9]+\.[0-9]+' "$AGENT" | sort | uniq -d)
if [ -z "$DUP_SECTIONS" ]; then
  pass "섹션 번호 중복 없음"
else
  fail "중복 섹션 번호: $DUP_SECTIONS"
fi

# --- Check 6: sdd 경로 확인 ---
echo ""
echo "▶ Check 6: sdd 경로 확인"
check

if grep -q 'bin/sdd status' "$AGENT" 2>/dev/null; then
  if grep -q '\.harness-kit/bin/sdd status' "$AGENT" 2>/dev/null; then
    pass "sdd 경로 올바름 (.harness-kit/bin/sdd)"
  else
    fail "sdd 경로가 잘못됨 (.harness-kit/bin/sdd 여야 함)"
  fi
else
  pass "sdd 경로 참조 없음 (OK)"
fi

# --- 결과 ---
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL ${TOTAL_CHECKS} CHECKS PASSED"
else
  echo " ❌ ${FAIL}/${TOTAL_CHECKS} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
