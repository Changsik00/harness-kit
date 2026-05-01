#!/usr/bin/env bash
# tests/test-sdd-drift.sh
# spec-x-hk-align-drift-detect: sdd status 의 🔄 동기화 상태 (drift) 섹션 검증
#
# 5 시나리오:
#   T1: 깨끗한 fixture → "🔄 동기화 상태" 섹션이 drift 없음으로 보고
#   T2: 원격 behind 1 → "원격: behind 1 / ahead 0"
#   T3: specs/ 안 untracked 디렉토리 → "워킹트리: ... spec drift"
#   T4: queue active phase 의 모든 spec Merged → "phase done 미실행 의심"
#   T5: --no-drift → 동기화 섹션 미출력

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-sdd-drift ==="

if [ ! -f "$LIB" ]; then
  fail "tests/lib/fixture.sh 없음"
  exit 1
fi
if [ ! -f "$SDD" ]; then
  fail "sources/bin/sdd 없음"
  exit 1
fi

# shellcheck source=lib/fixture.sh
source "$LIB"

FIXTURES_TO_CLEAN=()
cleanup() {
  local d
  for d in "${FIXTURES_TO_CLEAN[@]:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
  done
}
trap cleanup EXIT

# fixture 안에서 sdd 호출 — 설치된 .harness-kit/bin/sdd 가 아니라 sources 의 sdd 를 쓰되
# SDD_ROOT 를 fixture 디렉토리로 강제. sdd 가 cwd 기반으로 SDD_ROOT 를 잡는다는 가정.
run_sdd_status() {
  local fx="$1"; shift
  ( cd "$fx" && HARNESS_DRIFT_FETCH=0 bash "$SDD" status "$@" 2>&1 )
}

# ─────────────────────────────────────────────────────────
# T1: 깨끗한 fixture → drift 섹션 "깔끔"
# ─────────────────────────────────────────────────────────
echo ""
echo "T1: 깨끗한 상태 → drift 섹션 깔끔"
F1=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F1")

OUT1=$(run_sdd_status "$F1")
if echo "$OUT1" | grep -q "🔄 동기화 상태"; then
  ok "동기화 상태 섹션 출력됨"
else
  fail "동기화 상태 섹션 누락 — sdd status 에 drift 섹션 미구현"
fi
if echo "$OUT1" | grep -qE "깔끔|clean"; then
  ok "깔끔 메시지 표시"
else
  fail "drift 없음을 알리는 표시 누락"
fi

# ─────────────────────────────────────────────────────────
# T2: 원격 behind 1 시뮬레이션
# ─────────────────────────────────────────────────────────
echo ""
echo "T2: 원격 behind 1 → 'behind 1' 메시지"
F2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F2")
REMOTE2=$(mktemp -d)
FIXTURES_TO_CLEAN+=("$REMOTE2")

# bare remote 셋업 + 첫 push → 그 다음 commit + push → 로컬 reset 으로 1 commit 뒤
git -C "$REMOTE2" init --bare -q
git -C "$F2" branch -m main 2>/dev/null || true
git -C "$F2" remote add origin "$REMOTE2"
git -C "$F2" push -u origin HEAD:main -q 2>/dev/null
git -C "$F2" commit --allow-empty -m "extra" -q
git -C "$F2" push -q 2>/dev/null
git -C "$F2" reset --hard HEAD~1 -q

# behind 비교는 fetch 결과 기반 — 테스트에서는 HARNESS_DRIFT_FETCH=1 로 강제 fetch
OUT2=$( cd "$F2" && HARNESS_DRIFT_FETCH=1 bash "$SDD" status 2>&1 )
if echo "$OUT2" | grep -qE "behind 1"; then
  ok "behind 1 보고됨"
else
  fail "behind 1 메시지 누락 — drift_remote 미구현"
fi

# ─────────────────────────────────────────────────────────
# T3: specs/ 안 untracked 디렉토리 → spec drift
# ─────────────────────────────────────────────────────────
echo ""
echo "T3: specs/ 미커밋 디렉토리 → spec drift 카운트"
F3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F3")

mkdir -p "$F3/specs/spec-x-fake-drift"
echo "stale" > "$F3/specs/spec-x-fake-drift/spec.md"

OUT3=$(run_sdd_status "$F3")
if echo "$OUT3" | grep -qE "spec drift|spec[ ]*:[ ]*[1-9]|워킹트리.*spec"; then
  ok "spec drift 감지됨"
else
  fail "spec drift 메시지 누락 — drift_worktree 미구현"
fi

# ─────────────────────────────────────────────────────────
# T4: queue active phase 의 모든 spec Merged → 정합성 경고
# ─────────────────────────────────────────────────────────
echo ""
echo "T4: 모든 spec Merged 인데 phase active → 정합성 경고"
F4=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F4")

# queue.md 의 active 섹션에 phase-08 등록
awk '
  /<!-- sdd:active:start -->/ {
    print
    print "- **phase-08** — fake — fixture phase — 1 spec — 다음: (spec 없음)"
    in_skip=1; next
  }
  /<!-- sdd:active:end -->/ { in_skip=0 }
  in_skip { next }
  { print }
' "$F4/backlog/queue.md" > "$F4/backlog/queue.md.tmp"
mv "$F4/backlog/queue.md.tmp" "$F4/backlog/queue.md"

# phase-08.md 에 모두 Merged 인 spec 표
cat > "$F4/backlog/phase-08.md" <<'PHASE_EOF'
# phase-08: fake (test fixture)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-08-01` | fake-1 | P1 | Merged | `specs/spec-08-01-fake-1/` |
<!-- sdd:specs:end -->
PHASE_EOF

OUT4=$(run_sdd_status "$F4")
if echo "$OUT4" | grep -qE "phase done 미실행|phase done 가능|모든 spec Merged"; then
  ok "정합성 경고 표시됨"
else
  fail "정합성 경고 메시지 누락 — drift_consistency 미구현"
fi

# ─────────────────────────────────────────────────────────
# T5: --no-drift → drift 섹션 미출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T5: --no-drift 옵션 → 동기화 섹션 미출력"
F5=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F5")

OUT5=$(run_sdd_status "$F5" --no-drift)
if echo "$OUT5" | grep -q "🔄 동기화 상태"; then
  fail "--no-drift 인데 동기화 섹션 출력됨"
else
  ok "--no-drift 옵션 정상 동작"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
