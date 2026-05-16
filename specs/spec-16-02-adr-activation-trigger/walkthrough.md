# Walkthrough: spec-16-02

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

> 작업 중 이슈가 발생했을 때, 어떤 선택지가 있었고 왜 이 방향을 결정했는지 기록합니다.

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 트리거 강제 수준 | A. ship 시 미체크 차단 / B. 권장만 | **B** | constitution §6.4 "얇은 보강" 철학 일관. 강제는 채택 저항 ↑. *접점 노출* 이 목적 |
| 체크 형태 | A. frontmatter 필드 / B. 본문 체크박스 | **B** | spec 마다 ADR 결정 0~1 개로 sparse — frontmatter 부적합. 본문 체크박스는 3 산출물 동일 문구로 grep 가능 |
| 첫 ADR 포함 | A. 트리거만 / B. ADR-001 까지 | **B** | 트리거가 *살아있는지* 검증하려면 첫 사용자 필요. RCA-001 이 RCA 트리거의 실증인 것과 대칭 |
| critique 통합 깊이 | A. 자동 식별 / B. 체크 섹션 | **B** | sub-agent prompt 비용 회피. 식별은 reviewer 판단 — 비강제 철학 일관 |
| walkthrough → ADR 추출 자동화 | A. `sdd adr suggest` 도구 / B. 가이드 문서 | **B** | 자동화는 spec-16-03 stale 탐지와 묶어 검토 — 본 spec 의 *얇은 보강* 범위 밖 |
| Planning 산출물 commit 형태 | A. 첫 feat 와 묶음 / B. 별도 chore | **B** | One Task = One Commit 원칙 깔끔. 후속 reviewer 가 "planning vs implementation" 분리 가능 |

### ADR 승격 가이드

> 위 결정 중 *cross-spec / long-lived* 인 것이 있다면 ADR 로 승격합니다 (constitution §6.3).

- [x] ADR 승격 대상 있음 → 작성됨: `docs/decisions/ADR-001-knowledge-types.md`
  - 다만 ADR-001 은 spec-16-01 의 *Knowledge Type Vocabulary* 결정에 대한 ADR 이지, 본 spec 의 결정에 대한 것이 아님. 본 spec 의 결정들은 *얇은 보강* 의 일부로, 단독 ADR 로 박을 가치는 낮다고 판단 (예: "본문 체크박스 vs frontmatter" 는 본 spec scope 내 전술적 결정).
- [ ] 없음

## 💬 사용자 협의

- **주제**: 4가지 핵심 결정 (강제 수준 / 체크 형태 / 첫 ADR 포함 / critique 깊이)
  - **사용자 의견**: "추천대로 굳히고 진행해" — agent 가 제시한 4가지 추천안을 일괄 수락
  - **합의**: B / B / B (포함) / B (체크 섹션만) — plan.md User Review Required 4 항목으로 박힘
- **주제**: phase-16 진행 우선순위 (spec-16-01 ship 후)
  - **사용자 의견**: "phase-16 먼저 완주" — 접근성 개선 Phase 는 Icebox 에 유지, phase-16 잔여 3 spec 순차 진행
  - **합의**: spec-16-02 → 16-03 → 16-04 순서. 접근성 개선은 phase-16 done 후 alignment 진입

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (grep / diff 기반)
- **명령**: `plan.md §검증 계획` 의 5 항목 일괄 실행
- **결과**: ✅ Passed (5/5)
- **로그 요약**:
```text
=== 1. 트리거 헤더 grep ===           ✓ spec/plan/walkthrough 3 군데 hit
=== 2. install 미러 diff ===            ✓ adr/spec/plan/walkthrough/hk-spec-critique/constitution 모두 동일
=== 3. ADR-001 type ===                 ✓ type: decision
=== 4. type closure ===                 ✓ decision + failure-pattern 만 (정규 어휘 집합 닫힘)
=== 5. critique prompt ===              ✓ "ADR 후보 추출" 2 군데 (prompt 본문 + 출력 형식)
```

#### 통합 테스트
Integration Test Required = no. Phase 레벨 통합 시나리오 1 (Knowledge Type 일관성) 은 phase-ship 시점에 별도 수행.

### 2. 수동 검증

1. **트리거 노출 확인** — `.harness-kit/agent/templates/spec.md` 출력에 "📑 ADR 후보" 섹션 49 줄에 박힘. ✓
2. **critique 출력 형식 확인** — `.claude/commands/hk-spec-critique.md` 출력 형식에 "## 4. ADR 후보 추출" 99 줄에 박힘 (실제 호출은 미실행 — 형식만 검증). ✓
3. **ADR-001 가독성** — 5 섹션 (Context / Decision / Consequences / Alternatives / Status) 모두 채워짐. Status 섹션에 첫 사용자 (RCA) / 두 번째 사용자 (ADR) 명시. ✓

## 🔍 발견 사항

- **`sdd ship` marker append 버그 (선행 spec-16-01 ship 시 발견)**: phase-16.md 의 Backlog 행을 *업데이트* 하지 않고 Merged 행을 *append* 하여 spec 표 중복 + NEXT 오인. spec-16-01 ship 시 manual workaround 필요했음. RCA 후보로 `backlog/queue.md` Icebox 에 기록됨 — phase-16 완주 후 별 spec 으로 fix 검토.
- **planning 산출물 commit timing**: sdd 의 기본 task.md 템플릿은 "브랜치 생성 only commit 없음" 이지만, spec/plan/task 파일이 commit 안 되어 첫 feat commit 까지 dangling 상태. 본 spec 에선 Task 1-2 로 "chore: planning artifacts" 단계를 추가. 향후 task.md 템플릿 보강 후보.
- **트리거 강제 vs 비강제 의 후속 효과**: 비강제로 굳혔지만, 후속 spec 의 walkthrough.md 들이 "ADR 승격 대상 있음" / "없음" 어느 쪽도 체크하지 않으면 *접점 자체가 죽는다*. spec-16-04 (reliability-positioning) 시점에 6 개 spec 의 walkthrough 를 sweep 하여 ratio 측정 권장 — 0% 면 강제 수준 재논의.

## 🚧 이월 항목

- `sdd ship` marker append 버그 → `backlog/queue.md` Icebox 에 추가됨 (RCA 후보)
- 접근성 개선 Phase (`curl ... | bash` + `/hk` 진입점 + README) → `backlog/queue.md` Icebox 에 추가됨 (phase-16 완주 후 alignment)
- task.md 템플릿에 "planning artifacts commit" 단계 명시 → spec-16-04 또는 별 spec-x 에서 보강 검토

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-16 (단일 세션) |
| **최종 commit** | `e2bc223` (Task 6 — ADR-001 작성) |
| **총 commit 수** | 9 (planning + adr template ×2 + trigger ×3 + critique + constitution + ADR-001) |
