# Walkthrough: spec-17-04

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|:---|:---|
| W1 §6.4 변경 범위 | closure 어휘 자체 변경 / "Used in" 열만 명확화 | **"Used in" 열만 명확화 + Rules 1 항 부연** | closure 5 어휘 자체는 안정 — 표 표현 모호성만 문제. ADR 승격 불필요 |
| W1 표 마크 형식 | "ADR 전용/공유" 한글 / "ADR only / shared" 영어 | **영어 (`ADR only` / `RCA only` / `+ ... (shared)`)** | 거버넌스 문서 영어 원칙 (메모리 `feedback_governance_english`) |
| W3 fixture slug | `ADR-999-valid` / `ADR-998-valid-paths-fixture` | **`ADR-998-valid-paths-fixture`** | spec-16-03 의 ADR-999-stale-fixture + spec-17-03 의 ADR-999-phase16-integration-fixture 와 다른 번호. trap cleanup 다중 안전 |
| W3 fixture 본문 경로 | 임의 valid / 항상 존재하는 핵심 파일 | **`sources/bin/sdd`, `README.md`, `version.json`** | 저장소 이동/삭제 가능성 0 인 핵심 파일 — fixture 자체가 false positive 안 나도록 |
| W4 가이드 위치 | frontmatter 다음 / Context 섹션 안 / Related 섹션 끝 | **`# ADR-...` 헤더 직후, Context 앞** | 작성자가 본문 시작 시 가장 먼저 보는 위치 — 표기 룰 인지 후 작성 시작 |
| W4 가이드 톤 | 강제 룰 ("MUST") / 권고 (Note) | **권고 (Note)** | spec-16-03 의 의도된 한계 (검사 로직 확장 아님) — 정보 노출만이 목적. 강제 어조 부적합 |
| W7 룰 위치 | 별 섹션 신설 / 기존 "릴리스 전략 → 룰" 하위 bullet | **기존 "릴리스 전략 → 룰" 하위 bullet** | 본 룰은 *릴리스 전략의 일부* — 별 섹션은 과도. 1 bullet 으로 충분 |
| W7 적용 시점 | 본 spec 에서 즉시 CHANGELOG draft 작성 / 룰만 추가 | **룰만 추가** | spec-16/17 의 phase-ship 은 이미 끝났음. 다음 release commit + post-phase-17 ship 이 첫 실증 — 본 spec 은 backfill scope 제외 |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 4 항목 모두 *문서 표현 명확화* / *테스트 fixture 분리* / *단발 룰 추가*. closure 어휘 자체나 stale 검사 *로직* 변경 없음. 장기 invariant 박힌 결정 없음.

## 💬 사용자 협의

- **주제**: spec-17-04 scope (W1/W3/W4/W7 묶음 cleanup)
  - **사용자 의견**: "그대로 진행"
  - **합의**: 4 항목 한 spec — 7 task / 6 commit. integration test 추가 없음. 본 spec 은 cleanup 묶음.
- **주제**: Plan Accept
  - **사용자 의견**: "Accept — 실행 시작"
  - **합의**: Task 1 (브랜치 + planning commit) 부터 자동 진행 (auto-task-execution 메모리 적용).

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 검증
- **명령**: 각 변경 항목 grep 검증
- **결과**: ✅ Passed
- **로그**:
```text
- §6.4 표 "Used in" 열 마크: sources / mirror 각 5 hits (`ADR only` / `RCA only` / `(shared)`)
- ADR 템플릿 stale 가이드: sources / mirror 각 1 hit ("stale ADR 검사 대상")
- CLAUDE.md CHANGELOG 룰: 1 hit ("Phase ship 시 CHANGELOG draft")
- install mirror sync: constitution.md / adr.md 양쪽 diff 0 (sync ok)
```

#### 회귀 테스트
- `tests/test-sdd-marker-idempotent.sh` — 3/3 PASS ✓
- `tests/test-drift-stale-adr.sh` — 3/3 PASS ✓ (Step 3 가 ADR-998 fixture 사용)
- `tests/test-phase16-integration.sh` — 3/3 PASS ✓
- `sdd status` — drift 0 + 워킹트리 깔끔 ✓

### 2. W3 fixture-independence 직접 검증
- **시나리오**: ADR-001 본문에 임시 stale 경로 추가 → 테스트 재실행 → ADR-001 본문 복원
- **결과**: Step 1 (clean state) 가 stale 라인을 잡아냄 — 의도된 동작. Step 3 의 *assertion* 은 더 이상 ADR-001 의 valid 상태에 *의도적으로* 의존하지 않음 (fixture 의 valid path 만 검증).
- **의미**: ADR-001 의 *정상* 갱신 (valid path 만 추가) 시 Step 3 영향 0. 회귀 마커가 fixture self-contained 화 — *외부 데이터 결합* 해소.

## 🔍 발견 사항

- **stale 검사는 *전역* 동작** — ADR 디렉토리 전체를 스캔하므로, fixture 가 valid 여도 다른 ADR 에 stale 이 있으면 같이 잡힘. W3 의 fix 는 *fixture 가 false positive 안 나도록* + *test assertion 의 의도가 ADR-001 에 종속 안 함* 까지가 한계. 진정한 격리는 temp dir 안 isolated run 이 필요 (Icebox).
- **§6.4 표의 영어/한글 혼용 위험** — 표 본문은 영어인데 "전용/공유" 한글 마크를 끼우면 일관성 깨짐. 영어 (`only`, `+ ... (shared)`) 통일 — 거버넌스 영어 원칙 (메모리 `feedback_governance_english`) 자연 적용.
- **W7 의 `## [Unreleased]` 섹션 부재** — 현 CHANGELOG.md 에는 [Unreleased] 섹션이 없음. 본 룰 신설 시점에 phase-17 phase-ship + 다음 release 가 둘 다 진행 중 — phase-17 phase-ship 시 [Unreleased] 신설 + draft entry 첫 작성이 본 룰의 첫 실증. 본 spec scope 에서는 룰 텍스트만.
- **Plan Accept 누락 → check-plan-accept hook 차단** — Task 3 commit 시 처음 hit. 사용자 verbal accept 후 `sdd plan accept` 호출 누락. hook 가 정상 차단 — 이건 *바람직한* 안전장치 동작. 향후 AskUserQuestion "Accept" 응답 직후 `sdd plan accept` 호출 표준화 필요 (별 spec / 메모리).

## 🚧 이월 항목

- **CHANGELOG.md phase-16 / phase-17 backfill 작성** — 본 spec 은 *룰만*. 실제 entry 는 phase-17 phase-ship + 다음 release commit 시점.
- **stale 검사의 isolated run (temp dir)** — 진정한 회귀 마커 격리. 본 spec 범위 초과 — Icebox.
- **`AskUserQuestion → Accept → sdd plan accept` 자동화** — 본 spec 진행 중 발견된 *프로세스 마찰점*. 별 spec 또는 hk-align/hk-plan-accept skill 보강.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-17 |
| **최종 commit** | `b757969` (Task 5 — W7 CHANGELOG 룰) — Task 6 검증만 / Task 7 ship 본 commit |
| **총 commit 수** | 6 (planning + W1 + W3 + W4 + W7 + ship) |
