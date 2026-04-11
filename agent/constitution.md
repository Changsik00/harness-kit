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
- **State Rule**: FF work MUST NOT modify `state.json`'s active phase/spec.

### 2.4 Work Mode Decision Tree

Use this two-step check at the start of every Alignment Phase (→ agent.md §3):

```
Step 1 — Is a PR required?
  NO  → FF  (Mode C)
  YES → Step 2

Step 2 — Is a Phase required?
  YES → SDD-P  (Mode A)  spec-{phaseN}-{seq}-{slug}
  NO  → SDD-x  (Mode B)  spec-x-{slug}
```

**Edge Cases**

| Example | PR? | Phase? | Mode |
|---|:---:|:---:|:---:|
| One-line typo fix in agent.md | NO | — | FF |
| `hk-pr-gh.md` PR confirmation UX standardization | YES | NO | SDD-x |
| `update.sh` version detection rewrite | YES | NO | SDD-x |
| Adding 5 new hooks (feature addition) | YES | YES | SDD-P |
| New spec self-critique workflow | YES | YES | SDD-P |

## 3. Work Type Model

This section defines the roles and boundaries of work types used in harness-kit. The Agent MUST classify work by this model before starting any task.

### 3.1 Phase (Epic)

- **Role**: A grouping of related Specs. Can serve as an independent integration test and release unit.
- **Entry Condition**: 3+ Specs, or inter-Spec dependencies exist, or integration testing is required.
- **Exit Condition**: All Specs merged, phase-level integration tests PASS, and User final approval via `/hk-phase-ship`.
- **Phase Ship Rule**: The Agent MUST NOT create a Phase PR (phase branch → main) without explicit User go/no-go approval. The `/hk-phase-ship` procedure — including success criteria verification, integration test execution, and go/no-go report — MUST be completed before PR creation. The Phase PR body MUST follow the `phase-ship.md` template.
- **Base Branch (opt-in)**: A Phase MAY optionally have a `phase-N-{slug}` base branch. In this case, Spec PRs target the phase branch instead of main, and the phase branch merges to main after all Specs are complete. The base branch is created just-in-time at the first Spec's hk-ship.
- **Identifier**: `phase-{N}` (→ §6.1)

### 3.2 Spec

- **Role**: A single PR unit within a Phase. Must be independently testable and fully functional.
- **Entry Condition**: A User-approved Plan exists within the Phase.
- **Exit Condition**: Unit tests PASS + walkthrough/pr_description written + PR merge.
- **PR Target**: `phase-N-{slug}` if Phase base branch mode, otherwise `main`.
- **Identifier**: `spec-{phaseN}-{seq}-{slug}` (→ §6.2)

### 3.3 spec-x (Solo Spec)

- **Role**: A standalone PR not affiliated with any Phase. For urgent fixes, one-off improvements too small for a Phase.
- **Entry Condition**: ALL of the following must be met (→ §5.1 Solo Spec conditions):
  1. Completable in a single PR
  2. Type limited to `chore`, `fix`, `docs`, or small-scope `refactor`
  3. No new architectural decisions or feature additions
- **Exit Condition**: PR merge + queue.md done section update.
- **PR Target**: Always `main`.
- **Identifier**: `spec-x-{slug}` (→ §6.2)

### 3.4 Icebox

- **Role**: A holding area for ideas, deferred items, and future work. Recorded in free-form in the queue.md Icebox section.
- **Entry Condition**: Any time an idea or item arises that should not be executed immediately.
- **Exit Condition (Promotion)**:
  - When related items accumulate → promote to a new Phase
  - When standalone → promote to spec-x
- **Execution Prohibition**: Icebox items are NON-EXECUTABLE. No code changes, tasks, or commits may be created until promoted to a Phase or spec-x (→ §12).
- **Identifier**: None (free-form in queue.md Icebox section)

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

### 5.2 Plan Accept & Critique Recognition
- A Plan is an execution contract. No execution is allowed without an approved Plan.
- The Plan MUST include branch creation and test execution tasks.
- **Plan Accept Recognition (SSOT)**: The following expressions are all treated as Plan Accept (case-insensitive):
  `1`, `Y`, `yes`, `ok`, `accept`, `plan accept`, `/hk-plan-accept`
- **Critique Entry**: Input of `2` or `/hk-spec-critique` enters the Critique phase.
- **Unrecognized Response**: For any response not in the above list, the Agent MUST re-request the selection.

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
- **Phase Base Branch**: In phase base branch mode, a `phase-{N}-{slug}` branch is created. The slug is a concise identifier derived from the phase.md title. Example: `phase-8-work-model`.

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
- Phase base branch format: `phase-{N}-{slug}` (→ §6.1). Example: `phase-8-work-model`

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
