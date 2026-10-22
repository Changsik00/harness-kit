# Plan Accept 전에도 편집·커밋을 허용하는 안전 경로 — pre-commit.sh 와 check-plan-accept.sh 가 공유한다.
# (phase-30 F3: 두 게이트가 각자 목록을 가져 정책이 어긋나던 문제의 단일 출처. 경로는 프로젝트 루트 기준 상대경로.)
# 사용: source 후 hk_plan_accept_safe_path "<상대경로>" → 0=안전(허용) / 1=그 외(Plan Accept 필요)
# 주의: _lib.sh 와 달리 부수효과가 없어(exit·전역변수 변경 없음) git pre-commit 에서도 안전하게 source 된다.
hk_plan_accept_safe_path() {
  case "$1" in
    .harness-kit/*|docs|docs/*|backlog|backlog/*|specs|specs/*|.claude|.claude/*|\
    .gitignore|README.md|CLAUDE.md|version.json|*.md)
      return 0 ;;
  esac
  return 1
}
