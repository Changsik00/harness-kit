#!/usr/bin/env bash
set -euo pipefail

# test-sdd-root-detection.sh
# spec-x-rootdir-device-fix: sdd_find_root() 파일시스템 앵커링 검증
#
# 검증 항목:
#   A) harness.config.json에 잘못된 rootDir(실제 존재하는 경로)가 기록된 경우
#      → sdd status가 올바른 루트(.harness-kit/ 위치)를 사용해야 함
#   B) harness.config.json에 rootDir가 없는 경우
#      → sdd status가 올바른 루트를 탐지해야 함
#   C) harness.config.json에 존재하지 않는 rootDir가 기록된 경우
#      → sdd status가 올바른 루트로 fallback해야 함

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"
SDD="$ROOT/.harness-kit/bin/sdd"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " sdd_find_root() Filesystem Anchoring (spec-x-rootdir-device-fix)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# 공통: 설치 fixture 생성 함수
# ──────────────────────────────────────────────
make_fixture() {
  local dir="$1"
  git -C "$dir" init -q
  git -C "$dir" checkout -b main 2>/dev/null || true
  git -C "$dir" config user.email "test@local"
  git -C "$dir" config user.name "test"
  bash "$INSTALL" --yes "$dir" > /dev/null 2>&1
}

# ──────────────────────────────────────────────
# 시나리오 A: 잘못된 rootDir (존재하는 경로 — 타 디바이스 크리티컬 케이스)
# ──────────────────────────────────────────────
echo "▶ 시나리오 A: rootDir 가 존재하지만 엉뚱한 경로"

FIXTURE_A="$(mktemp -d)"
WRONG_ROOT="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A" "$WRONG_ROOT"' EXIT

make_fixture "$FIXTURE_A"

# harness.config.json 의 rootDir 를 일부러 틀린 경로(존재함)로 교체
if command -v jq >/dev/null 2>&1; then
  cfg="$FIXTURE_A/.harness-kit/harness.config.json"
  tmp="$cfg.tmp"
  jq --arg r "$WRONG_ROOT" '. + {rootDir: $r}' "$cfg" > "$tmp"
  mv "$tmp" "$cfg"
fi

# sdd status 를 FIXTURE_A 에서 실행 — 올바른 루트를 써야 함
sdd_out=$(cd "$FIXTURE_A" && bash "$SDD" status 2>&1 || true)

check
if echo "$sdd_out" | grep -q 'harness-kit'; then
  pass "A-1: sdd status 실행 성공"
else
  fail "A-1: sdd status 실패 또는 출력 없음: $sdd_out"
fi

check
# 올바른 루트(FIXTURE_A)를 썼다면 backlog/queue.md 가 출력에 나타나야 함.
# 잘못된 rootDir(WRONG_ROOT) 를 쓰면 WRONG_ROOT/backlog 가 없으므로 queue.md 가 보이지 않음.
if echo "$sdd_out" | grep -q 'queue.md'; then
  pass "A-2: 올바른 루트(FIXTURE_A)의 backlog/queue.md 가 sdd status 에 표시됨"
else
  fail "A-2: queue.md 가 출력에 없음 — 잘못된 rootDir 가 루트로 사용되고 있음 (현재 출력: $(echo "$sdd_out" | head -10))"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 B: rootDir 필드 없음 (신규 install 기대값)
# ──────────────────────────────────────────────
echo "▶ 시나리오 B: rootDir 필드 없는 harness.config.json"

FIXTURE_B="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A" "$WRONG_ROOT" "$FIXTURE_B"' EXIT

make_fixture "$FIXTURE_B"

# rootDir 필드 제거
if command -v jq >/dev/null 2>&1; then
  cfg="$FIXTURE_B/.harness-kit/harness.config.json"
  tmp="$cfg.tmp"
  jq 'del(.rootDir)' "$cfg" > "$tmp"
  mv "$tmp" "$cfg"
fi

sdd_out_b=$(cd "$FIXTURE_B" && bash "$SDD" status 2>&1 || true)

check
if echo "$sdd_out_b" | grep -q 'harness-kit'; then
  pass "B-1: rootDir 없이도 sdd status 정상 실행"
else
  fail "B-1: sdd status 실패: $sdd_out_b"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 C: rootDir 가 존재하지 않는 경로
# ──────────────────────────────────────────────
echo "▶ 시나리오 C: rootDir 가 존재하지 않는 경로 (타 디바이스 일반 케이스)"

FIXTURE_C="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A" "$WRONG_ROOT" "$FIXTURE_B" "$FIXTURE_C"' EXIT

make_fixture "$FIXTURE_C"

if command -v jq >/dev/null 2>&1; then
  cfg="$FIXTURE_C/.harness-kit/harness.config.json"
  tmp="$cfg.tmp"
  jq '. + {rootDir: "/Users/nonexistent-user/some/path"}' "$cfg" > "$tmp"
  mv "$tmp" "$cfg"
fi

sdd_out_c=$(cd "$FIXTURE_C" && bash "$SDD" status 2>&1 || true)

check
if echo "$sdd_out_c" | grep -q 'harness-kit'; then
  pass "C-1: 존재하지 않는 rootDir 무시 후 sdd status 정상 실행"
else
  fail "C-1: sdd status 실패: $sdd_out_c"
fi

echo ""

# ──────────────────────────────────────────────
# 결과
# ──────────────────────────────────────────────
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL PASS ($TOTAL/$TOTAL)"
else
  echo " ❌ ${FAIL}/${TOTAL} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
