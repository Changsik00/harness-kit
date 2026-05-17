# spec-17-02: Accessibility — install + 진입점 + onboarding

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-17-02` |
| **Phase** | `phase-17` (운영 성숙도) |
| **Branch** | `spec-17-02-accessibility-install-and-entry` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

**Install 경로**:
- `get.sh` (curl 인스톨러) 이미 존재 + 작동.
- README line 92: `bash <(curl -fsSL https://raw.githubusercontent.com/Changsik00/harness-kit/main/get.sh) --yes ~/Project/my-app` — 사용자에게 노출.
- install.sh 가 `sources/commands/*.md` 전체 자동 복사 — 신규 슬래시 커맨드 추가는 install 변경 없이 작동.

**진입점**:
- `.claude/commands/` 에 13 개 슬래시 커맨드 (`hk-align`, `hk-archive`, `hk-cleanup`, `hk-code-review`, `hk-doctor`, `hk-phase-review`, `hk-phase-ship`, `hk-plan-accept`, `hk-pr-bb`, `hk-pr-gh`, `hk-ship`, `hk-spec-critique`, `hk-update`).
- `/hk-align` = 세션 시작 시 부트스트랩 (constitution 로딩 + 상태 보고 + 단 하나의 질문). 무거움.
- **`/hk` 없음** — *현재 상태에서 다음에 무엇을 해야 하는가* 를 한 줄로 안내하는 단일 진입점 부재. 사용자가 13 개 커맨드를 외워야 함.

**README**:
- Step 1 (line 126-): `/hk-align` 만 안내. `/hk` 도입 시 추가 필요.

### 문제점

- 신규 사용자가 키트 설치 후 *어떤 슬래시 커맨드를 외워야 하는지* 부담 — 채택 마찰 ↑.
- 기존 사용자도 *지금 무엇을 해야 하는지* 매번 `sdd status` 출력을 읽고 매핑해야 — 13 커맨드 중 적절한 것 선택 인지 비용.
- `/hk-align` 은 *세션 시작* 용이지 *지금 다음 행동 추천* 용이 아님 — 두 역할이 동일 커맨드에 묶임.
- README onboarding 이 *세션 시작 흐름* 만 안내 — *지속적 사용 흐름* 부재.

### 해결 방안 (요약)

`.claude/commands/hk.md` 단일 진입점 신규 — `sdd status --json` 기반으로 *현 상태에 맞는 다음 행동* 1 줄 안내. 7 상태 분기 매핑. install 부분은 *검증만* (이미 작동). README 의 onboarding 첫 단계에 `/hk` 추가 안내.

## 🎯 요구사항

### Functional Requirements

1. **`/hk` 슬래시 커맨드 신규** (`sources/commands/hk.md` + install 미러 `.claude/commands/hk.md`):
   - `sdd status --json` 호출 → JSON 파싱 (jq)
   - 7 상태 매핑 → *현 상태 1 줄 요약* + *권장 다음 행동 1 줄* 출력
   - 추가 진단 (drift, install 부산물) 있으면 1 줄 더
2. **상태 매핑 (7 카테고리)**:

| state.json 조합 | 다음 행동 출력 |
|---|---|
| `phase: null` | "Active phase 없음. 새 phase 시작: `/hk-align` 또는 `sdd phase new <slug>`" |
| `phase: phase-N, spec: null, NEXT: spec-X` | "다음 spec 대기: `sdd spec new <slug>` (NEXT: spec-X)" |
| `phase: phase-N, spec: null, NEXT: 없음` (전 spec Merged) | "Phase 완료 가능: `/hk-phase-ship`" |
| `phase: phase-N, spec: spec-X, planAccepted: false, artifacts 미완` | "spec/plan/task 작성 필요" |
| `phase: phase-N, spec: spec-X, planAccepted: false, artifacts ✓` | "Plan Accept: `/hk-plan-accept` (또는 비판 필요시 `/hk-spec-critique`)" |
| `phase: phase-N, spec: spec-X, planAccepted: true, walkthrough/pr_desc 미완` | "Strict Loop 진행 — task.md 의 다음 task" |
| `phase: phase-N, spec: spec-X, planAccepted: true, Ship-ready` | "Ship: `/hk-ship`" |

3. **README onboarding 갱신**: Step 1 에 `/hk` 추가 안내. `/hk-align` (세션 시작) vs `/hk` (지속적 사용) 차이 명시. 3-5 줄 변경.
4. **install 검증**: `get.sh` 가 README 의 URL 로 실제 동작하는지 fixture 검증 — 실제 install 없이 dry-run (`curl -fsSL <URL> | bash -s -- --dry-run --yes /tmp/fixture-target`) 으로.

### Non-Functional Requirements

1. **`/hk` 가벼움** — `sdd status --json` 호출 1 회 + jq 파싱 + echo 출력. < 200ms 응답.
2. **`/hk` 가 `/hk-align` 대체 아님** — 두 진입점 공존, 역할 분리 명시 (README + `/hk` 자기 설명).
3. **상태 매핑 fallback** — JSON 파싱 실패 / sdd 부재 / unrecognized state 시 graceful fallback ("sdd 상태 확인 불가 — `bash .harness-kit/bin/sdd status` 수동 확인").

## 🚫 Out of Scope

- **`/hk` 가 state 를 *변경* 하는 동작** (예: `/hk plan accept`, `/hk ship`) — 본 spec 의 `/hk` 는 *read-only 안내* 만. 동작은 기존 슬래시 커맨드 호출.
- **`get.sh` / `install.sh` 코드 수정** — 검증만, 수정 없음 (이미 작동).
- **다른 슬래시 커맨드 (`hk-*`) 의 통합 / 폐기** — 본 spec 은 `/hk` 추가만. 다른 커맨드는 그대로.
- **`sdd` CLI 의 `--brief` 옵션 추가** — 본 spec 의 `/hk` 가 자체 jq 파싱.
- **README 전면 onboarding 재설계** — Step 1 minor 갱신만. install 섹션 / 본문 구조 유지.

## ✅ Definition of Done

- [ ] `sources/commands/hk.md` 신규 작성 (7 상태 분기 + fallback)
- [ ] `.claude/commands/hk.md` install 미러 동기화
- [ ] README Step 1 에 `/hk` 안내 추가 (3-5 줄)
- [ ] `get.sh` 동작 검증 — fixture dry-run 으로 install 시뮬레이션 (실제 변경 없음)
- [ ] 단위 검증: `/hk` 출력 형식이 7 상태 모두에서 expected 패턴 일치 (현 phase-17 상태 1 시연 + 나머지 6 은 state.json mock 으로)
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] `spec-17-02-accessibility-install-and-entry` 브랜치 push 완료 + PR 생성 (target: `phase-17-coherence-fix`)
