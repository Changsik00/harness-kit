#!/usr/bin/env bash
# PreToolUse hook (matcher: Edit|Write|MultiEdit)
# 목적: 변경 파일이 plan.md 의 Proposed Changes 에 명시된 범위 안인지 검증 (constitution §6.2)
#
# plan.md 에서 [MODIFY], [NEW], [DELETE] 뒤의 경로 패턴을 추출하고,
# 편집 대상 파일이 그 범위에 포함되는지 확인.
# plan.md 가 없거나 active spec 이 없으면 통과.

_self() { if [ -n "${BASH_VERSION:-}" ]; then echo "${BASH_SOURCE[0]}"; elif [ -n "${ZSH_VERSION:-}" ]; then echo "${(%):-%x}"; else echo "$0"; fi; }
HOOK_DIR="$(cd "$(dirname "$(_self)")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "SCOPE" "warn"

target="$(hook_tool_input file_path)"
[ -z "$target" ] && exit 0

# 절대경로 → 상대경로
case "$target" in
  /*) rel="${target#$HARNESS_ROOT/}" ;;
  *)  rel="$target" ;;
esac

# 안전 경로는 항상 허용 (거버넌스, 산출물, 설정 등)
case "$rel" in
  agent/*|docs/*|backlog/*|specs/*|.claude/*|scripts/harness/*|\
  .gitignore|README.md|CLAUDE.md|VERSION|\
  *.md)
    exit 0 ;;
esac

# Plan Accept 상태가 아니면 검사 불필요 (check-plan-accept 가 담당)
plan_accepted="$(hook_state planAccepted)"
[ "$plan_accepted" != "true" ] && exit 0

# active spec 확인
spec="$(hook_state spec)"
[ -z "$spec" ] && exit 0

plan_file="$HARNESS_ROOT/specs/$spec/plan.md"
[ ! -f "$plan_file" ] && exit 0

# plan.md 에서 파일 경로 추출: [MODIFY] `path`, [NEW] `path`, [DELETE] `path`
# 백틱 안의 경로를 추출
scope_paths="$(grep -oE '\[(MODIFY|NEW|DELETE)\][[:space:]]+`[^`]+`' "$plan_file" | sed -E 's/.*`([^`]+)`.*/\1/')"

[ -z "$scope_paths" ] && exit 0

# 대상 파일이 scope 에 포함되는지 확인
while IFS= read -r pattern; do
  [ -z "$pattern" ] && continue
  # 정확히 일치하거나 디렉토리 prefix 일치
  if [ "$rel" = "$pattern" ]; then
    exit 0
  fi
  # 와일드카드 디렉토리 매칭 (path/to/dir/ 로 시작하면 통과)
  dir_pattern="${pattern%/*}/"
  case "$rel" in
    "$dir_pattern"*) exit 0 ;;
  esac
done <<< "$scope_paths"

hook_violation \
  "Plan 범위 밖 파일 편집 (constitution §6.2)" \
  "대상 파일: $rel" \
  "active spec: $spec" \
  "plan.md 에 명시된 파일만 편집 가능" \
  "해결: plan.md 에 해당 파일을 추가하거나 사용자와 재정렬"
