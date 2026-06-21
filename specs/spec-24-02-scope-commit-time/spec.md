# spec-24-02: blast-radius scope 가드 커밋시점 정렬

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-24-02` |
| **Phase** | `phase-24` |
| **Branch** | `spec-24-02-scope-commit-time` |
| **Base 브랜치** | `main` (phase-24 는 base 브랜치 없음 — 각 spec → main) |
| **상태** | Planning |
| **타입** | Feature (hook 가드 추가) |
| **작성일** | 2026-06-21 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

blast-radius scope 불변식(constitution §6.2 — spec.md `Proposed Changes` 에 명시된 파일만 편집)은 현재 `sources/hooks/check-scope.sh` 가 **PreToolUse `Edit|Write|MultiEdit` 매처** 로만 강제한다. 즉 Claude Code 네이티브 편집 도구를 통과하는 편집만 검사된다.

### 문제점

ADR-009 Consequences(부정)가 명시한 우회 경로: **MCP 경유 편집(예: Serena 쓰기)은 `Edit|Write` 훅 매처를 우회**한다. MCP 도구로 spec 범위 밖 파일을 고쳐도 scope 가드가 발동하지 않는다. auto 모드(unattended)에서는 사람이 실시간으로 못 잡으므로 이 우회가 phase-ship 까지 묻힐 수 있다 — auto 모드의 선행조건 결함이다.

핵심: scope 불변식이 *편집 도구* 에 묶여 있어 도구를 바꾸면 무력화된다. 불변식은 *모든 변경이 반드시 통과하는 지점* = **git 커밋 시점** 에서 검사되어야 도구 무관하게 유효하다.

### 해결 방안

scope 매칭의 *순수 로직* 을 `_scope.sh` 로 추출해 (1) 기존 편집시점 `check-scope.sh` 와 (2) 신규 **커밋시점 검사**(git `pre-commit.sh`)가 공유한다. 커밋시점 검사는 staged 파일을 spec.md `Proposed Changes` scope 와 대조해 위반을 알린다. git 네이티브 pre-commit hook 은 편집 도구·MCP·터미널 등 *모든* 커밋 경로에서 발동하므로 도구 무관하게 유효하다. hook 단계론(CLAUDE.md #5)에 따라 **경고 모드(stderr + exit 0)** 로 시작한다.

## 요구사항

1. scope 매칭 핵심 로직을 `sources/hooks/_scope.sh` 의 순수 함수로 추출한다(hook env·모드 의존 없음).
2. `check-scope.sh` 는 `_scope.sh` 를 source 해 동일 동작을 유지한다(behavior-preserving 리팩터 — turbo/auto 편집시점 면제 등 기존 분기 보존).
3. `pre-commit.sh` 에 **커밋시점 scope 검사** 를 추가한다:
   - 활성 spec + `specs/<spec>/spec.md` 존재 + `Proposed Changes` scope 패턴이 있을 때만 동작.
   - staged 파일 중 안전경로(§핵심 전략)도 scope 패턴도 아닌 파일을 **경고**(stderr)한다.
   - **경고 모드** — 위반해도 커밋을 막지 않는다(exit 0). 기존 plan-accept 차단 로직의 exit code 에 영향 없음.
   - 모드(governed/turbo/auto) 와 무관하게 동작한다(turbo/auto 의 MCP 우회를 잡는 것이 목적).
4. 도그푸딩 미러(`.harness-kit/hooks/`)에 동일 반영. `.git/hooks/pre-commit` 은 `.harness-kit/hooks/pre-commit.sh` 를 호출하는 래퍼라 별도 재설치 불필요.
5. 신규 테스트 `tests/test-scope-commit-time.sh` PASS + 기존 `tests/test-git-precommit-hook.sh` 회귀 없음.

## Out of Scope

- 정지규칙 ②(비가역 행동) 엔진 / 결정 로그 — spec-24-03.
- 경고 → 차단(exit 2) 승격 — 1주 운영 후 별건(phase-FF 또는 후속 spec).
- `check-scope.sh` 의 scope 패턴 문법 확장(현행 ``[MODIFY|NEW|DELETE] `path` `` 유지).
- 안전경로 화이트리스트 정책 변경.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 커밋시점 검사를 **경고 모드** 로만 시작(차단 아님). MCP 우회를 *탐지·로깅* 하되 커밋은 통과 — 차단 승격은 1주 운영 후 별건.

> [!WARNING]
> - [ ] 본 spec 의 hook 변경은 도그푸딩으로 *이 저장소의 실제 pre-commit* 에 즉시 적용됨. 경고 모드(exit 0)라 커밋 차단 위험은 없으나, scope 밖 파일 커밋 시 stderr 경고가 출력될 수 있음.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **`_scope.sh`** | scope 매칭 순수 함수 추출 (`scope_is_safe_path`·`scope_extract_paths`·`scope_path_in_scope`) | 편집시점·커밋시점이 *동일 불변식* 공유 → DRY·일관·테스트 용이 |
| **`check-scope.sh`** | inline 매칭 제거 → `_scope.sh` 위임 | behavior-preserving. 기존 早期 exit(모드/plan/spec) 유지 |
| **`pre-commit.sh`** | staged 파일 루프 + `scope_path_in_scope` 대조, 경고 모드 | git 네이티브 hook = 도구 무관 커밋 관문. 모든 모드에서 동작 |

**안전경로**(항상 허용, `_scope.sh` 에 집약): `.harness-kit/*` `docs/*` `backlog/*` `specs/*` `.claude/*` `.gitignore` `README.md` `CLAUDE.md` `version.json` `*.md` — 기존 화이트리스트와 동일 유지.

**커밋시점 동작 조건**(편집시점과 다름): `planAccepted` 와 무관하게 **활성 spec + spec.md + scope 패턴 존재** 만으로 동작. auto/turbo 는 `planAccepted=false` 여도 spec.md `Proposed Changes` 가 존재하므로 이 경로로 잡힌다.

## Proposed Changes

#### [NEW] `sources/hooks/_scope.sh`
scope 매칭 순수 함수 라이브러리. hook env·모드 의존 없는 3 함수: `scope_is_safe_path <rel>`(안전경로면 0), `scope_extract_paths <plan_file>`(``[MODIFY|NEW|DELETE] `path` `` 패턴 추출), `scope_path_in_scope <rel> <plan_file>`(안전경로 OR 패턴 매칭 OR 패턴 없음 → 0=in-scope, 아니면 1=out-of-scope).

#### [MODIFY] `sources/hooks/check-scope.sh`
inline scope 추출·매칭 블록 제거 후 `_scope.sh` source → `scope_path_in_scope` 위임. 모드/plan/spec/plan_file 早期 exit 와 `hook_violation` 호출은 유지. 동작 불변.

#### [MODIFY] `sources/hooks/pre-commit.sh`
secret 검사 이후, plan-accept 게이트 이전에 **커밋시점 scope 경고 블록** 추가. `_scope.sh` source, 활성 spec/spec.md 확인 후 staged 파일 루프, out-of-scope 면 stderr 경고(exit 0 유지). `STATE_FILE` 정의를 블록 앞으로 이동.

#### [NEW] `tests/test-scope-commit-time.sh`
TDD. 커버리지: (a) `_scope.sh` 함수 in/out-scope 판정, (b) pre-commit out-of-scope staged → stderr 경고, (c) in-scope staged → 무경고, (d) 경고 모드 → 항상 exit 0(커밋 미차단), (e) spec.md 없음 → no-op.

#### [NEW] `.harness-kit/hooks/_scope.sh` · [MODIFY] `.harness-kit/hooks/check-scope.sh` · [MODIFY] `.harness-kit/hooks/pre-commit.sh`
도그푸딩 미러. sources/ 와 동일 내용(각 구현 task 에서 두 트리 동시 반영).

## 검증 계획

```bash
bash tests/test-scope-commit-time.sh      # 신규 — PASS
bash tests/test-git-precommit-hook.sh     # 회귀 — PASS 유지
bash tests/run-all.sh                     # 전체 스위트 회귀 (존재 시)
```

수동 검증 시나리오:
1. 임시 repo 에 활성 spec + spec.md(``Proposed Changes: [MODIFY] `a.sh` ``) 주입 → `b.sh`(scope 밖) staged → `pre-commit.sh` 실행. 기대: stderr 에 `⚠ [scope:warn] ... b.sh`, **exit 0**(커밋 통과).
2. 동일 상태에서 `a.sh` staged → 기대: scope 경고 없음, exit 0.

## 롤백 계획

- `git revert` 로 전체 되돌림. state/마이그레이션/외부 부수효과 없음.
- 도그푸딩 hook 은 `.harness-kit/hooks/` 파일 revert 시 즉시 원복(래퍼 indirection — 재설치 불필요).

## ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — ADR-009 가 이미 "blast-radius 가드 커밋시점 정렬" 을 거버닝. 본 spec 은 그 구현이며 새 아키텍처 결정 없음. (Bash 매처 대신 git 네이티브 hook 선택 근거는 walkthrough 결정 기록에 남김.)

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (신규 + 회귀)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-24-02-scope-commit-time` 브랜치 push 완료
