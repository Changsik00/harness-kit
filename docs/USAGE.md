# harness-kit 사용 가이드

> 본 문서는 **사용자(사람) 관점의 워크플로 가이드** 입니다.
> 명령/슬래시/hook 의 사전식 레퍼런스는 [REFERENCE.md](./REFERENCE.md) 를 보세요.

## 설치

### 사전 준비 (macOS)
```bash
brew install bash jq git    # bash 4.0+ 필요 (시스템 bash 는 3.2)
```

### 첫 설치
```bash
# 1. 키트가 있는 위치에서 대상 프로젝트로
~/Project/ai/claude/install.sh ~/my-project

# 또는 대상 프로젝트로 이동해서
cd ~/my-project
~/Project/ai/claude/install.sh

# 또는 dry-run 으로 미리 보기
~/Project/ai/claude/install.sh --dry-run ~/my-project
```

### 점검
```bash
~/Project/ai/claude/doctor.sh ~/my-project
# 또는 대상에서
./scripts/harness/doctor.sh   # (있다면)
```

### 갱신
```bash
~/Project/ai/claude/update.sh ~/my-project
```

### 제거
```bash
~/Project/ai/claude/uninstall.sh ~/my-project
# backlog/specs 같은 산출물은 보존됩니다.
```

---

## 일상 워크플로 (Day in the life)

> 🎯 핵심 원칙: **사용자가 명시적으로 승인하기 전까지 에이전트는 코드를 만지지 않는다.**

### 🌅 1. 첫 세션 시작

```
Terminal:        cd ~/my-project && claude
Claude Code 안:   /align
```

`/align` 슬래시 커맨드는 다음을 자동으로 합니다:
1. `agent/constitution.md`, `agent/agent.md` 로딩
2. `bin/sdd status` 실행
3. 현재 상태 요약 보고
4. **단 하나의 질문**: "어떤 컨텍스트로 진행할까요?"

이 시점에 사용자가 결정합니다 — 새 phase 시작? 기존 spec 이어서? 다른 일?

---

### 🆕 2. 새 Phase 시작 (전략적 묶음)

새 비즈니스 가치/위험 영역을 다룰 때.

```bash
./scripts/harness/bin/sdd phase new payment-stability
```

이 명령은:
- `backlog/phase-1.md` 단일 파일 생성 (slug 는 phase 제목으로만 사용)
- `phase.md` 템플릿 복사 (한국어 골격)
- `backlog/queue.md` 자동 생성/갱신 (대시보드)
- 통합 테스트 시나리오는 `phase-1.md` 의 인라인 섹션에 작성
- `.claude/state/current.json` 의 active phase 갱신

생성 후 **사용자가 직접** `phase.md` 를 채웁니다. 배경/목표/성공 기준/포함된 SPEC 목록/의존성 등.

> 💡 phase.md 의 SPEC 목록은 *계획* 입니다. 진행하면서 SPEC 이 추가/제거될 수 있습니다.

---

### 📝 3. 새 SPEC 시작 (한 PR 단위 작업)

```bash
./scripts/harness/bin/sdd spec new webhook-lock-fail-throw
```

이 명령은:
- 자동으로 다음 SPEC 번호 부여 (현재 phase 안에서)
- `specs/spec-1-001-webhook-lock-fail-throw/` 생성 (소문자, 평면 배치)
- 5종 템플릿 복사: `spec.md`, `plan.md`, `task.md`, `walkthrough.md`, `pr_description.md`
- active spec 갱신, `planAccepted=false`

이제 **PLANNING 모드** 입니다. 에이전트는 이 시점부터:
- ✅ spec.md / plan.md / task.md 작성 가능
- ✅ 문서 (`agent/`, `docs/`, `*.md`) 편집 가능
- ❌ src/, lib/ 등 production 코드 편집 불가 (hook 가 차단)

사용자와 함께 spec.md → plan.md → task.md 순으로 작성합니다.

---

### ✅ 4. Plan Accept (실행 모드 진입)

plan.md / task.md 가 충분하다고 판단되면:

```bash
./scripts/harness/bin/sdd plan accept
```

이 명령은:
- plan.md / task.md 가 비어있지 않은지 확인
- 템플릿 placeholder (`{phaseN}`, `{slug}`, `<제목>` 등) 가 남아있지 않은지 확인
- `planAccepted=true` 로 설정
- **이제 hook 가 production 코드 편집을 통과시킵니다.**

> ⚠️ 한 번 Accept 하면 에이전트가 코드를 만질 수 있게 됩니다. 본 명령은 신중하게.

---

### 🔄 5. Strict Loop (한 Task = 한 Commit)

Plan Accept 후 에이전트는 task.md 의 첫 task 부터 다음을 반복:

1. **브랜치 확인** — main 이 아닌지
2. **Test 작성** — TDD red
3. **Implement** — 최소 코드
4. **Test Pass** — TDD green
5. **`./scripts/harness/bin/sdd test passed`** — 테스트 통과 시각 기록
6. **Commit** — `<type>(spec-1-001): description` (모두 소문자)
7. **`./scripts/harness/bin/sdd task done <num>`** — task.md 갱신
8. **사용자에게 보고 + 다음 task 진행 신호 대기**

> ⚠️ Strict Loop 은 batching 금지. 한 task 끝낼 때마다 사용자 확인을 받습니다.

---

### 🚪 6. Hand-off (작업 종료)

모든 task 완료 후:

```bash
./scripts/harness/bin/sdd ship --check    # walkthrough/pr_description 검증
```

부족한 부분 보완 후:

```bash
./scripts/harness/bin/sdd ship            # ship commit 생성
git push -u origin spec-1-001-webhook-lock-fail-throw
./scripts/harness/bin/sdd plan reset
```

PR 은 hosted git UI 에서 사용자가 직접 생성. 본문은 `pr_description.md` 그대로 복사.

---

### 🏁 7. Phase 종료

해당 phase 의 모든 SPEC 이 merged 되면:

1. `phase.md` 의 SPEC 표 갱신 (Status: Merged)
2. `backlog/phase-N.md` 의 통합 테스트 시나리오 모두 실행 → PASS 확인
3. `walkthrough.md` (phase 단위) 작성 — 통합 테스트 결과 첨부
4. 사용자 최종 승인

---

## 자주 마주치는 상황

### "에이전트가 코드를 못 만져요"
- 원인 1: `planAccepted=false` (예상된 동작 — Plan Accept 를 안 했음)
- 원인 2: hook 가 차단 모드인데 main 브랜치 위에 있음
- 확인: `./scripts/harness/bin/sdd status`
- 해결: `sdd plan accept` 또는 `git checkout -b feature/...`

### "테스트는 통과했는데 commit 이 차단돼요"
- 원인: hook check-test-passed 가 lastTestPass 시각을 못 찾음
- 해결: `./scripts/harness/bin/sdd test passed` 호출 후 commit 재시도
- 또는: hook 를 일시 비활성 — `HARNESS_HOOK_MODE=off git commit ...`

### "Hook 메시지가 너무 시끄러워요 (warn 모드)"
- 원래 의도: 처음 1주는 warn (메시지만), 이후 block 으로 승격
- 영구 비활성: `export HARNESS_HOOK_MODE=off` (권장 안 함)
- block 모드로 전환: `export HARNESS_HOOK_MODE=block`

### "다른 슬래시 커맨드가 어디 있는지 모르겠어요"
- `.claude/commands/` 디렉토리 안의 `.md` 파일들
- 슬래시 입력 시 Claude Code 가 자동완성 제공

### "키트를 갱신하고 싶어요"
- `~/Project/ai/claude/update.sh ~/my-project`
- 사용자 산출물 (backlog, specs) 은 보존됨
- `.claude/settings.json` 은 jq 머지 (사용자 권한 보존, hooks 갱신)
- `CLAUDE.md` 의 HARNESS-KIT 블록만 갱신

---

## 다음 단계

- [REFERENCE.md](./REFERENCE.md) — 모든 명령/슬래시/hook 사전
- `agent/constitution.md` — 거버넌스 규약
- `agent/agent.md` — 에이전트 작업 절차
