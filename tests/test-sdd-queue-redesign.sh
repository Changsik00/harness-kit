#!/usr/bin/env bash
set -euo pipefail

# test-sdd-queue-redesign.sh
# spec-8-001: sdd status NEXT 계산 및 sdd queue 구조화 출력 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/scripts/harness/bin/sdd"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Queue Redesign Verification (spec-8-001)"
echo "═══════════════════════════════════════════"
echo ""

# --- 픽스처 설정 ---
FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_DIR"' EXIT

# 픽스처: 최소 git repo + state + backlog + phase
mkdir -p "$FIXTURE_DIR/.claude/state"
mkdir -p "$FIXTURE_DIR/backlog"
mkdir -p "$FIXTURE_DIR/specs/spec-8-001-queue-redesign"
mkdir -p "$FIXTURE_DIR/scripts/harness/bin/lib"

# git 초기화
git -C "$FIXTURE_DIR" init -q
git -C "$FIXTURE_DIR" checkout -b main 2>/dev/null || true

# sdd + lib 복사
cp "$ROOT/scripts/harness/bin/sdd" "$FIXTURE_DIR/scripts/harness/bin/sdd"
cp "$ROOT/scripts/harness/bin/lib/"* "$FIXTURE_DIR/scripts/harness/bin/lib/"

# state.json 설정
cat > "$FIXTURE_DIR/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-8",
  "spec": "spec-8-001-queue-redesign",
  "branch": null,
  "planAccepted": true,
  "lastTestPass": null,
  "installedAt": "2026-04-11T00:00:00Z"
}
EOF

# phase-8.md 설정 (spec 표에 In Progress + Backlog 항목 포함)
cat > "$FIXTURE_DIR/backlog/phase-8.md" <<'EOF'
# phase-8: 테스트용 Phase

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-8` |
| **상태** | In Progress |
| **Base Branch** | `phase-8` |

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-8-001 | queue-redesign | P1 | In Progress | `specs/spec-8-001-queue-redesign/` |
| spec-8-002 | phase-base-branch | P1 | Backlog | `specs/spec-8-002-phase-base-branch/` |
| spec-8-003 | ship-completion-gate | P1 | Backlog | `specs/spec-8-003-ship-completion-gate/` |
| spec-8-004 | align-and-governance | P2 | Backlog | `specs/spec-8-004-align-and-governance/` |
<!-- sdd:specs:end -->
EOF

# queue.md 설정 (신규 구조)
cat > "$FIXTURE_DIR/backlog/queue.md" <<'EOF'
# Backlog Queue

## 🔴 NOW

<!-- sdd:now:start -->
없음
<!-- sdd:now:end -->

## ⏭ NEXT

<!-- sdd:next:start -->
없음
<!-- sdd:next:end -->

## 📦 진행 중 Phase

<!-- sdd:active:start -->
없음
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

- [ ] 아이디어: 테스트 항목

## 📋 대기 Phase

<!-- sdd:queued:start -->
없음
<!-- sdd:queued:end -->

## ✅ 완료

<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
EOF

SDD_CMD="bash $FIXTURE_DIR/scripts/harness/bin/sdd"

echo "▶ Check 1: sdd status — NEXT 행 존재 여부"
check
STATUS_OUT=$(cd "$FIXTURE_DIR" && $SDD_CMD status 2>&1 || true)
if echo "$STATUS_OUT" | grep -q "NEXT:"; then
  pass "sdd status 출력에 'NEXT:' 행이 있음"
else
  fail "sdd status 출력에 'NEXT:' 행이 없음"
  echo "    출력: $STATUS_OUT"
fi

echo ""
echo "▶ Check 2: sdd status — NEXT 값이 spec-8-002인지 확인"
check
if echo "$STATUS_OUT" | grep -q "NEXT:.*spec-8-002"; then
  pass "NEXT = spec-8-002 (첫 번째 Backlog spec)"
else
  fail "NEXT 값이 spec-8-002가 아님"
  echo "    출력: $(echo "$STATUS_OUT" | grep NEXT || echo '(NEXT 행 없음)')"
fi

echo ""
echo "▶ Check 3: sdd queue — NOW/NEXT/Icebox 섹션 헤더 존재"
check
QUEUE_OUT=$(cd "$FIXTURE_DIR" && $SDD_CMD queue 2>&1 || true)
MISSING=""
for section in "🔴 NOW" "⏭ NEXT" "🧊 Icebox"; do
  if ! echo "$QUEUE_OUT" | grep -q "$section"; then
    MISSING="$MISSING '$section'"
  fi
done
if [ -z "$MISSING" ]; then
  pass "queue 출력에 NOW/NEXT/Icebox 섹션 모두 존재"
else
  fail "누락된 섹션:$MISSING"
fi

echo ""
echo "▶ Check 4: sdd queue --raw — queue.md 원문 출력"
check
RAW_OUT=$(cd "$FIXTURE_DIR" && $SDD_CMD queue --raw 2>&1 || true)
if echo "$RAW_OUT" | grep -q "sdd:now:start"; then
  pass "sdd queue --raw 는 queue.md 원문(마커 포함) 출력"
else
  fail "sdd queue --raw 가 원문을 출력하지 않음"
fi

echo ""
echo "▶ Check 5: 모든 spec Merged 시 NEXT = 없음"
check
# phase-8.md의 모든 spec을 Merged로 변경
sed -i.bak 's/| In Progress |/| Merged |/g; s/| Backlog |/| Merged |/g' \
  "$FIXTURE_DIR/backlog/phase-8.md"
STATUS_ALL_DONE=$(cd "$FIXTURE_DIR" && $SDD_CMD status 2>&1 || true)
if echo "$STATUS_ALL_DONE" | grep -qE "NEXT:.*없음|NEXT:.*none"; then
  pass "모든 spec Merged 시 NEXT = 없음"
else
  fail "모든 spec Merged 시에도 NEXT가 없음으로 표시되지 않음"
  echo "    출력: $(echo "$STATUS_ALL_DONE" | grep NEXT || echo '(NEXT 행 없음)')"
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
