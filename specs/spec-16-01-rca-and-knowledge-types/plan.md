# Implementation Plan: spec-16-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-16-01-rca-and-knowledge-types`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **Knowledge Type 정규 집합 5 개로 확정**: `decision` / `invariant` / `failure-pattern` / `convention` / `tradeoff`. 추가 제안서의 *runbook* 은 RCA prevention 섹션이 흡수 — 정규 집합에서 제외.
> - [ ] **첫 RCA 주제**: "sdd ship 이 spec/plan/task 를 add 하지 않는 패턴" — 두 번 연속 확인된 실제 운영 이슈. *검증 도구이자 phase 성공 기준 1 만족 수단* 으로 동시 작용.
> - [ ] **Type 어휘 문서화 위치**: `sources/governance/constitution.md` §6 안 새 sub-section §6.4 (ADR 정의 §6.3 옆). 기존 §6.1~6.3 번호 보존.
> - [ ] **RCA 본문 언어**: 한국어 (다른 키트 산출물과 일관). frontmatter 키만 영문.

> [!WARNING]
> - 본 spec 머지 후에도 *현재 인 progress 인 ADR / walkthrough 결정 표는 type 슬롯 없음*. ADR 의 type 슬롯 도입은 spec-16-02 가 담당. type vocabulary 만 먼저 박고, ADR 적용은 두 번째 spec.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---|:---|:---|
| **RCA 5 섹션** | symptom → reproduction → root cause → invariant → prevention 강제 | 외부 진단 #3 / 추가 제안서 §D 표준. 1~3 줄 분량 가이드로 작성 부담 낮춤. |
| **RCA frontmatter** | YAML 4 필드 (id / type / date / status) + severity 1 필드 | walkthrough 가 frontmatter 안 쓰는 형태와 차별 OK. grep 친화 (`^type:` / `^severity:`). |
| **type 정규 집합** | 5 type (decision / invariant / failure-pattern / convention / tradeoff) | runbook 제외 — RCA prevention 이 사실상 흡수. 5 가 grep / 인지 부하 균형점. |
| **type 어휘 위치** | constitution.md §6.4 신설 | §6 이 식별자 시스템 — type 도 *명명 규약*. ADR (§6.3) 옆이 자연스러움. |
| **/hk-rca 동작** | 가벼운 부트스트랩 — id 자동 + 슬러그/severity 입력 + 5 섹션 골조 생성 | 자동 분석은 본 spec out of scope. 사용자 수동 작성. |
| **도그푸딩 방식** | install.sh 매트릭스 확장 → 본 키트에 자기 install 실행 | 키트 원본/도그푸딩 결과 *동시* 변경. CLAUDE.md "두 시점이 한 파일에 공존함에 주의" 원칙. |
| **첫 사용자 선정** | `RCA-001-sdd-ship-spec-add-missing.md` | spec-x-readme-refresh / spec-x-phase-16-define 두 번 연속 발견된 실제 패턴. phase 성공 기준 1 (1 회 RCA) 자연 만족 + 두 번째 사용 우려 차단. |

### 아키텍처 컨텍스트

```
sources/
├── governance/constitution.md   ← §6.4 추가 (5 type vocabulary)
├── templates/rca.md             ← 신규 (골조 + frontmatter)
└── commands/hk-rca.md           ← 신규 (슬래시 커맨드)

install.sh                       ← 복사 매트릭스 확장 (2 file)
                                    └─ self-install →
.harness-kit/agent/
├── constitution.md              ← mirror
└── templates/rca.md             ← mirror

.claude/commands/hk-rca.md       ← mirror

docs/rca/                        ← 신규 디렉토리
├── .gitkeep
└── RCA-001-sdd-ship-spec-add-missing.md  ← 첫 사용자 (type: failure-pattern)
```

## 📂 Proposed Changes

### Sources (키트 원본)

#### [MODIFY] `sources/governance/constitution.md`

`§6 Identifier System (lowercase, hyphen-separated)` 안에 새 sub-section 추가:

```md
### 6.4 Knowledge Type Vocabulary

Artifacts whose frontmatter exposes a `type:` field MUST use exactly one of the following values:

| Type | Used in | When to apply |
|---|---|---|
| `decision` | ADR | A non-trivial design choice with rationale; long-lived. |
| `invariant` | ADR / runbook-style notes | A property the system MUST preserve (e.g. domain ≠ infra). |
| `failure-pattern` | RCA | A recurring failure with reproduction + prevention. |
| `convention` | ADR / style guide | A naming/structure rule adopted for consistency. |
| `tradeoff` | ADR | A choice with explicit cost on the rejected side. |

Rules:
- `type:` MUST be present in any frontmatter that adopts this vocabulary (currently RCA; ADR adoption deferred to spec-16-02).
- Values outside the set are a violation — grep tools rely on closure.
- Vocabulary changes (add / rename / remove) are themselves architecture decisions — record as an ADR with `type: decision`.
```

#### [NEW] `sources/templates/rca.md`

```md
---
id: RCA-{NNN}
type: failure-pattern
date: YYYY-MM-DD
severity: medium    # critical | high | medium | low
status: active      # active | resolved
---

# RCA-{NNN}: <한 줄 제목>

## 🔍 Symptom
<!-- 관찰된 현상. 1~3 줄. -->

## 🔁 Reproduction
<!-- 어떻게 재현하는가. 명령 / 조건 / 시점. -->

## 🎯 Root Cause
<!-- 표면 증상이 아닌 *진짜 원인*. 1~3 줄. -->

## 🛡 Invariant Violated
<!-- 어떤 시스템 불변식이 깨졌는가. 이전에 명시되지 않았다면 *지금* 명시. -->

## 🚧 Prevention
<!-- 같은 패턴이 재발하지 않도록 박을 장치 (코드 / 규약 / 자동화 / hook). -->

## 🔗 Related
<!-- 관련 PR / ADR / spec / 다른 RCA. -->
```

#### [NEW] `sources/commands/hk-rca.md`

슬래시 커맨드 가이드. 동작:
1. `docs/rca/` 디렉토리 스캔 → 최대 `RCA-NNN` + 1 으로 새 id 생성.
2. 사용자에게 *슬러그* 와 *severity* 만 묻는다 (`AskUserQuestion`).
3. `templates/rca.md` 를 `docs/rca/RCA-{NNN}-{slug}.md` 로 복사하고 frontmatter id/date/severity 자동 채움.
4. 5 섹션은 사용자가 직접 채우도록 골조만 남김.
5. 에이전트가 *최근 발견 사항* (walkthrough 의 발견 사항 / 사용자 대화) 을 *제안* 형태로 5 섹션 초안 작성 — 사용자 확정 후 commit.

#### [MODIFY] `install.sh`

복사 매트릭스에 신규 2 파일 추가. 기존 keep-list / overlay 정책 변경 없음. dry-run 으로 신규 파일이 *cp 대상* 으로 노출되는지 확인.

### 도그푸딩 결과 (자동 mirror — install.sh 실행 결과)

#### [NEW/MODIFY] `.harness-kit/agent/constitution.md`, `.harness-kit/agent/templates/rca.md`, `.claude/commands/hk-rca.md`

install.sh 가 sources/ → 위 3 경로로 복사. 본 spec 의 *별도 commit* 으로 분리 (sources 변경 commit ↔ install 부산물 commit).

### docs

#### [NEW] `docs/rca/.gitkeep`

빈 파일. 디렉토리 컨벤션 박기.

#### [NEW] `docs/rca/RCA-001-sdd-ship-spec-add-missing.md`

첫 사용자 RCA. 주제:
- **symptom**: `sdd ship` 실행 후 spec.md / plan.md / task.md 가 ship commit 에 포함되지 않아 working tree 에 untracked 로 남음. push 전 사후 commit 필요.
- **reproduction**: 새 spec-x 디렉토리에서 `sdd ship` 실행. ship 직후 `git status` → spec/plan/task untracked.
- **root cause**: `sdd ship` 의 git add 매트릭스가 *walkthrough / pr_description* 만 포함. spec-x 절차 가정 — spec/plan/task 는 *Pre-flight* 단계에서 별도 commit 됐어야 한다는 전제. 실제 운영에서 spec-x 흐름은 한 번에 spec/plan/task 작성 후 Plan Accept → Strict Loop 라 *Pre-flight commit* 단계가 없음.
- **invariant violated**: 본 RCA 작성 전까지 명시 부재. *명시*: `sdd ship` 후 working tree 에 신규 산출물 untracked 가 남으면 안 된다.
- **prevention**: 별도 spec-x 후보 — `sdd ship` 의 git add 매트릭스에 `specs/<active-spec>/{spec,plan,task}.md` 도 포함하도록 확장.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트
- 본 spec 은 *docs / script copy 매트릭스 / 신규 디렉토리* 변경. 단위 테스트 없음.

### 수동 검증 시나리오

1. **install.sh dry-run**:
   ```bash
   bash install.sh --dry-run .
   ```
   - 기대: `sources/templates/rca.md → .harness-kit/agent/templates/rca.md`, `sources/commands/hk-rca.md → .claude/commands/hk-rca.md` 두 라인 노출.
2. **본 키트 자기 install**:
   ```bash
   bash install.sh .
   ```
   - 기대: `.harness-kit/agent/templates/rca.md`, `.claude/commands/hk-rca.md`, `.harness-kit/agent/constitution.md` 존재 + sources 와 동일.
3. **type 정규 집합 회귀**:
   ```bash
   grep -rh "^type:" docs/rca | sort -u
   ```
   - 기대: 한 줄 — `type: failure-pattern`. 정규 집합 안.
4. **constitution §6.4 가시**:
   ```bash
   grep -n "Knowledge Type Vocabulary" sources/governance/constitution.md .harness-kit/agent/constitution.md
   ```
   - 기대: 두 경로 모두 hit.
5. **RCA-001 형식 점검**:
   - 5 섹션 헤더 (Symptom / Reproduction / Root Cause / Invariant Violated / Prevention) 모두 존재.
   - frontmatter `type: failure-pattern` / `id: RCA-001`.

### 통합 테스트 (phase 단위)
- 본 spec 단독 통합 테스트 없음. phase done 시점 시나리오 1 (Knowledge Type 일관성) 의 *RCA 측 입력* 만족.

## 🔁 Rollback Plan

- 단일 PR. revert 로 즉시 복원. install/도그푸딩 결과 파일은 revert 후 `.harness-kit/` / `.claude/` 가 다시 이전 상태로 cp 되도록 update 1 회 재실행 필요.
- 정확성 위해 commit 단위로 분리 (sources 변경 / install 매트릭스 / 도그푸딩 mirror / RCA-001) — 부분 rollback 가능.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
