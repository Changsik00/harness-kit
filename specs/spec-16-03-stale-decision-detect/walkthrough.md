# Walkthrough: spec-16-03

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

> 작업 중 이슈가 발생했을 때, 어떤 선택지가 있었고 왜 이 방향을 결정했는지 기록합니다.

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Scope 범위 | A. missing-path + TTL 둘 다 / B. missing-path 만 / C. TTL 만 / D. RCA 도 포함 | **B (missing-path 만)** | TTL 은 임의적, false positive 우려. phase-16.md 시나리오 2 는 missing-path 가 핵심. RCA 는 *failure 기록* 으로 stale 의미 다름 — 별 spec 으로 분리 |
| 경로 추출 휴리스틱 | A. 모든 backtick 토큰 / B. 슬래시 포함 / C. 슬래시 + 확장자/끝슬래시 + URL 제외 | **C (가장 좁게)** | 첫 ADR 인 ADR-001 본문에 `obj.method`, `text` 같은 비-경로 backtick 다수. 좁은 규칙으로 false positive 회피 |
| 출력 위치 | A. 별 drift 라인 / B. 별 섹션 신설 | **A** | 5 카테고리 drift 와 동일 형식 일관. 별 섹션은 *과시* — 정보 가치 대비 시각적 비용 ↑ |
| 출력 list 형식 | A. 모든 ADR 경로 / B. 최대 3 개 + "…" | **B** | 다수 ADR stale 시 한 줄이 폭주. 3 개 cap 으로 시각적 무결성 유지 |
| TDD test 호출 대상 | A. sources/bin/sdd / B. .harness-kit/bin/sdd | **B (install 미러)** | 도그푸딩 환경에서 *사용자가 실제로 실행하는 바이너리* 가 install 미러. test 가 진짜 사용 경로 검증 |
| 구현 + sync 분리 | A. 한 commit / B. 두 commit (sources / install) | **B** | 도그푸딩이라 둘 다 손대지만 *논리적 단위* 분리 명확 — Task 3=구현, Task 4=동기화 |

### ADR 승격 가이드

> 위 결정 중 *cross-spec / long-lived* 인 것이 있다면 ADR 로 승격합니다 (constitution §6.3).

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 결정들은 *전술적* (sub-구현 선택). "regex 휴리스틱" 은 *수정 가능한 휴리스틱* 이지 long-lived invariant 아님. 정말로 invariant 가 박힐 경우는 spec-16-04 이후 누적 패턴이 보일 때 결정.

## 💬 사용자 협의

- **주제**: spec-16-03 의 scope 4 가지 선택지
  - **사용자 의견**: "TTL 제거 — missing-path 만" 선택
  - **합의**: ① missing-path 만, ADR-*.md 한정 (RCA 제외), 1 줄 요약. TTL/contradiction/auto-fix 는 명시적 Out of Scope.
- **주제**: 경로 추출 false positive 위험
  - **에이전트 분석**: ADR-001 본문에 `decision`, `failure-pattern` 같은 텍스트 + `obj.method` 같은 인라인 코드 다수 — 추출 규칙 좁게 잡지 않으면 회귀 위험
  - **합의**: 슬래시 필수 + URL 제외 + 확장자/끝슬래시 보유 — 3 중 필터로 좁게

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-drift-stale-adr.sh`
- **결과**: ✅ Passed (3/3)
- **로그 요약**:
```text
Test: _drift_stale_adr()
  ✓ clean state: no stale ADR line
  ✓ fixture ADR (1 missing path) → stale ADR: 1 detected
  ✓ regression: ADR-001 paths all valid
All tests passed.
```

#### 통합 테스트 (phase-16 시나리오 2)
- **명령**:
  ```bash
  cat > docs/decisions/ADR-999-stale-integration.md <<EOF
  ---
  type: decision
  status: accepted
  ---
  Reference: \`src/removed-module.ts\`
  EOF
  HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status
  ```
- **결과**: ✅ Passed
- **출력**:
```text
🔄 동기화 상태
  stale ADR: 1 (missing-path) — docs/decisions/ADR-999-stale-integration.md
```
- **Cleanup 후**: stale 라인 사라짐 (grep count = 0). ✓

### 2. 수동 검증

1. **clean state**: ADR-001 만 존재 → "stale ADR" 라인 출력 안 됨. → 회귀 없음 ✓
2. **fixture 주입**: 부재 경로 참조 ADR 1 개 추가 → "stale ADR: 1 (missing-path) — <경로>" 출력. ✓
3. **install 미러 동일성**: `diff sources/bin/sdd .harness-kit/bin/sdd` → 차이 없음. ✓

## 🔍 발견 사항

- **`sdd status` 의 backtick 정규식 limitation**: `grep -oE '`[^`]+`'` 가 *한 줄 내* backtick pair 만 잡음. 멀티라인 코드 블록 (```` ``` ````) 안 경로는 추출 안 됨. ADR 에서 code fence 안 경로를 검사 대상으로 보려면 별 처리 필요 — 현재는 inline backtick 만 검사 (의도된 한계).
- **`HARNESS_DRIFT_FETCH=0` 사용 권장**: 테스트/CI 에서 `_drift_remote` 의 git fetch 가 noise 또는 hang 가능. 본 spec 의 테스트 스크립트도 이 환경변수로 fetch 우회.
- **`_drift_stale_adr()` 의 process substitution `< <(...)`**: bash 3.2+ 에서 정상 동작 확인. zsh 호환성은 별도 (bash shebang 강제).
- **ADR 본문 형식 가이드 누락**: ADR 작성자가 *어떤 경로 표기* 가 stale 검사 대상이 되는지 알아야 함 — backtick + 슬래시 + 확장자. 향후 ADR 템플릿에 한 줄 안내 추가 후보 (spec-x 또는 spec-16-04 의 일부 검토).
- **`sdd ship` / `sdd spec new` marker append 버그 재발**: 본 spec 시작 시 phase-16.md 의 spec-16-03 행이 또 중복됨 (이전에 Icebox 기록). 매 spec 시작 / ship 마다 수동 dedupe 필요한 *예측 가능한 비용*. spec-16-04 ship 후 별 spec-x 로 fix 권장.

## 🚧 이월 항목

- code fence (` ``` `) 안 경로까지 검사 확대 — 별 spec-x 또는 spec-16-04 결합 검토 (현재 한계 명시됨)
- ADR 템플릿에 "stale 검사 대상 경로 형식" 안내 1 줄 추가 — spec-16-04 의 한국어 톤 보강 시 함께
- `sdd` marker append 버그 fix — `backlog/queue.md` Icebox 에 기록됨, phase-16 done 후 별 spec-x
- TTL 기반 staleness 재검토 — 운영 누적 후 (3 개월+) 결정의 *방치* 패턴 확인되면 spec-x 로 도입

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-16 (단일 세션) |
| **최종 commit** | `ce25da9` (Task 4 install sync) |
| **총 commit 수** | 4 (planning + test + feat + sync) — 검증 task 는 commit 없음 |
