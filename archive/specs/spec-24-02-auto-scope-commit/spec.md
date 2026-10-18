# spec-24-02: blast-radius 가드 커밋시점 정렬 (scope dual-mode)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-24-02` |
| **Phase** | `phase-24` |
| **Branch** | `spec-24-02-auto-scope-commit` |
| **Base 브랜치** | `main` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-06-19 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`check-scope.sh` 는 Edit/Write PreToolUse 훅이다 — 편집 대상 1개 파일(`hook_tool_input file_path`)을 active spec 의 `spec.md` Proposed Changes(`[MODIFY/NEW/DELETE] \`path\``) 와 대조해 범위 밖이면 차단. turbo/auto bypass(spec-24-01).

### 문제점

ADR-009 Consequences(부정): **MCP 경유 편집(Serena 쓰기 등)은 `Edit|Write` 매처를 우회** → scope 검사를 안 거친다. auto 모드(unattended)에서 이 구멍이 특히 위험하다 — 사람이 실시간으로 diff 를 안 보므로. scope 는 *도구가 아니라 결과(diff)* 기준의 blast-radius 가드여야 한다.

### 해결 방안

`check-scope.sh` 를 **dual-mode** 로 (이미 `check-secrets.sh` 가 쓰는 `HARNESS_GIT_HOOK_MODE` 패턴). 커밋 시점에 `pre-commit.sh` 가 staged diff 전체를 같은 scope 규칙으로 검사 → *편집 도구와 무관하게* MCP 편집까지 포착. 단, auto 를 멈추지 않도록 **경고 모드(exit 0 + stderr)** 로 시작(hook 단계론). blast-radius 는 차단이 아니라 *사후 노출* (phase-ship 검토)로 (ADR-009).

## 요구사항

1. `check-scope.sh` 가 commit 모드(`HARNESS_GIT_HOOK_MODE=1`)에서 staged 파일 전체를 scope 대조.
2. commit 모드는 **경고만**(exit 0 + stderr) — 커밋/auto 진행을 막지 않음.
3. commit 모드는 **mode 무관**(turbo/auto 도 검사) — blast-radius 가드라서. (edit 모드는 기존대로 turbo/auto bypass 유지)
4. scope 추출·매칭 로직은 edit/commit 모드가 공유 (DRY).
5. `pre-commit.sh` 가 secret 검사 뒤 scope 검사 호출.
6. 안전경로(.md·docs·specs 등)·plan 미승인·active spec 없음은 기존대로 면제.

## Out of Scope

- 정지규칙 ②(비가역 행동) — spec-24-03 (scope warn 은 정지가 아님)
- 경고 → 차단 승격 — 1주 운영 후 별도 (hook 단계론)
- 결정 로그 적재 — spec-24-03

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] commit 모드 scope 는 **경고 only + mode 무관** — auto 를 멈추지 않으면서 MCP 우회를 노출. (ADR-009 기반 채택)

> [!WARNING]
> - [ ] edit 모드(turbo/auto bypass)와 commit 모드(mode 무관)의 동작 차이가 의도적임 — 혼동 주의. spec 에 명시.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| `check-scope.sh` | edit/commit dual-mode, 로직 공유 | DRY, check-secrets 선례 |
| commit 모드 | 경고(exit 0) + mode 무관 | auto 안 멈춤 + 도구 무관 노출 |
| `pre-commit.sh` | scope(commit 모드) 호출 추가 | 커밋 = 도구 무관 지점 |

## Proposed Changes

#### [MODIFY] `sources/hooks/check-scope.sh` (+ 미러 `.harness-kit/hooks/check-scope.sh`)
- scope 추출 + 단일경로 매칭을 함수로 분리. `HARNESS_GIT_HOOK_MODE=1` 이면 staged 파일 루프 + 경고(exit 0), mode bypass 안 함. edit 모드는 기존 동작 유지.

#### [MODIFY] `sources/hooks/pre-commit.sh` (+ 미러 `.harness-kit/hooks/pre-commit.sh`)
- secret 검사 블록 뒤에 `HARNESS_GIT_HOOK_MODE=1 bash check-scope.sh || true` (경고 모드).

#### [NEW] `tests/test-scope-commit.sh`
- commit 모드: 범위 밖 staged 파일 → 경고(exit 0) + stderr 메시지, 범위 안 → 무출력, turbo/auto 에서도 검사됨, .md 면제.

## 검증 계획

```bash
bash tests/test-scope-commit.sh
for t in tests/test-*.sh; do bash "$t" >/dev/null 2>&1 && echo "PASS $t" || echo "FAIL $t"; done
```

수동 검증 시나리오:
1. plan-accepted spec 에서 scope 밖 파일 staged + commit → 기대: 커밋 성공(경고 only) + stderr 에 scope 경고
2. mode=auto 로 동일 → 기대: 여전히 경고 출력(mode 무관)

## 롤백 계획

- `git revert` — 훅 로직 추가만, 경고 모드라 기존 커밋 흐름 불변(차단 없음). state 영향 없음.

## ADR 후보

- [ ] 있음
- [x] 없음 — ADR-009 가 거버닝(blast-radius 커밋시점 정렬은 그 Consequences 항목의 구현).

## ✅ Definition of Done

- [ ] 모든 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-24-02-auto-scope-commit` 브랜치 push 완료
