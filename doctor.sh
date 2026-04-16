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
echo "[1/7] 외부 의존성 + 환경"
case "$(uname -s)" in
  Darwin) check_pass "OS = macOS (1차 타깃)" ;;
  Linux)  check_warn  "OS = Linux (best-effort)" ;;
  *)      check_warn  "OS = $(uname -s) (미지원)" ;;
esac
command -v git >/dev/null && check_pass "git" || check_fail "git 없음"
command -v jq  >/dev/null && check_pass "jq"  || check_fail "jq 없음 (brew install jq / apt install jq)"
# 셸 모드 감지: 설치된 스크립트의 shebang 으로 판별
_detect_shell_mode() {
  local sdd="$TARGET/.harness-kit/bin/sdd"
  if [ -f "$sdd" ] && head -1 "$sdd" | grep -q 'zsh'; then
    echo "zsh"
  else
    echo "bash"
  fi
}
INSTALLED_SHELL="$(_detect_shell_mode)"

if [ "$INSTALLED_SHELL" = "zsh" ]; then
  if command -v zsh >/dev/null; then
    zv=$(zsh --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    check_pass "zsh $zv (zsh 모드로 설치됨)"
  else
    check_fail "zsh 없음 (zsh 모드로 설치되었으나 zsh 를 찾을 수 없음)"
  fi
else
  if command -v bash >/dev/null; then
    bv=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    bv_major="${bv%%.*}"
    if [ "${bv_major:-0}" -ge 4 ]; then
      check_pass "bash $bv"
    else
      check_warn "bash $bv (4.0+ 권장 — brew install bash 또는 --shell=zsh)"
    fi
  else
    check_fail "bash 없음 (--shell=zsh 옵션으로 재설치 권장)"
  fi
fi
echo ""

# ========== 2. 디렉토리 구조 ==========
echo "[2/7] 디렉토리 구조"
# harness.config.json 경로 읽기 (prefix 반영)
_HK_CONFIG="$TARGET/.harness-kit/harness.config.json"
_BACKLOG_DIR="backlog"
_SPECS_DIR="specs"
if [ -f "$_HK_CONFIG" ] && command -v jq >/dev/null; then
  _bd=$(jq -r '.backlogDir // "backlog"' "$_HK_CONFIG" 2>/dev/null)
  _sd=$(jq -r '.specsDir   // "specs"'  "$_HK_CONFIG" 2>/dev/null)
  _BACKLOG_DIR="${_bd:-backlog}"
  _SPECS_DIR="${_sd:-specs}"
fi
for d in .harness-kit .harness-kit/agent .harness-kit/agent/templates .harness-kit/bin .harness-kit/hooks .claude/commands .claude/state "$_BACKLOG_DIR" "$_SPECS_DIR"; do
  if [ -d "$TARGET/$d" ]; then
    check_pass "$d"
  else
    check_fail "$d 없음"
  fi
done
echo ""

# ========== 3. 거버넌스 + 템플릿 ==========
echo "[3/7] 거버넌스 + 템플릿"
for f in .harness-kit/agent/constitution.md .harness-kit/agent/agent.md .harness-kit/agent/align.md; do
  [ -f "$TARGET/$f" ] && check_pass "$f" || check_fail "$f 없음"
done
for f in queue.md phase.md spec.md plan.md task.md walkthrough.md pr_description.md; do
  [ -f "$TARGET/.harness-kit/agent/templates/$f" ] && check_pass ".harness-kit/agent/templates/$f" || check_fail ".harness-kit/agent/templates/$f 없음"
done
echo ""

# ========== 4. Claude Code 통합 ==========
echo "[4/7] Claude Code 통합"
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

# ========== 5. State ==========
echo "[5/7] State"
INSTALLED_JSON="$TARGET/.harness-kit/installed.json"
STATE="$TARGET/.claude/state/current.json"
if [ -f "$INSTALLED_JSON" ]; then
  check_pass ".harness-kit/installed.json 존재"
  if command -v jq >/dev/null; then
    kit_ver=$(jq -r '.kitVersion // "unknown"' "$INSTALLED_JSON")
    echo "  ${C_DIM}kit version: $kit_ver${C_RST}"
  fi
else
  check_fail ".harness-kit/installed.json 없음"
fi
HK_CONFIG_FILE="$TARGET/.harness-kit/harness.config.json"
if [ -f "$HK_CONFIG_FILE" ]; then
  check_pass ".harness-kit/harness.config.json 존재"
  if command -v jq >/dev/null; then
    _cbd=$(jq -r '.backlogDir // "backlog"' "$HK_CONFIG_FILE" 2>/dev/null)
    _csd=$(jq -r '.specsDir   // "specs"'  "$HK_CONFIG_FILE" 2>/dev/null)
    echo "  ${C_DIM}backlogDir: ${_cbd:-backlog}  specsDir: ${_csd:-specs}${C_RST}"
  fi
fi
if [ -f "$STATE" ]; then
  check_pass ".claude/state/current.json 존재"
  if command -v jq >/dev/null; then
    plan_accepted=$(jq -r '.planAccepted // false' "$STATE")
    echo "  ${C_DIM}plan accepted: $plan_accepted${C_RST}"
  fi
else
  check_warn ".claude/state/current.json 없음"
fi
echo ""

# ========== 6. Hook 권한 ==========
echo "[6/7] Hook 권한"
if [ -d "$TARGET/.harness-kit/hooks" ]; then
  hook_count=$(find "$TARGET/.harness-kit/hooks" -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$hook_count" -eq 0 ]; then
    check_warn "hook 스크립트 없음 (--no-hooks 설치 또는 hooks 미완성)"
  else
    for f in "$TARGET/.harness-kit/hooks"/*.sh; do
      if [ -x "$f" ]; then
        check_pass "$(basename "$f") (executable)"
      else
        check_fail "$(basename "$f") 실행 권한 없음 (chmod +x 필요)"
      fi
    done
  fi
else
  check_warn ".harness-kit/hooks/ 없음"
fi
echo ""

# ========== 7. 프로젝트 품질 도구 ==========
echo "[7/7] 프로젝트 품질 도구"

_check_nodejs() {
  local pkg="$TARGET/package.json"
  echo "  ${C_DIM}프로젝트 타입: Node.js (package.json 감지)${C_RST}"

  # test
  if command -v jq >/dev/null 2>&1; then
    local test_script
    test_script=$(jq -r '.scripts.test // ""' "$pkg" 2>/dev/null)
    if [ -n "$test_script" ] && ! echo "$test_script" | grep -qE '(no test|echo .*(Error|test))'; then
      check_pass "test 스크립트 설정됨"
    else
      check_warn "test 스크립트 없음 (npm install --save-dev jest 또는 vitest)"
    fi

    # lint
    local lint_script
    lint_script=$(jq -r '.scripts.lint // ""' "$pkg" 2>/dev/null)
    if [ -n "$lint_script" ]; then
      check_pass "lint 스크립트 설정됨"
    else
      check_warn "lint 스크립트 없음 (npm install --save-dev eslint && npm init @eslint/config)"
    fi
  fi

  # typecheck (tsconfig.json 존재 여부)
  if [ -f "$TARGET/tsconfig.json" ]; then
    check_pass "TypeScript 설정 (tsconfig.json)"
  else
    # TypeScript 가 devDependencies 에 있으면 tsconfig 누락 경고
    if command -v jq >/dev/null 2>&1; then
      local has_ts
      has_ts=$(jq -r '.devDependencies.typescript // .dependencies.typescript // ""' "$pkg" 2>/dev/null)
      if [ -n "$has_ts" ]; then
        check_warn "typescript 설치됨이나 tsconfig.json 없음 (npx tsc --init)"
      fi
    fi
  fi
}

_check_python() {
  echo "  ${C_DIM}프로젝트 타입: Python 감지${C_RST}"

  # test
  if [ -f "$TARGET/pyproject.toml" ] && grep -q '\[tool\.pytest' "$TARGET/pyproject.toml" 2>/dev/null; then
    check_pass "pytest 설정됨"
  elif [ -d "$TARGET/tests" ] || [ -d "$TARGET/test" ]; then
    check_pass "테스트 디렉토리 존재"
  else
    check_warn "테스트 설정 없음 (pip install pytest)"
  fi

  # lint
  if [ -f "$TARGET/.flake8" ] || [ -f "$TARGET/ruff.toml" ] || [ -f "$TARGET/.ruff.toml" ] || \
     ([ -f "$TARGET/pyproject.toml" ] && grep -qE '\[tool\.(ruff|flake8|pylint)\]' "$TARGET/pyproject.toml" 2>/dev/null); then
    check_pass "linter 설정됨"
  else
    check_warn "linter 설정 없음 (pip install ruff)"
  fi

  # type checker
  if [ -f "$TARGET/mypy.ini" ] || [ -f "$TARGET/.mypy.ini" ] || [ -f "$TARGET/pyrightconfig.json" ] || \
     ([ -f "$TARGET/pyproject.toml" ] && grep -qE '\[tool\.(mypy|pyright)\]' "$TARGET/pyproject.toml" 2>/dev/null); then
    check_pass "type checker 설정됨"
  else
    check_warn "type checker 없음 (pip install mypy)"
  fi
}

_check_go() {
  echo "  ${C_DIM}프로젝트 타입: Go (go.mod 감지)${C_RST}"
  check_pass "test (go test 내장)"

  if [ -f "$TARGET/.golangci.yml" ] || [ -f "$TARGET/.golangci.yaml" ] || [ -f "$TARGET/.golangci.toml" ]; then
    check_pass "golangci-lint 설정됨"
  else
    check_warn "golangci-lint 설정 없음 (go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest)"
  fi
}

if [ -f "$TARGET/package.json" ]; then
  _check_nodejs
elif [ -f "$TARGET/pyproject.toml" ] || [ -f "$TARGET/setup.py" ]; then
  _check_python
elif [ -f "$TARGET/go.mod" ]; then
  _check_go
else
  check_warn "프로젝트 타입 감지 불가 — lint/test 설정을 직접 확인하세요"
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
