#!/usr/bin/env bash
# tests/test-install-manifest-sync.sh
# spec-15-05: sources/governance/ 와 sources/templates/ 의 .md 명단이 install 결과와 1:1 일치 검증.
#             새 .md 가 sources/ 에 추가되었지만 install.sh 갱신이 누락된 경우 (Schema Drift) 즉시 fail.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

echo "═══════════════════════════════════════════════════════"
echo " test-install-manifest-sync (spec-15-05)"
echo "═══════════════════════════════════════════════════════"

F=$(mktemp -d); CLEANUP+=("$F")
bash "$INSTALL" --yes "$F" >/dev/null 2>&1

# ─────────────────────────────────────────────────────────
# Check 1: governance 명단 1:1 (count)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Group 1: governance manifest sync"

src_gov=$(find "$ROOT/sources/governance" -maxdepth 1 -name '*.md' -type f 2>/dev/null \
          | sort | xargs -n1 basename 2>/dev/null)
inst_gov=$(find "$F/.harness-kit/agent" -maxdepth 1 -name '*.md' -type f 2>/dev/null \
           | sort | xargs -n1 basename 2>/dev/null)

src_gov_count=$(printf '%s\n' "$src_gov" | grep -c . 2>/dev/null || echo 0)
inst_gov_count=$(printf '%s\n' "$inst_gov" | grep -c . 2>/dev/null || echo 0)

if [ "$src_gov_count" = "$inst_gov_count" ] && [ "$src_gov_count" -gt 0 ]; then
  ok "governance 파일 개수 일치 ($src_gov_count files)"
else
  fail "governance 개수 불일치 (sources=$src_gov_count installed=$inst_gov_count)"
fi

if [ "$src_gov" = "$inst_gov" ]; then
  ok "governance 파일명 1:1 일치"
else
  fail "governance 명단 불일치"
fi

# ─────────────────────────────────────────────────────────
# Check 2: templates 명단 1:1
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Group 2: templates manifest sync"

src_tpl=$(find "$ROOT/sources/templates" -maxdepth 1 -name '*.md' -type f 2>/dev/null \
          | sort | xargs -n1 basename 2>/dev/null)
inst_tpl=$(find "$F/.harness-kit/agent/templates" -maxdepth 1 -name '*.md' -type f 2>/dev/null \
           | sort | xargs -n1 basename 2>/dev/null)

src_tpl_count=$(printf '%s\n' "$src_tpl" | grep -c . 2>/dev/null || echo 0)
inst_tpl_count=$(printf '%s\n' "$inst_tpl" | grep -c . 2>/dev/null || echo 0)

if [ "$src_tpl_count" = "$inst_tpl_count" ] && [ "$src_tpl_count" -gt 0 ]; then
  ok "templates 파일 개수 일치 ($src_tpl_count files)"
else
  fail "templates 개수 불일치 (sources=$src_tpl_count installed=$inst_tpl_count)"
fi

if [ "$src_tpl" = "$inst_tpl" ]; then
  ok "templates 파일명 1:1 일치"
else
  fail "templates 명단 불일치"
fi

# ─────────────────────────────────────────────────────────
# Check 3: 내용 cp 정합성 (각 디렉토리 첫 파일 sample)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Group 3: content cp 정합성"

# governance 의 constitution.md (확실히 존재하는 파일) 비교
if [ -f "$ROOT/sources/governance/constitution.md" ] \
   && [ -f "$F/.harness-kit/agent/constitution.md" ] \
   && diff -q "$ROOT/sources/governance/constitution.md" \
              "$F/.harness-kit/agent/constitution.md" >/dev/null 2>&1; then
  ok "governance 내용 cp 정합 (constitution.md)"
else
  fail "governance 내용 불일치"
fi

# templates 의 spec.md 비교
if [ -f "$ROOT/sources/templates/spec.md" ] \
   && [ -f "$F/.harness-kit/agent/templates/spec.md" ] \
   && diff -q "$ROOT/sources/templates/spec.md" \
              "$F/.harness-kit/agent/templates/spec.md" >/dev/null 2>&1; then
  ok "templates 내용 cp 정합 (spec.md)"
else
  fail "templates 내용 불일치"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
