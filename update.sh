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
# 설치 확인
# ============================================================
STATE_FILE="$TARGET/.claude/state/current.json"
if [ ! -f "$STATE_FILE" ]; then
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
PREV_VER=$(jq -r '.kitVersion // "0.0.0"' "$STATE_FILE")
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
SAVED_PHASE=$(jq -r '.phase'          "$STATE_FILE")
SAVED_SPEC=$(jq -r  '.spec'           "$STATE_FILE")
SAVED_PLAN=$(jq -r  '.planAccepted'   "$STATE_FILE")
SAVED_TEST=$(jq -r  '.lastTestPass'   "$STATE_FILE")
SAVED_STACK=$(jq -r '.stack // ""'    "$STATE_FILE")

# ============================================================
# install.sh 실행
# ============================================================
STACK_ARG=""
if [ -n "$SAVED_STACK" ] && [ "$SAVED_STACK" != "null" ]; then
  STACK_ARG="--stack=$SAVED_STACK"
fi

echo ""
log "파일 설치 중..."
"$KIT_DIR/install.sh" --yes $STACK_ARG $SHELL_ARG "$TARGET"

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
