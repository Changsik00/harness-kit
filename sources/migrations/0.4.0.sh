#!/usr/bin/env bash
# harness-kit Migration: → 0.4.0
#
# 이 파일은 update.sh 에 의해 source 됩니다.
# 직접 실행하지 마세요.
#
# 변경 내용:
#   - 5개의 PreToolUse 훅 신규 추가
#   - /hk-spec-review 커맨드 제거 (→ /hk-code-review 통합)
#   - hk- prefix 이전 구 커맨드 파일명 정리

# ──────────────────────────────────────────────
# 삭제할 파일 목록 (TARGET 기준 상대 경로, 한 줄에 하나)
# ──────────────────────────────────────────────
migration_cleanup() {
  cat <<'EOF'
.claude/commands/hk-spec-review.md
.claude/commands/align.md
.claude/commands/spec-new.md
.claude/commands/plan-accept.md
.claude/commands/spec-status.md
.claude/commands/code-review.md
.claude/commands/handoff.md
.claude/commands/gh-pr.md
.claude/commands/bb-pr.md
EOF
}

# ──────────────────────────────────────────────
# 신규 기능 설명 (update.sh 가 출력)
# ──────────────────────────────────────────────
migration_new_features() {
  cat <<'EOF'

  [+] 5개의 PreToolUse 훅 추가:
      check-commit-msg    커밋 메시지 형식 검증 (type(spec-N-NNN): 패턴)
      check-diff-size     비정상적으로 큰 diff 감지 (기본: 500줄)
      check-scope         스펙 범위 이탈 감지
      check-secrets       시크릿/자격증명 노출 방지
      check-task-checkbox task.md 체크박스 업데이트 검증

  [-] /hk-spec-review 제거 → /hk-code-review 로 통합됨

  [!] 모든 새 훅은 기본값 warn 모드 (경고만, 차단 안 함)
      1주 운영 후 block 모드로 전환 권장:
        export HARNESS_HOOK_MODE=block
        또는 개별: export HARNESS_HOOK_MODE_CHECK_SECRETS=block
      모드 확인: ./scripts/harness/bin/sdd hooks

EOF
}
