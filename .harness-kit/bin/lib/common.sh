#!/usr/bin/env bash
# bin/sdd 공통 라이브러리
# bash 4.0+ (macOS 1차 타깃)

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

# 프로젝트 루트 찾기 (CWD 부터 위로 올라가며 .harness-kit/installed.json 또는 .claude/state/current.json 이 있는 디렉토리)
sdd_find_root() {
  local d="${1:-$PWD}"
  local depth=0
  while [ "$d" != "/" ] && [ $depth -lt 10 ]; do
    if [ -f "$d/.harness-kit/harness.config.json" ]; then
      local root=""
      if command -v jq >/dev/null 2>&1; then
        root=$(jq -r '.rootDir // empty' "$d/.harness-kit/harness.config.json" 2>/dev/null || true)
      else
        root=$(grep -o '"rootDir":"[^"]*"' "$d/.harness-kit/harness.config.json" 2>/dev/null | cut -d'"' -f4 || true)
      fi
      if [ -n "$root" ] && [ -d "$root" ]; then
        echo "$root"
        return 0
      fi
    fi
    if [ -f "$d/.harness-kit/installed.json" ] || [ -f "$d/.claude/state/current.json" ]; then
      echo "$d"
      return 0
    fi
    d="$(dirname "$d")"
    depth=$((depth + 1))
  done
  return 1
}

SDD_ROOT="$(sdd_find_root)" || die "프로젝트 루트를 찾지 못했습니다 (.harness-kit/installed.json 또는 .claude/state/current.json 필요)"
SDD_STATE="$SDD_ROOT/.claude/state/current.json"
SDD_BACKLOG="$SDD_ROOT/backlog"
SDD_SPECS="$SDD_ROOT/specs"
SDD_AGENT="$SDD_ROOT/.harness-kit/agent"
SDD_TEMPLATES="$SDD_ROOT/.harness-kit/agent/templates"

# harness.config.json 읽기 (존재 시 경로 override)
_HK_CONFIG="$SDD_ROOT/.harness-kit/harness.config.json"
if [ -f "$_HK_CONFIG" ]; then
  if command -v jq >/dev/null 2>&1; then
    _bd=$(jq -r '.backlogDir // "backlog"' "$_HK_CONFIG" 2>/dev/null)
    _sd=$(jq -r '.specsDir   // "specs"'  "$_HK_CONFIG" 2>/dev/null)
  else
    _bd=$(grep -o '"backlogDir":"[^"]*"' "$_HK_CONFIG" 2>/dev/null | cut -d'"' -f4)
    _sd=$(grep -o '"specsDir":"[^"]*"'   "$_HK_CONFIG" 2>/dev/null | cut -d'"' -f4)
  fi
  SDD_BACKLOG="$SDD_ROOT/${_bd:-backlog}"
  SDD_SPECS="$SDD_ROOT/${_sd:-specs}"
fi

# slug 검증
sdd_slug_ok() {
  local s="$1"
  echo "$s" | grep -qE '^[a-z][a-z0-9-]{1,40}$'
}

# ─────────────────────────────────────────────────────────
# Marker section helpers
# 마커 형식: <!-- sdd:<name>:start --> ... <!-- sdd:<name>:end -->
# ─────────────────────────────────────────────────────────

# 마커 사이에 한 줄 append (end 마커 직전).
# 동일 라인이 마커 영역 내부에 이미 있으면 append 생략 (멱등).
sdd_marker_append() {
  local file="$1" name="$2" line="$3"
  [ -f "$file" ] || die "파일 없음: $file"
  local start="<!-- sdd:${name}:start -->"
  local end="<!-- sdd:${name}:end -->"
  awk -v s="$start" -v e="$end" -v ln="$line" '
    BEGIN { in_section = 0; found = 0 }
    $0 == s { in_section = 1; print; next }
    $0 == e {
      in_section = 0
      if (!found) print ln
      print; next
    }
    in_section && $0 == ln { found = 1 }
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

# 마커 영역 내부에서 needle 검색 — exit 0 (찾음) / 1 (못찾음)
sdd_marker_grep() {
  local file="$1" name="$2" needle="$3"
  [ -f "$file" ] || return 1
  local start="<!-- sdd:${name}:start -->"
  local end="<!-- sdd:${name}:end -->"
  awk -v s="$start" -v e="$end" -v n="$needle" '
    BEGIN { in_section = 0; found = 0 }
    $0 == s { in_section = 1; next }
    $0 == e { in_section = 0; next }
    in_section && index($0, n) > 0 { found = 1 }
    END { exit (found ? 0 : 1) }
  ' "$file"
}
