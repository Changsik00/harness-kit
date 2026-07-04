# spec-27-03: 완료 phase의 backlog 잔존을 `sdd status` 진단에 노출

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-27-03` |
| **Phase** | `phase-27` |
| **Branch** | `spec-27-03-archive-residue-detect` |
| **Base 브랜치** | `phase-27-docs-integrity` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-07-03 |
| **소유자** | changsik |

## 배경 및 문제 정의

### 현재 상황

spec-27-02 에서 `_backlog_completed_residue` 공유 헬퍼(완료 phase 중 `backlog/phase-NN.md` 가 아직 남아있는 것을 찾는 함수)를 만들어 `sdd doctor` 에 이미 연결했다. `sdd doctor` 를 실행하면 phase-23~26 잔존이 실제로 잡힌다(spec-27-02 walkthrough 실증).

### 문제점

`cmd_archive()` 코드를 직접 확인한 결과, `queue.md` done 구간의 모든 phase(활성 제외)를 기본값(`--keep=0`)으로 이미 정확히 아카이브 대상에 포함시키고 있다 — **잔존을 "놓치는" 버그는 현재 코드에 없다.** 실제 문제는 순전히 **가시성**이다: `sdd archive` 를 실행하기 전까지는 완료 phase 가 조용히 쌓이기만 하고, 사용자가 그 사실을 알 계기가 `sdd doctor` 를 별도로 실행할 때뿐이다. `sdd status` 는 `/hk-align` 마다 항상 보는 화면인데 여기엔 이 신호가 없다.

### 해결 방안

`_backlog_completed_residue` 를 `sdd status` 의 `_status_diagnose()`(🔍 진단 섹션)에도 연결한다. `cmd_archive()` 자체의 동작은 변경하지 않는다 — 이미 옳게 동작하므로.

## 요구사항

1. `sdd status` 실행 시 완료 phase 중 `backlog/phase-NN.md` 가 잔존하면 🔍 진단 섹션에 `💡 완료 phase N개가 backlog/*.md 로 잔존 (phase-XX, ...) — sdd archive 로 정리 가능` 한 줄을 추가한다.
2. 잔존이 없으면 아무것도 출력하지 않는다(기존 진단 섹션의 "경고가 있을 때만 표시" 관례 유지).
3. 잔존 목록은 `_backlog_completed_residue`(spec-27-02 에서 이미 top-level 공유 헬퍼로 분리됨)를 그대로 재사용한다 — 새 파싱 로직을 만들지 않는다.

## Out of Scope

- `cmd_archive()` 자체의 아카이브 대상 계산 로직 변경 — 코드 확인 결과 이미 정확함(버그 없음). 본 spec 은 가시성만 추가.
- `sdd archive` 를 자동으로 트리거하는 것 — 항상 사용자 명시 실행만 (constitution 자동 정리 금지 원칙).

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] `cmd_archive()` 를 고치지 않기로 한 결정 — 코드 리딩으로 "이미 정확히 동작함"을 확인했고, phase.md 원안(#168 제안 3)의 "sdd archive 가 놓친다"는 서술은 다운스트림 사용자의 과거 버전 경험이거나 관찰 시점 차이로 보임. 실제 개선 지점은 status 가시성.

> [!WARNING]
> - [ ] 없음 — 순수 진단 출력 추가, 기존 동작 변경 없음.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **연결 위치** | `sdd archive` 내부 수정 대신 `sdd status`(`_status_diagnose`) 확장 | archive 는 이미 정확 — 필요한 건 사전 가시성. status 가 `/hk-align` 마다 보이는 실제 접점 |
| **로직 재사용** | `_backlog_completed_residue` 그대로 호출 (spec-27-02 산출물) | 중복 구현 방지 — spec-27-02 walkthrough 의 이월 항목을 그대로 이행 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd`
`_status_diagnose()` 의 "3. specs 디렉토리 수 검사" 블록 뒤에 `_backlog_completed_residue` 호출 + 진단 라인 추가.

#### [MODIFY] `.harness-kit/bin/sdd`
동일 변경 미러.

#### [NEW] `tests/test-status-backlog-residue.sh`
잔존 있음/없음 두 케이스를 fixture 로 검증.

## 검증 계획

```bash
bash tests/test-status-backlog-residue.sh
bash tests/run.sh
```

수동 검증 시나리오:
1. `bash .harness-kit/bin/sdd status` (실 저장소) — 기대 결과: 🔍 진단에 phase-23~26 잔존 안내 등장(spec-27-01/02 는 이미 Merged 지만 phase-27 자체는 아직 활성이라 이 phase 는 안 잡히고, 그 이전 phase-23~26 만 잡힘).

## 롤백 계획

- `git revert` — state 영향 없음. 진단 출력 추가만이라 롤백 리스크 없음.

## ADR 후보

- [ ] ADR 가치 있는 결정 있음 → 후보: 없음
- [x] 없음

## ✅ Definition of Done

- [ ] 모든 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-27-03-archive-residue-detect` 브랜치 push 완료
