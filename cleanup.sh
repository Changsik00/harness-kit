#!/usr/bin/env bash
# harness-kit versioned migration runner
#
# Usage:
#   ./cleanup.sh --from <ver> --to <ver> [--yes] [TARGET]
#
# Arguments:
#   --from <ver>   업데이트 이전 버전 (예: 0.3.0)
#   --to <ver>     업데이트 이후 버전 (예: 0.4.0)
#   --yes          확인 프롬프트 자동 수락
#   TARGET         대상 디렉토리 (기본값: 현재 디렉토리)
#
# 동작:
#   sources/migrations/*.sh 에서 from < version <= to 범위의 파일을 찾아
#   버전 오름차순으로 정렬 후 각 migration 의 cleanup / new_features 를 실행

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'
  C_CYN=$'\033[36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_CYN=""; C_DIM=""; C_RST=""
fi
log()  { echo "${C_CYN}[cleanup]${C_RST} $*"; }
ok()   { echo "${C_GRN}✓${C_RST} $*"; }
warn() { echo "${C_YLW}⚠${C_RST} $*" >&2; }
err()  { echo "${C_RED}✗${C_RST} $*" >&2; }
die()  { err "$*"; exit 1; }

# ── 인자 파싱 ────────────────────────────────────────────────
FROM_VER=""
TO_VER=""
ASSUME_YES=0
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --yes|-y)   ASSUME_YES=1 ;;
    --from)     ;;  # 다음 인자에서 처리
    --to)       ;;  # 다음 인자에서 처리
    *)          ;;
  esac
done

# positional 인자 파싱 (--from <ver> --to <ver> 형식)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)
      shift
      FROM_VER="${1:-}"
      ;;
    --to)
      shift
      TO_VER="${1:-}"
      ;;
    --yes|-y)
      ASSUME_YES=1
      ;;
    -*)
      die "알 수 없는 옵션: $1"
      ;;
    *)
      TARGET="$1"
      ;;
  esac
  shift
done

[ -n "$FROM_VER" ] || die "--from 버전을 지정해야 합니다"
[ -n "$TO_VER"   ] || die "--to 버전을 지정해야 합니다"

TARGET="${TARGET:-$(pwd)}"
TARGET="$(cd "$TARGET" && pwd)"

MIGRATIONS_DIR="$KIT_DIR/sources/migrations"

# ── semver 비교 함수 ──────────────────────────────────────────
# returns 0 (true) if $1 < $2, 1 (false) otherwise
# macOS 의 sort -V 미지원 → 수동 구현
semver_lt() {
  local IFS=.
  local i
  # shellcheck disable=SC2206
  local a=($1) b=($2)
  for ((i=0; i<3; i++)); do
    local x=${a[i]:-0} y=${b[i]:-0}
    if ((x < y)); then return 0; fi
    if ((x > y)); then return 1; fi
  done
  return 1  # equal → not less than
}

# ── migration 파일 필터링 및 정렬 ──────────────────────────────
# 파일명 형식: <version>.sh (예: 0.4.0.sh)
# 조건: from < version <= to

collect_migrations() {
  local dir="$1"
  local from="$2"
  local to="$3"

  if [ ! -d "$dir" ]; then
    return 0
  fi

  # 버전 목록 수집
  local versions=()
  for f in "$dir"/*.sh; do
    [ -f "$f" ] || continue
    local fname
    fname="$(basename "$f" .sh)"
    # 파일명이 semver 형식인지 간단 확인 (숫자.숫자.숫자)
    if [[ "$fname" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      # from < fname <= to 조건 검사
      if semver_lt "$from" "$fname" && ! semver_lt "$to" "$fname"; then
        versions+=("$fname")
      fi
    fi
  done

  if [ ${#versions[@]} -eq 0 ]; then
    return 0
  fi

  # 버전 오름차순 정렬 (bubble sort — 파일 수가 적으므로 충분)
  local n=${#versions[@]}
  local i j tmp
  for ((i=0; i<n-1; i++)); do
    for ((j=0; j<n-i-1; j++)); do
      if ! semver_lt "${versions[$j]}" "${versions[$((j+1))]}"; then
        # swap
        tmp="${versions[$j]}"
        versions[$j]="${versions[$((j+1))]}"
        versions[$((j+1))]="$tmp"
      fi
    done
  done

  for v in "${versions[@]}"; do
    echo "$v"
  done
}

# ── 메인 ──────────────────────────────────────────────────────
log "대상: $TARGET"
log "버전 범위: $FROM_VER → $TO_VER"

# 빈 범위 (from == to) 또는 역방향 범위 처리
if ! semver_lt "$FROM_VER" "$TO_VER"; then
  log "적용할 migration 없음 (from >= to)"
  exit 0
fi

# 적용 대상 migration 수집
mapfile -t MIGRATIONS < <(collect_migrations "$MIGRATIONS_DIR" "$FROM_VER" "$TO_VER") 2>/dev/null || {
  # mapfile (bash 4+) 미지원 환경 fallback
  MIGRATIONS=()
  while IFS= read -r line; do
    MIGRATIONS+=("$line")
  done < <(collect_migrations "$MIGRATIONS_DIR" "$FROM_VER" "$TO_VER")
}

if [ ${#MIGRATIONS[@]} -eq 0 ]; then
  log "적용할 migration 없음"
  exit 0
fi

log "적용할 migration: ${MIGRATIONS[*]}"

# 확인 프롬프트
if [ "$ASSUME_YES" -eq 0 ]; then
  echo ""
  warn "위 migration 을 실행하면 오래된 파일이 삭제됩니다."
  printf "계속하시겠습니까? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS]) ;;
    *) log "취소됨"; exit 0 ;;
  esac
fi

# 각 migration 실행
for ver in "${MIGRATIONS[@]}"; do
  migration_file="$MIGRATIONS_DIR/${ver}.sh"
  log "migration ${ver} 실행 중..."

  # 함수 이름 충돌 방지를 위해 subshell 에서 source
  # (함수 정의를 가져오기 위해 동일 shell 에서 source 후 호출)
  # 주의: set -e 환경에서 source 오류 방지
  unset -f migration_cleanup 2>/dev/null || true
  unset -f migration_new_features 2>/dev/null || true

  # shellcheck source=/dev/null
  source "$migration_file"

  # migration_cleanup: 삭제 대상 파일 목록 출력
  if declare -f migration_cleanup > /dev/null 2>&1; then
    while IFS= read -r rel_path; do
      rel_path="$(echo "$rel_path" | tr -d '[:space:]')"
      [ -n "$rel_path" ] || continue
      target_file="$TARGET/$rel_path"
      if [ -f "$target_file" ]; then
        rm -f "$target_file"
        ok "삭제: $rel_path"
      else
        echo "${C_DIM}  skip (없음): $rel_path${C_RST}"
      fi
    done < <(migration_cleanup)
  fi

  # migration_new_features: 변경 사항 출력
  if declare -f migration_new_features > /dev/null 2>&1; then
    echo ""
    log "변경 사항 (${ver}):"
    migration_new_features
  fi

  ok "migration ${ver} 완료"
  echo ""
done

ok "모든 migration 완료"
