# Walkthrough: spec-x-planning-economy

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|:---|:---|
| §planning-economy 위치 | constitution / agent.md / 별 doc | **agent.md §11 (RCA Protocol 다음)** | operational protocol 측면 강함. invariant 핵심만 ADR-002 로 분리. RCA + planning-economy = 둘 다 recurring-pattern governance 라 인접 자연 |
| §planning-economy 언어 | 영어 / 한국어 | **영어** | 거버넌스 영어 원칙 (메모리 `feedback-governance-english`) |
| pre-flight 형태 | gate (강제) / 출력 (주의 환기) | **출력 (주의 환기)** | 비파괴. user 가 무시하면 기존 동작. 강제는 인지 부하 ↑ + cancel 부담 |
| pre-flight 출력 형식 | json / 텍스트 블록 / 한 줄 | **텍스트 3 블록 (`📋 / 📋 / 💡`)** | sdd status emoji 블록 일관 + 시각 분리 + bash 단순 |
| ADR-002 type | decision / invariant / convention | **invariant** | 가장 강제력 — 매 spec 시작 시 재검증 의무가 *항시 유지* property. convention 측면은 본문 Decision 에 부연 |
| ADR-002 본문 언어 | 영어 / 한국어 | **한국어** | ADR-001 일관 (docs/decisions 패턴) |
| `_pre_spec_validation` helper 분리 | 별 함수 / `spec_new` 안 inline | **별 함수** | 테스트 가능성 + 단일 책임 + 향후 다른 sdd 호출 (예: `sdd phase show`) 에서도 재사용 가능 |
| 다음 merged spec 검색 방법 | state.json / phase.md 표 parse | **phase.md 표 parse** | state.json 은 *현재* 만 추적 — *직전* merged 는 phase.md 의 Merged 행 마지막. parse 단순 (awk) |
| ADR-002 의 stale 경로 issue | 회피 / 본 spec scope 외 처리 | **회피만 (`backlog/phase-NN.md` placeholder 제거, `src/foo.ts` 예시 제거)** | 본 spec 은 §planning-economy 박는 것. 템플릿 자체 결함 (W4) 은 별 spec |
| Plan Accept 호출 시점 | 첫 commit 차단 후 / Task 1 직전 선제 | **Task 1 직전 선제 호출** | spec-17-04/05 의 학습 — hook 차단 마찰 회피. memory `feedback-sdd-economy` 자기 적용 (작은 절차 개선) |

### ADR 승격 가이드

- [x] **ADR 승격 대상 있음** → **ADR-002** 작성 완료 (`docs/decisions/ADR-002-planning-economy.md`, type: invariant)
- [ ] 없음

## 💬 사용자 협의

- **주제**: planning 단계 가이드 부재 — 모델 의존도 높음
  - **사용자 의견**: "지난번에 보니깐 커밋 한두개 하는데 sdd 로 진행되어서 보니.. phase 에서 미리 계획 해 놔서 그런거였어.. 다음 sdd 가 이전에 바뀐거에 의해서 검증이 되어야 하는데 그런거 없더라고.. 너무 작은 단위로 pr 을 요청받고.. 하니 토큰 소모가 더 컸어.. sdd 방식이 토큰소모가 크거든.."
  - **합의**: 두 빈 곳 식별 — (1) inter-spec validation 부재, (2) SDD 최소 경제 단위 미정의. memory `feedback-sdd-economy` 저장 + 본 spec-x 로 governance 박음
- **주제**: 재조정 메커니즘 phase 컨텍스트 처리
  - **사용자 의견**: "스펙단위가 크지 않다면 모아서 한번에 진행 phase 스펙이기 때문에 x 보다는 그냥 모아서 하는게 나음. 모을 정도가 아닌데 커밋할게 남았다면 phase 에 ff 로 바로 진행"
  - **합의**: 4 옵션 (drop / bundle / phase FF / 계속) — phase 컨텍스트에서 spec-x demote 회피, bundle/phase FF 우선
- **주제**: RCA / ADR 적용 여부
  - **사용자 의견**: "이전에 개발해 놓은 RCA, ADR 이 기능이 적용되는건가?"
  - **합의**: ADR 강하게 적용 (ADR-002 작성), RCA 약함 (단 1 회 관찰 — recurring 아님. ADR Context 인용 으로 충분)
- **주제**: scope / slug
  - **사용자 의견**: "A 로 진행하는데", "planning-economy 로 진행"
  - **합의**: spec-x (phase 없음) / slug = planning-economy / Plan Accept 받음

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 검증
- **명령**: 각 변경 항목 grep / diff
- **결과**: ✅ Passed
- **로그**:
```text
- agent.md §11: sources / mirror 각 1 hit ("Planning Economy") + diff 0
- sdd _pre_spec_validation: sources / mirror 각 2 hit + diff 0 + bash -n 통과
- ADR-002: id=ADR-002, type=invariant, frontmatter OK
- ADR-002 stale 경로: 3 backtick (sources/governance/agent.md, sources/commands/hk-update.md, .harness-kit/cache.json) 모두 valid
```

#### 통합 테스트 (Integration Test Required = no — governance/CLI 신규)
- 자체 새 통합 테스트 없음. 기존 phase-17 통합 테스트 회귀 확인.

#### 회귀 테스트 (4 종)
- `tests/test-sdd-marker-idempotent.sh` — 3/3 PASS ✓
- `tests/test-drift-stale-adr.sh` — 3/3 PASS ✓ (ADR-002 포함 clean state)
- `tests/test-phase16-integration.sh` — 3/3 PASS ✓
- `tests/test-phase17-integration.sh` — 3 passed / 1 skipped ✓
- `sdd status` — drift 0 + 워킹트리 clean ✓

### 2. pre-flight 비파괴 검증

- **시나리오**: main 또는 spec-x 진행 중 (phase 없음) 상태에서 `_pre_spec_validation` 호출
- **결과**: `[ -z "$phase_id" ] || [ "$phase_id" = "null" ] && return 0` early-exit — 출력 없음 + 기존 `spec_new` 동작 무영향
- **의미**: 본 spec 머지 후 다른 사용자 환경 (phase 없는 상태) 에 영향 0. 점진 도입.

### 3. ADR-002 stale 경로 fix 직접 검증

- **첫 commit 직후**: `bash tests/test-drift-stale-adr.sh` Step 1 가 `stale ADR: 1` 라인 detected → ADR-002 의 `backlog/phase-NN.md` (placeholder) + `src/foo.ts` (Note 예시) 가 원인
- **fix**: placeholder 를 plain text 로, Note block 의 예시 제거
- **결과**: 3/3 PASS — clean state. commit amend 로 단일 commit 유지 (One Task = One Commit)

## 🔍 발견 사항

- **spec-17-04 W4 의 ADR 템플릿 Note 블록 자체가 stale 검사 trigger** — `예: src/foo.ts` 인라인 backtick + 슬래시 + 확장자 → stale ADR 검사 hit. 모든 신규 ADR 이 같은 issue 가질 잠재성. 본 spec 의 ADR-002 가 *처음 부딪힘*. **이월 항목** (Note block 표기 fix 별 spec) — 대안: 예시를 backtick 없이 평문, 또는 슬래시 없는 짧은 form (`foo.ts`).
- **`_pre_spec_validation` 의 검증 환경 제약** — main 또는 spec-x 진행 중에는 phase 없어 실 시연 어려움. 본 spec 머지 후 *다음 phase 의 첫 spec 진행 시* 자연 발현이 첫 실 검증.
- **Plan Accept 선제 호출 패턴 안착** — spec-17-04 의 Task 3 commit 차단 학습 → spec-17-05 부터 적용 → 본 spec 도 Task 1 직전 선제 호출. *마찰점 → 작업 습관* 전환 사례. 메모리 자동화는 후속.
- **stale 검사가 새 ADR 부닥치는 것이 결과적으로 *방어선 작동* 증거** — ADR-002 의 placeholder 가 즉시 잡혔음. 도구가 *실제 일함* 의 증거 (spec-17-04 W4 의 "도구가 일하는 척만" 우려 부분 해소).

## 🚧 이월 항목

- **ADR 템플릿의 Note block 예시 `src/foo.ts` 표기 fix** — 모든 신규 ADR 이 stale 검사 trigger. 별 spec (예: spec-x-adr-template-note-fix) 또는 다음 phase 의 docs sweep 으로 처리. 우선순위 중 — 새 ADR 자주 작성될 때 누적
- **`_pre_spec_validation` 실 시연 fixture** — phase + Merged spec 1 개 fixture 작성으로 자동 테스트 가능. 본 spec 은 *비파괴* 만 확인. fixture 테스트는 별 spec
- **agent.md §11 의 *모드 추정 보고* (§11.2 마지막 줄) 자기 적용** — 본 spec 부터 `/hk-align` / alignment 응답에서 "이 작업은 [FF / spec-x / spec / bundle] 권장" 1 줄 자기 보고 시작. 메모리 또는 hk-align skill 강화로 추가 박음 가능

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-17 |
| **최종 commit** | `fbc13c3` (Task 4 — ADR-002 amend 포함) — Task 5 검증만 / Task 6 ship 본 commit |
| **총 commit 수** | 5 (planning + agent.md + sdd + ADR-002 + ship) |
| **출처** | 사용자 피드백 (planning 가이드 부재 + SDD 토큰 비용) + phase-17 회고 (spec-17-03 누수 미발견 패턴) |
