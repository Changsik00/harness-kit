# Walkthrough: spec-17-03

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|:---|:---|
| cache 파일 위치 | `.harness-kit/cache.json` / `.claude/state/cache.json` / 별 dir | **`.harness-kit/cache.json`** | install 자산과 grouping. `.harness-kit/` 전체 gitignore 아니라 cache.json 만 별도 무시 |
| Migration 시점 | install.sh / hook 첫 실행 | **hook 첫 실행** | 기존 사용자도 SessionStart 한 번이면 자동. install.sh 변경 회피 |
| Migration 책임 분산 | hook 만 / sdd 만 / 둘 다 | **둘 다 (동일 로직)** | 사용자가 sdd 만 호출하는 시나리오도 가능 — 양쪽 자동 처리 |
| doctor 의 docs/rca/decisions 부재 처리 | check_fail / check_warn / silent skip | **silent skip** | 기존 사용자 (phase-16 산출물 install 안 받음) false negative 0. 존재 시만 검증 |
| phase16-integration fixture slug | `ADR-999-fixture` (spec-16-03 동일) / 다른 slug | **`ADR-999-phase16-integration-fixture`** | spec-16-03 fixture 와 격리 — 동시 실행 race 회피 |
| helper 일반화 task | 포함 / 선택 skip | **skip** | 호출 측 분기로 기능적 충분. 본 spec scope 줄여 momentum 유지 |
| install.sh 변경 | 변경 / hook 만으로 충분 | **hook 만으로 충분** | hook migration 이 모든 케이스 (신규/기존 사용자) 커버. install.sh 변경은 backward compat 추가 risk |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 결정은 모두 *내부 인프라 전술* (파일 위치 / migration 시점). long-lived invariant 가 박힌 결정은 없음 — *워킹트리 cleanliness* 자체는 invariant 후보지만 명시화는 phase-17 종료 시 회고에서.

## 💬 사용자 협의

- **주제**: spec-17-03 scope (3 묶음 + helper 일반화 선택)
  - **사용자 의견**: "그대로 (추천) — 3 묶음 + helper 일반화 선택"
  - **합의**: 3 묶음 필수, helper 일반화는 시간 남으면. 실제 실행 시 helper 일반화는 skip (caller-side branch 기능적 충분).

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 검증
- **명령**: hook + sdd 실행, cache.json 생성/installed.json 정리 확인, doctor 신규 항목 hit
- **결과**: ✅ Passed
- **로그**:
```text
- installed.json: has("lastVersionCheck") = false ✓ (migration 정상)
- cache.json: {lastVersionCheck, latestKnownVersion} 정상 작성 ✓
- gitignore: .harness-kit/cache.json 추가 ✓
- doctor.sh: docs/rca, docs/decisions, rca.md, adr.md 4 항목 hit ✓
```

#### 통합 테스트 (phase-17.md 시나리오 2)
- **명령**: `bash tests/test-phase16-integration.sh`
- **결과**: ✅ Passed (3/3)
- **로그**:
```text
  ✓ Scenario 1: Knowledge Type closure (모든 type 정규 어휘 안)
  ✓ Scenario 2: Stale ADR detection (fixture → drift 라인)
  ✓ Scenario 3: 'reliability layer' 키워드 3 곳 hit
```

#### 회귀 테스트
- `tests/test-sdd-marker-idempotent.sh` — 3/3 PASS ✓
- `tests/test-drift-stale-adr.sh` — 3/3 PASS ✓
- `sdd status` — 정상 출력 + drift 0

### 2. 워킹트리 cleanliness (C3 해소 직접 검증)
- **명령**: `git status --porcelain`
- **결과**: 빈 출력 (변경 파일 수 0)
- **의미**: SessionStart hook 실행되어도 워킹트리 dirty 0. **phase-ship cleanliness 가정 충족** — 매번 `git checkout --` 수동 절차 종식.

## 🔍 발견 사항

- **Hook + sdd 두 곳에 같은 migration 로직 중복** — DRY 원칙 위반이지만 *책임 분리* (hook 은 자기 contract, sdd 는 자기 contract) 가 더 중요. 함수 추상화하면 sourcing 의존 추가. 현 패턴 (각자 inline migration) 이 더 robust.
- **`installed.json` 의 캐시 필드 제거 commit (`e172921`) 이 본 spec 의 첫 *real-world* migration** — 본 저장소 자체의 installed.json 도 migration 대상이었음. 이게 *도그푸딩의 가치* — 다른 사용자 환경에서 일어날 일이 본 저장소에서 자동 시연됨.
- **phase16-integration fixture slug 가 `ADR-999-phase16-integration-fixture`** — spec-16-03 의 `ADR-999-fixture` 와 다른 slug. 만약 두 테스트가 *동시 실행* 되면 양쪽 모두 안전. 명명 규약: 테스트 fixture 는 *spec/phase 식별 prefix* 포함.
- **`doctor.sh` 가 root 의 `doctor.sh` 만 존재 — `.harness-kit/bin/doctor.sh` 부재** — install 미러 동기화 대상 없음. 본 spec 의 doctor 확장은 root 의 doctor.sh 만 손댐. 사용자 환경에서는 install.sh 가 doctor.sh 를 어떻게 처리하는지 확인 필요 (별도 spec).

## 🚧 이월 항목

- `install.sh` / `update.sh` 가 새 installed.json 생성 시 캐시 필드 처음부터 미포함하도록 명시 — hook migration 이 처리하지만 *불필요한 캐시 필드* 가 한 번이라도 들어가는 것 회피 — 별 spec-x
- `sdd_marker_grep` helper 일반화 (Task 7 skip) — Icebox 또는 다음 phase
- `doctor.sh` 의 install 미러 (`.harness-kit/bin/doctor.sh`) — 본 저장소 부재. install.sh 가 doctor 를 어떻게 배포하는지 별도 검토 — Icebox

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-17 |
| **최종 commit** | `1104f99` (Task 6 — doctor.sh 확장) |
| **총 commit 수** | 6 (planning + .gitignore + hook + sdd + test + doctor) — Task 7 skip / Task 8 검증만 |
