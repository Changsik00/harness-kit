# spec-x-phase-15-finalize: phase-15 후처리 (queue 동기화 + 잔재 정리)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-phase-15-finalize` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-phase-15-finalize` |
| **상태** | Planning |
| **타입** | Chore |
| **Integration Test Required** | no |
| **작성일** | 2026-04-30 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- PR #91 (`feat(phase-15): upgrade-safety`) 가 2026-04-29 main 으로 머지됨 — phase-level 통합 PR.
- `backlog/phase-15.md` 의 spec 표는 6 spec 모두 **Merged** 로 표시됨 (PR #91 에 반영).
- `backlog/queue.md` 의 active 섹션은 여전히 `phase-15` 를 가리킴 — **`sdd phase done` 후처리 미실행**.
- `sdd status` 가 phase-15 를 active 로 오판 → `Active Spec: spec-15-01-upgrade-danger-audit / Plan Accept yes / 30 pending tasks` 같은 stale 결과.
- 워킹트리에 untracked 1 건: `.harness-kit/agent/templates/phase-ship.md` — origin tracked 아님. 로컬 install 부산물 추정.

### 문제점

1. **다음 작업 진입 차단**: 새 phase 또는 spec-x 를 시작하려 해도 `sdd status` 가 phase-15 를 active 로 잡고 있어 의도와 다른 컨텍스트 보고를 하게 됨.
2. **multi-device 신뢰 저하**: 다른 device 에서도 pull 직후 동일하게 stale 상태로 보임 — phase 단위 PR 의 후처리 누락이 원인.
3. **untracked 잔재 의심**: `phase-ship.md` 템플릿이 git 외부에 남아 있어 install 동기 상태가 모호.

### 해결 방안 (요약)

`sdd phase done phase-15` 실행으로 queue.md 의 phase-15 를 done 섹션으로 이동시킨다. untracked `.harness-kit/agent/templates/phase-ship.md` 의 출처를 `sources/templates/phase-ship.md` 와 비교 후 처리 결정. 결과를 단일 cleanup 커밋으로 묶고 PR 을 생성한다.

## 🎯 요구사항

### Functional Requirements

1. `sdd phase done phase-15` 실행 후 `sdd status` 가 "Active Phase: 없음" 으로 보고해야 한다.
2. `backlog/queue.md` 의 active 섹션에서 phase-15 가 제거되고 done 섹션에 등록되어야 한다.
3. `.harness-kit/agent/templates/phase-ship.md` 에 대한 처리 결정 (keep / 폐기) 이 walkthrough 에 명시되어야 한다.

### Non-Functional Requirements

1. **No code change**: `sources/`, `install.sh`, `update.sh` 등 키트 본체 코드는 수정하지 않는다 (finalize 전용).
2. **Idempotent**: 이미 done 처리된 phase 에 대해 재실행해도 안전해야 한다 (sdd 의 책임).
3. **Audit trail**: 단일 commit 으로 깔끔히 분리되어 git log 에서 finalize 의도가 드러나야 한다.

## 🚫 Out of Scope

- `hk-align` drift detection 추가 — 후속 spec (`spec-x-hk-align-drift-detect`) 에서 다룸.
- `hk-phase-ship` 가 `sdd phase done` 을 자동 호출하도록 하는 보강 — 별도 spec 으로 분리.
- spec-15-01 의 task.md 잔존 `[ ]` 정리 — Research spec 의 task 형식 자체에 대한 결정은 본 spec 범위 밖.
- `sdd archive` 실행 — 별도 사용자 결정 사항.

## ✅ Definition of Done

- [ ] `sdd phase done phase-15` 실행 + 결과 확인
- [ ] `sdd status` 가 phase-15 를 active 로 표시하지 않음을 검증
- [ ] untracked `phase-ship.md` 처리 결정 + walkthrough 에 기록
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-phase-15-finalize` 브랜치 push 완료
- [ ] PR 생성 및 사용자 검토 요청 알림 완료
