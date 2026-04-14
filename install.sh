#!/usr/bin/env bash
# harness-kit installer
#
# 대상 환경 (Target Platform):
#   - macOS (1차 타깃, Sonoma+ / Apple Silicon & Intel)
#   - Linux (best-effort, 미검증)
#   - Windows: WSL2 안에서만, 그 외 미지원
# AI 호스트:
#   - Claude Code 전용 (.claude/ 구조 + slash commands + hooks 의존)
#
# Usage:
#   ./install.sh                       # 현재 디렉토리에 설치
#   ./install.sh /path/to/project      # 지정 디렉토리에 설치
#   ./install.sh --dry-run             # 실제 변경 없이 계획만 출력
#   ./install.sh --force               # 확인 프롬프트 없이 진행
#   ./install.sh --no-hooks            # hooks 설치 생략
#   ./install.sh --shell=zsh           # 셸 선택 프롬프트 스킵, zsh 로 강제 (CI/자동화용)
#   ./install.sh --yes                 # 모든 프롬프트 생략 (셸은 환경에 맞게 자동 선택)
#
# 필수 의존성 (macOS 기준 — brew install ...):
#   bash 4.0+ (또는 --shell=zsh 사용 시 macOS 기본 zsh), jq, git

set -euo pipefail

# ============================================================
# 0. 색상 / 로그
# ============================================================
if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'
  C_BLU=$'\033[34m'; C_CYN=$'\033[36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_BLU=""; C_CYN=""; C_DIM=""; C_RST=""
fi

log()  { echo "${C_CYN}[harness-kit]${C_RST} $*"; }
ok()   { echo "${C_GRN}✓${C_RST} $*"; }
warn() { echo "${C_YLW}⚠${C_RST} $*" >&2; }
err()  { echo "${C_RED}✗${C_RST} $*" >&2; }
die()  { err "$*"; exit 1; }

# ============================================================
# 1. 인자 파싱
# ============================================================
TARGET=""
DRY_RUN=0
FORCE=0
NO_HOOKS=0
ASSUME_YES=0
SHELL_MODE=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    --no-hooks) NO_HOOKS=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    --shell=*) SHELL_MODE="${arg#--shell=}" ;;
    -h|--help)
      sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      die "알 수 없는 옵션: $arg"
      ;;
    *)
      [ -z "$TARGET" ] || die "대상 디렉토리는 하나만 지정 가능"
      TARGET="$arg"
      ;;
  esac
done

[ -z "$TARGET" ] && TARGET="$(pwd)"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || die "대상 디렉토리가 존재하지 않음"

# ============================================================
# 2. 키트 위치 (이 스크립트가 있는 디렉토리)
# ============================================================
# bash/zsh 호환 자기 위치 탐지
_self() { if [ -n "${BASH_VERSION:-}" ]; then echo "${BASH_SOURCE[0]}"; elif [ -n "${ZSH_VERSION:-}" ]; then echo "${(%):-%x}"; else echo "$0"; fi; }
KIT_DIR="$(cd "$(dirname "$(_self)")" && pwd)"
[ -d "$KIT_DIR/sources" ] || die "키트 sources/ 디렉토리를 찾을 수 없음 (KIT_DIR=$KIT_DIR)"

KIT_VERSION="$(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "unknown")"

# ============================================================
# 3. 사전 점검
# ============================================================
log "harness-kit v${KIT_VERSION}"
log "키트 위치: $KIT_DIR"
log "대상 위치: $TARGET"

if ! command -v jq >/dev/null 2>&1; then
  die "jq 가 필요합니다. macOS: brew install jq / Linux: apt install jq"
fi

# OS 안내 (1차 타깃 = macOS)
case "$(uname -s)" in
  Darwin) ;;  # 1차 타깃, 메시지 없음
  Linux)  warn "Linux 환경: best-effort 지원 (1차 타깃은 macOS). 동작 이상 발견 시 보고 부탁." ;;
  *)      warn "비표준 OS ($(uname -s)): 동작이 보장되지 않습니다." ;;
esac

# 셸 선택 (--shell 미지정 시 대화형 프롬프트)
if [ -z "$SHELL_MODE" ]; then
  # 환경 감지
  _bash_ver=""
  _bash_ok=0
  if command -v bash >/dev/null 2>&1; then
    _bash_ver=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    _bash_major="${_bash_ver%%.*}"
    [ "${_bash_major:-0}" -ge 4 ] && _bash_ok=1
  fi
  _has_zsh=0
  _zsh_ver=""
  if command -v zsh >/dev/null 2>&1; then
    _has_zsh=1
    _zsh_ver=$(zsh --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
  fi

  case "$(uname -s)" in
    Darwin)
      if [ $_has_zsh -eq 1 ]; then
        # macOS: zsh 가 있으면 선택 프롬프트
        echo ""
        echo "${C_CYN}🐚 스크립트 셸 선택${C_RST}"
        echo ""
        if [ $_bash_ok -eq 1 ]; then
          echo "  1) zsh  ${C_DIM}(macOS 기본, 추가 설치 불필요)${C_RST}"
          echo "  2) bash ${C_DIM}(${_bash_ver})${C_RST}"
          _default=1
        else
          echo "  1) zsh  ${C_GRN}← 권장${C_RST} ${C_DIM}(macOS 기본, 추가 설치 불필요)${C_RST}"
          echo "  2) bash ${C_DIM}(${_bash_ver:-없음}${_bash_ver:+ — 4.0+ 필요, brew install bash})${C_RST}"
          _default=1
        fi
        echo ""
        if [ $ASSUME_YES -eq 1 ]; then
          _choice=$_default
        else
          printf "  선택 [${_default}]: "
          read -r _choice < /dev/tty 2>/dev/null || _choice=""
          [ -z "$_choice" ] && _choice=$_default
        fi
        case "$_choice" in
          1) SHELL_MODE="zsh" ;;
          2) SHELL_MODE="bash" ;;
          *) SHELL_MODE="zsh" ;;
        esac
      else
        SHELL_MODE="bash"
      fi
      ;;
    *)
      # Linux 등: bash 가 보통 최신이므로 프롬프트 스킵
      SHELL_MODE="bash"
      ;;
  esac
fi
log "셸 모드: ${C_GRN}${SHELL_MODE}${C_RST}"

if [ ! -d "$TARGET/.git" ]; then
  warn "$TARGET 는 git 리포지토리가 아닙니다. 계속 진행하지만 권장하지 않습니다."
fi

# ============================================================
# 4. 설치 계획 출력
# ============================================================
cat <<EOF

${C_BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}
${C_BLU}설치 계획${C_RST}
${C_BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}

생성/복사할 디렉토리:
  - .harness-kit/agent/                 (governance + templates)
  - .harness-kit/bin/                   (sdd 메타 명령)
  - .harness-kit/hooks/                 (hook 스크립트)
  - .claude/commands/                   (slash commands)
  - .claude/state/                      (런타임 state, gitignore)
  - backlog/                            (phase 정의 = todo list)
  - specs/                              (실제 spec 작업 = work log)

생성할 파일:
  - .harness-kit/installed.json         (설치 버전 기록)

머지/추가할 파일:
  - .claude/settings.json               (jq 머지)
  - CLAUDE.md                           (HARNESS-KIT 블록 추가)
  - .gitignore                          (!.harness-kit/ un-ignore 추가)

셸: $SHELL_MODE
모드: $([ $DRY_RUN -eq 1 ] && echo 'DRY RUN (실제 변경 없음)' || echo '실제 설치')
Hooks: $([ $NO_HOOKS -eq 1 ] && echo '설치 안 함' || echo '설치')

EOF

if [ $ASSUME_YES -eq 0 ] && [ $DRY_RUN -eq 0 ]; then
  read -r -p "진행할까요? [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) log "취소됨"; exit 0 ;;
  esac
fi

# ============================================================
# 6. 헬퍼: do (DRY_RUN 분기)
# ============================================================
do_run() {
  if [ $DRY_RUN -eq 1 ]; then
    echo "${C_DIM}[dry-run]${C_RST} $*"
  else
    eval "$@"
  fi
}

do_mkdir() { do_run "mkdir -p '$1'"; }
do_cp()    { do_run "cp -f '$1' '$2'"; }
do_cp_r()  { do_run "cp -rf '$1' '$2'"; }

# shebang 교체: --shell=zsh 일 때 #!/usr/bin/env bash → #!/usr/bin/env zsh
do_fix_shebang() {
  local file="$1"
  if [ "$SHELL_MODE" = "zsh" ] && [ $DRY_RUN -eq 0 ]; then
    sed -i.tmp '1s|#!/usr/bin/env bash|#!/usr/bin/env zsh|' "$file"
    rm -f "${file}.tmp"
  fi
}

# ============================================================
# 7. (백업 제거됨 — git history 가 보호하므로 불필요)
# ============================================================

# ============================================================
# 8. 디렉토리 생성
# ============================================================
log "디렉토리 생성"
do_mkdir "$TARGET/.harness-kit/agent/templates"
do_mkdir "$TARGET/.harness-kit/bin/lib"
do_mkdir "$TARGET/.harness-kit/hooks"
do_mkdir "$TARGET/.harness-kit/lib"
do_mkdir "$TARGET/.claude/commands"
do_mkdir "$TARGET/.claude/state"
do_mkdir "$TARGET/backlog"
do_mkdir "$TARGET/specs"

# ============================================================
# 9. 거버넌스 + 템플릿 복사
# ============================================================
log "거버넌스 복사"
for f in constitution.md agent.md align.md; do
  do_cp "$KIT_DIR/sources/governance/$f" "$TARGET/.harness-kit/agent/$f"
done

log "템플릿 복사"
for f in queue.md phase.md spec.md plan.md task.md walkthrough.md pr_description.md; do
  do_cp "$KIT_DIR/sources/templates/$f" "$TARGET/.harness-kit/agent/templates/$f"
done

# ============================================================
# 10. 슬래시 커맨드 복사
# ============================================================
if [ -d "$KIT_DIR/sources/commands" ]; then
  cmd_count=$(find "$KIT_DIR/sources/commands" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$cmd_count" -gt 0 ]; then
    log "슬래시 커맨드 복사 ($cmd_count 개)"
    for f in "$KIT_DIR/sources/commands"/*.md; do
      [ -e "$f" ] || continue
      do_cp "$f" "$TARGET/.claude/commands/$(basename "$f")"
    done
  else
    warn "슬래시 커맨드 source 가 비어있음 (Phase 3 미완)"
  fi
fi

# ============================================================
# 11. Hook 복사
# ============================================================
if [ $NO_HOOKS -eq 0 ] && [ -d "$KIT_DIR/sources/hooks" ]; then
  hook_count=$(find "$KIT_DIR/sources/hooks" -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$hook_count" -gt 0 ]; then
    log "Hook 스크립트 복사 ($hook_count 개)"
    for f in "$KIT_DIR/sources/hooks"/*.sh; do
      [ -e "$f" ] || continue
      _hf="$TARGET/.harness-kit/hooks/$(basename "$f")"
      do_cp "$f" "$_hf"
      do_fix_shebang "$_hf"
      do_run "chmod +x '$_hf'"
    done
  else
    warn "Hook source 가 비어있음 (Phase 3 미완)"
  fi
fi

# ============================================================
# 12. bin 복사
# ============================================================
if [ -d "$KIT_DIR/sources/bin" ]; then
  log "bin/ 복사"
  do_cp_r "$KIT_DIR/sources/bin/." "$TARGET/.harness-kit/bin/"
  if [ $DRY_RUN -eq 0 ]; then
    for bf in "$TARGET/.harness-kit/bin/sdd" "$TARGET/.harness-kit/bin/bb-pr"; do
      if [ -f "$bf" ]; then
        do_fix_shebang "$bf"
        chmod +x "$bf" 2>/dev/null || true
      fi
    done
    # lib/ 내 .sh 파일도 shebang 교체
    for lf in "$TARGET/.harness-kit/bin/lib"/*.sh; do
      [ -f "$lf" ] && do_fix_shebang "$lf"
    done
  fi
fi

# ============================================================
# 13. .claude/settings.json 머지
# ============================================================
log ".claude/settings.json 머지"
SETTINGS="$TARGET/.claude/settings.json"
FRAGMENT="$KIT_DIR/sources/claude-fragments/settings.json.fragment"

if [ $DRY_RUN -eq 1 ]; then
  echo "${C_DIM}[dry-run]${C_RST} jq merge $FRAGMENT into $SETTINGS"
else
  if [ -f "$SETTINGS" ]; then
    # 머지 전략 (사용자 친화):
    #   - permissions.allow / permissions.deny / permissions.ask : 합집합 (union)
    #   - hooks                                                   : 키트가 권위 (덮어쓰기)
    #   - 그 외 사용자 키 (env, model, ...)                        : 사용자 보존
    #
    # 사용자가 hook 을 직접 추가하고 싶다면:
    #   1) sources/claude-fragments/settings.json.fragment 를 직접 수정 (키트 PR)
    #   2) install 후 .claude/settings.json 을 직접 수정 (단, update.sh 가 덮어씀)
    tmp="$(mktemp)"
    jq -s '
      .[0] as $user | .[1] as $kit |
      $user
      | .permissions = (
          ($user.permissions // {})
          | .allow = (((.allow // []) + ($kit.permissions.allow // [])) | unique)
          | (if $kit.permissions.deny then
               .deny = (((.deny // []) + $kit.permissions.deny) | unique)
             else . end)
          | (if $kit.permissions.ask then
               .ask = (((.ask // []) + $kit.permissions.ask) | unique)
             else . end)
        )
      | .hooks = ($kit.hooks // $user.hooks)
    ' "$SETTINGS" "$FRAGMENT" > "$tmp"
    mv "$tmp" "$SETTINGS"
  else
    cp "$FRAGMENT" "$SETTINGS"
  fi
  ok "settings.json 머지 완료"
fi

# ============================================================
# 15. CLAUDE.md 에 fragment append (멱등)
# ============================================================
log "CLAUDE.md 갱신"
CLAUDE_MD="$TARGET/CLAUDE.md"
CLAUDE_FRAGMENT="$KIT_DIR/sources/claude-fragments/CLAUDE.md.fragment"

if [ $DRY_RUN -eq 1 ]; then
  echo "${C_DIM}[dry-run]${C_RST} append CLAUDE.md.fragment to $CLAUDE_MD"
else
  if [ -f "$CLAUDE_MD" ]; then
    # 마커 검출은 라인 시작의 HTML 주석으로 엄격히 매치한다.
    # (본문에서 마커 문자열을 인용·설명할 수 있으므로 substring 매치는 위험)
    if grep -qE '^<!-- HARNESS-KIT:BEGIN' "$CLAUDE_MD"; then
      log "기존 HARNESS-KIT 블록 발견 → 갱신"
      tmp="$(mktemp)"
      # 1) 기존 블록 strip
      # 2) trailing blank line 제거 (재실행 시마다 빈 줄이 누적되는 것을 방지).
      #    blank 카운터를 버퍼링하다 비-blank 라인 직전에만 flush, EOF 시 discard.
      awk '
        /^<!-- HARNESS-KIT:BEGIN/ { skip=1 }
        !skip { print }
        /^<!-- HARNESS-KIT:END/   { skip=0; next }
      ' "$CLAUDE_MD" | awk '
        /[^[:space:]]/ { for (i=1; i<=blanks; i++) print ""; blanks=0; print; next }
        { blanks++ }
      ' > "$tmp"
      mv "$tmp" "$CLAUDE_MD"
    fi
    printf "\n" >> "$CLAUDE_MD"
    cat "$CLAUDE_FRAGMENT" >> "$CLAUDE_MD"
  else
    cat "$CLAUDE_FRAGMENT" > "$CLAUDE_MD"
  fi
  ok "CLAUDE.md 갱신 완료"
fi

# ============================================================
# 16. .gitignore 업데이트
# ============================================================
log ".gitignore 갱신"
GI="$TARGET/.gitignore"
if [ $DRY_RUN -eq 1 ]; then
  echo "${C_DIM}[dry-run]${C_RST} .gitignore 에 harness-kit 항목 추가"
else
  touch "$GI"
  # harness-kit 섹션이 없으면 추가
  if ! grep -q '# harness-kit' "$GI"; then
    {
      echo ""
      echo "# harness-kit"
      echo "!.harness-kit/"
      echo ".harness-backup-*/"
      echo ".claude/state/"
    } >> "$GI"
  fi
  ok ".gitignore 갱신"
fi

# ============================================================
# 17. State 파일 초기화
# ============================================================
log "installed.json 작성"
INSTALLED_JSON="$TARGET/.harness-kit/installed.json"
if [ $DRY_RUN -eq 1 ]; then
  echo "${C_DIM}[dry-run]${C_RST} write $INSTALLED_JSON"
else
  cat > "$INSTALLED_JSON" <<EOF
{
  "kitVersion": "$KIT_VERSION",
  "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
  ok "installed.json 작성 완료"
fi

log "초기 state 파일 작성"
STATE_FILE="$TARGET/.claude/state/current.json"
if [ $DRY_RUN -eq 1 ]; then
  echo "${C_DIM}[dry-run]${C_RST} write $STATE_FILE"
else
  cat > "$STATE_FILE" <<EOF
{
  "kitVersion": "$KIT_VERSION",
  "phase": null,
  "spec": null,
  "branch": null,
  "planAccepted": false,
  "lastTestPass": null,
  "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
fi

# ============================================================
# 18. 결과 출력
# ============================================================
cat <<EOF

${C_GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}
${C_GRN}설치 완료${C_RST}
${C_GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}

대상: $TARGET
키트 버전: $KIT_VERSION

다음 단계:
  1) cd $TARGET
  2) ${C_CYN}bash .harness-kit/bin/sdd status${C_RST}    # 상태 확인
  3) Claude Code 새 세션에서 ${C_CYN}/hk-align${C_RST} 호출
  4) 첫 PHASE / SPEC 만들기

문제가 생기면:
  - ${C_CYN}./scripts/harness/doctor.sh${C_RST}  (점검)
  - 제거: ${C_CYN}$KIT_DIR/uninstall.sh $TARGET${C_RST}

EOF
