---
kind: synthesis
sources:
  - sources/hooks/
  - sources/claude-fragments/settings.json.fragment
  - sources/hooks/_lib.sh
  - archive/specs/spec-02-03-enforce-to-suggest/walkthrough.md
  - archive/specs/spec-x-hook-bypass-fix/walkthrough.md
  - archive/specs/spec-x-hook-allow-ff-when-no-spec/walkthrough.md
  - archive/specs/spec-x-check-secrets-dual-mode/walkthrough.md
  - archive/specs/spec-24-01-auto-mode-base/walkthrough.md
  - archive/specs/spec-24-02-auto-scope-commit/walkthrough.md
  - archive/specs/spec-24-03-stop-rules/walkthrough.md
  - archive/specs/spec-25-01-askquestion-redirect-hook/walkthrough.md
  - archive/specs/spec-25-04-stop-rule-layering/walkthrough.md
  - docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md
  - CHANGELOG.md
linked:
  - "[[wiki/direction]]"
  - "[[ADR-009]]"
updated: 2026-10-22
---

# 컴포넌트 — hooks (안전 가드)

> **시범 페이지 (3층 구조 중 "구현" 층).** 구조: 현재 설계 → 변경 이력 → 반복·미결 → 기술 부채.
> §현재 설계의 표는 `sources/hooks/*.sh` 와 `settings.json.fragment` 에서 확인한 사실이다(2026-10-22). 코드가 바뀌면 이 표가 먼저 낡는다 → 의미 lint 의 대상.

## 책임

에이전트가 규약(main 직접 작업 금지, Plan Accept 전 편집 금지, 테스트 없는 커밋 금지, 시크릿·비가역 행동 차단 등)을 어길 때 *문서가 아니라 코드로* 막거나 알린다. 막는 층은 둘이다: Claude Code 의 `PreToolUse`/`Stop`/`SessionStart` 이벤트, 그리고 git `pre-commit`.

## 현재 설계

### 강제 수준 (기본 모드)

모드: `block`(exit 2, 차단) / `warn`(stderr 경고, 통과) / `off`. 전환은 `HARNESS_HOOK_MODE_<NAME>` 환경변수, 글로벌 `HARNESS_HOOK_MODE` (`_lib.sh` `hook_resolve_mode`).

| hook | 걸리는 곳 | 기본 | 비고 |
|---|---|---|---|
| check-branch | PreToolUse Bash | **block** | main 에서 commit/push 차단 |
| check-secrets | PreToolUse Bash + git pre-commit | **block** | staged 추가 라인(`+`)만 검사. 듀얼 모드는 `HARNESS_GIT_HOOK_MODE=1` 명시 신호 |
| check-askquestion-auto | PreToolUse AskUserQuestion | **block** | auto 모드에서만 발동 |
| check-irreversible | PreToolUse Bash | **auto=block / attended=warn** | 모드 불명이면 block(fail-safe). 환경변수 이름은 `STOP_RULES` |
| check-plan-accept | PreToolUse Edit·Write | warn | turbo·auto 는 통과. 허용 경로는 `_plan_accept_paths.sh` 공유 |
| check-scope | PreToolUse Edit·Write + git pre-commit | warn | edit 모드는 turbo/auto 통과, commit 모드는 모드 무관 경고 |
| check-test-passed | PreToolUse Bash | warn | 최근 테스트 PASS 기록 없으면 commit 알림 |
| check-commit-msg / check-diff-size / check-task-checkbox | PreToolUse Bash | warn | 형식·크기·체크박스 |
| check-test-trust | git pre-commit | 경고만 | 모드 무관. 구현 변경에 테스트 동반했나/단언 있나 휴리스틱 |
| check-staged-lint | git pre-commit | warn | |
| pre-commit.sh | git pre-commit | **block (자체 로직)** | 활성 spec 이 있고 Plan Accept 전이면 whitelist 외 staged 파일 차단 |
| post-commit-verify | Stop | turbo 한정 | 테스트 실패 시 `git revert HEAD` |
| notify-on-input-wait | Notification·Stop | 알림 | 차단 없음 |
| check-kit-version | SessionStart | 알림 | 24h 캐시, 실패는 silent |

`permissions.deny` 가 별도 1층: `sudo`, `rm -rf /`·`~`, `git push --force`, `git clean -f`, `curl … | bash` 등 *never-justify* 명령을 settings 에서 직접 막는다. hook(`check-irreversible`)은 `reset --hard`·`rebase --onto` 같은 *맥락 의존* 명령을 맡는 2층 모델(spec-25-04).

### 강제 수준 분류 (2026-10-22 처분)

기본 모드가 왜 그 값인지의 분류. "승격 후보"는 *지금 승격하지 않는다* — 조건이 충족되면 별도 결정.

| 분류 | hook | 근거 |
|---|---|---|
| 차단 (block) | check-branch, check-secrets, check-askquestion-auto(auto), check-irreversible(auto) | 결정론적이거나 fail-safe 방향이 명확 |
| 다른 층이 차단 | check-plan-accept | edit 시점은 warn 이지만 git `pre-commit.sh` 가 Plan Accept 전 production staged 를 차단 |
| 의도적 warn — 휴리스틱 | check-scope, check-diff-size, check-test-trust | 정확한 판정 불가(Proposed Changes 파싱, 500줄 임계, 정적 프록시). 오탐 비용 > 차단 이득 |
| 의도적 warn — 구조적 | check-test-passed | 시각 기록(30분 창)만 보며 "이 변경이 테스트됐다"를 보장하지 못함. 헌법 TDD 의 red 커밋(실패 테스트 추가)과 충돌. docs/chore/style 은 면제 |
| 의도적 warn — 환경 의존 | check-staged-lint | linter 가용성에 의존(shellcheck 미설치 등) |
| 승격 후보 (조건부) | check-commit-msg | 결정론적이고 오탐 미관측(heredoc 포함 확인). 단 `grep` 이 줄 단위라 *어느 줄이든* 형식에 맞으면 통과 — **첫 줄만 검사하도록 엄격화한 뒤** 승격 검토 |
| 승격 후보 (조건부) | check-task-checkbox | 결정론적. push 대상·task.md 부재 케이스 범위 검증 후 |

### 설계 규칙

- **단계론**: 휴리스틱은 warn 으로 시작해 운영 후 승격. 결정론적·fail-safe 는 즉시 차단 가능, 모드별 fail-safe 방향이 다르면 모드 차등(CLAUDE.md #5, 0.20.0 정제).
- **좁게 감지**: 오탐 비용 > 차단 이득이면 narrow. 경계(`--force-with-lease`, `reset --soft` 등 제외)는 `tests/test-stop-rules.sh` 가 고정(W1-a/b/c: `git -C … reset --hard`, `rebase -i`, `rm -rf ./dir` 는 *의도적 미감지*).
- **함수 공유**: 한 hook 이 두 경로(Claude 이벤트 / git hook)에 걸리면 판정 함수를 공유(check-secrets, check-scope 선례).
- **모든 게이트는 모드를 일관 인식**: turbo/auto 가 한 게이트만 우회하고 다른 게이트는 막는 불일치를 금지(spec-24-01).

## 변경 이력

| 시점 | 변화 | 이유/출처 |
|---|---|---|
| 2026-04 (0.3.0) | hook 모드 분리(warn/block/off), per-hook 변수. check-branch 기본 block, plan-accept·test-passed 는 warn "명시적 선언" | main 보호는 안전 관련이라 항상 block. 환경변수 하나를 공유해 개별 제어가 안 됐음 — spec-02-03 |
| 2026-04 (0.4.0) | PreToolUse 훅 5개 추가 | |
| 2026-05-09 (0.7.0) | git `pre-commit` 에 Plan Accept 안전망 | Edit/Write 훅이 Bash 경유 편집으로 우회됨. *Bash 명령 파싱(패턴이 너무 많아 유지 불가)* 대신 *커밋 시점 git hook* 으로 막기로 결정. 같은 spec 에서 `Write(~/**)` deny 가 오히려 Bash 우회를 유도하는 아이러니도 발견 — spec-x-hook-bypass-fix |
| 2026-05-10 (0.8.0) | 활성 spec 이 없으면 hook 통과 | FF 작업이 hook 에 막혀 `--no-verify` 를 쓰게 됨 → constitution 과 모순. pre-commit 과 check-plan-accept 의 정책이 따로 구현돼 어긋난 사례 — spec-x-hook-allow-ff-when-no-spec |
| 2026-05-23 (0.13.5) | check-secrets 듀얼 모드 | cmd 빈 값 추론이 아닌 명시 env 신호로 모드 감지; BSD grep 옵션 오인식 수정 — spec-x-check-secrets-dual-mode |
| 2026-06-13 (0.17.0) | turbo 용 post-commit-verify | Plan Accept 없이 자유 편집하되 사후 검증+자동 revert |
| 2026-06-19~21 (phase-24) | auto 모드: 모드를 모든 게이트에서 인식, scope commit-mode(blast-radius 가드), 정지규칙 ②③ (check-irreversible, hard-stop) | turbo 에서 Edit 은 통과·pre-commit 은 차단하던 불일치 발견·수정 — spec-24-01/02/03 |
| 2026-06-22 (0.20.0, phase-25) | check-askquestion-auto (block), 비가역 2층 모델·모드 차등, test-trust | **전제 번복**: "AskUserQuestion 은 hook 으로 못 막는다"(24-04)를 공식문서+라이브 spike 로 반증 — spec-25-01. **방침 번복**: "warn 1주 후 block 승격" → "모드 차등(auto=block, attended=warn)" — spec-25-04 후속 |
| 2026-07-05 (0.21.0) | 모드 불명 시 block(fail-safe) 통일, 우회 변형 경계를 테스트로 고정 | phase-26 W1/W2 |

## 반복·미결

1. **게이트 간 정책 불일치가 반복됐다 (3회).** 0.8.0(pre-commit vs Edit 훅), spec-24-01(turbo: Edit 통과·pre-commit 차단), spec-24-02(edit vs commit 모드의 scope). 대응은 *함수 공유*와 *모드 일관 인식*. 남아 있던 Plan Accept 이중 구현(`pre-commit.sh` whitelist vs `check-plan-accept.sh` 안전 경로)은 **처분 (phase-30, 2026-10-22): 코드 수정** — `_plan_accept_paths.sh` 의 `hk_plan_accept_safe_path` 한 곳으로 통합하고 `tests/test-plan-accept-parity.sh` 가 두 게이트 판정 일치와 단일 출처를 고정한다. **상태: 해소.**
2. **우회 경로가 계속 발견된다.** Bash 경유 편집(0.7.0), MCP/Serena 편집(24-02 → 커밋 시점 scope 가드), refspec `+` force push(0.20.0), `git -C` 변형(의도적 미감지로 고정). 대응 철학은 *좁게 감지 + 경계를 테스트로 고정*이므로 우회가 앞으로도 나오는 것은 설계상 예견됨. **상태: 수용(의도적).**
3. **"경고로 시작해 승격"이 대부분 이행되지 않았다.** CLAUDE.md #5 는 휴리스틱 hook 을 1주 운영 후 차단으로 승격한다고 하나, 현재 기본 `block` 은 check-branch·check-secrets·askquestion(auto)·irreversible(auto) 뿐이고 나머지는 도입(2026-04~05) 후에도 warn. 승격 *결정/기록*을 찾지 못했다(승격이 언급된 곳은 신규 hook 인 24~25 계열과, "차단 승격 없음"을 명시한 spec-x-harness-footguns 뿐). **처분 (phase-30, 2026-10-22): 문서화.** 각 hook 이 왜 warn 인지를 위 §강제 수준 분류에 기록했다. 일괄 승격은 하지 않는다. 승격 후보는 check-commit-msg(엄격화 선행)·check-task-checkbox 두 개뿐.
4. **README 주장과 기본값이 어긋났다.** README 는 hook 이 "테스트 미실행 커밋을 물리적으로 차단"한다고 썼으나 `check-test-passed` 는 기본 warn. **처분 (phase-30, 2026-10-22): 문서 수정.** block 으로 올리지 않는다 — TDD red 커밋과 구조적으로 충돌하고 시각 기록만으로는 보장이 안 된다. README 문구를 "차단(main·시크릿·Plan Accept 우회) / 경고(휴리스틱)" 로 정정했다.
5. **`warn→block` 방침 번복의 영향 범위.** "승격" 대신 "모드 차등"을 택한 결정(spec-25-04 후속)이 attended 모드 hook 들에는 적용되지 않았다 — attended 에서 irreversible 은 계속 warn. 이 결정이 위 3번의 미승격을 *정당화*하는지는 기록돼 있지 않다.

## 기술 부채

- ~~`sdd hooks` 가 4개만 표시~~ → **해소 (phase-30)**: hook 파일의 `hook_resolve_mode` 선언에서 전체 11개를 읽는다(`tests/test-sdd-hooks-all.sh`). 모드별 차등 hook 은 "모드별" 로 표시.
- ~~Plan Accept 판정 이중 구현~~ → **해소 (phase-30)**: 위 반복·미결 1번.
- hook 은 에이전트의 의도를 읽지 못한다 — askquestion 에서 routine 과 정지규칙 ① 을 구분하려고 stderr 지침으로 우회(spec-25-01). 구조적 한계로 수용.
- 설치 경로 3중: `sources/hooks/` → `.harness-kit/hooks/` → `settings.json` 참조. 사본 불일치는 phase-28 의 drift 검사가 감시하나, `settings.json` 머지 결과는 검사 대상이 아니다.
- shellcheck 미설치로 hook 스크립트 lint 가 건너뛰어진다.
- lefthook 네이티브 통합 미착수(Icebox): install 이 `.git/hooks/pre-commit` 에 append 하는 방식은 lefthook 이 디스패처를 재생성하면 덮인다.

## 관련 결정

- [[ADR-009]] — 거버넌스를 신뢰도·blast-radius 로 재배분, auto 모드, Addendum(AskUserQuestion 백스톱)
- spec-25-04 — 비가역 2층 모델 (분류표는 `check-irreversible.sh` 헤더에 있음)
- [[wiki/direction]] 원칙 5 (Hook 단계론)
