# spec-x-fix-archive-test-expectation: archive 테스트 기대값 + 활성 .md 표기 일관성 교정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-fix-archive-test-expectation` |
| **Phase** | 없음 (Solo Spec) |
| **Branch** | `spec-x-fix-archive-test-expectation` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-21 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

로컬 `main` 이 `origin/main` 보다 2개 커밋 앞서 있음 (push 안 됨):
- `120d0f2` fix: align docs/hooks/tests with 2-digit seq padding
- `f601417` fix: resolve remaining test regressions and sdd specx done UX bugs

두 커밋은 feature branch 없이 `main` 에 직접 커밋됨 (constitution §10.1 위반). Push 전 감사 과정에서 세 건의 문제가 확인됨.

### 문제점

**P1 — 테스트 기대값 반전 방향 오류 (`f601417`)**
- `tests/test-sdd-dir-archive.sh` Check 4 의 기대값이 "spec-x 가 아카이브됨" 으로 반전됨. 커밋 메시지는 "PR #64 신 동작 반영" 이라 주장하나, 실제로는 **PR #65 (`34f055b`) 에서 spec-x 아카이브 블록이 명시적으로 제거된 상태**. 즉 기대값 방향이 실 구현과 정반대.
- 결과: `bash tests/test-sdd-dir-archive.sh` → `PASS=9 FAIL=1` (Check 4 실패).

**P2 — 활성 .md 의 ID 표기가 constitution 과 불일치**
- `constitution.md §6.2` 는 소문자 `spec-{phaseN}-{seq}` placeholder 를 표준으로 선언.
- 그러나 일부 활성 문서는 대문자 포맷 사용:
  - `.harness-kit/agent/align.md:43-44`, `sources/governance/align.md:43-44`: `PHASE-{N}-{slug}`, `SPEC-{N}-{seq}-{slug}`
  - `.claude/commands/hk-plan-accept.md:36`, `sources/commands/hk-plan-accept.md:36`: `SPEC-{N}-{NN}-{slug}` (placeholder 이름까지 다름)
- 이 문서들은 agent/Plan Accept 단계에서 **사용자에게 상태 리포트를 출력할 때** 참조됨. 표기 불일치는 ID 작성 혼동으로 이어짐.

**P3 — `f601417` 두 UX 수정의 회귀 테스트 공백**
- `sdd specx done` 의 (a) 이중 prefix 방지, (b) active spec 매칭 시 state 리셋. 두 동작 모두 코드 트레이스상 정상이나 **테스트 0건**. 본 PR 의 다른 주장들이 검증되지 않아 문제였던 점과 대칭적으로, 이 부분도 회귀 방지가 필요.

### 해결 방안 (요약)

현재 로컬 `main` HEAD 를 그대로 가져오는 새 브랜치 `spec-x-fix-archive-test-expectation` 를 만들고, 로컬 `main` 포인터를 `origin/main` 으로 되돌림 (destructive, 작업은 브랜치에 보존). 브랜치 위에서 P1 을 복원, P2 의 4개 파일을 constitution 과 일관되게 소문자화, P3 의 회귀 테스트 2 개 추가. 전체를 단일 PR 로 제출해 정식 리뷰를 거친다.

## 🎯 요구사항

### Functional Requirements
1. **P1**: `tests/test-sdd-dir-archive.sh` Check 4 의 기대값을 "spec-x 디렉토리는 아카이브되지 않음" 으로 복원.
2. **P2**: 아래 4 개 파일의 ID 플레이스홀더를 constitution §6.2 의 `spec-{phaseN}-{seq}` / `phase-{N}` 소문자 표기와 일치시킴:
   - `.harness-kit/agent/align.md`
   - `sources/governance/align.md`
   - `.claude/commands/hk-plan-accept.md`
   - `sources/commands/hk-plan-accept.md`
3. **P3**: `tests/test-sdd-ship-completion.sh` 또는 `tests/test-sdd-specx-done.sh` (판단에 따라) 에 다음 두 회귀 테스트 추가:
   - `sdd specx done spec-x-<slug>` (prefix 포함 호출) → 이중 prefix 없이 정상 처리.
   - state.json 의 active spec 이 방금 완료한 spec-x 와 일치 → `spec=null`, `planAccepted=false` 로 리셋.
4. 전체 테스트 (`for t in tests/test-*.sh; do bash "$t"; done`) 가 FAIL 0 으로 통과.
5. `120d0f2` 와 `f601417` 커밋의 내용 전체가 하나의 PR 로 묶여 `origin/main` 으로 들어감 (브랜치 history: 원 2 + 교정 3 = 5 커밋 + ship docs).
6. 로컬 `main` 포인터는 작업 시작 전 `origin/main` 과 같은 위치로 되돌려져 있어야 함.

### Non-Functional Requirements
1. `sources/bin/sdd` 와 `.harness-kit/bin/sdd` 의 실행 로직은 수정하지 않음 (이미 PR #65 대로 spec-x skip).
2. 다른 테스트의 기대값·fixture 는 함께 수정하지 않음 (범위 폭주 방지).
3. `backlog/phase-12.md` 의 3-digit 헤더 잔재 등 *과거 역사 기록* 성격 파일은 건드리지 않음 (사용자 지침).

## 🚫 Out of Scope

- `sdd archive` 의 spec-x 처리 정책 재검토 (PR #65 결정 유지).
- 7개 테스트 fixture 의 3-digit spec-id 2-digit 전환 (별도 spec-x 로 분리 가능, 본 스펙 미포함).
- `backlog/phase-12.md` 본문의 spec-12-001/002 헤더 (사용자 지시로 보존).
- main 직접 커밋을 유발한 워크플로우 개선.
- `120d0f2` / `f601417` 의 *다른* 변경 내용 재검토.

## ✅ Definition of Done

- [ ] P1 교정 커밋 존재
- [ ] P2 교정 커밋 존재 (4 개 파일)
- [ ] P3 회귀 테스트 추가 커밋 존재 + 신규 테스트 PASS
- [ ] `for t in tests/test-*.sh; do bash "$t"; done` 결과 FAIL=0
- [ ] 로컬 `main` == `origin/main`
- [ ] `spec-x-fix-archive-test-expectation` 브랜치 push 완료
- [ ] PR 생성 및 URL 보고
- [ ] walkthrough.md / pr_description.md ship commit
