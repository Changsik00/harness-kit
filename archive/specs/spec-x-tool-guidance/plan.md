# Implementation Plan: spec-x-tool-guidance

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-tool-guidance`
- 시작 지점: `main` (최신)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 점검 결과는 warn(안내)로만 — fail(차단)이 아님
> - [ ] 1차 타깃은 Node.js (NestJS), Python/Go는 기본 감지만

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **감지 방식** | 파일 존재 여부 (package.json, go.mod 등) | 단순하고 신뢰성 높음 |
| **점검 수준** | warn만 사용 | 프로젝트 초기에는 도구가 없을 수 있음 |
| **섹션 위치** | 기존 6개 섹션 뒤에 새 섹션 7 추가 | 기존 구조 유지 |

## 📂 Proposed Changes

### [MODIFY] `doctor.sh`

기존 `[6/6] Hook 권한` 다음에 `[7/7] 프로젝트 품질 도구` 섹션 추가.
기존 섹션 번호의 `/6`을 `/7`로 변경.

```
[7/7] 프로젝트 품질 도구
  프로젝트 타입: Node.js (package.json 감지)
  ✓ test 스크립트 설정됨 (package.json scripts.test)
  ⚠ lint 스크립트 없음 (npm install --save-dev eslint && npm init @eslint/config)
  ⚠ typecheck 설정 없음 (npx tsc --init)
```

감지 로직:
1. `package.json` 존재 → Node.js
2. `pyproject.toml` 또는 `setup.py` 존재 → Python
3. `go.mod` 존재 → Go
4. 위 모두 없음 → "프로젝트 타입 감지 불가"

Node.js 점검:
- `scripts.test` 존재 + `"echo"` 또는 `"no test"`가 아닌지
- `scripts.lint` 존재
- `tsconfig.json` 존재 (TypeScript 프로젝트인 경우)

Python 점검:
- pytest/unittest 설정 여부 (`[tool.pytest]` in pyproject.toml 또는 pytest 패키지)
- ruff/flake8/pylint 설정 파일 존재
- mypy/pyright 설정 여부

Go 점검:
- `go test` 내장이므로 test는 항상 pass
- golangci-lint 설정 (`.golangci.yml`) 여부

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오

1. 현재 프로젝트(harness-kit)에서 `doctor.sh` 실행 → "프로젝트 타입 감지 불가" warn 표시 (package.json 없음)
2. Node.js 프로젝트에서 실행 시 lint/test/typecheck 점검 확인 (별도 테스트 불필요 — doctor.sh 출력으로 확인)

## 🔁 Rollback Plan

- `doctor.sh` 단일 파일 수정이므로 `git revert`로 원복

## 📦 Deliverables 체크

- [x] spec.md 작성
- [x] plan.md 작성 (이 파일)
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
