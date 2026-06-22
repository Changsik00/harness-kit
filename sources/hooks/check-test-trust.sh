#!/usr/bin/env bash
# check-test-trust.sh — 칸0 사후 테스트 신뢰 휴리스틱 (spec-25-02, GitHub #212 비용 사다리)
# commit-time(HARNESS_GIT_HOOK_MODE=1) staged diff 검사. 경고만(exit 0), mode 무관(blast-radius 가드처럼 항상).
#   (a) 구현 파일 변경 ∧ 테스트 무변경        → "구현 망가뜨리면 빨개지나?"의 정적 프록시
#   (b) 단언 없는 테스트 추가/변경            → 동어반복(가짜 green) 의심
# 휴리스틱이라 coarse — 안전 경로 화이트리스트로 오탐 억제. 1차는 경고(차단 없음, hook 단계론).

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/_lib.sh"

# 칸0 는 커밋 시점 전용 — edit/기타 호출엔 무간섭.
[ "${HARNESS_GIT_HOOK_MODE:-0}" = "1" ] || exit 0

# 안전 경로: 산출물·문서·설정 — 테스트 동반 의무 없음.
_tt_is_safe() {
  case "$1" in
    docs/*|backlog/*|specs/*|.harness-kit/*|.claude/*|.github/*|\
    *.md|*.json|*.yml|*.yaml|*.txt|.gitignore|LICENSE|version.json) return 0 ;;
  esac
  return 1
}
# 테스트 파일: 테스트 디렉토리 하위 또는 test/spec 파일명. ('check-test-trust.sh' 같은
# 중간 토큰 'test' 는 제외 — basename 이 test 로 시작/끝나거나 .test./.spec. 일 때만.)
_tt_is_test() {
  case "$1" in
    tests/*|*/tests/*|test/*|*/test/*|*/__tests__/*|spec/*|*/spec/*) return 0 ;;
  esac
  case "$(basename "$1")" in
    test[-_.]*|test_*|*.test.*|*.spec.*|*_test.*|*_spec.*) return 0 ;;
  esac
  return 1
}
# 구현 코드: 확장자 또는 bin/ 실행 스크립트(확장자 없는 sdd 등).
_tt_is_code() {
  case "$1" in
    bin/*|*/bin/*) return 0 ;;
    *.sh|*.bash|*.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.py|*.go|*.rb|*.java|*.rs|*.c|*.h|*.cpp|*.php|*.kt|*.swift|*.scala) return 0 ;;
  esac
  return 1
}
# staged 내용에 단언 토큰이 있나 (bash/js/go 등 broad — 휴리스틱).
_tt_has_assertion() {
  git -C "$HARNESS_ROOT" show ":$1" 2>/dev/null | grep -qE \
    'assert|expect|toBe|toEqual|toMatch|toThrow|toContain|should|require\(|chai|-eq |-ne |-gt |-lt |-ge |-le |\[\[|grep -q'
}

code_files=""; test_count=0; assertionless=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  _tt_is_safe "$f" && continue
  if _tt_is_test "$f"; then
    test_count=$(( test_count + 1 ))
    _tt_has_assertion "$f" || assertionless="$assertionless $f"
  elif _tt_is_code "$f"; then
    code_files="$code_files $f"
  fi
done < <(git -C "$HARNESS_ROOT" diff --cached --name-only 2>/dev/null)

# (a) 구현 변경 + 테스트 무변경
if [ -n "$code_files" ] && [ "$test_count" -eq 0 ]; then
  echo "⚠ [test-trust:warn] 구현이 바뀌었는데 동반 테스트가 없습니다 (가짜 green 위험 — #212 칸0):" >&2
  for f in $code_files; do echo "   $f" >&2; done
  echo "   '구현을 망가뜨리면 테스트가 빨개지나?' 를 이 커밋은 보장하지 않습니다. 의도면 무시, 아니면 테스트 추가." >&2
fi
# (b) 단언 없는 테스트
if [ -n "$assertionless" ]; then
  echo "⚠ [test-trust:warn] 단언이 보이지 않는 테스트 (동어반복 위험 — #212 칸0):" >&2
  for f in $assertionless; do echo "   $f" >&2; done
fi

exit 0
