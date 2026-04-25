#!/usr/bin/env bash
set -euo pipefail

# test-sdd-queued-marker-removed.sh
# spec-14-01: sdd:queued 마커가 템플릿에서 완전히 제거되었고,
#             그 부재 상태에서 sdd 명령들이 정상 동작함을 검증.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"
SDD_LIB_DIR="$ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$ROOT/sources/templates"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " queued marker removal (spec-14-01)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# Phase 1: 템플릿 검증 — sdd:queued 마커 부재
# ─────────────────────────────────────────────────────────

echo "▶ Phase 1: 템플릿에 sdd:queued 마커가 없는지 검증"

for tpl in \
  "$ROOT/sources/templates/queue.md" \
  "$ROOT/.harness-kit/agent/templates/queue.md"
do
  check
  if [ ! -f "$tpl" ]; then
    fail "템플릿 파일 부재: $tpl"
    continue
  fi
  if grep -q "sdd:queued" "$tpl"; then
    fail "$tpl 에 sdd:queued 마커가 남아 있음"
  else
    pass "$tpl — sdd:queued 마커 없음"
  fi
done

echo ""

# ─────────────────────────────────────────────────────────
# Phase 2: 픽스처 검증 — 마커 없는 queue.md 에서 sdd 명령 정상 동작
# ─────────────────────────────────────────────────────────

echo "▶ Phase 2: 마커 없는 queue.md 픽스처에서 sdd 명령 정상 동작"

FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_DIR"' EXIT

mkdir -p "$FIXTURE_DIR/.claude/state"
mkdir -p "$FIXTURE_DIR/backlog"
mkdir -p "$FIXTURE_DIR/.harness-kit/bin/lib"
mkdir -p "$FIXTURE_DIR/.harness-kit/agent/templates"

git -C "$FIXTURE_DIR" init -q
git -C "$FIXTURE_DIR" config user.email "test@local"
git -C "$FIXTURE_DIR" config user.name "test"
git -C "$FIXTURE_DIR" checkout -b main 2>/dev/null || true

cp "$SDD" "$FIXTURE_DIR/.harness-kit/bin/sdd"
for f in "$SDD_LIB_DIR"/*.sh; do
  cp "$f" "$FIXTURE_DIR/.harness-kit/bin/lib/$(basename "$f")"
done
for f in "$SDD_TEMPLATES_DIR"/*.md; do
  cp "$f" "$FIXTURE_DIR/.harness-kit/agent/templates/$(basename "$f")"
done

# 프로젝트 루트 마커 — sdd 가 root 를 식별하기 위해 필요
cat > "$FIXTURE_DIR/.harness-kit/installed.json" <<'EOF'
{
  "kitVersion": "test",
  "installedAt": "2026-04-25T00:00:00Z"
}
EOF

# 빈 state — sdd phase new 가 active 를 갱신할 수 있어야 함
cat > "$FIXTURE_DIR/.claude/state/current.json" <<'EOF'
{
  "phase": null,
  "spec": null,
  "branch": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

# sdd:queued 마커가 *없는* queue.md
cat > "$FIXTURE_DIR/backlog/queue.md" <<'EOF'
# Backlog Queue

## 📦 진행 중 Phase

<!-- sdd:active:start -->
없음
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

- [ ] (없음)

## 📋 대기 Phase

> 사람이 직접 편집합니다.

없음

## ✅ 완료

<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
EOF

SDD_CMD="bash $FIXTURE_DIR/.harness-kit/bin/sdd"

# Check: sdd phase new
check
PHASE_NEW_OUT=$(cd "$FIXTURE_DIR" && $SDD_CMD phase new test-phase 2>&1 || echo "__SDD_FAIL__")
if echo "$PHASE_NEW_OUT" | grep -q "__SDD_FAIL__"; then
  fail "sdd phase new 실패"
  echo "    출력: $PHASE_NEW_OUT"
elif echo "$PHASE_NEW_OUT" | grep -q "phase 생성"; then
  pass "sdd phase new — 마커 부재 상태에서 정상 동작"
else
  fail "sdd phase new 출력 이상"
  echo "    출력: $PHASE_NEW_OUT"
fi

# Check: queue.md active 마커가 phase-01 로 갱신됐는지 (zero-padded)
check
if grep -A1 "sdd:active:start" "$FIXTURE_DIR/backlog/queue.md" | grep -qE "phase-0*1\b"; then
  pass "queue.md active 마커에 phase-01 등록됨"
else
  fail "queue.md active 마커가 갱신되지 않음"
  echo "    active 영역:"
  awk '/sdd:active:start/,/sdd:active:end/' "$FIXTURE_DIR/backlog/queue.md" | sed 's/^/      /'
fi

# Check: sdd status
check
STATUS_OUT=$(cd "$FIXTURE_DIR" && $SDD_CMD status 2>&1 || true)
if echo "$STATUS_OUT" | grep -q "Active Phase"; then
  pass "sdd status — 마커 부재 상태에서 정상 출력"
else
  fail "sdd status 출력 이상"
  echo "    출력: $STATUS_OUT"
fi

# Check: sdd phase done (active phase 자동 사용)
check
PHASE_DONE_OUT=$(cd "$FIXTURE_DIR" && $SDD_CMD phase done 2>&1 || echo "__SDD_FAIL__")
if echo "$PHASE_DONE_OUT" | grep -q "__SDD_FAIL__"; then
  fail "sdd phase done 실패"
  echo "    출력: $PHASE_DONE_OUT"
elif echo "$PHASE_DONE_OUT" | grep -q "phase done"; then
  pass "sdd phase done — 마커 부재 상태에서 정상 동작"
else
  fail "sdd phase done 출력 이상"
  echo "    출력: $PHASE_DONE_OUT"
fi

# Check: queue.md 의 사람 편집 섹션 ("📋 대기 Phase") 본문이 보존됐는지
check
if grep -q "사람이 직접 편집" "$FIXTURE_DIR/backlog/queue.md"; then
  pass "📋 대기 Phase 섹션 사람 편집 안내문 보존"
else
  fail "사람 편집 섹션 안내문이 sdd 명령 실행 후 손실됨"
fi

# 정리
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL $TOTAL CHECKS PASSED"
else
  echo " ❌ $FAIL / $TOTAL CHECKS FAILED"
  exit 1
fi
