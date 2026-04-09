# Claude Code 하네스 구축 계획 (2026-04-09)

> 이 문서는 **계획서**이며 실행 전 사용자 승인이 필요합니다 (Plan Accept).
> 본 계획은 사용자가 만든 SDD 거버넌스 레이어(`agent/`)를 Claude Code 의 네이티브 기능으로 *자동 강제*하기 위한 것입니다.

---

## 0. 목표

**"의도(거버넌스 문서) + 강제(Claude Code 네이티브) = 진짜 하네스"**

현재 거버넌스(constitution/agent/templates) 는 잘 작성되어 있으나, 매 세션마다 사용자가 직접 로딩해야 하고, 위반을 막아주는 장치가 없습니다. 이 계획은 그 갭을 메꾸는 것입니다.

---

## 1. 설계 원칙 (이 계획 전체의 헌법)

| # | 원칙 | 의미 |
|:---:|------|------|
| 1 | **Context Budget First** | 시스템 프롬프트에 들어가는 모든 토큰은 비용. 가능하면 *지연 로딩*되거나 *호출 시에만* 컨텍스트에 들어오는 형태를 선호 |
| 2 | **Cost Order: Shell > Skills > Slash > MCP** | 같은 효과라면 컨텍스트 비용이 적은 순서로 채택. Shell 스크립트는 시스템 프롬프트에 *전혀* 안 들어감 |
| 3 | **Enforcement > Guideline** | "MUST" 라고 적기보다 *물리적으로 차단* 할 수 있으면 차단 (hooks) |
| 4 | **Reproducibility** | 슬래시 커맨드 한 번 = 항상 같은 결과. 자유 형식 프롬프트 의존 최소화 |
| 5 | **Korean Docs** | constitution 과 일관 |
| 6 | **No Over-engineering** | 본 NestJS 프로젝트 규모에 안 맞는 LLM 프로젝트용 의례(예: 20개 테스트 케이스 minimum)는 도입 안 함 |

---

## 2. MCP 평가 (사용자 질문 1)

### 2.1 MCP 의 본질적 트레이드오프

| 항목 | 장점 | 단점 |
|------|------|------|
| 도구 노출 | 외부 시스템 직접 호출 가능 | **각 MCP 서버의 모든 tool 정의가 시스템 프롬프트에 상주** → 보통 1개 서버당 5~50개 tool, 5K~20K 토큰 추가 |
| 실시간성 | API 응답을 그대로 모델이 봄 | API 응답이 길면 컨텍스트 폭발 |
| 인증 | OAuth 등 자동화 가능 | 시크릿 관리 부담 |
| 신뢰성 | 구조화된 호출 | 서드파티 MCP 서버 품질 편차 큼, 일부는 미성숙 |

### 2.2 사용자 우려에 대한 답
**"요즘 MCP 가 안 좋다"** 는 평가는 정확합니다. 이유는 두 가지:

1. **컨텍스트 점유**: 사용자가 지적한 그대로. MCP 서버 3개만 붙여도 시스템 프롬프트에서 20K+ 토큰을 잃을 수 있습니다. 본 프로젝트의 모델 컨텍스트가 1M 이라 *절대 부족* 한 건 아니지만, **Claude 의 attention 효율은 컨텍스트가 비어 있을 때 가장 높습니다**. 토큰을 살 수 있어도 attention 은 못 삽니다.
2. **호출 빈도 vs 비용**: 하루 5번 쓰는 도구를 위해 매 메시지에 5K 토큰을 지불하는 건 비효율. 같은 일을 *호출 시점에만* 비용이 발생하는 shell 스크립트로 대체할 수 있다면 그게 정답.

### 2.3 본 프로젝트에 MCP 가 필요한가?

| MCP 후보 | 가치 | 컨텍스트 비용 | 대체재 | 결정 |
|----------|:---:|:---:|------|:---:|
| **Bitbucket MCP** | 中 | 中 | (사용자가 hosted UI 에서 직접) | ❌ |
| **MySQL MCP (read-only)** | 高 (SP 직접 호출 프로젝트라 스키마 introspection 가치 큼) | 中 | `bin/sp-show` zsh 스크립트 | ❌ → shell 로 대체 |
| **Redis MCP** | 低 | 中 | `redis-cli` (zsh 직접) | ❌ |
| **Filesystem MCP** | (이미 내장 도구) | 中 | Read/Edit/Glob/Grep | ❌ 중복 |
| **Sentry MCP** | (현재 미사용) | 中 | — | ❌ |
| **Linear/Jira MCP** | (현재 미사용 추정) | 中 | — | ❌ |
| **Playwright MCP** | E2E 테스트가 본격화되면 | 高 | `npm run test:e2e` | ❌ 현 시점 |

### 2.4 결론
- **현재 단계: MCP 도입 0개.**
- **이유**: 본 프로젝트가 필요로 하는 모든 외부 통합은 *zsh 스크립트 + Bash 도구* 로 같은 효과를 컨텍스트 비용 0 에 얻을 수 있습니다.
- **장래 검토 후보**: 운영 안정화 후 MySQL MCP (read-only). 단, 그때도 먼저 zsh 스크립트로 6주 운영해 보고, *진짜로 부족한 것이 무엇인지* 확인한 후에.

---

## 3. Skills 평가

### 3.1 Skills vs Slash Commands vs Shell

| 항목 | Skills | Slash Commands | Shell Scripts |
|------|:---:|:---:|:---:|
| 시스템 프롬프트 비용 | 트리거 설명만 (작음) | 최소 (등록만) | **0** |
| 호출 주체 | 모델 또는 사용자 | 사용자만 | 모델 (Bash 통해) |
| 복잡 워크플로 | ✅ | △ | ✅ |
| 외부 어셋 번들 | ✅ | ❌ | ✅ |
| 발견성(discoverability) | ✅ (모델이 알아서 호출) | △ | ❌ (모델이 알아야 함) |

### 3.2 사용 기준
- **Slash Command**: 사용자가 *반복 입력하는 절차* (예: `/align`)
- **Skill**: 모델이 *자동으로 호출해야 하는* 패턴 (예: 코드 리뷰 요청 시 자동으로 spec 검증)
- **Shell**: *데이터 처리, 외부 시스템 호출, 검증* (예: SP 조회, 테스트 선별 실행)

### 3.3 채택 후보

| 종류 | 이름 | 우선순위 |
|------|------|:---:|
| Slash | `/align` | 🥇 필수 |
| Slash | `/spec-new <slug>` | 🥇 필수 |
| Slash | `/plan-accept` | 🥇 필수 |
| Slash | `/spec-status` | 🥈 권장 |
| Slash | `/phase-new <slug>` | 🥈 권장 |
| Slash | `/archive` | 🥈 권장 |
| Slash | `/handoff` | 🥉 옵션 |
| Skill | `spec-validator` | 🥈 권장 (모델이 spec 작성 시 자동 검증) |
| Skill | `phase-planner` | 🥉 옵션 |

### 3.4 결론
- **Skills 는 1~2개만**, 모델이 *자동으로 호출하면 가치가 큰* 것에 한정.
- **나머지는 모두 Slash + Shell 조합**으로 처리.

---

## 4. Shell Tooling (사용자 질문 2 — 핵심 권장)

> 이 섹션이 본 계획에서 가장 비중이 큽니다. 사용자가 zsh/Homebrew 환경이라는 점이 결정적 이점입니다.

### 4.1 디렉토리 구조 제안
```
nextmarket-api/
├── bin/                          # PATH 추가 권장 (또는 ./bin/sdd 로 직접 호출)
│   ├── sdd                       # 메타 명령. 모든 SDD 작업의 진입점
│   ├── sp-show                   # SP 정의 조회
│   ├── sp-list                   # SP 목록
│   ├── test-spec                 # SPEC 단위 테스트 선별 실행
│   ├── test-phase                # PHASE 통합 테스트 실행
│   ├── check-branch              # 브랜치 가드 (hook 에서 사용)
│   ├── webhook-replay            # 로컬 DB 의 웹훅 로그 재실행
│   └── lib/
│       ├── common.sh             # 공통 헬퍼 (색상, 로그, 경로)
│       └── state.sh              # .claude/state 읽기/쓰기
└── scripts/
    └── (기존 nextmarket-db 등)
```

### 4.2 핵심 메타 명령 — `bin/sdd`

```bash
sdd                               # 도움말
sdd status                        # 현재 phase/spec/branch/test 상태 한눈에
sdd phase new <slug>              # PHASE-NNN-<slug> 디렉토리 + phase.md 골격 생성
sdd phase list                    # 모든 phase + 진행률
sdd spec new <slug>               # 현재 phase 안에 SPEC-NNN-<slug> 생성
sdd spec list [--phase NNN]       # spec 목록
sdd plan accept                   # .claude/state/plan-accepted 플래그 ON (hook 가 검사)
sdd plan reset                    # 플래그 OFF
sdd task done <num>               # task.md 의 N번 항목을 [x] 로
sdd archive                       # 현재 spec 의 walkthrough/pr_description 검증
sdd commit-check                  # 커밋 직전 검증 (브랜치, 테스트, 한 커밋의 변경량)
```

### 4.3 왜 zsh 스크립트인가
| 비교 | zsh 스크립트 | MCP | 슬래시 커맨드 |
|------|:---:|:---:|:---:|
| 컨텍스트 비용 | **0** | 中~高 | 낮음 |
| 모델이 호출 가능 | ✅ (Bash 통해) | ✅ | ❌ |
| 사용자도 직접 사용 | ✅ (터미널) | ❌ | ❌ |
| 디버깅 | `bash -x` | 어려움 | 어려움 |
| 버전 관리 | git 으로 그대로 | 별도 | git |
| CI 통합 | 그대로 | 어려움 | ❌ |

**이중 사용 가치**: 같은 스크립트를 사용자가 터미널에서 직접 쓰고, 모델도 Bash 도구로 호출합니다. *사람과 에이전트가 같은 인터페이스를 공유* 하는 게 가장 큰 가치입니다.

### 4.4 안전 규칙
- 모든 스크립트는 `set -euo pipefail` 시작
- 변경 작업은 항상 dry-run 모드 지원 (`--dry-run`)
- 색상 출력은 TTY 가 아닐 때 자동 비활성
- 종료 코드 일관: 0=성공, 2=가드 차단, 1=일반 에러

---

## 5. Slash Commands (사용자 질문 3)

### 5.1 등록 위치
`.claude/commands/<name>.md`

### 5.2 핵심 5종

#### `/align` — 세션 부트스트랩
```markdown
---
description: SDD 세션 정렬 — constitution 로드 + 컨텍스트 점검
---

다음을 순서대로 수행:
1. @agent/.agent/constitution.md @agent/.agent/agent.md 를 읽어 규약 인지
2. `bin/sdd status` 실행하여 현재 phase/spec/branch/플래그 확인
3. `git log -3 --oneline` 으로 최근 작업 맥락 파악
4. 미완 task 가 있으면 어떤 phase/spec 에 속하는지 보고
5. **단 하나의 질문**만 사용자에게: "어떤 컨텍스트로 진행할까요?"
```

#### `/spec-new <slug>`
```markdown
---
description: 현재 phase 안에 새 spec 디렉토리와 템플릿 4종 생성
argument-hint: <slug>
---

1. `bin/sdd spec new $1` 실행 (디렉토리/번호/템플릿 복사 모두 처리)
2. 생성된 `spec.md` 를 열어 §1 배경 및 문제 정의부터 사용자와 함께 작성 시작
3. **이 시점부터는 PLANNING 모드**: 코드 편집 금지 (constitution §4.3)
```

#### `/plan-accept`
```markdown
---
description: 현재 spec 의 plan.md 를 사용자가 명시적으로 승인 — 실행 모드 진입
---

1. 현재 spec 의 plan.md 가 존재하고 비어있지 않은지 확인
2. `bin/sdd plan accept` 실행 (.claude/state/plan-accepted 플래그 ON)
3. 사용자에게 다음 메시지 출력:
   "Plan Accepted. 첫 task 부터 Strict Loop 시작합니다."
4. task.md 의 첫 미완 task 부터 §6.1 Strict Loop 진행
```

#### `/spec-status`
```markdown
---
description: 현재 spec 의 task 진행률, 변경 파일, 테스트 상태 출력
---
1. `bin/sdd status --verbose` 실행
2. 미완 task 가 있다면 다음 task 명만 보고 (먼저 실행하지 말 것)
```

#### `/handoff`
```markdown
---
description: 현재 spec 작업 종료 — walkthrough/pr_description 검증 후 푸시 준비
---
1. `bin/sdd archive` 로 walkthrough/pr_description 누락 검증
2. `npm run lint` + `npm test` 통과 확인
3. 통과 시 `git status` 출력하고 사용자에게 푸시 여부 묻기
4. 사용자 승인 후 `git push -u origin <branch>`
5. PR 생성 절차 안내 (사용자가 hosted git UI 에서 수행)
```

### 5.3 옵션 4종 (Phase 2)
- `/phase-new <slug>` — 새 phase 생성
- `/phase-status` — phase 진행률
- `/task-done <n>` — task 완료 마킹
- `/archive` — 단독 호출 가능한 archive

---

## 6. Hooks — 진짜 강제 (사용자 질문 3 의 다른 면)

### 6.1 `.claude/settings.json` 후크 설계

#### Hook 1: main 브랜치 보호
```jsonc
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "bin/check-branch --block-main"
  }]
}
```
- `git commit`, `git push` 가 main 에서 실행되면 차단 (exit 2)
- 차단 메시지: "constitution §9.1 위반: main 브랜치 직접 작업 금지"

#### Hook 2: Plan Accept 검증 (PreToolUse, Edit/Write 매칭)
```jsonc
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "bin/check-branch --require-plan-accept"
  }]
}
```
- `.claude/state/plan-accepted` 가 없으면 production 코드 편집 차단
- 단, **예외 경로**: `agent/`, `docs/`, `specs/`, `backlog/`, `.claude/`, `*.md` 는 항상 허용 (planning 단계의 문서 작업)

#### Hook 3: 테스트 미실행 커밋 차단 (PostToolUse Bash matcher)
```jsonc
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "bin/check-branch --require-test-passed-before-commit"
  }]
}
```
- `git commit` 직전 `.claude/state/last-test-pass` 의 timestamp 확인
- N분 이내 통과 기록 없으면 차단

#### Hook 4: SessionStart — 자동 align
```jsonc
{
  "SessionStart": [{
    "hooks": [{
      "type": "command",
      "command": "bin/sdd status --json"
    }]
  }]
}
```
- 새 세션 시작 시 자동으로 상태 출력 → 모델이 첫 응답에서 인지

### 6.2 Hook 안전 원칙
- 모든 hook 은 *zsh 스크립트* 호출. settings.json 에 인라인 bash 금지(가독성/디버깅).
- 각 hook 은 환경변수로 비활성 가능: `CLAUDE_HOOKS_DISABLED=1`
- 모든 차단은 *왜 차단되었는지* + *어떻게 풀 것인지* 를 stderr 로 출력

---

## 7. Backlog: Phase > Spec 계층 (사용자 질문 4)

### 7.1 디렉토리 구조
```
backlog/
├── queue.md                              # 다음 우선순위 (자유 형식)
├── INDEX.md                              # 모든 phase 한눈에 (자동 생성)
└── phases/
    ├── PHASE-001-payment-stability/
    │   ├── phase.md                      # phase 정의 (배경/목표/성공 기준)
    │   ├── integration-tests.md          # 통합 테스트 계획 (필수)
    │   ├── walkthrough.md                # phase 완료 후 작성
    │   └── specs/
    │       ├── SPEC-001-stock-locking/
    │       │   ├── spec.md
    │       │   ├── plan.md
    │       │   ├── task.md
    │       │   ├── walkthrough.md
    │       │   └── pr_description.md
    │       └── SPEC-002-webhook-lock-fix/
    │           └── ...
    └── PHASE-002-.../
```

### 7.2 번호 체계
- **PHASE-NNN**: 전역 단조 증가 (PHASE-001, 002, 003, ...)
- **SPEC-NNN**: 전역 단조 증가, phase 와 무관 (SPEC-001 ~ ∞)
- **이유**: One Spec = One PR 이고 PR 은 phase 에 종속되지 않으므로 SPEC ID 가 PR 추적과 1:1 매칭되도록.

### 7.3 Phase 규칙
- **정의**: 전략적으로 묶인 Spec 들의 그룹. 한 비즈니스 가치 또는 한 위험 영역.
- **phase.md 필수 섹션**:
  - 배경 / 문제 정의
  - 목표 / 성공 기준 (정량)
  - 포함된 SPEC 목록 (계획 + 완료)
  - 의존성 (다른 phase, 외부 시스템)
  - 통합 테스트 계획 요약 (상세는 `integration-tests.md`)
- **Phase Done 조건**:
  1. 모든 SPEC merged
  2. **integration-tests.md 의 모든 시나리오 통과** (PHASE 단위 통합 테스트 의무)
  3. `walkthrough.md` (phase 단위) 작성 및 commit
- **통합 테스트 위치**: `test/integration/PHASE-NNN/*.e2e-spec.ts`

### 7.4 Spec 규칙 (기존 + 강화)
- **단위 테스트 필수**: `*.spec.ts` 가 SPEC 안에 최소 1개
- **통합 테스트 옵션 (단, 명시 필요)**: spec.md 에 `## Integration Test Required: yes/no` 필드
- **One Spec = One PR**: 변경 안 됨
- **Spec 은 항상 어떤 Phase 에 소속**: 고아 Spec 금지. 임시면 `PHASE-000-misc` 사용

### 7.5 첫 Phase 예시 (계획 검증용)
이전 리뷰에서 도출된 critical 이슈들로 첫 phase 를 만들면:

```
PHASE-001-payment-stability (결제·웹훅 안정성)
├── SPEC-001-webhook-lock-fail-throw     (webhooks.service.ts:44 한 줄 수정 + 테스트)
├── SPEC-002-stock-row-locking           (재고 차감 FOR UPDATE 도입)
├── SPEC-003-subscription-saga-rollback  (구독 생성 보상 트랜잭션)
├── SPEC-004-order-idempotency-key       (주문 멱등성 키)
└── SPEC-005-health-endpoint             (/health + terminus)

통합 테스트:
- T1: 동시 100 주문 → 재고 음수 발생 안 함
- T2: 같은 idempotencyKey 로 5회 재시도 → 1건만 생성
- T3: webhook 처리 중 Redis 차단 → 자동 재시도되고 결국 처리됨
```

이 구조가 §10 의 첫 검증 대상이 됩니다.

---

## 8. Usage Guide (사용자 질문 3 — 사용 가이드)

### 8.1 위치
`docs/agent-guide/USAGE.md` (사용자용) + `docs/agent-guide/REFERENCE.md` (명령어 레퍼런스)

### 8.2 가이드 목차 (작성 예정)
1. **첫 세션 시작 시**
   - 터미널 열기 → 프로젝트 디렉토리 → `claude` 실행 → `/align`
2. **새 기능 시작 시**
   - 현재 phase 확인 또는 `/phase-new <slug>` → `/spec-new <slug>` → spec.md 작성
3. **Plan 검토 후 실행 시작**
   - plan.md 검토 → `/plan-accept` → 모델이 첫 task 부터 Strict Loop
4. **Task 완료마다**
   - 모델이 자동으로 commit + task.md 업데이트 + 다음 task 보고
5. **Spec 종료 시**
   - `/handoff` → 검증 + 푸시 + 사용자에게 PR 안내
6. **Phase 종료 시**
   - 통합 테스트 실행 → phase walkthrough 작성 → backlog/queue.md 업데이트
7. **세션 중간 재정렬 필요 시**
   - 언제든 `/align` 다시 호출 가능
8. **위반 시**
   - hook 가 차단하면 stderr 메시지 그대로 읽고 원인 해결
9. **자주 쓰는 zsh 명령**
   - `sdd status`, `sp-show NMP_ORDER_CREATE`, `test-spec SPEC-007`
10. **트러블슈팅**
    - 플래그 꼬임, 브랜치 꼬임, hook 비활성화 방법

---

## 9. 그 밖의 의견 (사용자 질문 5)

### 9.1 추가 권장 항목

#### A. State 파일
`.claude/state/current.json` (gitignore)
```json
{
  "phase": "PHASE-001-payment-stability",
  "spec": "SPEC-001-webhook-lock-fail-throw",
  "branch": "feature/SPEC-001-webhook-lock-fail-throw",
  "planAccepted": false,
  "lastTestPass": "2026-04-09T10:30:00Z"
}
```
- `bin/sdd status` 가 이걸 단일 진실 소스로 사용
- hook 들도 이걸 봄
- `/align` 이 첫 응답에서 이걸 요약

#### B. ADR (Architecture Decision Records)
`docs/decisions/ADR-NNN-<slug>.md`
- walkthrough 는 *어떻게 했는지* 의 증거 로그
- ADR 은 *왜 그렇게 결정했는지* 의 의사결정 로그
- 둘이 보완 관계
- 예: "ADR-001: MCP 대신 zsh 스크립트를 채택한 이유"

#### C. 컨벤션 검사 스크립트
`bin/lint-conventions` — ESLint 가 못 잡는 본 프로젝트만의 안티패턴
- `result[0]?.[0]` 같은 매직 인덱싱
- `<any>` SP 결과
- `db.call(` 직접 호출 (Repository 도입 후엔 금지)
- 한국어 주석 누락된 신규 controller

ESLint 커스텀 룰까지는 과해서 빠른 grep 기반 스크립트로 출발. PostToolUse hook 으로 commit 직전에 자동 실행.

#### D. 테스트 선별 실행기
`bin/test-spec SPEC-001` 가 변경된 파일을 git 으로 추적해서 *관련 *.spec.ts 만* 골라 jest 에 전달.
- 매번 전체 jest 안 돌려도 됨
- Strict Loop 의 "Test Pass" 단계가 빠르고 가벼워짐

#### E. CLAUDE.md 분리
현재 `CLAUDE.md` 는 프로젝트 지식(아키텍처, SP 패턴 등) 으로 충실. 거버넌스를 *그 위에 추가* 하면 너무 길어집니다.
- `CLAUDE.md` 는 그대로 두고 맨 위에 import 두 줄만:
  ```markdown
  ## 에이전트 운영 규약
  - @agent/.agent/constitution.md
  - @agent/.agent/agent.md
  - @docs/agent-guide/USAGE.md
  ```

#### F. 경로 정합성 수정
`agent/.agent/agent.md` §4.1 의 `docs/protocols/templates/` 표현을 `agent/templates/` 로 통일 (이전 리뷰에서 발견된 미해결 항목).

### 9.2 의도적으로 도입 *안 하는* 것
- **MCP 서버 (현 시점)** — §2 결론
- **CI hook 강제** — bitbucket-pipelines 는 그대로 두고, 하네스는 로컬 개발 단계만 강제. CI 는 안전망.
- **Agent SDK 별도 구축** — 본 프로젝트는 코드 작업이 주이고, 외부에서 호출되는 자율 에이전트가 아님. 과잉 설계.
- **자체 LLM 통신 코드** — Claude Code 가 이미 함.

---

## 10. 실행 페이즈 (이 계획을 실행하는 단계)

> 본 계획 자체도 SDD 원칙을 따라 phase 단위로 쪼갭니다.

### Phase A — 자동 로딩 + 기본 강제 (예상 30분)
**가치**: 가장 큰 갭(자동 로딩 부재)을 한 번에 해결
- A-1. `CLAUDE.md` 에 거버넌스 import 두 줄 추가
- A-2. `agent/.agent/agent.md` §4.1 경로 표기 수정
- A-3. `.claude/settings.json` 생성 + 안전 명령 화이트리스트 (`git status`, `git log`, `npm test`, `npm run lint`, `git branch`, `ls`, `bin/sdd*`)
- A-4. 검증: 새 세션에서 모델이 constitution 을 자동 인지하는지 확인

### Phase B — Backlog 골격 + 첫 Phase 만들기 (예상 1시간)
**가치**: 사용자가 만들고 싶어하는 phase>spec 계층의 형태를 *실제로* 사용해 봄
- B-1. `backlog/`, `specs/` 디렉토리 + `.gitkeep`
- B-2. `agent/templates/phase.md` 신규 작성 (통합 테스트 섹션 포함)
- B-3. `backlog/INDEX.md` 와 `backlog/queue.md` 초기 작성
- B-4. **첫 phase 작성**: PHASE-001-payment-stability (이전 리뷰의 critical 이슈들로 구성)
- B-5. 그 안에 SPEC-001-webhook-lock-fail-throw 까지 spec.md 골격 작성

### Phase C — Shell Tooling 1차 (예상 2시간)
**가치**: zsh 스크립트가 본격 가동되기 시작
- C-1. `bin/lib/common.sh`, `bin/lib/state.sh`
- C-2. `bin/sdd status` (읽기만)
- C-3. `bin/sdd phase new`, `bin/sdd spec new`
- C-4. `bin/sdd plan accept|reset`
- C-5. `bin/check-branch` (hook 용)

### Phase D — Slash Commands + Hooks (예상 1.5시간)
**가치**: 강제(enforcement) 가동
- D-1. `.claude/commands/align.md`
- D-2. `.claude/commands/spec-new.md`
- D-3. `.claude/commands/plan-accept.md`
- D-4. `.claude/commands/spec-status.md`
- D-5. `.claude/commands/handoff.md`
- D-6. `.claude/settings.json` 에 hook 4종 등록
- D-7. 검증: main 브랜치에서 `git commit` 시 차단되는지 확인

### Phase E — Shell Tooling 2차 + 사용 가이드 (예상 2시간)
- E-1. `bin/sp-show`, `bin/sp-list`
- E-2. `bin/test-spec`, `bin/test-phase`
- E-3. `bin/lint-conventions`
- E-4. `bin/webhook-replay`
- E-5. `docs/agent-guide/USAGE.md` 작성
- E-6. `docs/agent-guide/REFERENCE.md` 작성

### Phase F — 옵션 (필요 시)
- F-1. Skill: `spec-validator`
- F-2. ADR 디렉토리 골격
- F-3. 첫 ADR: "MCP 대신 zsh 채택"

---

## 11. 사용자 승인 요청 (Plan Accept Items)

> 다음 항목들은 실행 전 사용자의 명시적 승인이 필요합니다.

### 🛑 결정 필요
- [ ] **Q1**. MCP 0개 도입에 동의하시나요? (대안: 1~2개만이라도 시범 도입)
- [ ] **Q2**. SPEC ID 가 phase 에 종속되지 않고 *전역 단조 증가*인 것에 동의?
- [ ] **Q3**. Hook 차단이 너무 공격적으로 느껴질 수 있습니다. 첫 도입 시 **경고만** (exit 0, stderr 출력) 으로 시작했다가 1주 후 진짜 차단(exit 2) 으로 승격하는 게 어떨까요?
- [ ] **Q4**. `bin/` 디렉토리를 만들 것인지, 기존 `scripts/` 안에 둘지?
- [ ] **Q5**. 첫 Phase 를 PHASE-001-payment-stability 로 시작하는 데 동의? (이전 리뷰의 4 critical 이슈 묶음)

### ⚠️ 잠재적 영향
- [ ] **A**. `.claude/settings.json` 에 hook 등록 시, 사용자의 다른 프로젝트에는 영향 없음 (project-local 설정)
- [ ] **B**. `bin/` 을 PATH 에 추가할지는 사용자 환경 결정. 기본은 `./bin/sdd` 형태로 호출
- [ ] **C**. 모든 zsh 스크립트는 dry-run 지원, 실제 변경 없이 출력만 가능

### 📋 실행 모드
- [ ] **Mode**. SDD (Spec-Driven Development) 로 진행 — 본 계획서 자체를 첫 PHASE-000-harness-buildout 의 spec 으로 승격하여 진행
- [ ] **Granularity**. Phase A~F 각각을 별도 SPEC 으로 쪼개어 한 번에 한 SPEC 씩 진행 (One Spec = One Commit Series)

---

## 12. TL;DR

1. **MCP 도입 0개.** zsh 스크립트로 같은 효과를 컨텍스트 비용 0 에 얻습니다. 운영 안정화 후 MySQL MCP 만 재검토.
2. **`bin/sdd` 메타 명령**이 본 하네스의 중심. 사람과 모델이 같은 인터페이스를 공유.
3. **슬래시 커맨드 5종**: `/align`, `/spec-new`, `/plan-accept`, `/spec-status`, `/handoff`.
4. **Hook 4종**: main 보호, plan-accept 검증, 테스트 강제, SessionStart 자동 status.
5. **Backlog 계층**: `backlog/phases/PHASE-NNN/specs/SPEC-NNN/` — phase 단위 통합 테스트 의무, spec 단위 단위 테스트 의무.
6. **첫 phase 후보**: PHASE-001-payment-stability (이전 리뷰의 critical 이슈 4건).
7. **실행은 6개 phase (A~F) 로 쪼개어 약 7시간**. SPEC 단위 승인을 받으며 진행.

---

## ✋ 다음 단계

1. 이 계획서를 검토
2. §11 의 결정 항목(Q1~Q5)에 답
3. **Plan Accept** 또는 수정 요청
4. 승인 후 Phase A 부터 실행

> Plan Accept 가 떨어지기 전까지 본 에이전트는 **PLANNING 모드** 에 머무릅니다. 코드/설정 변경 없습니다.

---

*작성일: 2026-04-09 · 작성자: Claude Code Plan (harness build-out 편)*
