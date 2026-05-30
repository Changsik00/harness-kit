#!/usr/bin/env bash
# tests/test-doctor-hookspath-lefthook.sh
# spec-x-doctor-hookspath-lefthook (issue #161):
#   lefthook 사용 + core.hooksPath 로컬 설정 충돌을 doctor 가 감지해 경고하는지 검증.
#   - sdd doctor (sources/bin/sdd cmd_doctor)
#   - 루트 doctor.sh
# 경고 메시지는 '#161' 토큰을 포함, 정상/범위외 케이스는 미포함.
set -uo pipefail

PASS=0; FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"
SDD_LIB_DIR="$ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$ROOT/sources/templates"
DOCTOR="$ROOT/doctor.sh"

ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

# make_repo <with_lefthook:0|1> <with_hookspath:0|1>
make_repo() {
  local with_lh="$1" with_hp="$2"
  local dir; dir="$(mktemp -d)"; CLEANUP+=("$dir")

  mkdir -p "$dir/.claude/state" "$dir/backlog" "$dir/.harness-kit/hooks"
  mkdir -p "$dir/.harness-kit/bin/lib" "$dir/.harness-kit/agent/templates"
  cp "$SDD" "$dir/.harness-kit/bin/sdd"
  local f
  for f in "$SDD_LIB_DIR"/*.sh; do cp "$f" "$dir/.harness-kit/bin/lib/$(basename "$f")"; done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do cp "$f" "$dir/.harness-kit/agent/templates/$(basename "$f")"; done
  printf '{ "kitVersion":"0.0.0" }\n' > "$dir/.harness-kit/installed.json"

  if [ "$with_lh" = "1" ]; then
    printf 'pre-commit:\n  commands:\n    noop:\n      run: true\n' > "$dir/lefthook.yml"
  fi

  git -C "$dir" init -q
  git -C "$dir" config user.email "test@local"
  git -C "$dir" config user.name "test"
  if [ "$with_hp" = "1" ]; then
    git -C "$dir" config --local core.hooksPath "$dir/.git/hooks"
  fi
  echo "$dir"
}

run_sdd_doctor()  { (cd "$1" && bash .harness-kit/bin/sdd doctor 2>&1); }
run_root_doctor() { bash "$DOCTOR" "$1" 2>&1; }

echo "═══════════════════════════════════════════════════════"
echo " test-doctor-hookspath-lefthook (issue #161)"
echo "═══════════════════════════════════════════════════════"

# ── Case 1: lefthook + hooksPath → sdd doctor 경고 ──
echo ""
echo "▶ Case 1: lefthook + core.hooksPath → sdd doctor 충돌 경고"
R1="$(make_repo 1 1)"
out1="$(run_sdd_doctor "$R1")"
if echo "$out1" | grep -q '#161'; then
  ok "Case 1: sdd doctor 가 충돌 경고(#161) 출력"
else
  fail "Case 1: sdd doctor 충돌 경고 미출력"
fi

# ── Case 2: lefthook + hooksPath → 루트 doctor.sh 경고 ──
echo ""
echo "▶ Case 2: lefthook + core.hooksPath → 루트 doctor.sh 충돌 경고"
R2="$(make_repo 1 1)"
out2="$(run_root_doctor "$R2")"
if echo "$out2" | grep -q '#161'; then
  ok "Case 2: 루트 doctor.sh 가 충돌 경고(#161) 출력"
else
  fail "Case 2: 루트 doctor.sh 충돌 경고 미출력"
fi

# ── Case 3: lefthook + hooksPath 미설정 → 경고 없음 (정상) ──
echo ""
echo "▶ Case 3: lefthook + hooksPath 미설정 → 충돌 경고 없음"
R3="$(make_repo 1 0)"
out3a="$(run_sdd_doctor "$R3")"
out3b="$(run_root_doctor "$R3")"
if ! echo "$out3a$out3b" | grep -q '#161'; then
  ok "Case 3: hooksPath 미설정 시 충돌 경고 없음"
else
  fail "Case 3: hooksPath 미설정인데 충돌 경고 출력됨"
fi

# ── Case 4: lefthook 미사용 + hooksPath 설정 → 경고 없음 (범위 외) ──
echo ""
echo "▶ Case 4: lefthook 미사용 + hooksPath 설정 → 충돌 경고 없음"
R4="$(make_repo 0 1)"
out4a="$(run_sdd_doctor "$R4")"
out4b="$(run_root_doctor "$R4")"
if ! echo "$out4a$out4b" | grep -q '#161'; then
  ok "Case 4: lefthook 미사용 시 충돌 경고 없음"
else
  fail "Case 4: lefthook 미사용인데 충돌 경고 출력됨"
fi

echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
