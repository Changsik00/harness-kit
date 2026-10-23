#!/usr/bin/env bash
set -euo pipefail

# test-wiki-schema-v2.sh
# spec-30-01: wiki 3층 구조 · 제자리 갱신 규약의 정적 계약 검증
#   (인제스트는 LLM 절차라 행동은 검증하지 못한다 — 문구·섹션·마커·크기만 고정)
#   1. 컴포넌트 페이지 템플릿
#   2. schema.md 규약 문구
#   4. 시범 페이지 섹션·크기 상한
#   3. /hk-wiki-ingest 계약
#   5. verify 마커
#   7. CLAUDE fragment 조회 순서

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

# ─────────────────────────────────────────────
echo ""
echo "▶ Case 2: schema.md 규약 문구"
SCHEMA="$ROOT/docs/wiki/schema.md"
for phrase in "direction.md" "components/" "threads.md" "변경 이력" "충돌" "사용자 확인" "<!-- verify:" "200줄" "150줄" "300줄" "covers"; do
  if grep -qF -- "$phrase" "$SCHEMA"; then
    pass "schema.md — '$phrase'"
  else
    fail "schema.md — '$phrase' 없음"
  fi
done
if grep -qE "삭제하거나 교체하지 않는다|삭제·교체하지 않는다" "$SCHEMA"; then
  fail "schema.md — append-only 문구가 남아 있음"
else
  pass "schema.md — append-only 문구 없음"
fi

# ─────────────────────────────────────────────
echo ""
echo "▶ Case 4: 시범 페이지 섹션·크기 상한"
DIR="$ROOT/docs/wiki/direction.md"
for sec in "한 줄 의도" "원칙 대비 현황" "연혁" "반복되는 방향 이슈" "열린 질문"; do
  if grep -q "^## ${sec}" "$DIR"; then pass "direction.md ## $sec"; else fail "direction.md ## $sec 없음"; fi
done
lines="$(wc -l < "$DIR" | tr -d ' ')"
if [ "$lines" -le 150 ]; then pass "direction.md ${lines}줄 (<=150)"; else fail "direction.md ${lines}줄 (>150)"; fi

for page in "$ROOT"/docs/wiki/components/*.md; do
  name="components/$(basename "$page")"
  for sec in "책임" "현재 설계" "변경 이력" "반복·미결" "기술 부채" "관련 결정"; do
    if grep -q "^## ${sec}" "$page"; then pass "$name ## $sec"; else fail "$name ## $sec 없음"; fi
  done
  lines="$(wc -l < "$page" | tr -d ' ')"
  if [ "$lines" -le 200 ]; then pass "$name ${lines}줄 (<=200)"; else fail "$name ${lines}줄 (>200)"; fi
done

# ─────────────────────────────────────────────
echo ""
echo "▶ Case 3: /hk-wiki-ingest 계약"
ING="$ROOT/sources/commands/hk-wiki-ingest.md"
ING_COPY="$ROOT/.claude/commands/hk-wiki-ingest.md"
for phrase in "covers" "Proposed Changes" "사용자 확인" "변경 이력" "제자리" "threads.md"; do
  if grep -qF -- "$phrase" "$ING"; then pass "hk-wiki-ingest — '$phrase'"; else fail "hk-wiki-ingest — '$phrase' 없음"; fi
done
for phrase in "삭제하거나 교체하지 않는다" "섹션 하단에 추가"; do
  if grep -qF -- "$phrase" "$ING"; then fail "hk-wiki-ingest — 구 규약 문구 잔존: '$phrase'"; else pass "hk-wiki-ingest — 구 규약 문구 없음: '$phrase'"; fi
done
if [ -f "$ING_COPY" ] && cmp -s "$ING" "$ING_COPY"; then pass "사본 .claude/commands/ 와 동일"; else fail "사본 없음 또는 원본과 다름"; fi

# ─────────────────────────────────────────────
echo ""
echo "▶ Case 7: CLAUDE fragment 조회 순서"
for frag in "$ROOT/sources/claude-fragments/CLAUDE.fragment.md" "$ROOT/.harness-kit/CLAUDE.fragment.md"; do
  fname="${frag#$ROOT/}"
  line="$(grep -F 'docs/wiki/' "$frag" | grep -F 'schema.md' | head -1 || true)"
  for phrase in "direction.md" "components/" "threads.md"; do
    case "$line" in *"$phrase"*) pass "$fname — '$phrase'" ;; *) fail "$fname — 질의 문구에 '$phrase' 없음" ;; esac
  done
done

# ─────────────────────────────────────────────
echo ""
echo "▶ Case 5: hooks.md verify 마커 (표 바로 위)"
HOOKS="$ROOT/docs/wiki/components/hooks.md"
marker_next="$(grep -A1 -F '<!-- verify: hooks-defaults -->' "$HOOKS" | tail -1 || true)"
case "$marker_next" in
  "|"*) pass "hooks-defaults 마커 바로 아래가 표" ;;
  *)    fail "hooks-defaults 마커 없음 또는 표가 바로 아래에 없음" ;;
esac

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "✓ wiki schema v2 PASS"
  exit 0
fi
echo "✗ wiki schema v2 FAIL: $FAIL"
exit 1
