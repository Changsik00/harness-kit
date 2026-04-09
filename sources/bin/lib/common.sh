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
