# Walkthrough: spec-17-02

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|:---|:---|
| `/hk` vs `/hk-align` 관계 | 대체 / 보완 | **보완** (공존) | `/hk-align` = 세션 시작 부트스트랩 (무거움) / `/hk` = 지속적 사용 안내 (가벼움). 역할 분리 |
| `/hk` read-only vs 동작 | read-only 안내 / Plan Accept·Ship 등 실행 | **read-only 안내** | `/hk` 가 동작까지 하면 책임 폭주. 추천만, 실행은 사용자 |
| 상태 분기 수 | 4-5 (간단) / 7-8 (세분화) | **8 (7 매핑 + 1 fallback)** | 작업 흐름의 모든 자연 분기 (phase/spec/planAccepted/artifacts 조합). fallback 으로 graceful degradation |
| slash command 본문 형식 | bash 스크립트 직접 호출 / Claude 가 markdown 지시 따라 실행 | **markdown 지시** | 기존 `hk-*.md` 패턴과 동일. Claude 가 sdd status 호출 + 8 상태 표 보고 분기 |
| install 검증 방식 | dry-run 실제 / URL 접근성만 | **URL 접근성만** | get.sh 가 `--dry-run` 미지원 (install.sh 한테 위임 안 함). 실제 install 검증은 fixture 환경 필요 — 본 spec 범위 밖. URL 접근성 + 스크립트 형식 확인으로 *install 경로 살아있음* 만 검증 |
| README 변경 범위 | minor (Step 1 안에 5 줄) / 큰 재설계 | **minor** | 본 spec 의 가치는 `/hk` 신설. README 는 노출 도구일 뿐 — 본문 구조 유지 |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 결정은 전술적 (UI/UX 선택). `/hk` 자체가 *진입점 추상* 으로 long-lived 가치이지만, 본 spec 의 결정은 진입점 *구현 디테일* — ADR 가치는 진입점 *합의 자체* 가 아닌 *유지/확장 정책* 발생 시 (예: `/hk` 가 다른 진입점들과 통합/대체될 때)

## 💬 사용자 협의

- **주제**: spec-17-03 (당초 design) vs spec-17-02 (sdd 자동 할당)
  - **사용자 의견**: "A (17-03 Accessibility) 부터 진행해"
  - **합의**: sdd 가 sequential 로 17-02 할당함을 수용 — 17-02 = accessibility (실행 순서), 17-03 = internal-reliability (다음). phase-17.md spec table 재조정.
- **주제**: phase 단위 피로감 ("phase-17, phase-18 이런게 너무 자잘한 내용을 처리해서 처리 단위에 대한 피로감만 커")
  - **합의**: phase-17 확장 (정합성 + 접근성 + governance 잡탕). 본 spec (accessibility) 이 그 확장의 직접 실현
  - **메모리**: `feedback_phase_size.md` 신규

## 🧪 검증 결과

### 1. 자동화 테스트 (단위 검증)
- **명령**: `diff sources/commands/hk.md .claude/commands/hk.md` + 8 키워드 grep
- **결과**: ✅ Passed
- **로그**: install 미러 identical / 7 상태 키워드 hit / README `/hk` 안내 ≥2 곳

### 2. 회귀 테스트
- `bash tests/test-sdd-marker-idempotent.sh` — 3/3 PASS ✓
- `bash tests/test-drift-stale-adr.sh` — 3/3 PASS ✓

### 3. install URL 접근성
- `curl -fsSL https://raw.githubusercontent.com/Changsik00/harness-kit/main/get.sh | head -3` → `#!/usr/bin/env bash\nset -euo pipefail` ✓

### 4. `/hk` 자기 시연 (현 phase-17 상태)
- **Given**: phase=phase-17, spec=spec-17-02-accessibility-install-and-entry, planAccepted=true, artifacts (Executing)
- **When**: `/hk` 호출 (상태 6 매칭)
- **Then**:
  ```
  📍 Strict Loop 진행 중 (spec-17-02-accessibility-install-and-entry)
  → task.md 의 다음 task 실행. 모든 task 완료 시 walkthrough/pr_description 작성
  ```
- **결과**: ✅ Passed — 본 spec 의 ship 직전 시점에 정확히 *현 행동* 안내

## 🔍 발견 사항

- **`get.sh` 가 `--dry-run` 을 install.sh 한테 위임 안 함** — get.sh 가 옵션 list 에 `--version`/`--update`/`--uninstall`/`--yes`/`--help` 만 있고 `--dry-run` 은 미정의. 사용자가 `get.sh --dry-run` 호출 시 usage 출력 후 종료. *향후 spec-x 또는 spec-17-03 (internal-reliability-infra) 에서 get.sh 가 install.sh 의 dry-run pass-through 도입 검토*.
- **sdd status --json 의 출력이 최소** — phase/spec/branch/baseBranch/planAccepted/lastTestPass/installedAt 만. NEXT/artifacts/drift 정보는 text 출력에만. `/hk` 는 text 출력 파싱 패턴으로 가야 함 — JSON 만으로 부족. (slash command 본문이 sdd status text 를 grep 으로 파싱하도록 명시).
- **slash command 가 *Claude 의 markdown 지시* 라는 점** — 본 spec 작성 중 처음엔 bash 스크립트로 작성하려다 패턴 확인 후 정정. 다른 `hk-*` 커맨드와 동일하게 *Claude 가 따라야 할 지시*. bash 실행 결과를 *해석해서 분기* 하는 책임은 Claude.
- **사용자 피드백 "phase 단위가 너무 작다" 가 본 spec 의 직접 동기** — 본 spec 이 *phase-18 후보* 였던 접근성 개선을 phase-17 안으로 흡수한 결과물. memory `feedback_phase_size.md` 와 phase-17.md 결정 기록 표의 *재정의 행* 이 동일 사건의 두 흔적.

## 🚧 이월 항목

- `get.sh` 의 `--dry-run` pass-through — 후속 spec-x 또는 spec-17-03 검토
- `sdd status --json` 의 출력 확장 (NEXT, artifacts 필드 추가) — 후속 spec-x. 현재 `/hk` 가 text 파싱 우회 가능하나 JSON 활용이 robust
- (phase-17 잔여) spec-17-03 (internal-reliability-infra) / spec-17-04 (governance-test-coherence)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-17 (단일 세션) |
| **최종 commit** | `4c00513` (Task 3 — README 갱신) |
| **총 commit 수** | 4 (planning + hk.md + sync + README) — 검증 task 는 commit 없음 |
