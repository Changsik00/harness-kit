#!/usr/bin/env bash
# bin/sdd 공통 라이브러리
# bash 3.2 호환 (macOS 1차 타깃)

# 색상
if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'
  C_BLU=$'\033[34m'; C_CYN=$'\033[36m'; C_MAG=$'\033[35m'
  C_DIM=$'\033[2m'; C_BLD=$'\033[1m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_BLU=""; C_CYN=""; C_MAG=""; C_DIM=""; C_BLD=""; C_RST=""
fi

log()  { echo "${C_CYN}[sdd]${C_RST} $*"; }
ok()   { echo "${C_GRN}✓${C_RST} $*"; }
warn() { echo "${C_YLW}⚠${C_RST} $*" >&2; }
err()  { echo "${C_RED}✗${C_RST} $*" >&2; }
die()  { err "$*"; exit 1; }

# 프로젝트 루트 찾기 (CWD 부터 위로 올라가며 .claude/state/current.json 또는 agent/constitution.md 가 있는 디렉토리)
sdd_find_root() {
  local d="${1:-$PWD}"
  while [ "$d" != "/" ]; do
    if [ -f "$d/.claude/state/current.json" ] || [ -f "$d/agent/constitution.md" ]; then
      echo "$d"
      return 0
    fi
    d="$(dirname "$d")"
  done
  return 1
}

SDD_ROOT="$(sdd_find_root)" || die "프로젝트 루트를 찾지 못했습니다 (.claude/state/current.json 또는 agent/constitution.md 필요)"
SDD_STATE="$SDD_ROOT/.claude/state/current.json"
SDD_BACKLOG="$SDD_ROOT/backlog"     # phase 정의 (todo list)
SDD_SPECS="$SDD_ROOT/specs"          # 실제 spec 작업 (work log)
SDD_AGENT="$SDD_ROOT/agent"
SDD_TEMPLATES="$SDD_ROOT/agent/templates"

# slug 검증
sdd_slug_ok() {
  local s="$1"
  echo "$s" | grep -qE '^[a-z][a-z0-9-]{1,40}$'
}

# ─────────────────────────────────────────────────────────
# Marker section helpers
# 마커 형식: <!-- sdd:<name>:start --> ... <!-- sdd:<name>:end -->
# ─────────────────────────────────────────────────────────

# 마커 사이에 한 줄 append (end 마커 직전)
sdd_marker_append() {
  local file="$1" name="$2" line="$3"
  [ -f "$file" ] || die "파일 없음: $file"
  local start="<!-- sdd:${name}:start -->"
  local end="<!-- sdd:${name}:end -->"
  awk -v s="$start" -v e="$end" -v ln="$line" '
    $0 == e { print ln; print; next }
    { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# 마커 사이를 지정 콘텐츠로 교체 (멀티라인 가능)
sdd_marker_replace() {
  local file="$1" name="$2" content="$3"
  [ -f "$file" ] || die "파일 없음: $file"
  local start="<!-- sdd:${name}:start -->"
  local end="<!-- sdd:${name}:end -->"
  awk -v s="$start" -v e="$end" -v c="$content" '
    BEGIN { in_section = 0 }
    $0 == s { print; print c; in_section = 1; next }
    $0 == e { in_section = 0; print; next }
    !in_section { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# 마커 사이의 한 줄을 다른 한 줄로 교체 (정확 매치)
# 매치 못 찾으면 아무 변경 없음
sdd_marker_update_row() {
  local file="$1" name="$2" needle="$3" newline="$4"
  [ -f "$file" ] || die "파일 없음: $file"
  local start="<!-- sdd:${name}:start -->"
  local end="<!-- sdd:${name}:end -->"
  awk -v s="$start" -v e="$end" -v needle="$needle" -v newline="$newline" '
    BEGIN { in_section = 0 }
    $0 == s { in_section = 1; print; next }
    $0 == e { in_section = 0; print; next }
    in_section && index($0, needle) > 0 { print newline; next }
    { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}
