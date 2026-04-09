# 하네스 엔지니어링 리뷰 (2026-04-09)

> 검토 대상: `agent/` 디렉토리 (`.agent/agent.md`, `.agent/constitution.md`, `.agent/kickoff.md`, `templates/*.md`)
> 사용자 질문
> 1. 지금 내가 하는 게 "하네스 엔지니어링"이 맞는가? 더 좋은 방법이 있는가?
> 2. 내가 준 파일들이 실제로 유용한가?
> 3. `gh` 부분은 환경에 안 맞으니 제거 → **완료** (이 문서 §4 참조)

---

## 1. "하네스(harness)"라는 용어가 맞는가

### 결론: **부분적으로 맞다. 하지만 더 정확한 이름이 따로 있다.**

| 용어 | 의미 | 본 케이스에 부합? |
|------|------|----------------|
| **Agent Harness** | 모델 주위를 감싸는 실행 환경 전체(툴 노출, 컨텍스트 관리, 루프, 안전 가드). Claude Code 자체가 하네스. | △ — 본 케이스는 하네스 위에 얹는 "행동 규약" 쪽에 가까움 |
| **Context / Prompt Engineering** | 모델에게 주는 컨텍스트를 의도적으로 설계 | ○ — `constitution.md`/`agent.md` 가 전형적 예 |
| **Spec-Driven Development (SDD)** | Spec → Plan → Task → 실행 → 회고를 강제하는 워크플로 | ◎ — 본 파일들이 명시적으로 SDD 를 표방함 |
| **Agent Operating Procedure (AOP)** | 에이전트가 따라야 할 절차 규약 | ◎ — 파일명도 그렇게 부르고 있음 |
| **Constitutional AI / Project Constitution** | 무조건 준수해야 할 상위 규칙 집합 | ◎ — `constitution.md` 가 정확히 이것 |

### 가장 정확한 이름
사용자가 만들고 있는 것은 **"Spec-Driven Development 워크플로 + Project Constitution + Template Enforcement"** 의 조합입니다. 업계에서는 보통:

- **Speckit / Spec-Kit 스타일** (GitHub Next 가 공개한 방법론과 유사)
- **Cursor Rules / Cline Rules / Claude Code Memory** 같은 *행동 규약 파일* 패턴
- **AgentOS / Agent Operating Procedures**

이런 이름으로 부릅니다. "하네스 엔지니어링"이라고 해도 통하지만, 더 정확히 말하면 **"에이전트 거버넌스(governance) 레이어를 설계하는 것"** 입니다.

### 하네스 vs 거버넌스 — 구분이 왜 중요한가
- **하네스(Harness)** = 모델이 *무엇을 할 수 있는지*(도구, 컨텍스트 윈도우, 루프). Claude Code, Cursor, Cline 자체.
- **거버넌스(Governance)** = 모델이 *무엇을 해야 하는지/하면 안 되는지*(절차, 산출물, 승인 게이트). 본 케이스의 `agent/` 가 이것.

→ 사용자가 만든 건 **거버넌스 레이어**이고, 이걸 *진짜로 강제*하려면 **하네스(Claude Code) 의 네이티브 기능을 활용**해야 한다는 게 핵심입니다. 아래 §3 에서 다룹니다.

---

## 2. 파일별 유용성 재평가

### 한눈에 보기

| 파일 | 유용성 | 평가 요지 |
|------|:---:|----------|
| `.agent/constitution.md` | ⭐⭐⭐⭐⭐ | 매우 유용. 표준 거버넌스 레이어. 단, **현재 위치로는 모델이 자동으로 안 읽음** |
| `.agent/agent.md` | ⭐⭐⭐⭐ | 유용하나 `constitution.md` 와 일부 중복. 합쳐도 됨 |
| `.agent/kickoff.md` | ⭐⭐⭐ | 좋은 아이디어이나 슬래시 커맨드(`/kickoff`)로 만드는 게 정답 |
| `templates/spec.md` | ⭐⭐⭐⭐ | 골격 좋음. 한국어 헤더 + Mermaid 표준 |
| `templates/plan.md` | ⭐⭐⭐⭐ | "User Review Required" 섹션이 특히 좋음 |
| `templates/task.md` | ⭐⭐⭐ | TDD 체크리스트 패턴 좋음. **단, 본 프로젝트는 NestJS 인데 템플릿이 Python(`uv run pytest`) 이었음 → 이 문서의 §4에서 수정** |
| `templates/walkthrough.md` | ⭐⭐⭐⭐ | "Evidence Log" 개념이 강력. PR 리뷰어/미래의 자신에게 가장 큰 가치 |
| `templates/pr_description.md` | ⭐⭐⭐ | 구조 좋음. `gh` 의존 제거 후엔 일반 PR 본문으로 활용 가능 |
| `agent.zip`, `templates.zip` | ⭐ | **삭제 권장.** 동일 내용의 zip 사본 — 버전 충돌 원인 |
| `.DS_Store` | 0 | `.gitignore` 추가 |

### 핵심 강점
1. **"승인 없이는 코드 안 친다(Premature Execution = CRITICAL VIOLATION)"** — 가장 가치 있는 규칙. 에이전트가 먼저 달려나가는 사고를 막는 정공법.
2. **One Task = One Commit** — Git 히스토리가 곧 의도의 기록이 됨.
3. **Walkthrough(증거 로그)** — 단순 PR 설명서가 아니라 *어떻게 검증했는지* 를 남기는 문화. 회귀 추적에 강력.
4. **Korean Language Lock** — 사용자 본인이 빠르게 검토할 수 있는 언어로 산출물을 강제.
5. **Spec 033 Benchmark 언급** — "최소 품질의 기준점" 을 두는 것은 매우 좋은 패턴. 다만 본 프로젝트에는 Spec 033 이 없으므로 *본 프로젝트만의 기준점*을 다시 정해야 함.

### 핵심 약점
1. **Python 프로젝트 잔재**
   - `task.md` 에 `uv run pytest`, `app/path/to/file.py` 등이 박혀 있었음 (현재는 NestJS 용으로 수정 완료).
   - `agent.md` §6.4 의 "Python Static Analysis Tools (ruff)" 도 마찬가지로 NestJS 용으로 교체 (`tsc --noEmit`, `npm run lint`).
2. **`gh` 의존** — 현재 환경(Bitbucket 추정)과 불일치. 제거 완료.
3. **`docs/templates/` 와 `agent/templates/` 경로 혼동**
   - `agent.md` §4.1 은 "`docs/protocols/templates/` 를 읽으라" 고 했지만 실제 파일은 `agent/templates/` 에 있음. 경로 불일치 → 에이전트가 못 찾음.
   - 한 곳으로 통일 필요.
4. **Claude Code 가 자동으로 못 읽는 위치**
   - `.agent/` 디렉토리는 Claude Code 의 표준 로딩 경로(`CLAUDE.md`, `.claude/commands/`, `.claude/agents/`, `.claude/settings.json`)가 아님.
   - 즉, 에이전트 매 세션마다 사용자가 *직접* "`.agent/agent.md` 읽어줘" 하지 않으면 무시됨.
5. **강제(enforcement) 메커니즘 부재**
   - "MUST", "CRITICAL VIOLATION" 이라고 적혀 있지만 *위반 시 자동으로 막아주는* 장치가 없음. 모델이 까먹으면 끝.
6. **과대 적용 위험**
   - "20개 테스트 케이스 minimum", "Spec 033 benchmark" 등은 LangGraph 프롬프트 엔지니어링 프로젝트에서 가져온 흔적. NestJS API 프로젝트에는 과중함. **본 프로젝트 톤에 맞게 다이어트 필요**.

---

## 3. 더 좋은 방법 — Claude Code 네이티브로 옮기기

지금 구조는 "어느 에이전트 도구에서나 통하는 일반형" 이라 휴대성은 좋지만, **Claude Code 안에서는 절반밖에 효력이 없습니다.** Claude Code 가 자동으로 읽어주는 자리로 옮기면 같은 내용으로 훨씬 강력해집니다.

### 네이티브 매핑표

| 현재 파일 | Claude Code 네이티브 위치 | 효과 |
|----------|------------------------|------|
| `agent/.agent/constitution.md` | `CLAUDE.md` 본문 또는 `@agent/.agent/constitution.md` import | **매 세션 자동 로딩** |
| `agent/.agent/agent.md` | `CLAUDE.md` 본문에 흡수 또는 `.claude/agents/sdd-architect.md` (서브에이전트) | 자동 로딩 + 위임 가능 |
| `agent/.agent/kickoff.md` | `.claude/commands/kickoff.md` | `/kickoff` 슬래시 커맨드로 호출 |
| `agent/templates/*.md` | 그대로 두되 `CLAUDE.md` 에서 경로 명시 | 에이전트가 정확히 어디서 읽는지 알게 됨 |
| (없음) | `.claude/settings.json` `hooks` | **PreToolUse/PostToolUse/Stop hook 으로 진짜 강제** |

### 강제(Enforcement)를 진짜로 거는 방법 — Hook

지금은 "main 브랜치에 직접 커밋하면 안 된다"가 *문서상의 약속*입니다. Hook 을 쓰면 *물리적으로* 막을 수 있습니다.

```jsonc
// .claude/settings.json (개념 예시)
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if git branch --show-current | grep -qx main; then echo \"❌ main 브랜치 직접 작업 금지 (constitution §9.1)\" >&2; exit 2; fi'"
          }
        ]
      }
    ]
  }
}
```
- exit 2 면 도구 호출이 차단되고 stderr 가 모델에게 전달되어 에이전트가 자기 행동을 교정합니다.
- 같은 패턴으로 "Plan Accept 전에 코드 편집 금지", "테스트 안 돌리고 commit 금지" 도 자동화 가능합니다.

### 슬래시 커맨드로 옮기기

```markdown
<!-- .claude/commands/kickoff.md -->
---
description: SDD 세션 시작 — constitution 로드 후 컨텍스트 점검
---

다음 순서로 진행:
1. @agent/.agent/constitution.md @agent/.agent/agent.md 를 읽고 규약을 인지
2. `git branch --show-current` 와 `git log -1 --oneline` 로 현재 상태 확인
3. `specs/` 디렉토리를 훑어 진행 중 Spec 파악
4. 사용자에게 "어떤 컨텍스트를 이어갈까요?" 로 단 하나의 질문만 하기
```
이렇게 두면 사용자가 `/kickoff` 한 줄로 항상 같은 부트스트랩이 실행됩니다.

### 서브에이전트로 분리

`.claude/agents/sdd-planner.md` 같은 식으로 **계획 전용 서브에이전트**를 두면, 메인 컨텍스트를 어지럽히지 않고 spec/plan 을 만들고 산출물만 돌려받을 수 있습니다. "코드는 못 쓰는 모드" 의 원래 의도를 도구 권한 수준에서도 강제할 수 있습니다.

---

## 4. 적용 완료한 변경사항 (`gh` 제거 + NestJS 화)

이번 세션에서 실제로 수정한 내용:

### `agent/.agent/agent.md`
- §6.3 **Tooling Enforcement** → **Commit & Branch Enforcement** 로 개명
  - `gh pr create`, `gh` 관련 문구 전부 제거
  - "PR 생성은 사용자가 hosted git UI 에서 수행" 명시
- §6.4 Tool Resolution
  - Priority 2: `uv run ruff` → **`npx tsc --noEmit` + `npm run lint`**
  - Priority 3: `sd` (Python 텍스트 편집기) 제거, `ast-grep`/`rg`/`fd` 만 유지
- §2 Bootstrap: "Open PRs" → "Pushed Branches"

### `agent/.agent/constitution.md`
- §9 제목 **Git & GitHub Law** → **Git Law**
- §9.2 **GitHub CLI Protocol** → **Commit Protocol** (gh 강제 조항 삭제, "PR 생성은 사용자 책임" 명시)

### `agent/templates/task.md`
- Task 1 의 TDD 예시
  - `tests/unit/test_xxx.py` → `src/modules/xxx/xxx.service.spec.ts`
  - `app/path/to/file.py` → `src/modules/xxx/xxx.service.ts`
  - `uv run pytest ...` → `npm test -- xxx.service`
- Task N (마지막)
  - "PR Creation & Archiving" → **"Archiving & Hand-off"**
  - `uv run ruff check` → `npm run lint`
  - `uv run pytest` → `npm test`
  - `gh pr create ...` 라인 삭제 → `git push -u origin feature/...` + 사용자에게 알림

### 미수정 (사용자 결정 필요)
- `templates/pr_description.md` — 본문 구조는 hosted git UI 에 그대로 붙여넣기 가능하므로 유지. 다만 `🤖 Generated with Claude Code` 푸터/이모지 톤은 본 프로젝트 컨벤션과 맞춰 다듬을 수 있음.
- `agent.zip`, `templates.zip` — 사본 파일. 삭제 권장하나 사용자 확인 필요.

---

## 5. 권장 로드맵

### Phase 1 — 즉시 (오늘)
1. **`gh` 제거** ✅ (완료)
2. **경로 일관화**: `agent.md` §4.1 의 `docs/protocols/templates/` 표현을 `agent/templates/` 로 통일
3. **`CLAUDE.md` 에 거버넌스 import 한 줄 추가**
   ```markdown
   ## 에이전트 운영 규약
   - @agent/.agent/constitution.md
   - @agent/.agent/agent.md
   ```
   → 매 세션 자동 로딩됨. 현재 가장 큰 문제(자동으로 안 읽힘) 즉시 해결.
4. `agent.zip`/`templates.zip`/`.DS_Store` 정리

### Phase 2 — 단기 (이번 주)
5. **`/kickoff` 슬래시 커맨드** 만들기 → `.claude/commands/kickoff.md`
6. **간단한 hook 1개**: main 브랜치 보호 (위 §3 예시)
7. **Spec 033 benchmark 대체**: 본 프로젝트만의 "기준점 Spec" 1개 작성 (예: 이번에 작성한 Code Review 문서들이 그 역할을 할 수 있음)
8. `specs/`, `backlog/` 디렉토리 골격 생성

### Phase 3 — 중기 (이번 스프린트)
9. **`.claude/agents/sdd-planner.md`** — 계획 전용 서브에이전트
10. **PreToolUse hook 추가**:
    - Plan Accept 플래그(예: `.claude/state/plan-accepted`) 가 없으면 Edit/Write 차단
    - 테스트 미실행 시 git commit 차단 (`PostToolUse`)
11. **템플릿 다이어트**: Spec/Plan 템플릿에서 본 프로젝트 규모에 안 맞는 섹션(예: "20 test cases minimum" 같은 LLM 프로젝트용 항목) 삭제

### Phase 4 — 장기
12. 실제 운영하면서 위반 빈도 측정 → 어떤 hook 이 자주 발동되는지 보고 규약 자체를 다듬기
13. `walkthrough.md` 들을 모아 *프로젝트 결정 로그(decision log)* 로 활용

---

## 6. 핵심 답변 요약 (TL;DR)

1. **"하네스 엔지니어링" 이란 표현은 절반만 맞습니다.** 정확히는 **"Spec-Driven Development 거버넌스 레이어"** 를 만들고 있는 것이고, 이걸 진짜로 강제하려면 Claude Code 의 **하네스 네이티브 기능(CLAUDE.md, `.claude/commands/`, `.claude/agents/`, `.claude/settings.json` hooks)** 을 활용해야 합니다.

2. **파일들은 매우 유용합니다.** 특히 `constitution.md` 의 "Premature Execution = Critical Violation" 과 `walkthrough.md` 의 "Evidence Log" 개념은 그대로 가져갈 가치가 있습니다. 다만:
   - 이전 Python 프로젝트(LangGraph 추정)에서 가져온 잔재가 일부 있어 NestJS 용으로 손봐야 했고
   - `.agent/` 위치에 두면 Claude Code 가 자동으로 안 읽으므로 `CLAUDE.md` 에 import 하거나 `.claude/` 로 옮겨야 합니다.

3. **`gh` 제거는 완료했습니다.** `agent.md`, `constitution.md`, `templates/task.md` 세 파일에서 GitHub CLI 의존을 모두 걷어내고, "PR 생성은 사용자가 hosted git UI 에서 직접" 으로 책임을 분리했습니다.

4. **다음에 할 가장 가치 있는 한 수**: `CLAUDE.md` 에 다음 두 줄만 추가하세요.
   ```markdown
   ## 에이전트 운영 규약
   - @agent/.agent/constitution.md
   - @agent/.agent/agent.md
   ```
   이 한 번의 변경으로 지금까지 만든 모든 규약이 *매 세션 자동으로* 적용됩니다.

---

*작성일: 2026-04-09 · 작성자: Claude Code Review (harness/governance 편)*
