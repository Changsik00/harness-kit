# Implementation Plan: spec-x-check-secrets-dual-mode

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-check-secrets-dual-mode`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `pre-commit.sh`에서 `check-secrets.sh`를 block 모드(`|| exit 1`)로 호출 — 시크릿 발견 시 사용자 직접 commit이 차단됨. 현재 staged-lint는 경고 모드(`|| true`)로 동작 중이므로 동작 방식이 다름.
> - [ ] `check-secrets.sh`가 Claude Code 환경 감지에 실패 시 fallback 경로(git hook 모드)로 진입 — 오탐 가능성 미미하지만 존재.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **환경 감지** | `hook_tool_input command` 반환값 유무로 Claude Code 환경 판별 | 기존 함수 재사용, 환경변수 추가 불필요 |
| **듀얼 분기** | `cmd` 비어있으면 git hook 모드로 진입, 있으면 기존 `git commit` 매칭 로직 | 단일 파일 SSOT, 코드 중복 없음 |
| **호출 방식** | `pre-commit.sh`에서 `|| exit 1` (block 모드) | secret은 warn보다 block이 적합 |

### 📑 ADR 후보

- [ ] 없음

## 📂 Proposed Changes

### [MODIFY] `sources/hooks/check-secrets.sh`

현재 line 15-21 (`cmd` 체크 및 `git commit` 매칭 조건):

```bash
# 현재:
cmd="$(hook_tool_input command)"
[ -z "$cmd" ] && exit 0          # ← Claude Code 환경 아니면 즉시 통과 (버그)

if ! echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+commit\b'; then
  exit 0
fi

# 변경 후:
cmd="$(hook_tool_input command)"
if [ -z "$cmd" ]; then
  # git hook 모드 (직접 commit) — 명령어 매칭 불필요, 바로 staged 검사로 진입
  : # fall through
else
  # Claude Code 모드 — git commit 명령만 검사
  if ! echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+commit\b'; then
    exit 0
  fi
fi
```

### [MODIFY] `sources/hooks/pre-commit.sh`

line 17 (staged-lint 호출 다음)에 `check-secrets.sh` 호출 추가:

```bash
# staged-lint 다음에 추가:
if [ -f "$HARNESS_HOOKS/check-secrets.sh" ]; then
  bash "$HARNESS_HOOKS/check-secrets.sh" || exit 1
fi
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/run_tests.sh
```

### 수동 검증 시나리오

1. AWS 키 패턴(`AKIA` + 16자 대문자/숫자)을 파일에 추가 후 `git add` → `git commit` 직접 실행
   - 기대 결과: secret 감지 메시지 + 커밋 차단
2. 정상 파일 `git commit` 직접 실행
   - 기대 결과: 커밋 통과
3. Claude Code 에이전트가 `git commit` 실행 (기존 동작 회귀 없음)
   - 기대 결과: secret 있으면 차단, 없으면 통과

## 🔁 Rollback Plan

- `sources/hooks/check-secrets.sh`와 `sources/hooks/pre-commit.sh`를 이전 커밋으로 `git revert`
- 설치된 프로젝트는 `update.sh` 재실행 불필요 (미갱신 상태 유지됨)

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
