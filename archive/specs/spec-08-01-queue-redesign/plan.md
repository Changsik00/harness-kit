# Implementation Plan: spec-08-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-08-01-queue-redesign`
- 시작 지점: `main` (phase-08-work-model 브랜치는 hk-ship 시점에 just-in-time 생성)
- PR 타깃: `phase-08-work-model` (첫 hk-ship 시 자동 생성 후 타깃 지정)

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] queue.md 마커 구조 변경 — sdd가 관리하는 마커가 추가됨 (`sdd:now`, `sdd:next`, `sdd:specx`, `sdd:icebox`)
> - [ ] `sdd queue` 출력 방식 변경 — raw cat → 구조화 출력 (기존 raw 출력이 필요하면 `--raw` 플래그 추가 가능)

> [!WARNING]
> - [ ] 기존 `backlog/queue.md` 포맷이 바뀜 — 현재 sdd 마커와 신규 마커 공존 구간이 있음. 도그푸딩 반영 시 수동 편집 필요.

## 🎯 핵심 전략

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **NOW/NEXT 데이터 소스** | state.json(NOW) + phase.md 파싱(NEXT) | 별도 state 추가 없이 기존 파일 활용 |
| **NEXT 계산** | phase.md spec 표에서 첫 `Backlog` 행 탐색 | 단순 grep으로 구현 가능, 파싱 비용 최소 |
| **Icebox 관리** | queue.md 수동 섹션 — sdd가 건드리지 않음 | Icebox는 사람이 판단해서 넣고 꺼내는 영역 |
| **sdd queue 출력** | 구조화 출력 (색상 + NOW/NEXT 강조) | raw cat보다 포커스 명확, `--raw` 옵션으로 fallback |

### 변경 흐름

```
1. constitution 모델 정의
      ↓
2. queue.md 템플릿 재설계 (마커 추가)
      ↓
3. phase.md 템플릿 In Progress 상태 추가
      ↓
4. sdd status: NEXT 계산 로직 추가
      ↓
5. sdd queue: 구조화 출력 로직 추가
      ↓
6. 도그푸딩 반영 (agent/constitution.md, backlog/queue.md)
```

## 📂 Proposed Changes

### [거버넌스]

#### [MODIFY] `sources/governance/constitution.md` + `agent/constitution.md`
§2 (Work Modes) 뒤에 **§3 작업 유형 정의 (Work Type Model)** 섹션 추가:
- Phase, Spec, spec-x, Icebox 각각: 역할, 진입 조건, 종료 조건, 식별자 규칙 참조

기존 §3 이후 번호 순차 변경.

### [템플릿]

#### [MODIFY] `sources/templates/queue.md`
현재 구조를 아래로 교체:

```markdown
## 🔴 NOW
<!-- sdd:now:start -->
없음
<!-- sdd:now:end -->

## ⏭ NEXT
<!-- sdd:next:start -->
없음
<!-- sdd:next:end -->

---

## 📦 진행 중 Phase
<!-- sdd:active:start -->
없음
<!-- sdd:active:end -->

## 📥 spec-x 대기
<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox
<!-- 수동 관리: sdd가 이 섹션을 건드리지 않음 -->

## 📋 대기 Phase
<!-- sdd:queued:start -->
<!-- sdd:queued:end -->

## ✅ 완료
<!-- sdd:done:start -->
<!-- sdd:done:end -->
```

#### [MODIFY] `sources/templates/phase.md`
- spec 표 상태 컬럼 허용값에 `In Progress` 추가
- 메타 테이블에 `**Base Branch**` 행 추가 (값: `없음` 또는 `phase-N`)

### [sdd 도구]

#### [MODIFY] `sources/bin/sdd`

**`cmd_status()` 변경**:
- NEXT 계산 함수 `compute_next_spec()` 추가
  - active phase의 phase.md 읽기
  - `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이에서 `| Backlog |` 첫 행 추출
  - active spec과 동일한 행은 스킵
- `sdd status` 출력에 `NEXT: <spec-id>` 행 추가 (Active Spec 아래)

**`cmd_queue()` 변경**:
- raw cat 제거
- NOW/NEXT/Phase진행률/Icebox 섹션 구조화 출력
- `--raw` 플래그 추가 시 기존 cat 동작

**`update_queue_now_next()` 추가**:
- state.json 변경 시(plan accept, spec done 등) sdd:now, sdd:next 마커 자동 갱신

### [도그푸딩]

#### [MODIFY] `backlog/queue.md`
신규 마커 구조로 수동 재작성 (sdd가 아직 자동 갱신 못 하므로 이 commit에서 수동 반영)

#### [MODIFY] `agent/constitution.md`
sources/governance/constitution.md 변경 내용 반영

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-queue-redesign.sh
```

테스트 케이스:
- `sdd status` 출력에 `NEXT:` 행 포함 여부
- Backlog spec이 없을 때 NEXT = `없음` 출력
- `sdd queue` 출력에 `🔴 NOW`, `⏭ NEXT`, `🧊 Icebox` 섹션 포함 여부
- `sdd queue --raw`는 queue.md raw 출력

### 수동 검증 시나리오
1. `sdd status` 실행 → `NOW: spec-08-01-queue-redesign`, `NEXT: spec-08-02-phase-base-branch` 출력 확인
2. `sdd queue` 실행 → NOW/NEXT/Icebox 섹션 구조 확인
3. `sdd queue --raw` 실행 → queue.md 원문 그대로 출력 확인

## 🔁 Rollback Plan

- constitution 변경은 git revert로 즉시 복구 가능
- queue.md 마커 변경은 이전 포맷으로 수동 복구 (마커만 변경, 내용은 보존)
- sdd 스크립트는 단일 파일이므로 git revert 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
