#!/usr/bin/env bash
# Stack adapter: NestJS (TypeScript)

export HARNESS_STACK_NAME="nestjs"
export HARNESS_STACK_DESC="NestJS (TypeScript)"

export HARNESS_TEST_CMD="npm test"
export HARNESS_TEST_INTEGRATION_CMD="npm run test:e2e"
export HARNESS_LINT_CMD="npm run lint"
export HARNESS_TYPECHECK_CMD="npx tsc --noEmit"
export HARNESS_BUILD_CMD="npm run build"

# NestJS 컨벤션: *.spec.ts (단위), *.e2e-spec.ts (통합)
export HARNESS_TEST_FILE_GLOB="*.spec.ts"
export HARNESS_INTEGRATION_TEST_FILE_GLOB="*.e2e-spec.ts"
export HARNESS_SRC_DIR="src"
