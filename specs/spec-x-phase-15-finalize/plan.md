# Implementation Plan: spec-x-phase-15-finalize

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-phase-15-finalize` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main` (origin/main 동기화 완료 상태)
- 첫 task 가 브랜치 생성을 수행함
- spec-x 는 항상 main 에서 분기 (memory: spec-x는 main에서 브랜치)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **`sdd phase done phase-15` 의 자동 commit 동작 의존**: sdd 가 queue.md 변경을 commit 하는지 / 작업 트리만 수정하는지 검증 필요. commit 자동 생성이면 별도 staging 불필요.
> - [ ] **untracked `phase-ship.md` 처리 결정**: `sources/templates/phase-ship.md` 와 동일하면 정상 install 결과로 간주하여 그대로 두고, 차이가 있으면 폐기 (rm) — 본 spec 작업 commit 과 별개로 처리.

> [!WARNING]
> - [ ] **No new feature**: 본 spec 은 finalize 전용. 새 기능 발견 시 즉시 hard stop, 별도 spec 으로 분리.
> - [ ] **Phase 표 Merged 검증 우선**: `sdd phase done` 은 phase-15.md 의 모든 spec 이 Merged 임을 가정. 이미 검증 완료 (6/6 Merged).

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
[현재] main → queue.md(active=phase-15) ← sdd status 가 stale 보고
         ↓
[처리] sdd phase done phase-15
         ↓
[결과] queue.md(active 비움 / done=phase-15) → sdd status 깔끔
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **queue.md** | `sdd phase done phase-15` 단일 명령 사용 | 마커 자동 갱신 영역이라 수동 편집 금지 (agent.md §4.3) |
| **`phase-ship.md` untracked** | `sources/templates/phase-ship.md` 와 비교 → 동일 시 keep / 다르면 폐기 | install 결과의 정합성 확인이 우선; 본 finalize 의 고유 책임 |
| **Commit 단위** | finalize 변경 = 단일 commit | git log 에서 finalize 의도 분명히 |

## 📂 Proposed Changes

### [Backlog]

#### [MODIFY] `backlog/queue.md`
- `<!-- sdd:active:start -->` 영역에서 phase-15 항목 제거
- `<!-- sdd:done:start -->` (또는 done 섹션) 에 phase-15 추가
- **편집 방식**: `sdd phase done phase-15` 자동 처리 — 수동 편집 금지

### [Working tree 잔재]

#### [VERIFY/REMOVE] `.harness-kit/agent/templates/phase-ship.md`
- 단계 1: `diff sources/templates/phase-ship.md .harness-kit/agent/templates/phase-ship.md` 비교
- 단계 2: 동일하면 → 정상 install 부산물로 간주, 그대로 둠 (commit 대상 아님)
- 단계 3: 차이 있으면 → 로컬 임시 변경 의심, `rm` 으로 폐기

### [그 외]

- `sources/`, `install.sh`, `update.sh`, `.harness-kit/bin/sdd` 등 키트 본체는 변경 없음.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

본 spec 은 sdd 명령의 동작 검증이라 신규 단위 테스트 추가 불필요. 다만 다음 회귀 검증을 수행:

```bash
# sdd 자체 테스트 슈트가 깨지지 않는지 확인
bash tests/test-sdd-spec-new-seq.sh
```

### 수동 검증 시나리오

1. **finalize 전 상태 캡처**: `bash .harness-kit/bin/sdd status` → "Active Phase: phase-15" 확인
2. **finalize 실행**: `bash .harness-kit/bin/sdd phase done phase-15` → 종료 코드 0
3. **finalize 후 상태**: `bash .harness-kit/bin/sdd status` → "Active Phase: 없음" 또는 다음 phase 로 전환됨
4. **queue.md diff 확인**: `git diff backlog/queue.md` → phase-15 가 active → done 으로만 이동 (다른 변경 없음)
5. **untracked 잔재 처리**: `phase-ship.md` 비교 결과를 walkthrough 에 기록

### 통합 테스트
- (Integration Test Required = no) 해당 없음.

## 🔁 Rollback Plan

- `sdd phase done` 결과가 의도와 다르면 → `git checkout backlog/queue.md` 로 되돌리고 `sdd` 의 버그로 별도 spec-x 분리 검토.
- finalize commit 자체에 문제가 있으면 → PR 머지 전 force-push 로 amend 가능 (spec-x finalize 는 단일 commit 이라 단순).

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
