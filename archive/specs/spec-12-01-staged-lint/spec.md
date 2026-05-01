# spec-12-01: staged 파일 기반 선택적 linting 훅

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-12-01` |
| **Phase** | `phase-12` |
| **Branch** | `spec-12-01-staged-lint` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-20 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
harness-kit의 pre-commit 훅(check-branch, check-commit-msg, check-plan-accept 등)은 모두 거버넌스 검증에 집중되어 있다. 코드 품질 검증(lint/format)은 훅으로 제공되지 않아 사용자가 직접 설정해야 한다.

### 문제점
- 프로젝트에 ESLint/Prettier/pylint 등이 있어도 harness-kit 훅에서 자동 실행되지 않음
- 전체 파일 대상 lint는 대형 프로젝트에서 commit마다 느려짐
- lint-staged 같은 별도 툴을 추가 설치해야 하는 마찰이 있음

### 해결 방안 (요약)
`check-staged-lint.sh` 훅을 추가해 `git diff --cached --name-only`로 스테이징된 파일만 선별 후 프로젝트 타입(Node.js/Python/Go/Shell)에 맞는 linter를 실행한다. linter 미설치 또는 타입 미감지 시 경고만 출력하고 통과(exit 0)한다.

## 🎯 요구사항

### Functional Requirements
1. `git diff --cached --name-only`로 스테이징된 파일만 추출
2. 프로젝트 타입 자동 감지: `package.json` → Node.js, `pyproject.toml`/`setup.py` → Python, `go.mod` → Go, `*.sh` → Shell(shellcheck)
3. 감지된 타입에 맞는 linter 실행 (eslint/pylint or ruff/golangci-lint/shellcheck)
4. linter 미설치 시 경고 출력 후 exit 0 (훅 단계론: 경고 모드로 시작)
5. 스테이징된 해당 타입 파일 없으면 skip
6. `sources/hooks/check-staged-lint.sh` 추가 → install.sh로 대상 프로젝트에 배포

### Non-Functional Requirements
1. 훅 단계론 준수: 첫 배포는 경고 모드(exit 0). 차단 모드(exit 2)는 별도 승격 필요
2. 기존 훅과 독립 — 다른 훅 실패와 무관하게 동작
3. bash 3.2 호환 (macOS 기본 환경)

## 🚫 Out of Scope

- linter 자동 설치 (설치는 사용자 책임)
- 포맷터 자동 re-stage (Prettier/Black의 자동 수정 후 re-add)
- 병렬 훅 실행 엔진 (phase-12 범위 아님)
- Java/Rust/Ruby 등 추가 언어 지원

## ✅ Definition of Done

- [ ] `tests/test-staged-lint.sh` 전체 PASS
- [ ] `sources/hooks/check-staged-lint.sh` 구현 완료
- [ ] install.sh에서 훅 배포 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-12-01-staged-lint` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
