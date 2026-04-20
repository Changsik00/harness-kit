# feat(spec-12-01): staged 파일 기반 선택적 linting 훅

## 배경

harness-kit의 pre-commit 훅들은 거버넌스 검증에 집중되어 있고 코드 품질 검증(lint)은 없었다. lint-staged 같은 별도 툴 없이 staged 파일만 빠르게 lint하는 훅을 추가한다.

## 변경 사항

- `sources/hooks/check-staged-lint.sh` 신규: staged 파일 추출 → 타입 감지 → linter 실행
  - Node.js: eslint
  - Python: ruff → pylint
  - Go: golangci-lint --fast
  - Shell: shellcheck
- `sources/bin/sdd` 수정: `sdd hooks` 목록에 `STAGED_LINT:warn` 추가
- `tests/test-staged-lint.sh` 신규: TDD 6개 체크 PASS

## 훅 단계론

경고 모드(exit 0)로 시작. linter 미설치 또는 타입 미감지 시 경고 출력 후 항상 통과. 1주 운영 후 `export HARNESS_HOOK_MODE_STAGED_LINT=block`으로 승격 가능.

## 테스트

```
✅ ALL 6 CHECKS PASSED (tests/test-staged-lint.sh)
✅ ALL 19 tests PASS (전체 테스트 스위트)
```
