---
description: 지금 무엇을 해야 하나 — sdd 상태 기반 다음 행동 1 줄 안내
---

> 가벼운 진입점입니다. 세션 시작 시에는 `/hk-align` (전체 부트스트랩),
> 작업 중에는 `/hk` (현재 상태 기반 다음 행동 1 줄 안내).

## 1. 현재 상태 확인

다음 단일 명령으로 현재 상태를 파악합니다:

```bash
bash .harness-kit/bin/sdd status
```

출력에서 다음 정보를 추출합니다:
- **Active Phase** (phase-N 또는 "없음")
- **Active Spec** (spec ID 또는 "없음")
- **NEXT** (다음 spec ID 또는 "없음")
- **Plan Accept** (yes / no)
- **Artifacts** (`✓ spec ✓ plan ✓ task ✓ walkthrough ✓ pr_description` 같은 라인 — `(Ship-ready)` / `(Executing)` 마커 포함 여부)

## 2. 상태 매핑 (8 가지 분기)

위 정보를 다음 표로 분기합니다. *정확히 한 상태*만 매칭되어야 합니다. 매칭되지 않으면 마지막 fallback 으로.

| # | 조건 | 출력 (현 상태 1 줄 + 다음 행동 1 줄) |
|---|------|---------------------------------|
| 1 | Active Phase 없음 | 📍 Active phase 없음<br>→ 새 phase 시작: `/hk-align` 또는 `sdd phase new <slug>` |
| 2 | Phase 있음 / Spec 없음 / NEXT 있음 (다음 Backlog spec 존재) | 📍 phase-N 진행 중, spec 대기<br>→ 다음 spec 시작: `sdd spec new <slug>` (NEXT: `<id>`) |
| 3 | Phase 있음 / Spec 없음 / NEXT 없음 (전 spec Merged) | 📍 phase-N 의 전 spec Merged<br>→ Phase ship: `/hk-phase-ship` |
| 4 | Phase 있음 / Spec 있음 / planAccepted=no / artifacts 미완 (spec/plan/task 중 ✗) | 📍 spec 작성 중 (`<spec-id>`)<br>→ spec/plan/task 작성 필요 — task.md 의 Pre-flight 항목 확인 |
| 5 | Phase 있음 / Spec 있음 / planAccepted=no / artifacts ✓ spec ✓ plan ✓ task | 📍 spec 작성 완료, Plan Accept 대기<br>→ `/hk-plan-accept` (또는 비판 원하면 `/hk-spec-critique`) |
| 6 | Phase 있음 / Spec 있음 / planAccepted=yes / `(Executing)` 또는 walkthrough/pr_description 중 ✗ | 📍 Strict Loop 진행 중 (`<spec-id>`)<br>→ task.md 의 다음 task 실행. 모든 task 완료 시 walkthrough/pr_description 작성 |
| 7 | Phase 있음 / Spec 있음 / planAccepted=yes / `(Ship-ready)` 또는 전 artifacts ✓ | 📍 Ship 준비 완료 (`<spec-id>`)<br>→ Ship: `/hk-ship` |
| 8 | (fallback) sdd 출력 없음 / 파싱 실패 / 매핑 불가 | 📍 상태 확인 불가<br>→ `bash .harness-kit/bin/sdd status` 수동 확인 후 적절한 슬래시 커맨드 호출 |

## 3. 출력 형식

위 표의 *해당 상태 1 행* 을 그대로 사용자에게 출력합니다. 추가 설명 / 권고 / 질문 금지 — *1 줄 요약 + 1 줄 행동*만.

추가로 다음 두 가지가 있으면 별 줄에 1 줄 더:
- **drift / 진단 경고**: sdd status 의 "🔄 동기화 상태" / "🔍 진단" 섹션에 경고가 있으면 *가장 중요한 1 줄* 만 (예: "원격: behind 3 — git pull 권장").
- **유효한 NEXT**: 상태 2/3 의 경우 NEXT spec ID 명시 (상태 표에 이미 포함됨).

예시 출력 (상태 4 — 현재 spec-17-02 작성 중):

```
📍 spec 작성 중 (spec-17-02-accessibility-install-and-entry)
→ spec/plan/task 작성 필요 — task.md 의 Pre-flight 항목 확인
```

예시 출력 (상태 7 — Ship 준비):

```
📍 Ship 준비 완료 (spec-17-02-accessibility-install-and-entry)
→ Ship: /hk-ship
```

## 4. 절대 하지 말 것

- *어떤 슬래시 커맨드를 호출할지 사용자에게 묻기* — `/hk` 는 *추천만*, 실행은 사용자가 별 슬래시 커맨드 호출.
- *state 변경 동작* (Plan Accept / Ship / phase done 등) — `/hk` 는 read-only.
- *긴 설명* — 13 개 슬래시 커맨드 안내를 회피하려고 만든 진입점이라, 본인이 또 정보 폭주하면 무의미.
- *`/hk-align` 처럼 무거운 부트스트랩* — `/hk` 는 가벼움. constitution 로딩 / 단 하나의 질문 같은 절차 불필요.
