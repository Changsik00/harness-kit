#!/usr/bin/env bash
# PreToolUse hook (matcher: Edit|Write|MultiEdit)
# 목적: 변경 파일이 spec.md 의 Proposed Changes 에 명시된 범위 안인지 검증 (constitution §6.2)
#
# spec.md 에서 [MODIFY], [NEW], [DELETE] 뒤의 경로 패턴을 추출하고,
# 편집 대상 파일이 그 범위에 포함되는지 확인.
# spec.md 가 없거나 active spec 이 없으면 통과.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/_lib.sh"
source "$HOOK_DIR/_scope.sh"
hook_resolve_mode "SCOPE" "warn"

_hk_mode="$(hook_state mode)"; { [ "$_hk_mode" = "turbo" ] || [ "$_hk_mode" = "auto" ]; } && exit 0

target="$(hook_tool_input file_path)"
[ -z "$target" ] && exit 0

# 절대경로 → 상대경로
case "$target" in
  /*) rel="${target#$HARNESS_ROOT/}" ;;
  *)  rel="$target" ;;
esac

# 안전 경로는 항상 허용 (거버넌스, 산출물, 설정 등 — _scope.sh 가 판정)
scope_is_safe_path "$rel" && exit 0

# Plan Accept 상태가 아니면 검사 불필요 (check-plan-accept 가 담당)
plan_accepted="$(hook_state planAccepted)"
[ "$plan_accepted" != "true" ] && exit 0

# active spec 확인
spec="$(hook_state spec)"
[ -z "$spec" ] && exit 0

plan_file="$HARNESS_ROOT/specs/$spec/spec.md"
[ ! -f "$plan_file" ] && exit 0

# 대상 파일이 spec.md Proposed Changes scope 에 포함되는지 확인 (_scope.sh 위임)
scope_path_in_scope "$rel" "$plan_file" && exit 0

hook_violation \
  "Spec 범위 밖 파일 편집 (constitution §6.2)" \
  "대상 파일: $rel" \
  "active spec: $spec" \
  "spec.md 의 Proposed Changes 에 명시된 파일만 편집 가능" \
  "해결: spec.md 에 해당 파일을 추가하거나 사용자와 재정렬"
