# Walkthrough: spec-x-phase-16-define

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 외부 진단(8 문제) + 추가 제안서(5 축 + 5 차별화 + 포지셔닝) 를 어떻게 백로그화할까 | A. 항목별 spec-x 분산  /  B. Phase 한 개로 묶기  /  C. Icebox 한 줄로만 | **B** | 항목 간 의존성(Type 슬롯 → ADR 트리거 → Stale 탐지) 이 명확하고 통합 테스트가 *일관성 회로* 형태라 phase 단위가 자연스러움. Icebox 한 줄은 *실행 단위 결정* 을 미래로 미룸 → 시작 시 재분해 비용. |
| Phase 활성화 여부 | activate(`sdd phase activate phase-16`)  /  대기 상태로만 등록 | **대기 상태로만** | 사용자 의도가 "백로그에 넣자". 우선순위 비교 가능한 형태 유지. 시작 시점은 별도 결정. |
| Knowledge Type 슬롯을 별도 spec 으로 둘지 | A. spec-16-01 에 흡수 / B. 별도 spec | **A** | RCA 가 type 슬롯의 *첫 사용자*. 별도 spec 으로 빼면 *형식만 정의하고 사용자 없음* dead letter 위험. |
| 외부 진단의 어떤 항목까지 phase 에 넣을지 | 8 문제 전부 / 갭이 큰 4 개만 | **갭이 큰 4 개만 (+1 포지셔닝)** | Context Kernel / Capability matrix / Cost routing 은 본 키트 *thin orchestration* 철학과 정면 충돌 — 본 phase 의 위험 요소 표에 *명시적으로 거름* 으로 박음. |
| Phase base branch 사용 | 사용 / 미사용 | **미사용** | 4 spec, 의존 약함, 통합 테스트 매뉴얼 영역. base branch 오버헤드 > 가치. |
| spec-x 의 산출물 commit 순서 | spec/plan/task 를 *처음* commit / 마지막 합쳐 commit | **마지막 합쳐 commit** | 직전 spec-x-readme-refresh 작업에서 `sdd ship` 이 spec/plan/task 를 add 안 해 사후 commit 이 필요했던 *동일 패턴* 을 의식적으로 재현 — 별도 sdd 개선 spec 후보 (본 phase 외). |

## 💬 사용자 협의

- **주제**: 외부 글(velog) + 추가 제안서를 어떻게 키트에 반영할지
  - **갭 분석 결과**: RCA / ADR 활성화 / Knowledge Type / Stale 탐지 / 포지셔닝 5 영역이 *얇게* 도입 가능.
  - **합의**: "백로그에 phase 단위로 넣자." 추가 제안서 중 *Workflow engine 함정* 류 (Context Kernel / Capability matrix / Cost routing) 는 *의식적으로 거름*.
- **주제**: 모드 결정
  - **합의**: SDD-x PR (정석) — phase 정의 자체를 PR 받아 리뷰 가능 형태로.
- **주제**: Spec 분해
  - **합의**: 4 spec — RCA+Type / ADR 트리거 / Stale 탐지 / 포지셔닝.
- **주제**: 슬러그
  - **합의**: `reliability-layer` (포지셔닝 슬로건과 일치).

## 🧪 검증 결과

### 1. 자동화 테스트
- 본 spec 은 docs only — 자동 테스트 없음.

### 2. 수동 검증

1. **Action**: `grep -c "spec-16-" backlog/phase-16-reliability-layer.md`
   - **Result**: `21` (≥ 4) — 4 개 spec 후보가 표 + 상세 + 통합 테스트 / 결정 기록에 일관되게 박혀 있음을 확인.
2. **Action**: `bash .harness-kit/bin/sdd status --no-drift`
   - **Result**: `Active Phase: 없음` 유지. 본 spec-x 만 active 표시 (`spec-x-phase-16-define`). 의도대로 phase-16 은 *대기*.
3. **Action**: `git diff main --stat`
   - **Result**: 2 file changed — `backlog/phase-16-reliability-layer.md` 신규(+163) / `backlog/queue.md` (+2/-1). spec-x 산출물은 ship commit 으로 별도 처리 예정. plan 범위와 일치.

## 🔍 발견 사항

- **메타 검증**: 외부 진단(8 문제) + 추가 제안서(5 축 + 5 차별화) 의 *대부분* 이 본 키트의 thin orchestration 철학으로 이미 대응되거나 *의도적으로 거를* 영역이었다. 갭이 *진짜* 큰 영역은 (a) RCA 시스템, (b) type 슬롯 정규화, (c) ADR 활성화 — 즉 *지식 시스템* 부분에 집중되어 있었다.
- **포지셔닝 슬로건의 가치**: "A reliability layer for AI-assisted engineering" 은 본 키트의 *진짜 정체* 와 정확히 일치. spec-16-04 에서 어디에 박을지 결정 필요 (한영 비율, README 상단 / 부제 / `version.json` 등).
- **sdd ship 의 spec/plan/task add 누락**: 직전 spec-x-readme-refresh 에서도 동일 패턴 — `sdd ship` 이 walkthrough/pr_description 만 add. 별도 sdd 개선 spec 후보로 인지 (본 phase 외 spec-x 영역).

## 🚧 이월 항목

- 없음 (본 spec-x 는 phase 정의 + queue 등록까지). phase-16 의 실제 실행은 별도 시점.
- 메모만: *sdd ship 이 spec/plan/task 도 add 하도록 보강* — spec-x 후보로 인지 (현재 backlog 등록 보류).

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-15 |
| **최종 commit** | `e58079a` (ship 전 기준) |
