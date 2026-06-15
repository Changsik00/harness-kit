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
# 검증 6: sources[] 경로 실존 확인
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 6: sources[] 경로 실존 확인"
check_sources_paths() {
  local filepath="$1"
  local name
  name="$(basename "$filepath")"
  # frontmatter 영역(첫 --- ~ 두 번째 ---)에서 sources: 블록의 경로 항목 추출
  local in_fm=0 in_sources=0
  while IFS= read -r line; do
    if [ "$in_fm" -eq 0 ] && [ "$line" = "---" ]; then
      in_fm=1; continue
    fi
    [ "$in_fm" -eq 1 ] && [ "$line" = "---" ] && break
    if [ "$in_fm" -eq 1 ]; then
      if printf '%s\n' "$line" | grep -q "^sources:"; then
        in_sources=1; continue
      fi
      # sources 블록 종료: 다른 최상위 키
      if [ "$in_sources" -eq 1 ] && printf '%s\n' "$line" | grep -q "^[a-z]"; then
        in_sources=0
      fi
      if [ "$in_sources" -eq 1 ]; then
        # "  - path" 형식에서 경로 추출
        src="$(printf '%s\n' "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')"
        [ -z "$src" ] && continue
        check
        # archive-aware: spec 이 archive 되면 walkthrough 가 archive/specs/ 로 이동한다.
        # 경로는 깨진 게 아니라 이동된 것이므로 archive/ fallback 을 정당한 실존으로 인정한다.
        if [ -f "$ROOT/$src" ]; then
          pass "$name sources: $src"
        elif [ -f "$ROOT/archive/$src" ]; then
          pass "$name sources: $src (archived)"
        else
          fail "$name sources: $src — 파일 없음"
        fi
      fi
    fi
  done < "$filepath"
}

for f in \
  "$WIKI_DIR/patterns.md" \
  "$WIKI_DIR/decisions.md" \
  "$ADR_DIR/ADR-001-knowledge-types.md" \
  "$ADR_DIR/ADR-002-planning-economy.md" \
  "$ADR_DIR/ADR-003-wiki-frontmatter-schema.md" \
  "$RCA_DIR/RCA-001-sdd-ship-spec-add-missing.md"
do
  [ -f "$f" ] && check_sources_paths "$f"
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
