# spec-21-02: Turbo 훅 분기 및 PostCommit 검증

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-21-02` |
| **Phase** | `phase-21` |
| **Branch** | `spec-21-02-turbo-hooks` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-06-13 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

spec-21-01 에서 `sdd mode turbo` 로 모드 전환이 가능해졌다. 그러나 실제 훅들은 여전히 mode 필드를 읽지 않아 Turbo 모드에서도 `check-plan-accept.sh` 가 Plan Accept 없는 편집을 차단하고, `check-scope.sh` 가 scope 이탈을 막는다. 사전 차단을 우회할 수단이 없다.

### 문제점

Turbo 모드의 핵심 약속 — "Plan Accept 없이 실행 → 사후 검증으로 안전 확보" — 이 훅 분기 없이는 실현되지 않는다. 또한 사후 검증 훅(`post-commit-verify.sh`)이 없어 revert 루프도 동작하지 않는다.

### 해결 방안 (요약)

기존 두 PreToolUse 훅에 Turbo 모드 시 즉시 exit 0 하는 분기를 추가한다. 신규 `post-commit-verify.sh` (Stop 훅)를 작성하여, Turbo 모드에서 Claude 가 멈출 때 precheck 테스트를 실행하고 실패 시 `git revert HEAD --no-edit` 를 자동으로 수행한다.

## 🎯 요구사항

### Functional Requirements

1. `check-plan-accept.sh` — mode=turbo 이면 모든 검사를 skip (exit 0)
2. `check-scope.sh` — mode=turbo 이면 모든 검사를 skip (exit 0)
3. `post-commit-verify.sh` (Stop 훅 신규):
   - mode=turbo 가 아니면 즉시 exit 0 (no-op)
   - mode=turbo 이고 precheck 미설정이면 exit 0
   - mode=turbo 이고 최근 커밋이 10분 이내이면 precheck 실행
   - precheck 통과 시: `✓ [turbo:verify] 검증 통과` stderr 출력
   - precheck 실패 시: `git revert HEAD --no-edit` 실행 + 실패 원인 stderr 출력
4. `sources/hooks/` 동일 변경 미러링
5. `.claude/settings.json` + `sources/claude-fragments/settings.json.fragment` 에 Stop 훅 등록

### Non-Functional Requirements

1. Governed 모드에서 기존 훅 동작 완전 보존 — 회귀 없음
2. precheck 미설정 시 `post-commit-verify.sh` 는 항상 exit 0 (조용한 no-op)
3. bash 3.2+ 호환

## 🚫 Out of Scope

- `intent.yaml` 연동 (`post-commit-verify.sh` 의 테스트 소스) — spec-21-03
- constitution.md 조항 / `/hk-mode` 슬래시 커맨드 — spec-21-04
- Turbo 모드의 scope 추적 (intent 파일 기반) — spec-21-03

## 📑 ADR 후보

- [ ] 없음 (상위 결정은 spec-21-04 ADR-007 에서 다룸)

## 🔗 관련 문서

- 관련 spec: `specs/spec-21-01-mode-schema/` (mode 필드 도입)
- 관련 phase: `backlog/phase-21.md`

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-turbo-hooks.sh`)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-21-02-turbo-hooks` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
