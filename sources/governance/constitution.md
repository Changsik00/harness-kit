# Project Constitution (constitution.md)

The Constitution defines the invariant laws of this project. All Agents MUST comply with these rules at all times. This document takes precedence over all other instructions.

---

## 1. Authority & Decision Model

### 1.1 Roles
- **User**: Final decision maker and sole merge authority.
- **Agent**: Delegated executor within explicitly approved boundaries.

### 1.2 Decision Ownership
- The Agent MAY propose options with reasoning.
- The User MUST approve: Work Mode (SDD/FF), Spec scope, Plan (execution contract), and Pull Request merge.
- The Agent MUST NOT self-approve any of the above.

## 2. Work Modes

### 2.1 Mode A — SDD (Spec-Driven Development)
- **REQUIRED for**: New features, architectural changes, non-trivial refactoring, and any change producing a PR.

### 2.2 Mode B — FF (Fast Flow)
- ONLY allowed with explicit User approval.
- LIMITED to: Documentation, minor configuration, and small reversible experiments.

## 3. Alignment Requirement (Mandatory)

Before any Spec, Plan, or execution:
1. Agent MUST present: Intent understanding, Work Mode options, and Recommendation.
2. User MUST explicitly select a mode. No mode is valid without explicit confirmation.

## 4. Spec, Plan, and PR Contract

### 4.1 Spec Rules
- One Spec = One Pull Request.
- If the scope exceeds a single PR, the Spec MUST be split, and overflow moved to the Backlog.

### 4.2 Plan Rules
- A Plan is an execution contract. No execution is allowed without an approved Plan.
- The Plan MUST include branch creation and test execution tasks.

### 4.3 Premature Execution (Critical)
- **Zero Tolerance:** Writing production code or changing project state BEFORE the user has explicitly approved the `plan.md` is a **CRITICAL VIOLATION**.
- **Planning Mode:** Until approval is given, the Agent MUST remain in PLANNING mode and only edit documentation.

### 4.4 Artifact Integrity (Critical)
- **Template Enforcement**: Generating `spec`, `plan`, `task`, `walkthrough`, or `pr_description` WITHOUT reading and following the official templates in `docs/templates/` is a **CRITICAL VIOLATION**.
- **Language Requirement:** All artifacts MUST be written in **Korean** (except for technical terms/code) to ensure clear communication.
- **Spec 033 Benchmark:** Spec 033 (`LangGraph State Management`) represents the minimum expected quality for major features. Match its level of detail and visual clarity.
- **PR Description Omission:** Failing to create or archive `pr_description.md` before PR creation is considered an **Artifact Integrity Violation**.

## 5. Execution Delegation

### 5.1 Delegation Rule
Once a Plan is explicitly accepted (Plan Accept), the Agent is authorized to:
- Execute tasks in `tasks.md`, commit per Task, run tests, and create a PR.

### 5.2 Delegation Limits
- Valid ONLY if execution stays within Plan scope.
- Any deviation (e.g., needing a new file or new decision) MUST immediately stop execution for re-alignment.

## 6. Task & Commit Integrity

- **One Task = One Commit**: Each task in `tasks.md` represents one logical unit of work.
- **No Batch Commits**: Grouping multiple tasks into one commit is a CRITICAL VIOLATION.
- Commit history MUST reflect the intent and order of tasks.

## 7. Testing & Quality Gate (Commit-Level TDD)

- **Test Requirement**: For all testable behavior, tests MUST be written and pass before a task is considered complete.
- **No Test, No Commit**: Committing code without passing tests is prohibited unless explicitly justified (e.g., documentation).

## 8. Clean Architecture (Invariant)

- **Dependency Rule**: Source code dependencies MUST point inwards only.
- Layer violations (Entities, Use Cases, Adapters, Frameworks) are PROHIBITED.
- Any violation requires an immediate stop and correction.

## 9. Git Law (Strict Enforcement)

### 9.1 Branch Protection
- **No Work on `main`**: All work MUST be done on feature branches.
- Direct commits to `main` are strictly forbidden. The Agent MUST verify the current branch before starting any task.

### 9.2 Commit Protocol
- **Pre-Push Validation**: The Agent MUST execute all local tests and confirm they pass before pushing a feature branch for review.
- **Commit Title Format**: MUST follow `<type>(<scope>): <description>` (lowercase). Reference `git log --oneline` for project patterns.
- **Pull Request Creation**: PR creation is delegated to the User (via the project's hosted git platform UI). The Agent's responsibility ends at pushing the feature branch and archiving `walkthrough.md` / `pr_description.md` under `specs/`.

## 10. Backlog Law

- Backlog items are NON-EXECUTABLE.
- They MUST NOT produce code changes, tasks, or commits until promoted to a Spec with User approval.

## 11. Enforcement

- Violation of any rule invalidates current execution authority.
- Requires an immediate stop, acknowledgement of the violation, and user re-alignment.

## 12. Prompt Engineering Standards

### 12.1 Quality Assurance (Test Coverage)
- **Minimum Coverage**: All production prompts MUST be verified against at least **20 diverse test cases**.
- **Edge Case Requirement**: Test cases MUST include edge cases (e.g., empty input, injection attempts, non-English queries).
- **Golden Dataset**: Changes to prompts MUST NOT degrade performance on the Golden Dataset.

### 12.2 Versioning & Management
- **Versioning**: All prompts MUST be versioned (e.g., `v1.0`, `v1.1`).
- **No Hard-coding**: Prompts MUST be stored in external configuration or dedicated prompt files, NEVER hard-coded in logic code.
- **Traceability**: Every prompt change MUST be linked to a specific Spec or Issue.
