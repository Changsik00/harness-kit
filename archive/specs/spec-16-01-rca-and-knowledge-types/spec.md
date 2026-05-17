# spec-16-01: RCA 시스템 도입 + Knowledge Type 슬롯

> [!NOTE]
> **사후 변경 (2026-05-15, PR #116 머지 직전)**: `/hk-rca` 슬래시 커맨드는 사용자 결정으로 *제거*되었고, 대신 `agent.md §10 RCA Protocol` 한 섹션으로 대체됐다. RCA 부트스트랩은 에이전트가 템플릿을 직접 읽고 5 섹션 초안을 제안하는 *숨은 어시스트* 흐름으로 운영. 자세한 결정 근거는 `walkthrough.md §결정 기록` 참조. 이하 본문의 `/hk-rca` / `sources/commands/hk-rca.md` 관련 서술은 *원본 의도* 보존 차원에서 유지한다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-16-01` |
| **Phase** | `phase-16` |
| **Branch** | `spec-16-01-rca-and-knowledge-types` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no (phase 통합 테스트 일부 — phase done 시점) |
| **작성일** | 2026-05-15 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- 본 키트는 *작업 산출물* (spec / plan / task / walkthrough / pr_description / ADR) 까지는 정의되어 있으나 **RCA (Root Cause Analysis)** 형식이 부재하다.
- 운영 중 발견된 실패 패턴 (예: 두 번 연속 발생한 *sdd ship 의 spec/plan/task add 누락*) 이 *발견 사항* 으로 walkthrough 안에 묻혀 사라진다. 다음 작업자가 grep 으로 찾을 경로가 없다.
- 산출물 frontmatter 에 `type:` 정규화가 없어 *invariant 만* / *failure-pattern 만* 류의 추출이 불가능. *Knowledge Type System* 의 첫 사용자가 없다.

### 문제점

1. **실패가 패턴으로 승격되지 않음** — 외부 진단 글 #3 의 핵심: "실패 원인을 이해 못하고 surface patch만 함". 본 키트도 같은 통증 (직전 spec-x 두 건 연속 같은 문제 미해결).
2. **type 정규화 부재** — 어떤 type 이 정규 집합인지 어디에도 명시 안 됨. 도입하려 해도 *합의된 어휘* 가 없어 결국 자유 텍스트로 흩어진다.
3. **첫 사용자 부재의 위험** — type 슬롯만 정의하고 사용 산출물이 없으면 *dead letter*. RCA 가 type 슬롯의 자연스러운 첫 사용자다 (`type: failure-pattern`).

### 해결 방안 (요약)

- (a) `sources/templates/rca.md` 5 섹션 골조 (symptom → reproduction → root cause → invariant → prevention) + frontmatter (id / type / date / status).
- (b) `sources/commands/hk-rca.md` 슬래시 커맨드 — `docs/rca/RCA-{NNN}-{slug}.md` 자동 id + 사용자 슬러그/severity 입력만 받음.
- (c) `sources/governance/constitution.md` 에 §6.4 *Knowledge Type Vocabulary* 신설 — 정규 5 type (`decision` / `invariant` / `failure-pattern` / `convention` / `tradeoff`) 명시.
- (d) `install.sh` 복사 매트릭스 확장 + 도그푸딩 (`install.sh` 자기 적용으로 `.harness-kit/agent/templates/rca.md` + `.claude/commands/hk-rca.md` 동기화).
- (e) 검증 RCA: `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` — 본 키트 운영에서 두 번 연속 발견된 *sdd ship 이 spec/plan/task 를 add 안 함* 패턴을 첫 사용자로 작성. Phase 성공 기준 1 (RCA 1 회 작성) 자연 만족.

## 🎯 요구사항

### Functional Requirements

1. `sources/templates/rca.md` 신규 — 5 섹션 골조 + frontmatter:
   ```yaml
   ---
   id: RCA-{NNN}
   type: failure-pattern
   date: YYYY-MM-DD
   severity: critical | high | medium | low
   status: active | resolved
   ---
   ```
2. `sources/commands/hk-rca.md` 신규 — 슬래시 커맨드 가이드. 자동 id 부여(`docs/rca/` 의 최대 RCA-NNN + 1), 사용자에게 슬러그 / severity 만 묻고 5 섹션 골조 생성.
3. `sources/governance/constitution.md` §6 (Identifier System) 안에 새 sub-section **§6.4 Knowledge Type Vocabulary** 추가:
   - 정규 5 type 집합 (decision / invariant / failure-pattern / convention / tradeoff)
   - 각 type 의 *언제 쓰는지* 한 줄 설명
   - 산출물 frontmatter `type:` 필드는 위 집합 *중 하나* 만 허용 (grep 검색 일관성)
4. `install.sh` 복사 매트릭스 확장 — `templates/rca.md`, `commands/hk-rca.md` 두 신규 파일을 `.harness-kit/agent/templates/`, `.claude/commands/` 로 복사.
5. 본 키트에 install/update 자기 적용 — `.harness-kit/agent/templates/rca.md`, `.claude/commands/hk-rca.md`, `.harness-kit/agent/constitution.md` 동기화.
6. `docs/rca/.gitkeep` (또는 README) 신규 — 디렉토리 컨벤션 박기.
7. `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` 첫 사용자 RCA 신규.
8. 통합 검증 (수동, 본 spec 단위):
   - `grep -rh "^type:" docs/rca` 결과가 정규 5 type 안에 들어옴
   - `/hk-rca` 슬래시 커맨드가 RCA-NNN 자동 부여 + 골조 생성 동작

### Non-Functional Requirements

1. RCA 작성 부담 최소 — 5 섹션 모두 1~3 줄로 충분한 형식.
2. RCA 산출물 본문은 **한국어** (constitution / agent.md 영문 원칙 예외 — 다른 키트 산출물과 일관).
3. bash 3.2+ 호환 (install.sh / hk-rca.md 의 어떤 스크립트 예시든).
4. 기존 install.sh 동작 / 기존 keep-list / overlay 정책 영향 없음 (복사 매트릭스 *확장* 만).
5. constitution §6 의 기존 sub-section 번호 (6.1 / 6.2 / 6.3) 보존. 신규는 §6.4 로 append.

## 🚫 Out of Scope

- **ADR / walkthrough 결정 표의 type 슬롯 확장** — spec-16-02 (ADR 활성화 트리거) 에서 ADR frontmatter 가 type 슬롯의 *두 번째 사용자* 가 된다.
- **/hk-rca 의 자동 분석** (실패 로그 파싱, root cause 추론 등) — 너무 무거움. 사용자 수동 입력 only.
- **Failure Pattern Database 검색 도구** — grep + markdown 으로 충분.
- **RCA 자동 생성 트리거** (hook 으로 실패 감지 후 RCA 강제) — 사용자 수동 호출 only.
- **/hk-rca 의 sub-agent 분리** (RCA 전용 Opus sub-agent) — 추가 제안서 §RCA Agent 영역. 본 phase 외 후보.
- **runbook type 추가** — 추가 제안서의 6 type 중 *runbook* 은 RCA prevention 섹션에서 흡수 가능. 정규 집합은 5 로 한정.

## ✅ Definition of Done

- [ ] `sources/templates/rca.md` / `sources/commands/hk-rca.md` 신규
- [ ] `sources/governance/constitution.md` §6.4 Knowledge Type Vocabulary 추가
- [ ] `install.sh` 매트릭스 확장 + dry-run 검증 통과
- [ ] 본 키트 자기 적용 (`.harness-kit/agent/templates/rca.md`, `.claude/commands/hk-rca.md`, `.harness-kit/agent/constitution.md`)
- [ ] `docs/rca/` 디렉토리 + `RCA-001-sdd-ship-spec-add-missing.md` 첫 사용자
- [ ] 수동 검증 PASS: `grep -rh "^type:" docs/rca` 가 정규 5 type 집합 안
- [ ] `walkthrough.md` / `pr_description.md` 작성 및 ship
- [ ] `spec-16-01-rca-and-knowledge-types` 브랜치 push 완료, PR 생성
