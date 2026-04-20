#!/usr/bin/env bash
# pre-commit hook
# staged 파일 기반 선택적 linting (경고 모드 — exit 0)

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "STAGED_LINT" "warn"

# staged 파일 목록
staged_files="$(git -C "$HARNESS_ROOT" diff --cached --name-only 2>/dev/null || true)"
[ -z "$staged_files" ] && exit 0

# 프로젝트 타입 감지 (마커 파일 기반)
project_type=""
if [ -f "$HARNESS_ROOT/package.json" ]; then
  project_type="node"
elif [ -f "$HARNESS_ROOT/pyproject.toml" ] || [ -f "$HARNESS_ROOT/setup.py" ]; then
  project_type="python"
elif [ -f "$HARNESS_ROOT/go.mod" ]; then
  project_type="go"
fi

# Shell 파일이 staged 되어 있으면 타입 추가
shell_files="$(echo "$staged_files" | grep -E '\.sh$' || true)"

# 감지된 타입도 없고 shell 파일도 없으면 skip
if [ -z "$project_type" ] && [ -z "$shell_files" ]; then
  exit 0
fi

_warn() {
  echo "${HC_YLW}⚠ [staged-lint]${HC_RST} $1" >&2
}

# Node.js lint
if [ "$project_type" = "node" ]; then
  node_files="$(echo "$staged_files" | grep -E '\.(js|jsx|ts|tsx|mjs|cjs)$' || true)"
  if [ -n "$node_files" ]; then
    if command -v eslint > /dev/null 2>&1; then
      # shellcheck disable=SC2086
      eslint $node_files 2>&1 || _warn "eslint 경고가 있습니다 (커밋은 통과)"
    else
      _warn "eslint 미설치 — JS/TS lint skip (npm install -g eslint 로 설치)"
    fi
  fi
fi

# Python lint
if [ "$project_type" = "python" ]; then
  py_files="$(echo "$staged_files" | grep -E '\.py$' || true)"
  if [ -n "$py_files" ]; then
    if command -v ruff > /dev/null 2>&1; then
      # shellcheck disable=SC2086
      ruff check $py_files 2>&1 || _warn "ruff 경고가 있습니다 (커밋은 통과)"
    elif command -v pylint > /dev/null 2>&1; then
      # shellcheck disable=SC2086
      pylint $py_files 2>&1 || _warn "pylint 경고가 있습니다 (커밋은 통과)"
    else
      _warn "ruff/pylint 미설치 — Python lint skip"
    fi
  fi
fi

# Go lint
if [ "$project_type" = "go" ]; then
  go_files="$(echo "$staged_files" | grep -E '\.go$' || true)"
  if [ -n "$go_files" ]; then
    if command -v golangci-lint > /dev/null 2>&1; then
      golangci-lint run --fast 2>&1 || _warn "golangci-lint 경고가 있습니다 (커밋은 통과)"
    else
      _warn "golangci-lint 미설치 — Go lint skip"
    fi
  fi
fi

# Shell lint
if [ -n "$shell_files" ]; then
  if command -v shellcheck > /dev/null 2>&1; then
    while IFS= read -r f; do
      [ -f "$HARNESS_ROOT/$f" ] && shellcheck "$HARNESS_ROOT/$f" 2>&1 \
        || _warn "shellcheck 경고: $f (커밋은 통과)"
    done <<< "$shell_files"
  else
    _warn "shellcheck 미설치 — Shell lint skip (brew install shellcheck 로 설치)"
  fi
fi

exit 0
