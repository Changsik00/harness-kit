#!/usr/bin/env bash
set -euo pipefail

# test-wiki-structure.sh
# spec-19-01: docs/wiki/ 지식 증류 레이어 구조 검증.
# wiki 파일 존재 여부, frontmatter 유효성, ADR/RCA backfill 필드 확인.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WIKI_DIR="$ROOT/docs/wiki"
ADR_DIR="$ROOT/docs/decisions"
RCA_DIR="$ROOT/docs/rca"

FAIL=0
TOTAL=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " wiki structure (spec-19-01)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
# 검증 1: docs/wiki/ 디렉토리 존재
# ─────────────────────────────────────────────
echo "▶ Check 1: docs/wiki/ 디렉토리 존재"
check
if [ -d "$WIKI_DIR" ]; then
  pass "docs/wiki/ 존재"
else
  fail "docs/wiki/ 없음"
fi

# ─────────────────────────────────────────────
# 검증 2: 필수 wiki 파일 5개 존재
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 2: 필수 wiki 파일 존재"
for f in purpose.md index.md log.md decisions.md patterns.md; do
  check
  if [ -f "$WIKI_DIR/$f" ]; then
    pass "$f 존재"
  else
    fail "$f 없음"
  fi
done

# ─────────────────────────────────────────────
# 검증 3: 각 wiki 파일에 frontmatter 필드 존재
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 3: wiki 파일 frontmatter 유효성 (kind / sources / updated)"
for f in purpose.md index.md log.md decisions.md patterns.md; do
  filepath="$WIKI_DIR/$f"
  [ -f "$filepath" ] || continue

  check
  if grep -q "^kind:" "$filepath"; then
    pass "$f — kind: 필드 존재"
  else
    fail "$f — kind: 필드 없음"
  fi

  check
  if grep -q "^sources:" "$filepath"; then
    pass "$f — sources: 필드 존재"
  else
    fail "$f — sources: 필드 없음"
  fi

  check
  if grep -q "^updated:" "$filepath"; then
    pass "$f — updated: 필드 존재"
  else
    fail "$f — updated: 필드 없음"
  fi
done

# ─────────────────────────────────────────────
# 검증 4: kind 값이 catalog 또는 synthesis
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 4: wiki 파일 kind 값 유효 (catalog | synthesis)"
for f in purpose.md index.md log.md decisions.md patterns.md; do
  filepath="$WIKI_DIR/$f"
  [ -f "$filepath" ] || continue
  check
  # frontmatter(첫 --- ~ 두 번째 ---) 영역에서만 kind 값 추출
  kind_val="$(awk 'NR==1 && /^---/{in_fm=1; next} in_fm && /^---/{exit} in_fm && /^kind:/{print; exit}' "$filepath" | sed 's/kind: *//' | tr -d '[:space:]')"
  if [ "$kind_val" = "catalog" ] || [ "$kind_val" = "synthesis" ]; then
    pass "$f — kind: $kind_val (유효)"
  else
    fail "$f — kind 값 무효: '$kind_val' (catalog|synthesis 만 허용)"
  fi
done

# ─────────────────────────────────────────────
# 검증 5: 기존 ADR/RCA frontmatter backfill
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 5: ADR/RCA frontmatter sources 필드 backfill"
for f in \
  "$ADR_DIR/ADR-001-knowledge-types.md" \
  "$ADR_DIR/ADR-002-planning-economy.md" \
  "$RCA_DIR/RCA-001-sdd-ship-spec-add-missing.md"
do
  name="$(basename "$f")"
  check
  if [ ! -f "$f" ]; then
    fail "$name — 파일 없음"
    continue
  fi
  if grep -q "^sources:" "$f"; then
    pass "$name — sources: 필드 존재"
  else
    fail "$name — sources: 필드 없음"
  fi

  check
  if grep -q "^updated:" "$f"; then
    pass "$name — updated: 필드 존재"
  else
    fail "$name — updated: 필드 없음"
  fi
done

# ─────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────"
echo " 결과: $((TOTAL - FAIL))/$TOTAL PASS"
echo "───────────────────────────────────────────"
if [ "$FAIL" -gt 0 ]; then
  echo " ✗ FAIL ($FAIL 개 실패)"
  exit 1
else
  echo " ✓ ALL PASS"
fi
