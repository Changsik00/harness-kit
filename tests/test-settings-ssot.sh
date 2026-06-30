#!/usr/bin/env bash
set -uo pipefail

# test-settings-ssot.sh
# spec-26-01 (W3): settings push 권한 SSOT.
# 불변식: push 게이팅은 settings `ask` 가 아니라 constitution §5.7(push 자동) +
#         deny/check-irreversible(force-push 차단)이 담당한다.
#   T1: fragment `permissions.ask` 에 git push 없음 (게이트 없음 = 자동).
#   T2: fragment `permissions.deny` 에 force-push 변형 존재 (차단).
#   T3: sdd 가 모드 전환 시 `permissions.ask` 의 git push 를 조작하지 않음
#       (_settings_mode_patch 잔재 제거 — 방향2 회귀 방지).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FRAG="$ROOT/sources/claude-fragments/settings.json.fragment"
SDD="$ROOT/sources/bin/sdd"

source "$SCRIPT_DIR/lib/fixture.sh"
CLEAN=()
trap 'for d in "${CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "═══════════════════════════════════════════════════════"
echo " test-settings-ssot (spec-26-01 / W3)"
echo "═══════════════════════════════════════════════════════"

# T1: fragment ask 에 git push 없음 (push 자동 — §5.7)
ask_push=$(jq '[.permissions.ask[]? | select(test("git push"))] | length' "$FRAG" 2>/dev/null || echo "-1")
if [ "$ask_push" = "0" ]; then
  ok "T1: fragment permissions.ask 에 git push 없음 (자동, §5.7 정합)"
else
  fail "T1: fragment ask 에 git push ${ask_push}개 (방향2 위반 — push 는 ask 게이트 없어야)"
fi

# T2: fragment deny 에 force-push 변형 존재 (차단)
deny_force=$(jq '[.permissions.deny[]? | select(test("git push (--force|-f)"))] | length' "$FRAG" 2>/dev/null || echo "0")
if [ "$deny_force" -ge 2 ]; then
  ok "T2: fragment permissions.deny 에 force-push 변형 ${deny_force}개 (차단)"
else
  fail "T2: fragment deny 의 force-push 변형 부족 (${deny_force}개, ≥2 기대)"
fi

# T3: sdd 가 permissions.ask 의 git push 를 조작하지 않음 (구 ask 토글 로직 제거)
#     함수 정의(...())나 jq 조작(permissions.ask + git push) 의 *실체* 만 검사 — 산문 주석은 무관.
if grep -qE '_settings_mode_patch[[:space:]]*\(\)' "$SDD"; then
  fail "T3: sdd 에 settings ask 토글 함수 정의 잔존 (방향2 — 제거돼야)"
elif grep -qE 'permissions\.ask.*git push' "$SDD"; then
  fail "T3: sdd 가 permissions.ask 의 git push 를 jq 조작 (방향2 위반)"
else
  ok "T3: sdd 가 git push ask 를 조작하지 않음 (push 게이팅은 §5.7+deny 담당)"
fi

# ── 행동 테스트 (fixture) — phase-26 C1/W-1 ──────────────────────────────────

# T4 (C1): fresh install 의 state 에 mode 가 시드됨 (빈 mode 모호성 제거).
#   install 이 mode 를 안 넣으면 hook(빈→block) ↔ CLI(빈→governed) 가 상반 분류.
F4="$(make_fixture)"; CLEAN+=("$F4")
seeded="$(jq -r '.mode // "absent"' "$F4/.claude/state/current.json" 2>/dev/null)"
if [ "$seeded" = "governed" ]; then
  ok "T4: fresh install state 에 mode=governed 시드됨 (빈-mode 모호성 제거, C1)"
else
  fail "T4: install 이 mode 를 시드 안 함 (=$seeded) — 빈 mode → hook/CLI 상반 분류(C1)"
fi

# T5 (W-1): `sdd mode governed` round-trip 이 permissions.ask 에 git push 를 추가하지 않음.
#   구 _settings_mode_patch 의 버그 경로(governed → ask 에 push 추가)를 *행동*으로 회귀 방어.
F5="$(make_fixture)"; CLEAN+=("$F5")
( cd "$F5" && bash "$F5/.harness-kit/bin/sdd" mode turbo  >/dev/null 2>&1 )
( cd "$F5" && bash "$F5/.harness-kit/bin/sdd" mode governed >/dev/null 2>&1 )
ask_push5="$(jq '[.permissions.ask[]? | select(test("git push"))] | length' "$F5/.claude/settings.json" 2>/dev/null || echo "-1")"
if [ "$ask_push5" = "0" ]; then
  ok "T5: mode turbo→governed round-trip 후에도 ask 에 git push 없음 (토글 제거 행동 검증, W-1)"
else
  fail "T5: governed 복귀가 ask 에 git push ${ask_push5}개 추가 (구 토글 회귀)"
fi

echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
