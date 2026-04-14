#!/usr/bin/env bash
# harness-kit updater
#
# 기존 설치 위에 새 키트 버전을 덮어씁니다.
# state / 사용자 산출물(specs/, backlog/)은 보존됩니다.
#
# Usage:
#   ./update.sh                    # 현재 디렉토리 갱신
#   ./update.sh /path/to/project   # 지정 디렉토리 갱신
#   ./update.sh --yes              # 모든 프롬프트 자동 수락
#   ./update.sh --shell=bash       # 셸 재선택 (bash 또는 zsh)
#
# 동작:
#   1. 설치 버전 vs 키트 버전 비교
#   2. 해당 구간 마이그레이션 실행 (폐기 파일 제거 + 신규 기능 안내)
#   3. 구버전 백업 디렉토리 정리 안내
#   4. install.sh --yes 호출 (state 보존 후 복원)
#   5. doctor.sh 실행

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================
# 색상
# ============================================================
if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'
  C_CYN=$'\033[36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_CYN=""; C_DIM=""; C_RST=""
fi
log()  { echo "${C_CYN}[update]${C_RST} $*"; }
ok()   { echo "${C_GRN}✓${C_RST} $*"; }
warn() { echo "${C_YLW}⚠${C_RST} $*" >&2; }
err()  { echo "${C_RED}✗${C_RST} $*" >&2; }
die()  { err "$*"; exit 1; }

# ============================================================
# 인자 파싱
# ============================================================
TARGET=""
ASSUME_YES=0
SHELL_ARG=""

for arg in "$@"; do
  case "$arg" in
    --yes|-y)  ASSUME_YES=1 ;;
    --shell=*) SHELL_ARG="$arg" ;;
    -h|--help)
      sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
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
# 설치 확인 및 버전 감지
# ============================================================
# v0.4+: .harness-kit/installed.json
# v0.3 : .claude/state/current.json (old layout)
INSTALLED_JSON="$TARGET/.harness-kit/installed.json"
STATE_FILE="$TARGET/.claude/state/current.json"

OLD_LAYOUT=0
if [ -f "$INSTALLED_JSON" ]; then
  VERSION_SOURCE="$INSTALLED_JSON"
elif [ -f "$STATE_FILE" ] && [ -d "$TARGET/agent" ]; then
  # v0.3 old-layout 감지
  VERSION_SOURCE="$STATE_FILE"
  OLD_LAYOUT=1
elif [ -f "$STATE_FILE" ]; then
  VERSION_SOURCE="$STATE_FILE"
else
  err "$TARGET 에 harness-kit 이 설치되어 있지 않습니다."
  echo "  최초 설치: $KIT_DIR/install.sh $TARGET"
  exit 1
fi

# ============================================================
# 버전 비교 유틸
# ============================================================
# X.Y.Z → 정수 (비교용)
_ver_num() {
  echo "$1" | awk -F. '{ printf "%d%03d%03d", $1, $2, $3 }'
}
# $1 > $2 이면 true
_ver_gt() { [ "$(_ver_num "$1")" -gt "$(_ver_num "$2")" ]; }
# $1 <= $2 이면 true
_ver_lte() { [ "$(_ver_num "$1")" -le "$(_ver_num "$2")" ]; }

# ============================================================
# 버전 읽기
# ============================================================
PREV_VER=$(jq -r '.kitVersion // "0.0.0"' "$VERSION_SOURCE")
NEW_VER=$(cat "$KIT_DIR/VERSION")

echo ""
log "버전: ${C_YLW}${PREV_VER}${C_RST} → ${C_GRN}${NEW_VER}${C_RST}"
echo ""

if [ "$PREV_VER" = "$NEW_VER" ]; then
  warn "이미 ${NEW_VER} 입니다. 재설치를 진행합니다."
fi

# 다운그레이드 경고
if _ver_gt "$PREV_VER" "$NEW_VER"; then
  warn "다운그레이드: ${PREV_VER} → ${NEW_VER}"
  if [ "$ASSUME_YES" = "0" ]; then
    printf "  계속 진행할까요? [y/N] "
    read -r _ans < /dev/tty 2>/dev/null || _ans=""
    case "$_ans" in y|Y) ;; *) log "취소됨"; exit 0 ;; esac
  fi
fi

# ============================================================
# v0.3 → v0.4 레이아웃 마이그레이션 (old-layout 감지 시)
# ============================================================
if [ "$OLD_LAYOUT" = "1" ]; then
  echo ""
  warn "v0.3 레이아웃 감지 (agent/, scripts/harness/) — v0.4 (.harness-kit/) 로 마이그레이션합니다."
  echo ""
  echo "  변경 내용:"
  echo "    agent/          → .harness-kit/agent/"
  echo "    scripts/harness/ → .harness-kit/ (bin/, hooks/)"
  echo ""

  if [ "$ASSUME_YES" = "0" ]; then
    printf "  계속 진행할까요? [y/N] "
    read -r _ans < /dev/tty 2>/dev/null || _ans=""
    case "$_ans" in y|Y) ;; *) log "취소됨"; exit 0 ;; esac
  fi

  # 백업
  TS="$(date +%Y%m%d-%H%M%S)"
  BACKUP="$TARGET/.harness-backup-${TS}"
  mkdir -p "$BACKUP"
  [ -d "$TARGET/agent" ]           && cp -rf "$TARGET/agent"           "$BACKUP/"
  [ -d "$TARGET/scripts/harness" ] && cp -rf "$TARGET/scripts/harness" "$BACKUP/scripts-harness"
  ok "백업 완료: $BACKUP"

  # .harness-kit/ 생성
  mkdir -p "$TARGET/.harness-kit"

  # agent/ 이동
  if [ -d "$TARGET/agent" ]; then
    mv "$TARGET/agent" "$TARGET/.harness-kit/agent"
    ok "agent/ → .harness-kit/agent/"
  fi

  # scripts/harness/ 이동
  if [ -d "$TARGET/scripts/harness/bin" ]; then
    mv "$TARGET/scripts/harness/bin" "$TARGET/.harness-kit/bin"
    ok "scripts/harness/bin/ → .harness-kit/bin/"
  fi
  if [ -d "$TARGET/scripts/harness/hooks" ]; then
    mv "$TARGET/scripts/harness/hooks" "$TARGET/.harness-kit/hooks"
    ok "scripts/harness/hooks/ → .harness-kit/hooks/"
  fi
  if [ -d "$TARGET/scripts/harness/lib" ]; then
    mv "$TARGET/scripts/harness/lib" "$TARGET/.harness-kit/lib"
    ok "scripts/harness/lib/ → .harness-kit/lib/"
  fi
  # 빈 디렉토리 정리
  rmdir "$TARGET/scripts/harness" 2>/dev/null || true
  rmdir "$TARGET/scripts" 2>/dev/null || true

  # settings.json hook 경로 패치 (scripts/harness/hooks/ → .harness-kit/hooks/)
  SETTINGS="$TARGET/.claude/settings.json"
  if [ -f "$SETTINGS" ] && command -v jq >/dev/null 2>&1; then
    _tmp="$(mktemp)"
    # hooks 내 command 값에서 경로 치환
    jq '
      if .hooks then
        .hooks |= (
          to_entries | map(
            .value |= map(
              if .hooks then
                .hooks |= map(
                  if .command and (.command | test("scripts/harness/")) then
                    .command |= gsub("scripts/harness/hooks/"; ".harness-kit/hooks/")
                              | gsub("scripts/harness/bin/"; ".harness-kit/bin/")
                  else . end
                )
              else . end
            )
          ) | from_entries
        )
      else . end
    ' "$SETTINGS" > "$_tmp"
    mv "$_tmp" "$SETTINGS"
    ok "settings.json hook 경로 패치"
  fi

  # .gitignore 업데이트
  GI="$TARGET/.gitignore"
  touch "$GI"
  if ! grep -q '# harness-kit' "$GI"; then
    { echo ""; echo "# harness-kit"; echo "!.harness-kit/"; echo ".harness-backup-*/"; echo ".claude/state/"; } >> "$GI"
  elif ! grep -q '^!\.harness-kit/' "$GI"; then
    echo "!.harness-kit/" >> "$GI"
  fi
  ok ".gitignore 업데이트"

  # installed.json 임시 작성 (install.sh 가 덮어씀)
  cat > "$TARGET/.harness-kit/installed.json" <<EOF
{"kitVersion": "$PREV_VER", "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
EOF

  echo ""
  ok "v0.3 → v0.4 레이아웃 마이그레이션 완료"
  echo ""

  # 이후 버전 소스를 새 경로로 전환
  VERSION_SOURCE="$INSTALLED_JSON"
fi

# ============================================================
# 마이그레이션 실행
# ============================================================
MIG_DIR="$KIT_DIR/sources/migrations"
MIG_COUNT=0

if [ -d "$MIG_DIR" ]; then
  # 버전 순 정렬 실행
  for mig in $(ls "$MIG_DIR"/*.sh 2>/dev/null | sort -V); do
    mig_ver="$(basename "$mig" .sh)"

    # 이 마이그레이션이 prev < mig_ver <= new_ver 구간에 해당하는지 확인
    if _ver_gt "$mig_ver" "$PREV_VER" && _ver_lte "$mig_ver" "$NEW_VER"; then
      log "마이그레이션 적용: ${C_CYN}${mig_ver}${C_RST}"

      # 함수 정의 로드
      # shellcheck source=/dev/null
      source "$mig"

      # ── 폐기 파일 제거 ──────────────────────────────────
      REMOVED=0
      SKIPPED=0
      while IFS= read -r rel_path; do
        [ -z "$rel_path" ] && continue
        full_path="$TARGET/$rel_path"
        [ -f "$full_path" ] || continue

        if [ "$ASSUME_YES" = "1" ]; then
          rm -f "$full_path"
          echo "  ${C_DIM}[삭제]${C_RST} $rel_path"
          REMOVED=$((REMOVED + 1))
        else
          printf "  삭제: ${C_YLW}%-50s${C_RST} [Y/n] " "$rel_path"
          read -r _ans < /dev/tty 2>/dev/null || _ans=""
          case "$_ans" in
            n|N)
              echo "  ${C_DIM}[건너뜀]${C_RST} $rel_path"
              SKIPPED=$((SKIPPED + 1))
              ;;
            *)
              rm -f "$full_path"
              REMOVED=$((REMOVED + 1))
              ;;
          esac
        fi
      done < <(migration_cleanup)

      if [ "$REMOVED" -gt 0 ] || [ "$SKIPPED" -gt 0 ]; then
        ok "폐기 파일: ${REMOVED}개 삭제, ${SKIPPED}개 유지"
      else
        echo "  ${C_DIM}(폐기 파일 없음)${C_RST}"
      fi

      # ── 신규 기능 안내 ──────────────────────────────────
      echo ""
      echo "${C_CYN}━━ v${mig_ver} 신규 기능 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
      migration_new_features
      echo "${C_CYN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"

      MIG_COUNT=$((MIG_COUNT + 1))

      # 함수 정의 언로드 (다음 마이그레이션과 충돌 방지)
      unset -f migration_cleanup migration_new_features 2>/dev/null || true
    fi
  done
fi

# ============================================================
# 구버전 백업 디렉토리 정리
# ============================================================
BACKUP_DIRS=()
while IFS= read -r -d '' d; do
  BACKUP_DIRS+=("$d")
done < <(find "$TARGET" -maxdepth 1 -name '.harness-backup-*' -type d -print0 2>/dev/null)

if [ "${#BACKUP_DIRS[@]}" -gt 0 ]; then
  echo ""
  warn "구버전 백업 디렉토리 ${#BACKUP_DIRS[@]}개 발견:"
  for d in "${BACKUP_DIRS[@]}"; do
    echo "  ${C_DIM}$(basename "$d")${C_RST}"
  done
  echo "  (백업 역할은 git history 가 대체합니다. 삭제 권장)"

  if [ "$ASSUME_YES" = "1" ]; then
    rm -rf "${BACKUP_DIRS[@]}"
    ok "백업 디렉토리 삭제 완료"
  else
    printf "  모두 삭제할까요? [y/N] "
    read -r _ans < /dev/tty 2>/dev/null || _ans=""
    case "$_ans" in
      y|Y)
        rm -rf "${BACKUP_DIRS[@]}"
        ok "백업 디렉토리 삭제 완료"
        ;;
      *)
        echo "  ${C_DIM}(건너뜀)${C_RST}"
        ;;
    esac
  fi
fi

# ============================================================
# 현재 state 보존 (install.sh 가 덮어쓰므로 미리 저장)
# ============================================================
SAVED_PHASE=$(jq -r '.phase // "null"'        "$STATE_FILE" 2>/dev/null || echo "null")
SAVED_SPEC=$(jq -r  '.spec // "null"'         "$STATE_FILE" 2>/dev/null || echo "null")
SAVED_PLAN=$(jq -r  '.planAccepted // false'  "$STATE_FILE" 2>/dev/null || echo "false")
SAVED_TEST=$(jq -r  '.lastTestPass // "null"' "$STATE_FILE" 2>/dev/null || echo "null")

# ============================================================
# install.sh 실행
# ============================================================
echo ""
log "파일 설치 중..."
"$KIT_DIR/install.sh" --yes $SHELL_ARG "$TARGET"

# ============================================================
# state 복원 (phase / spec / planAccepted / lastTestPass)
# ============================================================
if command -v jq >/dev/null 2>&1 && [ -f "$STATE_FILE" ]; then
  _tmp="$(mktemp)"
  jq \
    --argjson phase        "$([ "$SAVED_PHASE" = "null" ] && echo 'null' || echo "\"$SAVED_PHASE\"")" \
    --argjson spec         "$([ "$SAVED_SPEC"  = "null" ] && echo 'null' || echo "\"$SAVED_SPEC\"")"  \
    --argjson planAccepted "$SAVED_PLAN" \
    --argjson lastTestPass "$([ "$SAVED_TEST"  = "null" ] && echo 'null' || echo "\"$SAVED_TEST\"")"  \
    '.phase = $phase | .spec = $spec | .planAccepted = $planAccepted | .lastTestPass = $lastTestPass' \
    "$STATE_FILE" > "$_tmp"
  mv "$_tmp" "$STATE_FILE"
  ok "state 복원 완료 (phase=${SAVED_PHASE}, spec=${SAVED_SPEC})"
fi

# ============================================================
# doctor 점검
# ============================================================
echo ""
log "doctor 점검"
"$KIT_DIR/doctor.sh" "$TARGET" || true

# ============================================================
# 완료
# ============================================================
echo ""
echo "${C_GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
echo "${C_GRN}업데이트 완료: ${PREV_VER} → ${NEW_VER}${C_RST}"
[ "$MIG_COUNT" -gt 0 ] && echo "  마이그레이션 ${MIG_COUNT}건 적용"
echo ""
echo "  CHANGELOG: $KIT_DIR/CHANGELOG.md"
echo "${C_GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
echo ""
