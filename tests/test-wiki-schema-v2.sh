#!/usr/bin/env bash
set -euo pipefail

# test-wiki-schema-v2.sh
# spec-30-01: wiki 3층 구조 · 제자리 갱신 규약의 정적 계약 검증
#   (인제스트는 LLM 절차라 행동은 검증하지 못한다 — 문구·섹션·마커·크기만 고정)
#   1. 컴포넌트 페이지 템플릿

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FAIL=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "═══════════════════════════════════════════"
echo " wiki schema v2 (spec-30-01)"
echo "═══════════════════════════════════════════"

# ─────────────────────────────────────────────
echo ""
echo "▶ Case 1: 컴포넌트 페이지 템플릿"
TPL="$ROOT/sources/templates/wiki-component.md"
TPL_COPY="$ROOT/.harness-kit/agent/templates/wiki-component.md"

if [ -f "$TPL" ]; then
  pass "sources/templates/wiki-component.md 존재"
  for field in kind sources covers linked updated; do
    if awk 'NR==1&&/^---/{f=1;next} f&&/^---/{exit} f' "$TPL" | grep -q "^${field}:"; then
      pass "frontmatter $field:"
    else
      fail "frontmatter $field: 없음"
    fi
  done
  for sec in "책임" "현재 설계" "변경 이력" "반복·미결" "기술 부채" "관련 결정"; do
    if grep -q "^## ${sec}" "$TPL"; then
      pass "섹션 ## $sec"
    else
      fail "섹션 ## $sec 없음"
    fi
  done
else
  fail "sources/templates/wiki-component.md 없음"
fi

if [ -f "$TPL_COPY" ] && cmp -s "$TPL" "$TPL_COPY"; then
  pass "사본 .harness-kit/agent/templates/ 와 동일"
else
  fail "사본 없음 또는 원본과 다름"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "✓ wiki schema v2 PASS"
  exit 0
fi
echo "✗ wiki schema v2 FAIL: $FAIL"
exit 1
