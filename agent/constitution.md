# Project Constitution

The Constitution defines the invariant laws of this project. All Agents MUST comply with these rules at all times. This document takes precedence over all other instructions.

---

## 1. Authority & Decision Model

### 1.1 Roles
- **User**: Final decision maker and sole merge authority.
- **Agent**: Delegated executor within explicitly approved boundaries.

### 1.2 Decision Ownership
- The Agent MAY propose options with reasoning.
- The User MUST explicitly approve: Work Mode (SDD/FF), Spec scope, Plan (execution contract), and any merge to the main branch.
- The Agent MUST NOT self-approve any of the above.

## 2. Work Modes

### 2.1 Mode A — SDD-P (Spec-Driven Development, Phase-bound)
- A Pull Request is produced. The change belongs to a Phase (multi-spec initiative).
- **REQUIRED for**: New features, architectural changes, non-trivial refactoring.

### 2.2 Mode B — SDD-x (Spec-Driven Development, Solo)
- A Pull Request is produced. The change is self-contained with no Phase affiliation.
- See §5.1 Solo Spec conditions and §6.2 for the `spec-x-{slug}` identifier.

### 2.3 Mode C — FF (Fast Flow)
- No Pull Request is produced.
- ONLY allowed with explicit User approval.
- LIMITED to: Inline fixes, minor wording, config tweaks that do not warrant a PR.
- **State Rule**: FF 작업은 `state.json`의 active phase/spec을 변경하지 않는다.

### 2.4 Work Mode Decision Tree

Use this two-step check at the start of every Alignment Phase (→ agent.md §3):

```
Step 1 — PR이 필요한가?
  NO  → FF  (Mode C)
  YES → Step 2

Step 2 — Phase가 필요한가?
  YES → SDD-P  (Mode A)  spec-{phaseN}-{seq}-{slug}
  NO  → SDD-x  (Mode B)  spec-x-{slug}
```

**Edge Cases**

| 작업 예시 | PR? | Phase? | 모드 |
|---|:---:|:---:|:---:|
| agent.md 오탈자 한 줄 수정 | NO | — | FF |
| `hk-pr-gh.md` PR 확인 UX 표준화 | YES | NO | SDD-x |
| `update.sh` 버전 인식 재작성 | YES | NO | SDD-x |
| 신규 훅 5개 추가 (기능 추가) | YES | YES | SDD-P |
| Spec 자기비판 워크플로우 신설 | YES | YES | SDD-P |

## 3. Work Type Model

이 섹션은 harness-kit에서 사용하는 작업 유형의 역할과 경계를 정의한다. 에이전트는 모든 작업 시작 전 이 모델을 기준으로 유형을 분류해야 한다.

### 3.1 Phase (Epic)

- **역할**: 연관된 Spec들의 묶음. 독립된 통합 테스트와 릴리즈 단위가 될 수 있다.
- **진입 조건**: Spec이 3개 이상이거나, Spec 간 의존성이 있거나, 통합 테스트가 필요한 경우.
- **종료 조건**: 모든 Spec이 merge되고 phase-level 통합 테스트가 PASS된 후 사용자 최종 승인.
- **Base Branch (opt-in)**: Phase는 선택적으로 `phase-N` base 브랜치를 가질 수 있다. 이 경우 Spec PR은 main이 아닌 phase 브랜치를 타깃으로 하며, 모든 Spec 완료 후 phase 브랜치가 main으로 merge된다. Base 브랜치는 첫 번째 Spec의 hk-ship 시점에 just-in-time으로 생성된다.
- **식별자**: `phase-{N}` (→ §6.1)

### 3.2 Spec

- **역할**: Phase 내 단일 PR 단위. 독립적으로 테스트 가능하고 완전히 동작하는 변경이어야 한다.
- **진입 조건**: Phase 내에서 User가 승인한 Plan이 존재할 것.
- **종료 조건**: 단위 테스트 PASS + walkthrough/pr_description 작성 + PR merge.
- **PR 타깃**: Phase base branch 모드이면 `phase-N`, 아니면 `main`.
- **식별자**: `spec-{phaseN}-{seq}-{slug}` (→ §6.2)

### 3.3 spec-x (Solo Spec)

- **역할**: Phase 비소속 단독 PR. 긴급 수정, 단발성 개선 등 Phase에 묶기엔 작은 작업.
- **진입 조건**: 아래 조건을 모두 충족할 것 (→ §5.1 Solo Spec conditions):
  1. 단일 PR로 완결 가능
  2. 타입: `chore`, `fix`, `docs`, 소규모 `refactor`만 허용
  3. 신규 아키텍처 결정 또는 기능 추가 없음
- **종료 조건**: PR merge + queue.md 완료 섹션 갱신.
- **PR 타깃**: 항상 `main`.
- **식별자**: `spec-x-{slug}` (→ §6.2)

### 3.4 Icebox

- **역할**: 아이디어, 보류 항목, 나중에 할 일의 보관소. queue.md 하단 Icebox 섹션에 자유 형식으로 기록.
- **진입 조건**: 즉시 실행하지 않을 아이디어나 항목 발생 시 언제든지.
- **종료 조건 (승격)**:
  - 관련 항목이 쌓여 연관성이 생기면 → 새 Phase로 승격
  - 단발성이면 → spec-x로 승격
- **실행 금지**: Icebox 항목은 NON-EXECUTABLE. Phase 또는 spec-x로 승격되기 전까지 코드 변경, task, commit을 생성할 수 없다 (→ §12).
- **식별자**: 없음 (queue.md Icebox 섹션에 자유 기록)

## 4. Alignment Requirement (Mandatory)

Before any Spec, Plan, or execution:
1. The Agent MUST present: Intent understanding, Work Mode options, and a Recommendation.
2. The User MUST explicitly select a mode. No mode is valid without explicit confirmation.

## 5. Spec, Plan, and PR Contract

### 5.1 Spec Rules
- **One Spec = One Pull Request.**
- If the scope exceeds a single PR, the Spec MUST be split, and overflow moved to the Backlog.
- Every Spec MUST belong to a Phase. Orphan Specs are forbidden (use `phase-0` if no logical home exists).
- **Phase Base Branch Branching Rule**: When creating a new Spec branch in phase base branch mode, the previous Spec's PR MUST be merged into the phase base branch first. If the previous PR is unmerged, the Agent MUST ask the User to merge it before proceeding. If starting before merge is unavoidable, the Agent MUST branch from the previous Spec branch and explicitly notify the User.
- **Exception — Solo Spec**: A Spec MAY be created without a Phase using the `spec-x-{slug}` identifier when ALL of the following conditions are met:
  1. The change is self-contained and completable in a single PR.
  2. The type is limited to `chore`, `fix`, `docs`, or small-scope `refactor`.
  3. No new architectural decisions or feature additions are involved.
  - Solo Specs do NOT require a `phase.md` entry or `queue.md` update.

### 5.2 Plan Accept & Critique 인식
- A Plan is an execution contract. No execution is allowed without an approved Plan.
- The Plan MUST include branch creation and test execution tasks.
- **Plan Accept 인식 (SSOT)**: 다음 표현은 모두 Plan Accept로 처리한다 (대소문자 무시):
  `1`, `Y`, `yes`, `ok`, `accept`, `plan accept`, `/hk-plan-accept`
- **Critique 진입**: `2` 또는 `/hk-spec-critique` 입력 시 Critique 단계로 진입한다.
- **목록 외 응답**: 위 목록에 없는 응답을 받은 경우 에이전트는 선택을 다시 요청한다.

### 5.3 Premature Execution (Critical)
- **Zero Tolerance**: Writing production code or changing project state BEFORE the User has explicitly approved the `plan.md` is a **CRITICAL VIOLATION**.
- **Planning Mode**: Until approval is given, the Agent MUST remain in PLANNING mode and only edit documentation.

### 5.4 Artifact Integrity (Critical)
- **Template Enforcement**: Generating `phase`, `spec`, `plan`, `task`, `walkthrough`, or `pr_description` WITHOUT reading and following the official templates in `agent/templates/` is a **CRITICAL VIOLATION**.
- **Language Requirement**: All artifacts MUST be written in **Korean** (except for code, file paths, and standard technical terms) to ensure clear communication with the User.
- **Quality Bar**: Each artifact MUST be rich enough to be self-contained for review. Vague placeholders are not acceptable in finalized artifacts.

## 6. Identifier System (lowercase, hyphen-separated)

### 6.1 Phase Identifier
- Format: `phase-{N}` where `N` is a positive integer.
- Examples: `phase-1`, `phase-2`.
- Descriptive name lives only inside `phase.md`'s title, not in the ID/directory.
- **Phase Base Branch**: Phase base branch 모드인 경우 `phase-{N}-{slug}` 브랜치가 생성된다. slug는 phase.md 제목에서 유래한 간결한 식별자. 예: `phase-8-work-model`.

### 6.2 Spec Identifier
- Format: `spec-{phaseN}-{seq}` where `phaseN` matches the parent phase number and `seq` is a 3-digit number reset per phase.
- Examples: `spec-1-001`, `spec-1-002`, `spec-2-001`.
- A Spec ID is immutable once assigned.
- **Solo Spec format**: `spec-x-{slug}` — used when no Phase affiliation exists (→ §5.1 Solo Spec conditions).
  - `x` is a literal character, not a phase number.
  - `{slug}` must be unique across all specs in the repository.
  - Example: `spec-x-update-migration`

### 6.3 Layout (Flat)
- Queue dashboard: `backlog/queue.md` (sdd-managed)
- Phase definition: `backlog/phase-{N}.md` (single file per phase, contains spec table + integration tests + ADR refs)
- Spec work: `specs/spec-{phaseN}-{seq}-{slug}/` (actual artifacts)
- ADR: `docs/decisions/ADR-{NNN}-{slug}.md`
- Note: `backlog/` and `specs/` are sibling directories — `backlog/` is the *plan*, `specs/` is the *progress log*. Phase definition lives as a *single flat file* in `backlog/`, not a subdirectory.

### 6.4 Branch Naming
- Spec branch name = spec directory name. **No `feature/` prefix.**
- Format: `spec-{phaseN}-{seq}-{slug}`
- Example: `spec-1-001-stock-row-locking`
- Phase base branch format: `phase-{N}-{slug}` (→ §6.1). 예: `phase-8-work-model`

## 7. Execution Delegation

### 7.1 Delegation Rule
Once a Plan is explicitly accepted (Plan Accept), the Agent is authorized to:
- Execute tasks in `task.md`, commit per Task, run tests, archive walkthrough, and push the feature branch.

### 7.2 Delegation Limits
- Valid ONLY if execution stays within Plan scope.
- Any deviation (e.g., needing a new file, a new dependency, or a new decision) MUST immediately stop execution for re-alignment.

## 8. Task & Commit Integrity

- **One Task = One Commit**: Each task in `task.md` represents one logical unit of work.
- **No Batch Commits**: Grouping multiple tasks into one commit is a CRITICAL VIOLATION.
- **Commit history MUST reflect the intent and order of tasks** (commit subject mentions the SPEC ID).

## 9. Testing Requirements (Two-Tier)

### 9.1 Spec-level (Unit Tests, Mandatory)
- For all testable behavior introduced by a SPEC, unit tests MUST be written and pass before the SPEC is considered Done.
- **No Test, No Commit**: Committing code without passing tests is prohibited unless explicitly justified (e.g., documentation-only changes).

### 9.2 Spec-level Integration Tests (Optional, Declared)
- A SPEC MAY require integration tests. If so, the SPEC document MUST declare it explicitly in its `Integration Test Required` field.
- Declared integration tests MUST pass before SPEC archive.

### 9.3 Phase-level (Integration Tests, Mandatory)
- A PHASE is considered Done only when all its SPECs are merged AND the phase-level integration test scenarios (inline in `backlog/phase-{N}.md`) pass end-to-end.
- The phase walkthrough MUST attach integration test evidence.

## 10. Git Law (Strict Enforcement)

### 10.1 Branch Protection
- **No Work on `main`**: All work MUST be done on feature branches.
- Direct commits to `main` are strictly forbidden. The Agent MUST verify the current branch before starting any task.

### 10.2 Commit Protocol
- **Pre-Push Validation**: The Agent MUST execute the project's local test suite and confirm it passes before pushing a feature branch for review.
- **Commit Title Format**: MUST follow `<type>(spec-{phaseN}-{seq}): <description>` (all lowercase).
  - Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `build`, `ci`.
  - Example: `feat(spec-1-001): introduce row-level lock for stock decrement`.
- **Pull Request Creation**: The Agent MAY create a PR via slash commands (`/hk-pr-gh`, `/hk-pr-bb`) after pushing the feature branch, but MUST obtain explicit User confirmation before executing. The Agent MUST archive `walkthrough.md` / `pr_description.md` under the SPEC directory before PR creation.

## 11. Backlog Law

- Backlog items are NON-EXECUTABLE.
- They MUST NOT produce code changes, tasks, or commits until promoted to a SPEC inside a PHASE with User approval.

## 12. Enforcement

- Violation of any rule invalidates current execution authority.
- The Agent MUST immediately stop, acknowledge the violation, and request user re-alignment.
- Hooks installed under `.claude/settings.json` may enforce specific rules at the tool-call level (e.g., main branch protection, plan-accept gate). Hook stderr output is authoritative.
