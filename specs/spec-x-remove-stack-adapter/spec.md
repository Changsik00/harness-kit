# spec-x-remove-stack-adapter: Stack Adapter 제거

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-remove-stack-adapter` |
| **Phase** | 없음 (Solo Spec) |
| **Branch** | `spec-x-remove-stack-adapter` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-12 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

harness-kit에 stack adapter 시스템(`stacks/generic.sh`, `stacks/nodejs.sh`)이 존재한다. 설치 시 프로젝트의 기술 스택을 감지하여 `HARNESS_TEST_CMD`, `HARNESS_LINT_CMD` 등 환경변수를 export하는 구조이다.

### 문제점

- **유일한 소비자가 에이전트 프롬프트**: `hk-ship.md`에서 `$HARNESS_LINT_CMD` 등을 참조하지만, 이는 에이전트가 읽는 프롬프트일 뿐 실제 bash 실행이 아님
- **에이전트가 이미 판단 가능**: Claude는 `package.json` 등을 읽고 적절한 명령어를 직접 판단할 수 있어, 하드코딩된 어댑터보다 정확함
- **유지보수 부담**: 프로젝트가 vitest로 전환하면 어댑터가 오히려 오래된 정보를 제공
- **오버엔지니어링**: 실제 자동화(hook, sdd CLI)에서 이 환경변수를 사용하는 곳이 없음

### 해결 방안 (요약)

`stacks/` 디렉토리, stack 감지/복사 로직, 관련 환경변수 참조를 모두 제거한다. `hk-ship.md`에서는 에이전트가 프로젝트 설정을 직접 확인하도록 안내한다.

## 🎯 요구사항

### Functional Requirements

1. `stacks/` 디렉토리 삭제 (`generic.sh`, `nodejs.sh`)
2. `install.sh`에서 `--stack` 옵션, `detect_stack()` 함수, stack 복사 로직 제거
3. `update.sh`에서 stack 복원 로직 제거
4. `doctor.sh`에서 stack 검증 항목 제거
5. `sdd` CLI에서 stack 변수/출력 제거
6. `.claude/state/current.json`에서 `stack` 필드 제거
7. `hk-ship.md`에서 `$HARNESS_` 환경변수 → 에이전트가 프로젝트 설정 확인 후 실행하도록 안내 변경
8. `agent.md`에서 §6.7 Stack Awareness 섹션 삭제
9. `plan.md` 템플릿에서 stack adapter 참조 제거
10. `README.md`, `docs/REFERENCE.md`, `docs/USAGE.md`, `CLAUDE.md`에서 stack 관련 문서 제거

### Non-Functional Requirements

1. `scripts/harness/lib/stack.sh` (설치된 결과물)은 `install.sh` 수정으로 더 이상 생성되지 않음. 기존 설치 프로젝트는 `update.sh` 실행 시 제거 필요 — 마이그레이션 스크립트에서 처리
2. 거버넌스 문서(constitution.md, agent.md) 변경은 영문으로 작성

## 🚫 Out of Scope

- lint/test 미설치 시 안내 기능 (별도 spec-x-tool-guidance에서 처리)
- 기존 설치 프로젝트의 `stack.sh` 자동 삭제 마이그레이션 (다음 update.sh 버전업 시 처리)

## ✅ Definition of Done

- [ ] `stacks/` 디렉토리 완전 삭제
- [ ] `install.sh`, `update.sh`, `doctor.sh`, `sdd` 에서 stack 로직 제거
- [ ] `hk-ship.md` 에서 환경변수 대신 에이전트 직접 판단 안내로 변경
- [ ] 거버넌스/템플릿/문서에서 stack 참조 제거
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-x-remove-stack-adapter` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
