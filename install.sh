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
#   ./install.sh --force               # 기존 파일 백업 없이 덮어쓰기
#   ./install.sh --stack=nodejs        # 스택 자동 감지 무시하고 강제 지정 (nodejs|generic)
#   ./install.sh --no-hooks            # hooks 설치 생략
#   ./install.sh --no-backup           # 백업 생성 생략
#   ./install.sh --yes                 # 확인 프롬프트 생략
#
# 필수 의존성 (macOS 기준 — brew install ...):
#   bash 4.0+, jq, git

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
NO_BACKUP=0
ASSUME_YES=0
FORCE_STACK=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    --no-hooks) NO_HOOKS=1 ;;
    --no-backup) NO_BACKUP=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    --stack=*) FORCE_STACK="${arg#--stack=}" ;;
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
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -d "$KIT_DIR/sources" ] || die "키트 sources/ 디렉토리를 찾을 수 없음 (KIT_DIR=$KIT_DIR)"
[ -d "$KIT_DIR/stacks" ]  || die "키트 stacks/ 디렉토리를 찾을 수 없음"

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

# bash 버전 (macOS 기본 bash 3.2 는 일부 문법 미지원 — Homebrew bash 권장)
bash_major="${BASH_VERSION%%.*}"
if [ "${bash_major:-0}" -lt 4 ]; then
  warn "bash $BASH_VERSION 사용 중. macOS 기본 bash 는 3.2 라 일부 기능에 문제 가능."
  warn "  권장: brew install bash"
fi

if [ ! -d "$TARGET/.git" ]; then
  warn "$TARGET 는 git 리포지토리가 아닙니다. 계속 진행하지만 권장하지 않습니다."
fi

# ============================================================
# 4. 스택 감지
# ============================================================
detect_stack() {
  if [ -n "$FORCE_STACK" ]; then
    echo "$FORCE_STACK"; return
  fi
  # NestJS, Next.js, Vite, Bun 등 모든 JS/TS 프로젝트는 nodejs 어댑터로.
  # 어댑터 내부에서 패키지 매니저(pnpm/yarn/bun/npm) 를 자동 감지함.
  if [ -f "$TARGET/package.json" ]; then
    echo "nodejs"; return
  fi
  echo "generic"
}

STACK="$(detect_stack)"
STACK_FILE="$KIT_DIR/stacks/${STACK}.sh"
if [ ! -f "$STACK_FILE" ]; then
  warn "스택 어댑터 $STACK 를 찾지 못함. generic 으로 폴백."
  STACK="generic"
  STACK_FILE="$KIT_DIR/stacks/generic.sh"
fi
log "감지된 스택: ${C_GRN}$STACK${C_RST}"

# ============================================================
# 5. 설치 계획 출력
# ============================================================
cat <<EOF

${C_BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}
${C_BLU}설치 계획${C_RST}
${C_BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}

생성/복사할 디렉토리:
  - agent/                              (governance + templates)
  - .claude/commands/                   (slash commands)
  - .claude/state/                      (런타임 state, gitignore)
  - scripts/harness/bin/                (sdd 메타 명령)
  - scripts/harness/hooks/              (hook 스크립트)
  - scripts/harness/lib/                (헬퍼 라이브러리 + stack)
  - backlog/                            (phase 정의 = todo list)
  - specs/                              (실제 spec 작업 = work log)

머지/추가할 파일:
  - .claude/settings.json               (jq 머지)
  - CLAUDE.md                           (HARNESS-KIT 블록 추가)
  - .gitignore                          (.claude/state/ 추가)

스택: $STACK
모드: $([ $DRY_RUN -eq 1 ] && echo 'DRY RUN (실제 변경 없음)' || echo '실제 설치')
백업: $(if [ $FORCE -eq 1 ]; then echo '없음 (--force)'; elif [ $NO_BACKUP -eq 1 ]; then echo '없음 (--no-backup)'; else echo '있음 (.harness-backup-TIMESTAMP/, 최근 3개 유지)'; fi)
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

# ============================================================
# 7. 백업
# ============================================================
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$TARGET/.harness-backup-$TS"

if [ $FORCE -eq 0 ] && [ $NO_BACKUP -eq 0 ] && [ $DRY_RUN -eq 0 ]; then
  needs_backup=0
  for p in agent .claude/commands .claude/settings.json scripts/harness CLAUDE.md; do
    if [ -e "$TARGET/$p" ]; then needs_backup=1; break; fi
  done

  # git-clean 감지: 워킹 트리가 clean이면 백업 스킵 (git history가 보호)
  if [ $needs_backup -eq 1 ] && git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
    if [ -z "$(git -C "$TARGET" status --porcelain 2>/dev/null)" ]; then
      log "git 워킹 트리가 clean → 백업 스킵 (git history 가 보호)"
      needs_backup=0
    fi
  fi

  if [ $needs_backup -eq 1 ]; then
    log "기존 파일 발견 → 백업: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for p in agent .claude scripts/harness CLAUDE.md; do
      [ -e "$TARGET/$p" ] && cp -rf "$TARGET/$p" "$BACKUP_DIR/" 2>/dev/null || true
    done
    ok "백업 완료"

    # 보존 정책: 최근 N개만 유지 (기본 3)
    keep="${HARNESS_BACKUP_KEEP:-3}"
    old_backups=$(ls -dt "$TARGET"/.harness-backup-* 2>/dev/null | tail -n +$((keep + 1)))
    if [ -n "$old_backups" ]; then
      log "백업 보존 정책: 최근 ${keep}개만 유지, 오래된 백업 삭제:"
      echo "$old_backups" | while IFS= read -r d; do
        log "  삭제: $(basename "$d")"
        rm -rf "$d"
      done
      ok "오래된 백업 정리 완료"
    fi
  fi
elif [ $NO_BACKUP -eq 1 ] && [ $DRY_RUN -eq 0 ]; then
  log "백업 스킵 (--no-backup)"
fi

# ============================================================
# 8. 디렉토리 생성
# ============================================================
log "디렉토리 생성"
do_mkdir "$TARGET/agent/templates"
do_mkdir "$TARGET/.claude/commands"
do_mkdir "$TARGET/.claude/state"
do_mkdir "$TARGET/scripts/harness/bin/lib"
do_mkdir "$TARGET/scripts/harness/hooks"
do_mkdir "$TARGET/scripts/harness/lib"
do_mkdir "$TARGET/backlog"
do_mkdir "$TARGET/specs"

# ============================================================
# 9. 거버넌스 + 템플릿 복사
# ============================================================
log "거버넌스 복사"
for f in constitution.md agent.md align.md; do
  do_cp "$KIT_DIR/sources/governance/$f" "$TARGET/agent/$f"
done

log "템플릿 복사"
for f in queue.md phase.md spec.md plan.md task.md walkthrough.md pr_description.md; do
  do_cp "$KIT_DIR/sources/templates/$f" "$TARGET/agent/templates/$f"
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
      do_cp "$f" "$TARGET/scripts/harness/hooks/$(basename "$f")"
      do_run "chmod +x '$TARGET/scripts/harness/hooks/$(basename "$f")'"
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
  do_cp_r "$KIT_DIR/sources/bin/." "$TARGET/scripts/harness/bin/"
  if [ $DRY_RUN -eq 0 ]; then
    [ -f "$TARGET/scripts/harness/bin/sdd" ]   && chmod +x "$TARGET/scripts/harness/bin/sdd"   2>/dev/null || true
    [ -f "$TARGET/scripts/harness/bin/bb-pr" ] && chmod +x "$TARGET/scripts/harness/bin/bb-pr" 2>/dev/null || true
  fi
fi

# ============================================================
# 13. Stack adapter 복사
# ============================================================
log "스택 어댑터 복사: $STACK"
do_cp "$STACK_FILE" "$TARGET/scripts/harness/lib/stack.sh"

# ============================================================
# 14. .claude/settings.json 머지
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
  echo "${C_DIM}[dry-run]${C_RST} .claude/state/ 를 .gitignore 에 추가"
else
  touch "$GI"
  if ! grep -qE '^\.claude/state/' "$GI"; then
    {
      echo ""
      echo "# harness-kit"
      echo ".claude/state/"
      echo ".harness-backup-*/"
    } >> "$GI"
  fi
  ok ".gitignore 갱신"
fi

# ============================================================
# 17. State 파일 초기화
# ============================================================
log "초기 state 파일 작성"
STATE_FILE="$TARGET/.claude/state/current.json"
if [ $DRY_RUN -eq 1 ]; then
  echo "${C_DIM}[dry-run]${C_RST} write $STATE_FILE"
else
  cat > "$STATE_FILE" <<EOF
{
  "kitVersion": "$KIT_VERSION",
  "stack": "$STACK",
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
스택: $STACK

다음 단계:
  1) cd $TARGET
  2) ${C_CYN}./scripts/harness/bin/sdd status${C_RST}    # 상태 확인 (스크립트 완성 후)
  3) Claude Code 새 세션에서 ${C_CYN}/align${C_RST} 호출
  4) 첫 PHASE / SPEC 만들기

문제가 생기면:
  - ${C_CYN}./scripts/harness/doctor.sh${C_RST}  (점검)
  - 백업: $BACKUP_DIR
  - 제거: ${C_CYN}$KIT_DIR/uninstall.sh $TARGET${C_RST}

EOF
