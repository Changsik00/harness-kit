#!/usr/bin/env bash
# PreToolUse hook (matcher: Edit|Write|MultiEdit)
# 목적: Plan Accept 전에 production 코드 편집 차단 (constitution §4.3)
#
# 안전 경로 (항상 허용):
#   - agent/**, docs/**, backlog/**, specs/**, .claude/**
#   - 모든 *.md 파일
#   - .gitignore, README.md, CLAUDE.md
#   - 키트 자체 (scripts/harness/**)
#
# 그 외 경로는 .claude/state/current.json 의 planAccepted=true 일 때만 허용

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$HOOK_DIR/_lib.sh"

target="$(hook_tool_input file_path)"
[ -z "$target" ] && exit 0

# 절대경로면 프로젝트 루트 기준 상대경로로 변환
case "$target" in
  /*) rel="${target#$HARNESS_ROOT/}" ;;
  *)  rel="$target" ;;
esac

# 안전 경로 화이트리스트
case "$rel" in
  agent/*|agent|\
  docs/*|docs|\
  backlog/*|backlog|\
  specs/*|specs|\
  .claude/*|.claude|\
  scripts/harness/*|\
  .gitignore|README.md|CLAUDE.md|VERSION)
    exit 0 ;;
esac

# *.md 는 항상 허용
case "$rel" in
  *.md) exit 0 ;;
esac

# Plan Accept 검사
plan_accepted="$(hook_state planAccepted)"
if [ "$plan_accepted" = "true" ]; then
  exit 0
fi

hook_violation \
  "Plan Accept 전 production 코드 편집 금지 (constitution §4.3)" \
  "대상 파일: $rel" \
  "현재 plan-accepted: ${plan_accepted:-false}" \
  "해결: spec.md / plan.md / task.md 작성 → 사용자에게 검토 요청 → /plan-accept 호출"
