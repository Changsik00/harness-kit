# Implementation Plan: spec-21-03

## 📋 Branch Strategy

- 신규 브랜치: `spec-21-03-intent-block`
- 시작 지점: `phase-21-turbo-mode` (spec-21-02 머지된 base branch)
- PR 대상: `phase-21-turbo-mode`
## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] intent.yaml 은 `.claude/state/` 에 위치 → 이미 gitignore 됨 (세션-로컬 상태)
> - [ ] intent.test 는 precheck 를 대체하지 않고 **우선**한다 — 둘 다 설정 시 intent.test 만 실행

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **intent.yaml 파싱** | grep/sed (yq 미사용) | bash 3.2 호환, yq 의존성 없음 |
| **intent vs precheck 우선순위** | intent.test 먼저, 없으면 precheck fallback | intent 가 더 구체적·세션-로컬 |
| **intent.yaml 경로** | `.claude/state/intent.yaml` | 기존 state 디렉토리 + gitignore 자동 적용 |
| **sdd intent 인터페이스** | `sdd intent "<goal>" [--test <cmd>] [--files <list>]` | 서브커맨드 없이 첫 인자가 goal |

### 📑 ADR 후보

- [ ] 없음

## 📂 Proposed Changes

### [sdd 바이너리 — intent 커맨드]

#### [MODIFY] `.harness-kit/bin/sdd`
`cmd_intent()` 함수 추가 + `main()` dispatch + `cmd_help()` 도움말 + `cmd_status()` Active Intent 행:

```bash
# sdd intent "<goal>" [--test <cmd>] [--files <a,b,c>]
# sdd intent show
# sdd intent clear

INTENT_FILE="$SDD_ROOT/.claude/state/intent.yaml"

cmd_intent() {
  local sub="${1:-show}"; shift || true
  case "$sub" in
    show)   _intent_show ;;
    clear)  _intent_clear ;;
    *)      _intent_write "$sub" "$@" ;;
  esac
}

_intent_write() { goal + test + files → intent.yaml }
_intent_show()  { cat intent.yaml or "intent 없음" }
_intent_clear() { rm intent.yaml }
```

Active Intent row in `cmd_status()` (Active Mode 행 다음에):
```bash
if [ -f "$INTENT_FILE" ]; then
  local goal
  goal=$(grep -E "^goal:" "$INTENT_FILE" | sed 's/^goal:[[:space:]]*//' | head -1)
  printf "  Active Intent: %s\n" "${C_CYN}${goal}${C_RST}"
fi
```

#### [MODIFY] `sources/bin/sdd`
동일 변경 미러링.

### [post-commit-verify 연동]

#### [MODIFY] `.harness-kit/hooks/post-commit-verify.sh`
Guard 2 이후에 intent.yaml `test` 필드 우선 확인:
```bash
INTENT_FILE="$HARNESS_ROOT/.claude/state/intent.yaml"
if [ -f "$INTENT_FILE" ]; then
  intent_test=$(grep -E "^test:" "$INTENT_FILE" | sed 's/^test:[[:space:]]*//' | head -1)
fi

if [ -n "${intent_test:-}" ]; then
  # intent.test 실행
else
  # 기존 precheck 로직 (installed.json)
fi
```

#### [MODIFY] `sources/hooks/post-commit-verify.sh`
동일 변경 미러링.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-intent-block.sh
```

9개 케이스:
- T01: `sdd intent "목표"` → intent.yaml goal 기록
- T02: `sdd intent "목표" --test "true"` → goal + test 기록
- T03: `sdd intent "목표" --files "a,b"` → goal + files 기록
- T04: `sdd intent show` → goal/test/files 출력
- T05: `sdd intent show` (intent 없음) → 안내 메시지
- T06: `sdd intent clear` → intent.yaml 삭제
- T07: `sdd status` → Active Intent 행 포함
- T08: post-commit-verify — turbo + intent.test PASS → exit 0
- T09: post-commit-verify — turbo + intent.test FAIL → revert

### 회귀 테스트
```bash
bash tests/test-turbo-hooks.sh   # T05~T08: precheck fallback 여전히 동작
bash tests/test-mode-schema.sh
```

## 🔁 Rollback Plan

- `sdd intent clear` 로 intent.yaml 제거 → post-commit-verify precheck fallback 복원
- 바이너리 변경은 git revert 로 복원 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
