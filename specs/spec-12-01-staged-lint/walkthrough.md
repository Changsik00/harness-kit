# Walkthrough: spec-12-01 staged 파일 기반 선택적 linting 훅

## 무엇을 만들었나

`check-staged-lint.sh` pre-commit 훅. `git diff --cached --name-only`로 스테이징된 파일만 추출해 프로젝트 타입에 맞는 linter를 실행한다. linter 미설치나 타입 미감지 시에는 경고 후 통과(exit 0)한다.

## 핵심 흐름

```
pre-commit 실행
  └── staged 파일 없으면 → 즉시 exit 0 (silent skip)
  └── 프로젝트 타입 감지 (package.json / pyproject.toml / go.mod / *.sh)
  └── 타입 미감지 + shell 없으면 → exit 0
  └── 각 타입별 linter 실행
        ├── Node.js: eslint (없으면 경고 + skip)
        ├── Python: ruff → pylint 순 (없으면 경고 + skip)
        ├── Go: golangci-lint --fast (없으면 경고 + skip)
        └── Shell: shellcheck 파일별 (없으면 경고 + skip)
  └── exit 0 (항상 통과 — 경고 모드)
```

## 변경 파일

| 파일 | 변경 | 설명 |
|---|---|---|
| `sources/hooks/check-staged-lint.sh` | 신규 | 훅 구현 |
| `.harness-kit/hooks/check-staged-lint.sh` | 신규 | 도그푸딩 동기화 |
| `sources/bin/sdd` | 수정 | `sdd hooks` 목록에 STAGED_LINT 추가 |
| `.harness-kit/bin/sdd` | 수정 | 동기화 |
| `tests/test-staged-lint.sh` | 신규 | TDD 테스트 6개 |

## 수동 검증 시나리오

```bash
# JS 파일 staged + package.json 있음 + eslint 없음
echo '{"name":"test"}' > package.json
echo 'var x=1' > app.js
git add package.json app.js
git commit -m "test"
# 예상: ⚠ [staged-lint] eslint 미설치 ... 경고 + 커밋 통과
```

## 모드 전환

```bash
# 차단 모드로 승격 (1주 운영 후)
export HARNESS_HOOK_MODE_STAGED_LINT=block
```
