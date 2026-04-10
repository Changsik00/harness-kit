#!/usr/bin/env bash
# Stack adapter: generic (fallback)
# 어떤 언어/프레임워크도 가정하지 않습니다. 사용자가 수동으로 명령을 채워야 합니다.

export HARNESS_STACK_NAME="generic"
export HARNESS_STACK_DESC="Generic / unknown stack"

# 테스트 명령 (단위)
export HARNESS_TEST_CMD="echo 'No test command configured. Edit .claude/state/stack.env or scripts/harness/lib/stack.sh'"

# 통합 테스트 명령
export HARNESS_TEST_INTEGRATION_CMD="$HARNESS_TEST_CMD"

# 린트 / 타입체크
export HARNESS_LINT_CMD="echo 'No lint command configured.'"
export HARNESS_TYPECHECK_CMD="echo 'No typecheck command configured.'"

# 빌드
export HARNESS_BUILD_CMD="echo 'No build command configured.'"

# 테스트 파일 패턴 (find 와 호환)
export HARNESS_TEST_FILE_GLOB="*test*"

# 소스 디렉토리
export HARNESS_SRC_DIR="."
