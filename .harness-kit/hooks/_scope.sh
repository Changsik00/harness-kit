#!/usr/bin/env bash
# harness-kit scope 매칭 순수 함수 라이브러리
# blast-radius scope 불변식(constitution §6.2)의 핵심 매칭 로직.
# 편집시점(check-scope.sh) 과 커밋시점(pre-commit.sh) 이 공유한다.
#
# hook env·모드에 의존하지 않는 순수 함수만 둔다 (호출자가 모드/early-exit 담당).

# 안전경로(항상 허용): 거버넌스·산출물·설정·문서.
# scope_is_safe_path <rel> → 안전경로면 0, 아니면 1
scope_is_safe_path() {
  case "$1" in
    .harness-kit/*|docs/*|backlog/*|specs/*|.claude/*|\
    .gitignore|README.md|CLAUDE.md|version.json|\
    *.md)
      return 0 ;;
  esac
  return 1
}

# spec.md 의 Proposed Changes 에서 [MODIFY|NEW|DELETE] `path` 의 path 추출.
# scope_extract_paths <plan_file> → 경로를 한 줄에 하나씩 출력
scope_extract_paths() {
  grep -oE '\[(MODIFY|NEW|DELETE)\][[:space:]]+`[^`]+`' "$1" 2>/dev/null \
    | sed -E 's/.*`([^`]+)`.*/\1/'
}

# 대상 경로가 scope 안인지 판정.
# scope_path_in_scope <rel> <plan_file>
#   0 = in-scope (안전경로 OR 패턴 매칭 OR 패턴 없음 — 판정 불가 시 통과)
#   1 = out-of-scope
scope_path_in_scope() {
  local rel="$1" plan_file="$2"

  scope_is_safe_path "$rel" && return 0

  local scope_paths
  scope_paths="$(scope_extract_paths "$plan_file")"
  [ -z "$scope_paths" ] && return 0

  local pattern dir_pattern
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    # 정확히 일치
    if [ "$rel" = "$pattern" ]; then
      return 0
    fi
    # 디렉토리 prefix 일치 (path/to/dir/ 로 시작하면 통과)
    dir_pattern="${pattern%/*}/"
    case "$rel" in
      "$dir_pattern"*) return 0 ;;
    esac
  done <<< "$scope_paths"

  return 1
}
