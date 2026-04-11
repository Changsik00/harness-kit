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
- See §4.1 Solo Spec conditions and §5.2 for the `spec-x-{slug}` identifier.

### 2.3 Mode C — FF (Fast Flow)
- No Pull Request is produced.
- ONLY allowed with explicit User approval.
- LIMITED to: Inline fixes, minor wording, config tweaks that do not warrant a PR.

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
| `hk-gh-pr.md` PR 확인 UX 표준화 | YES | NO | SDD-x |
| `update.sh` 버전 인식 재작성 | YES | NO | SDD-x |
| 신규 훅 5개 추가 (기능 추가) | YES | YES | SDD-P |
| Spec 자기비판 워크플로우 신설 | YES | YES | SDD-P |

## 3. Alignment Requirement (Mandatory)

Before any Spec, Plan, or execution:
1. The Agent MUST present: Intent understanding, Work Mode options, and a Recommendation.
2. The User MUST explicitly select a mode. No mode is valid without explicit confirmation.

## 4. Spec, Plan, and PR Contract

### 4.1 Spec Rules
- **One Spec = One Pull Request.**
- If the scope exceeds a single PR, the Spec MUST be split, and overflow moved to the Backlog.
- Every Spec MUST belong to a Phase. Orphan Specs are forbidden (use `phase-0` if no logical home exists).
- **Exception — Solo Spec**: A Spec MAY be created without a Phase using the `spec-x-{slug}` identifier when ALL of the following conditions are met:
  1. The change is self-contained and completable in a single PR.
  2. The type is limited to `chore`, `fix`, `docs`, or small-scope `refactor`.
  3. No new architectural decisions or feature additions are involved.
  - Solo Specs do NOT require a `phase.md` entry or `queue.md` update.

### 4.2 Plan Accept & Critique 인식
- A Plan is an execution contract. No execution is allowed without an approved Plan.
- The Plan MUST include branch creation and test execution tasks.
- **Plan Accept 인식 (SSOT)**: 다음 표현은 모두 Plan Accept로 처리한다 (대소문자 무시):
  `1`, `Y`, `yes`, `ok`, `accept`, `plan accept`, `/hk-plan-accept`
- **Critique 진입**: `2` 또는 `/hk-spec-critique` 입력 시 Critique 단계로 진입한다.
- **목록 외 응답**: 위 목록에 없는 응답을 받은 경우 에이전트는 선택을 다시 요청한다.

### 4.3 Premature Execution (Critical)
- **Zero Tolerance**: Writing production code or changing project state BEFORE the User has explicitly approved the `plan.md` is a **CRITICAL VIOLATION**.
- **Planning Mode**: Until approval is given, the Agent MUST remain in PLANNING mode and only edit documentation.

### 4.4 Artifact Integrity (Critical)
- **Template Enforcement**: Generating `phase`, `spec`, `plan`, `task`, `walkthrough`, or `pr_description` WITHOUT reading and following the official templates in `agent/templates/` is a **CRITICAL VIOLATION**.
- **Language Requirement**: All artifacts MUST be written in **Korean** (except for code, file paths, and standard technical terms) to ensure clear communication with the User.
- **Quality Bar**: Each artifact MUST be rich enough to be self-contained for review. Vague placeholders are not acceptable in finalized artifacts.

## 5. Identifier System (lowercase, hyphen-separated)

### 5.1 Phase Identifier
- Format: `phase-{N}` where `N` is a positive integer.
- Examples: `phase-1`, `phase-2`.
- Descriptive name lives only inside `phase.md`'s title, not in the ID/directory.

### 5.2 Spec Identifier
- Format: `spec-{phaseN}-{seq}` where `phaseN` matches the parent phase number and `seq` is a 3-digit number reset per phase.
- Examples: `spec-1-001`, `spec-1-002`, `spec-2-001`.
- A Spec ID is immutable once assigned.
- **Solo Spec format**: `spec-x-{slug}` — used when no Phase affiliation exists (→ §4.1 Solo Spec conditions).
  - `x` is a literal character, not a phase number.
  - `{slug}` must be unique across all specs in the repository.
  - Example: `spec-x-update-migration`

### 5.3 Layout (Flat)
- Queue dashboard: `backlog/queue.md` (sdd-managed)
- Phase definition: `backlog/phase-{N}.md` (single file per phase, contains spec table + integration tests + ADR refs)
- Spec work: `specs/spec-{phaseN}-{seq}-{slug}/` (actual artifacts)
- ADR: `docs/decisions/ADR-{NNN}-{slug}.md`
- Note: `backlog/` and `specs/` are sibling directories — `backlog/` is the *plan*, `specs/` is the *progress log*. Phase definition lives as a *single flat file* in `backlog/`, not a subdirectory.

### 5.4 Branch Naming
- Branch name = spec directory name. **No `feature/` prefix.**
- Format: `spec-{phaseN}-{seq}-{slug}`
- Example: `spec-1-001-stock-row-locking`

## 6. Execution Delegation

### 6.1 Delegation Rule
Once a Plan is explicitly accepted (Plan Accept), the Agent is authorized to:
- Execute tasks in `task.md`, commit per Task, run tests, archive walkthrough, and push the feature branch.

### 6.2 Delegation Limits
- Valid ONLY if execution stays within Plan scope.
- Any deviation (e.g., needing a new file, a new dependency, or a new decision) MUST immediately stop execution for re-alignment.

## 7. Task & Commit Integrity

- **One Task = One Commit**: Each task in `task.md` represents one logical unit of work.
- **No Batch Commits**: Grouping multiple tasks into one commit is a CRITICAL VIOLATION.
- **Commit history MUST reflect the intent and order of tasks** (commit subject mentions the SPEC ID).

## 8. Testing Requirements (Two-Tier)

### 8.1 Spec-level (Unit Tests, Mandatory)
- For all testable behavior introduced by a SPEC, unit tests MUST be written and pass before the SPEC is considered Done.
- **No Test, No Commit**: Committing code without passing tests is prohibited unless explicitly justified (e.g., documentation-only changes).

### 8.2 Spec-level Integration Tests (Optional, Declared)
- A SPEC MAY require integration tests. If so, the SPEC document MUST declare it explicitly in its `Integration Test Required` field.
- Declared integration tests MUST pass before SPEC archive.

### 8.3 Phase-level (Integration Tests, Mandatory)
- A PHASE is considered Done only when all its SPECs are merged AND the phase-level integration test scenarios (inline in `backlog/phase-{N}.md`) pass end-to-end.
- The phase walkthrough MUST attach integration test evidence.

## 9. Git Law (Strict Enforcement)

### 9.1 Branch Protection
- **No Work on `main`**: All work MUST be done on feature branches.
- Direct commits to `main` are strictly forbidden. The Agent MUST verify the current branch before starting any task.

### 9.2 Commit Protocol
- **Pre-Push Validation**: The Agent MUST execute the project's local test suite and confirm it passes before pushing a feature branch for review.
- **Commit Title Format**: MUST follow `<type>(spec-{phaseN}-{seq}): <description>` (all lowercase).
  - Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `build`, `ci`.
  - Example: `feat(spec-1-001): introduce row-level lock for stock decrement`.
- **Pull Request Creation**: The Agent MAY create a PR via slash commands (`/hk-gh-pr`, `/hk-bb-pr`) after pushing the feature branch, but MUST obtain explicit User confirmation before executing. The Agent MUST archive `walkthrough.md` / `pr_description.md` under the SPEC directory before PR creation.

## 10. Backlog Law

- Backlog items are NON-EXECUTABLE.
- They MUST NOT produce code changes, tasks, or commits until promoted to a SPEC inside a PHASE with User approval.

## 11. Enforcement

- Violation of any rule invalidates current execution authority.
- The Agent MUST immediately stop, acknowledge the violation, and request user re-alignment.
- Hooks installed under `.claude/settings.json` may enforce specific rules at the tool-call level (e.g., main branch protection, plan-accept gate). Hook stderr output is authoritative.
