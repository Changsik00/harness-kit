#!/usr/bin/env bash
# Stack adapter: Node.js (generic, npm-based)

export HARNESS_STACK_NAME="nodejs"
export HARNESS_STACK_DESC="Node.js (npm)"

export HARNESS_TEST_CMD="npm test"
export HARNESS_TEST_INTEGRATION_CMD="npm run test:integration 2>/dev/null || npm test"
export HARNESS_LINT_CMD="npm run lint"
export HARNESS_TYPECHECK_CMD="npx tsc --noEmit 2>/dev/null || true"
export HARNESS_BUILD_CMD="npm run build"

export HARNESS_TEST_FILE_GLOB="*.{test,spec}.{js,ts,jsx,tsx,mjs,cjs}"
export HARNESS_SRC_DIR="src"
