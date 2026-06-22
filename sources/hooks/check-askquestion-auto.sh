#!/usr/bin/env bash
# PreToolUse hook (matcher: AskUserQuestion)
# 목적: auto 모드에서 AskUserQuestion 호출을 차단 → 논블로킹의 기계적 백스톱.
#   (spec-25-01, ADR-009 Addendum) — 24-04 의 "hook 으로 못 막음" 전제 정정.
#   matcher 가 AskUserQuestion 만 필터하므로 tool_input 파싱 불필요 — mode 만 확인.
#
# 멈춤의 두 종류 분리:
#   routine 결정(work mode·plan-accept·PR 확인·idea capture) → 안 멈춤(기본값+로그)
#   정지규칙 ①(기본값 정당화 불가한 진짜 모호)            → 멈춤(decision add + 턴 종료)
#   둘 다 AskUserQuestion 이 아니라 stderr 지침대로 처리한다.
#
# 훅 단계론 예외: 기본 모드 block. warn(exit 0)은 질문 블로킹을 못 막아 무의미하므로
#   이 hook 은 차단이 곧 기능이다. auto 한정 발동이라 위험은 격리된다.
#   override: HARNESS_HOOK_MODE_ASKQUESTION=warn|off

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "ASKQUESTION" "block"

# auto 모드에서만 발동. governed/turbo/mode 부재 → 통과(질문 정상 동작).
[ "$(hook_state mode)" = "auto" ] || exit 0

hook_violation \
  "auto 모드: AskUserQuestion 비활성 — 논블로킹 백스톱 (ADR-009 Addendum)" \
  "routine 결정(work mode·plan-accept·PR 확인·idea capture)이면:" \
  "  → 기본값(ux-mode effective=text) 채택 + sdd decision add \"<이슈>\" \"<선택>\" \"<이유>\" 후 진행" \
  "정지규칙 ①(기본값을 정당화할 수 없는 진짜 모호)이면:" \
  "  → sdd decision add \"미해결:<이슈>\" \"STOP\" \"<이유>\" 기록 후 턴 종료 (notify 가 사용자에 전달)"
