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

### 2.1 Mode A — SDD (Spec-Driven Development)
- **REQUIRED for**: New features, architectural changes, non-trivial refactoring, and any change producing a Pull Request.

### 2.2 Mode B — FF (Fast Flow)
- ONLY allowed with explicit User approval.
- LIMITED to: Documentation, minor configuration, and small reversible experiments.

## 3. Alignment Requirement (Mandatory)

Before any Spec, Plan, or execution:
1. The Agent MUST present: Intent understanding, Work Mode options, and a Recommendation.
2. The User MUST explicitly select a mode. No mode is valid without explicit confirmation.

## 4. Spec, Plan, and PR Contract

### 4.1 Spec Rules
- **One Spec = One Pull Request.**
- If the scope exceeds a single PR, the Spec MUST be split, and overflow moved to the Backlog.
- Every Spec MUST belong to a Phase. Orphan Specs are forbidden (use `PHASE-0-misc` if no logical home exists).

### 4.2 Plan Rules
- A Plan is an execution contract. No execution is allowed without an approved Plan.
- The Plan MUST include branch creation and test execution tasks.

### 4.3 Premature Execution (Critical)
- **Zero Tolerance**: Writing production code or changing project state BEFORE the User has explicitly approved the `plan.md` is a **CRITICAL VIOLATION**.
- **Planning Mode**: Until approval is given, the Agent MUST remain in PLANNING mode and only edit documentation.

### 4.4 Artifact Integrity (Critical)
- **Template Enforcement**: Generating `phase`, `spec`, `plan`, `task`, `walkthrough`, or `pr_description` WITHOUT reading and following the official templates in `agent/templates/` is a **CRITICAL VIOLATION**.
- **Language Requirement**: All artifacts MUST be written in **Korean** (except for code, file paths, and standard technical terms) to ensure clear communication with the User.
- **Quality Bar**: Each artifact MUST be rich enough to be self-contained for review. Vague placeholders are not acceptable in finalized artifacts.

## 5. Identifier System

### 5.1 Phase Identifier
- Format: `PHASE-{N}-{slug}` where `N` is a positive integer.
- Examples: `PHASE-1-payment-stability`, `PHASE-2-observability`.

### 5.2 Spec Identifier
- Format: `SPEC-{phaseN}-{seq}` where `phaseN` matches the parent phase number and `seq` is a 3-digit number reset per phase.
- Examples: `SPEC-1-001`, `SPEC-1-002`, `SPEC-2-001`.
- A Spec ID is immutable once assigned.

### 5.3 Branch Naming
- Feature branch: `feature/SPEC-{phaseN}-{seq}-{slug}`.
- Example: `feature/SPEC-1-001-stock-row-locking`.

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
- A PHASE is considered Done only when all its SPECs are merged AND the phase-level integration test plan (`integration-tests.md`) passes end-to-end.
- The phase walkthrough MUST attach integration test evidence.

## 9. Git Law (Strict Enforcement)

### 9.1 Branch Protection
- **No Work on `main`**: All work MUST be done on feature branches.
- Direct commits to `main` are strictly forbidden. The Agent MUST verify the current branch before starting any task.

### 9.2 Commit Protocol
- **Pre-Push Validation**: The Agent MUST execute the project's local test suite and confirm it passes before pushing a feature branch for review.
- **Commit Title Format**: MUST follow `<type>(SPEC-{phaseN}-{seq}): <description>` (lowercase type and description).
  - Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `build`, `ci`.
  - Example: `feat(SPEC-1-001): introduce row-level lock for stock decrement`.
- **Pull Request Creation**: PR creation is delegated to the User (via the project's hosted git platform UI). The Agent's responsibility ends at pushing the feature branch and archiving `walkthrough.md` / `pr_description.md` under the SPEC directory.

## 10. Backlog Law

- Backlog items are NON-EXECUTABLE.
- They MUST NOT produce code changes, tasks, or commits until promoted to a SPEC inside a PHASE with User approval.

## 11. Enforcement

- Violation of any rule invalidates current execution authority.
- The Agent MUST immediately stop, acknowledge the violation, and request user re-alignment.
- Hooks installed under `.claude/settings.json` may enforce specific rules at the tool-call level (e.g., main branch protection, plan-accept gate). Hook stderr output is authoritative.
