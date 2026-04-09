#!/usr/bin/env bash
# harness-kit doctor — 설치 상태 점검
#
# Usage:
#   ./doctor.sh                    # 현재 디렉토리 점검
#   ./doctor.sh /path/to/project   # 지정 디렉토리 점검

set -uo pipefail   # set -e 는 일부러 비활성 — 항목별 실패를 누적 보고

if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'
  C_BLU=$'\033[34m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_BLU=""; C_DIM=""; C_RST=""
fi

TARGET="${1:-$(pwd)}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "${C_RED}대상 디렉토리 없음${C_RST}" >&2; exit 1; }

PASS=0
FAIL=0
WARN=0

check_pass() { echo "${C_GRN}✓${C_RST} $1"; PASS=$((PASS+1)); }
check_fail() { echo "${C_RED}✗${C_RST} $1"; FAIL=$((FAIL+1)); }
check_warn() { echo "${C_YLW}⚠${C_RST} $1"; WARN=$((WARN+1)); }

echo "${C_BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
echo "${C_BLU}harness-kit doctor${C_RST}  ($TARGET)"
echo "${C_BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
echo ""

# ========== 1. 외부 의존성 + 환경 ==========
echo "[1/6] 외부 의존성 + 환경"
case "$(uname -s)" in
  Darwin) check_pass "OS = macOS (1차 타깃)" ;;
  Linux)  check_warn  "OS = Linux (best-effort)" ;;
  *)      check_warn  "OS = $(uname -s) (미지원)" ;;
esac
command -v git >/dev/null && check_pass "git" || check_fail "git 없음"
command -v jq  >/dev/null && check_pass "jq"  || check_fail "jq 없음 (brew install jq / apt install jq)"
if command -v bash >/dev/null; then
  bv=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  bv_major="${bv%%.*}"
  if [ "${bv_major:-0}" -ge 4 ]; then
    check_pass "bash $bv"
  else
    check_warn "bash $bv (4.0+ 권장 — brew install bash)"
  fi
else
  check_fail "bash 없음"
fi
echo ""

# ========== 2. 디렉토리 구조 ==========
echo "[2/6] 디렉토리 구조"
for d in agent agent/templates .claude/commands .claude/state scripts/harness/bin scripts/harness/hooks scripts/harness/lib backlog specs; do
  if [ -d "$TARGET/$d" ]; then
    check_pass "$d"
  else
    check_fail "$d 없음"
  fi
done
echo ""

# ========== 3. 거버넌스 + 템플릿 ==========
echo "[3/6] 거버넌스 + 템플릿"
for f in agent/constitution.md agent/agent.md agent/align.md; do
  [ -f "$TARGET/$f" ] && check_pass "$f" || check_fail "$f 없음"
done
for f in phase.md spec.md plan.md task.md walkthrough.md pr_description.md; do
  [ -f "$TARGET/agent/templates/$f" ] && check_pass "agent/templates/$f" || check_fail "agent/templates/$f 없음"
done
echo ""

# ========== 4. Claude Code 통합 ==========
echo "[4/6] Claude Code 통합"
SETTINGS="$TARGET/.claude/settings.json"
if [ -f "$SETTINGS" ]; then
  check_pass ".claude/settings.json 존재"
  if jq -e '.permissions.allow' "$SETTINGS" >/dev/null 2>&1; then
    cnt=$(jq '.permissions.allow | length' "$SETTINGS")
    check_pass "permissions.allow ($cnt 개)"
  else
    check_warn "permissions.allow 없음"
  fi
  if jq -e '.hooks' "$SETTINGS" >/dev/null 2>&1; then
    check_pass "hooks 등록됨"
  else
    check_warn "hooks 등록 안 됨"
  fi
else
  check_fail ".claude/settings.json 없음"
fi

if [ -f "$TARGET/CLAUDE.md" ]; then
  if grep -q "HARNESS-KIT:BEGIN" "$TARGET/CLAUDE.md"; then
    check_pass "CLAUDE.md 에 HARNESS-KIT 블록 존재"
  else
    check_warn "CLAUDE.md 에 HARNESS-KIT 블록 없음 (install 미완)"
  fi
else
  check_fail "CLAUDE.md 없음"
fi
echo ""

# ========== 5. State / Stack ==========
echo "[5/6] State / Stack"
STATE="$TARGET/.claude/state/current.json"
if [ -f "$STATE" ]; then
  check_pass ".claude/state/current.json 존재"
  if command -v jq >/dev/null; then
    stack=$(jq -r '.stack // "unknown"' "$STATE")
    kit_ver=$(jq -r '.kitVersion // "unknown"' "$STATE")
    plan_accepted=$(jq -r '.planAccepted // false' "$STATE")
    echo "  ${C_DIM}stack: $stack${C_RST}"
    echo "  ${C_DIM}kit version: $kit_ver${C_RST}"
    echo "  ${C_DIM}plan accepted: $plan_accepted${C_RST}"
  fi
else
  check_warn ".claude/state/current.json 없음"
fi

if [ -f "$TARGET/scripts/harness/lib/stack.sh" ]; then
  check_pass "scripts/harness/lib/stack.sh 존재"
else
  check_fail "scripts/harness/lib/stack.sh 없음"
fi
echo ""

# ========== 6. Hook 권한 ==========
echo "[6/6] Hook 권한"
if [ -d "$TARGET/scripts/harness/hooks" ]; then
  hook_count=$(find "$TARGET/scripts/harness/hooks" -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$hook_count" -eq 0 ]; then
    check_warn "hook 스크립트 없음 (Phase 3-6 미완 또는 --no-hooks 설치)"
  else
    for f in "$TARGET/scripts/harness/hooks"/*.sh; do
      if [ -x "$f" ]; then
        check_pass "$(basename "$f") (executable)"
      else
        check_fail "$(basename "$f") 실행 권한 없음 (chmod +x 필요)"
      fi
    done
  fi
fi
echo ""

# ========== 결과 ==========
echo "${C_BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
echo "${C_GRN}PASS: $PASS${C_RST}    ${C_YLW}WARN: $WARN${C_RST}    ${C_RED}FAIL: $FAIL${C_RST}"
if [ $FAIL -gt 0 ]; then
  echo ""
  echo "${C_RED}진단 실패 항목이 있습니다. install.sh 를 다시 실행하거나 위 메시지를 참고하세요.${C_RST}"
  exit 1
fi
echo ""
echo "${C_GRN}하네스 설치 상태 양호.${C_RST}"
exit 0
