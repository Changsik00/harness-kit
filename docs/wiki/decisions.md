---
kind: synthesis
sources:
  - docs/decisions/ADR-001-knowledge-types.md
  - docs/decisions/ADR-002-planning-economy.md
  - docs/decisions/ADR-003-wiki-frontmatter-schema.md
  - docs/rca/RCA-001-sdd-ship-spec-add-missing.md
  - specs/spec-19-01-wiki-layer-bootstrap/walkthrough.md
  - archive/specs/spec-08-02-phase-base-branch/walkthrough.md
  - archive/specs/spec-13-02-pr-merge-detect/walkthrough.md
  - archive/specs/spec-15-05-dedupe-hardcoded-lists/walkthrough.md
  - archive/specs/spec-x-sdd-version-source-fix/walkthrough.md
  - archive/specs/spec-x-update-preserve-state/walkthrough.md
  - archive/specs/spec-x-check-secrets-dual-mode/walkthrough.md
  - archive/specs/spec-x-kit-update-notify/walkthrough.md
  - archive/specs/spec-x-doctor-hookspath-lefthook/walkthrough.md
  - archive/specs/spec-x-harness-footguns/walkthrough.md
  - docs/decisions/ADR-004-phase-ff-first-class.md
  - docs/decisions/ADR-005-context-orchestration.md
  - docs/decisions/ADR-006-director-mode.md
  - docs/decisions/ADR-007-extend-opt-in.md
  - docs/decisions/ADR-008-extension-preferential-use.md
  - docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md
  - archive/specs/spec-20-04-model-config-and-review/walkthrough.md
  - archive/specs/spec-22-01-extend-serena/walkthrough.md
  - archive/specs/spec-24-03-stop-rules/walkthrough.md
  - archive/specs/spec-25-01-askquestion-redirect-hook/walkthrough.md
  - archive/specs/spec-25-02-test-trust/walkthrough.md
  - archive/specs/spec-26-01-settings-push-ssot/walkthrough.md
  - archive/specs/spec-27-01-adr-index-gen/walkthrough.md
  - archive/specs/spec-27-02-docs-integrity-check/walkthrough.md
linked:
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
  - "[[ADR-002]]"
  - "[[ADR-003]]"
  - "[[ADR-004]]"
  - "[[RCA-001]]"
updated: 2026-10-20
---

# 핵심 결정 증류

> **출처별 로그 (격하).** 이 페이지는 결정을 출처 단위로 쌓은 기록이다. 삭제하지 않지만 *현재 입장*은 여기가 아니라 `direction.md`·`components/<name>.md` 에서 읽는다 (규약 → [[wiki/schema]]).

> raw ADR/RCA에서 추출한 의사결정 요약. 세부 근거는 원본 참조.

---

## [[ADR-001]] — Knowledge Type Vocabulary (2026-05-16)

**결정**: ADR/RCA frontmatter의 `type:` 슬롯에 5어휘 closure 도입.

| type | 의미 |
|---|---|
| `decision` | 비자명한 설계 선택 |
| `invariant` | 시스템이 보존해야 할 속성 |
| `failure-pattern` | 재발하는 실패 (재현+예방) |
| `convention` | 일관성을 위한 명명/구조 규칙 |
| `tradeoff` | 기각된 안에 명시적 비용이 있는 선택 |

**왜**: 결정과 실패가 grep 가능한 자산으로 누적되지 않던 문제. `grep -rh "^type:" docs/rca docs/decisions`로 type별 추출 가능.

**주의**: closure 변경 자체가 ADR 대상. vocabulary 밖 값은 거버넌스 위반.

---

## [[ADR-002]] — Planning Economy & Inter-Spec Re-Validation (2026-05-17)

**결정**: SDD ceremony 비용을 인식하고 3개 invariant 박음.

**Invariant 1 — ceremony 비용 의식**:
- 1-2 task + 단일 파일 + 가역적 → **FF** (사용자 명시 승인 필요)
- 3-5 task + 단일 영역 → **spec-x** 또는 **bundle/phase FF**
- 6+ task / cross-file / 통합 테스트 → **spec**

**Invariant 2 — phase plan은 draft, 매 spec 시작 시 재검증**:
직전 merged spec의 walkthrough(이월/발견) + `git diff --stat` 점검 후 잔여 spec 재평가.

**Invariant 3 — phase 내에서는 bundle/phase FF 우선 (spec-x demote 보다)**:
spec-x demote는 phase가 끝난 후 잔재일 때만.

**왜**: phase-17에서 spec-17-03이 install.sh 누수를 미발견 → spec-17-05 sweep으로 뒤늦게 처리. pre-spec 재검증으로 사전 차단 가능했음.

---

## [[RCA-001]] — sdd ship이 spec/plan/task를 git add 안 함 (2026-05-15)

**증상**: `sdd ship` 후 spec.md/plan.md/task.md가 untracked으로 남아 수동 add 필요. 2회 연속 발생.

**근인**: sdd ship의 git add 매트릭스가 walkthrough/pr_description만 포함. spec-x 운영에서 pre-flight commit이 없는 것이 일반적이라는 전제 누락.

**교훈**: "암묵적 전제"가 가장 위험한 버그 경로. sdd ship의 add 매트릭스는 spec 디렉토리 전체를 포함해야 함.

**Invariant**: `sdd ship` 후 해당 spec 디렉토리 내 신규 산출물 untracked이 남으면 안 됨.

---

## [[ADR-003]] — Wiki Frontmatter `kind:` vs ADR `type:` 네임스페이스 분리 (2026-05-27)

**결정**: wiki 페이지는 `kind:` 슬롯, ADR/RCA는 `type:` 슬롯을 사용한다. 두 네임스페이스는 공존하되 겹치지 않는다.

| 슬롯 | 사용 파일 | 허용 값 |
|---|---|---|
| `type:` | ADR/RCA (`docs/decisions/`, `docs/rca/`) | 5어휘 closure (ADR-001) |
| `kind:` | wiki 페이지 (`docs/wiki/`) | `catalog`, `synthesis`, `reference` |

**왜**: ADR-001의 `type:` 5어휘 closure는 ADR/RCA 전용. wiki 페이지에 `type: decision`을 붙이면 `grep -rh "^type:"` 쿼리가 오염되어 wiki 파일이 ADR/RCA로 오인됨.

**주의**: `type:`과 `kind:` 값 모두 closure 밖 값은 거버넌스 위반. vocabulary 변경은 ADR 대상.

출처: spec-19-01 walkthrough §결정 기록, [[ADR-003-wiki-frontmatter-schema]]

---

## [[spec-15-05]] — state.json 보존은 exclusion(blacklist), inclusion 아님 (2026)

**결정**: `update.sh` 가 install 후 state.json 을 복원할 때, 보존할 키를 whitelist(inclusion) 하지 않고 install-managed 키(`kitVersion`, `installedAt`)만 `del` 로 제외(exclusion)한다.

**왜**: inclusion 은 새 state 필드가 생길 때마다 update.sh 동기화를 강제 — 실제로 누락이 발생했었음(#82). exclusion 은 install template 이 바뀔 때만 영향받고, 사용자가 직접 추가한 필드까지 자동 보존된다.

**Trade-off**: 사용자가 stale 키를 남길 위험은 있으나, 본 프로젝트 컨벤션상 사용자가 state.json 을 직접 편집하지 않으므로 수용. install 자산은 항상 OVERWRITE → state 만 사후 복원하는 모델의 부담을 줄이는 방향.

출처: spec-15-05 walkthrough §결정 기록, spec-x-update-preserve-state walkthrough §발견 사항

---

## [[spec-x-sdd-version-source-fix]] — kitVersion SSOT 는 installed.json(git-tracked) (2026)

**결정**: `sdd version` / `sdd status` 가 읽는 kitVersion 소스를 gitignored `current.json` 에서 git-tracked `installed.json` 으로 변경한다.

**왜**: `current.json` 은 gitignore 대상이라 `update.sh` 를 우회하거나 멀티 디바이스 환경에서 쉽게 stale 해진다. `installed.json` 이 install 이 항상 새로 쓰는 SSOT. 실제로 본 저장소에서 `installed.json`=0.6.0 인데 `current.json.kitVersion`=0.5.0 으로 어긋난 사례가 발생.

**교훈**: 버전/메타 같은 install-managed 값의 SSOT 는 *git-tracked + install 이 항상 갱신하는* 파일이어야 한다. gitignored 파일을 SSOT 로 두면 "사용자가 update 를 안 돌린" 운영 누락이 곧 데이터 불일치로 드러난다.

출처: spec-x-sdd-version-source-fix walkthrough §결정 기록, spec-x-update-preserve-state walkthrough §발견 사항 1

---

## [[spec-13-02]] — 선택 도구 미설치는 차단(exit 1) 아닌 graceful degradation(exit 0 + 안내) (2026)

**결정**: `gh` 같은 선택 도구가 없을 때 워크플로 전체를 차단(exit 1)하지 않고 exit 0 + 안내를 출력한다. doctor 의 `gh` 체크도 FAIL 이 아닌 WARN. PR merge 감지는 자동 ship 이 아닌 안내만.

**왜**: 차단은 온보딩 마찰을 키우고, 부작용(자동 실행)은 사용자 확인 없는 위험을 만든다. 필수가 아닌 도구는 *없어도 핵심 경로가 살아있게* 하는 것이 reliability layer 의 일관 원칙.

**적용 범위**: 폴링은 데몬이 아닌 포그라운드 루프(종료 보장), merge 후 동작은 안내만, bash 절대경로 사용 + 필수 도구 PATH 유지.

출처: spec-13-02 walkthrough §결정 기록

---

## [[spec-08-02]] — 테스트 fixture 의 lib 심링크는 `bin/lib/` 에 (2026)

**결정**: `sdd` fixture 테스트 시 lib 심링크를 `scripts/harness/lib/` 가 아닌 `scripts/harness/bin/lib/` 에 만들고, 이를 `make_fixture()` 헬퍼로 표준화한다.

**왜**: `sdd` 는 `${BASH_SOURCE[0]}` 기준으로 `lib/` 을 탐색하므로 바이너리 *옆* 의 lib 만 인식한다. fixture 가 "사용 중인 사용자" 를 모사하려면 install 산출물(state.json 은 install 생성, queue.md 는 sdd 첫 호출 시 생성)을 그대로 갖춰야 한다.

**교훈**: fixture 는 "install 직후 빈 상태" 가 아니라 "sdd 를 한 번 쓴 흔적까지 포함한 상태" 가 자연스럽다. `.harness-kit/installed.json` + `.claude/state/current.json` 두 파일이 모든 sdd 스모크 테스트의 최소 셋업.

출처: spec-08-02 / spec-14-01 / spec-15-02 walkthrough §발견 사항

---

## [[spec-x-check-secrets-dual-mode]] — git hook 모드 감지는 cmd=empty 추론이 아닌 명시 env var (2026)

**결정**: check-secrets.sh 의 git-hook 모드 감지는 `cmd=empty` 추론 대신 `HARNESS_GIT_HOOK_MODE=1` 명시 신호를 사용한다.

**왜**: Claude Code PreToolUse hook 도 일부 상황에서 command env var 를 미제공해 `cmd=empty` 가 된다. 따라서 cmd=empty 를 "git hook 호출"로 추론하면 false positive 가 생긴다. 명시적 신호만이 두 호출 경로를 정확히 구분한다.

출처: spec-x-check-secrets-dual-mode walkthrough §결정 기록

---

## [[spec-x-check-secrets-dual-mode]] — 시크릿 가드 오탐 완화는 단일 부정 regex 가 아닌 다단계 grep -v + `+` 라인 필터 (2026)

**결정**: 시크릿 가드의 오탐 완화는 단일 부정형 regex 대신 다단계 `grep -v` 파이프와 staged diff 의 `+`(추가) 라인만 검사하는 필터로 처리한다.

**왜**: BSD grep 이 `-----BEGIN` 을 옵션으로 오해하고, 제거(`-`) 라인에서 self-trigger 하는 문제가 있었다. 다단계 `grep -v`(bash 3.2·BSD grep 안전) + `+` 라인 한정 필터가 이를 근본 해결하며 모든 패턴에 일관 적용된다.

출처: spec-x-check-secrets-dual-mode / spec-x-harness-footguns walkthrough §결정 기록

---

## [[spec-x-kit-update-notify]] — 버전 업데이트 알림은 두 번째 훅이 아닌 `sdd --brief` suffix 로 (2026)

**결정**: 키트 업데이트 알림은 별도 두 번째 훅(check-kit-version.sh) 출력이 아니라 `sdd status --brief` 의 suffix 로 노출한다. check-kit-version.sh 는 cache.json(24h TTL) 갱신 역할로 유지한다.

**왜**: Claude Code compact 포맷이 첫 번째 훅 출력만 에이전트 컨텍스트에 포함한다. 두 번째 훅에 알림을 두면 에이전트가 못 본다. SSOT 인 `sdd` 출력의 suffix 가 확실히 전달되는 경로다.

출처: spec-x-kit-update-notify walkthrough §결정 기록

---

## [[spec-x-doctor-hookspath-lefthook]] — lefthook × core.hooksPath 충돌은 자동 수정 아닌 진단·안내(warn) (2026)

**결정**: lefthook 와 core.hooksPath 충돌(issue #161)은 `sdd doctor` + 루트 doctor.sh 양쪽에서 진단+가이드(warn)만 한다. 감지는 lefthook AND hooksPath 조건일 때만 발화한다.

**왜**: 충돌 원인이 사용자의 hooksPath 설정이라 harness 가 직접 고칠 수 없다. 자동 수정/네이티브 통합은 사용자 환경을 침범한다. 소음 방지를 위해 두 조건이 동시 성립할 때만 경고한다 ([[spec-13-02]] graceful degradation 결).

출처: spec-x-doctor-hookspath-lefthook walkthrough §결정 기록

---

## [[ADR-004]] — phase-FF 를 phase 내 1급 작업 모드로 (2026-06-01)

**결정**: phase 내 작업은 항목별로 크기에 맞는 모드를 고른다. 실질적·불확실한 작업은 full Spec, 작고 명확하고 가역적인 1–2 commit 은 **phase-FF** — phase base 브랜치에 spec 산출물 없이 직접 커밋한다. phase-FF 는 재조정 fallback 이 아니라 착수 시점의 1급 선택지이며, 승인된 phase plan 이 항목 실행을 위임하므로 항목별 재승인은 없다. "phase 안이면 무조건 spec" 편향과 FF 회피용 bundle 을 금지한다.

**왜**: ceremony 고정비(5개 md + Plan Accept + PR + 리뷰, 약 6–8천 토큰)가 작업 크기와 무관하게 붙어 3줄 변경에도 문서 반복이 토큰 대부분을 차지했다(spec-15-05 실측). phase base 브랜치는 main 이 아니라 직접 커밋이 main 보호 불변식을 깨지 않으므로 ceremony 의 안전 근거가 약하다.

**대가**: per-spec 리뷰 입자도 상실(phase-ship PR 이 커짐). 완화 — 결정 로그를 phase.md "결정 기록" 에 누적. base 브랜치 모드 전제.

출처: ADR-004 · constitution §3.1 · agent.md §11.4

---

## [[ADR-005]] — 메인 에이전트는 context orchestrator (2026-06-01)

**결정**: 메인 세션을 orchestrator 로 명시하고 sub-agent 위임을 규약화한다. ① 토큰 무거운 노동만 위임 ② scoped slice 만 주입 ③ distilled result 만 반환 ④ 검증은 orchestrator 보유 ⑤ 독립 job 은 fan-out.

**왜**: 가장 비싼 자원은 메인 context 창이다. raw 산출물이 유입되면 의도의 흐름을 잃고 잘못된 가정 위에 작업이 쌓인다(understanding debt).

출처: ADR-005 · agent.md §6.6

---

## [[ADR-006]] — 디렉터 모드는 "지시 주입"으로 구현 (2026-06-03)

**결정**: `/hk-director` 로 켜는 운영 프로토콜. 디렉터(opus)는 의도 합의 후 worker(sonnet)에 작성·실행을 위임하고 증류 계약만 받는다. 검증은 transcript 재흡수가 아니라 **테스트 재실행 + 행동 검증**. Plan Accept·Ship 게이트는 위임하지 않는다. 모드 강제는 런타임 커널이 아니라 지시 주입(hk-align 과 같은 규약 강도).

**왜**: Claude Code 에 모드 커널이 없다. 실측(spec-20-01)에서 worker 가 각자 55k/100k 토큰을 격리 context 에서 소모하고 증류만 반납해 메인 오염을 막았다. 절감은 authoring 보다 **implementation 위임**에서 크다.

출처: ADR-006 · spec-20-01/02/03 walkthrough §결정 기록

---

## [[spec-20-04-model-config-and-review]] — 모델 이름은 config, 거버넌스는 역할만 (2026-06)

**결정**: 모델 매핑은 `harness.config.json` 의 `models`(후에 `.harness-kit/harness.config.json` 으로 SSOT 통일), 거버넌스 본문은 director/worker/scout 역할만 기술한다. review 패널은 전면 교체가 아니라 옵션이며 소규모는 단일 fallback.

**왜**: 모델 이름은 churn 이 잦다. 단일 Opus 깊이 손실·over-kill 도 피한다. 같은 파일(agent.md) 반복 편집 6건은 full spec 6개가 아니라 **번들 1개**가 맞다는 사용자 지적을 반영했다.

출처: spec-20-04 walkthrough §결정 기록

---

## [[ADR-007]] — extend 는 opt-in, 등록은 위임, 검증 후 추출 (2026-06-14)

**결정**: ① 확장은 default-off ② MCP 등록은 설정 파일 직접 편집이 아니라 `claude mcp add --scope` 에 위임(local 기본·user 옵션, 커밋되는 project 스코프 제외) ③ 검증된 확장 **3개 누적 후에만** 레지스트리로 추출. 첫 확장은 Serena(uvx 실행).

**왜**: project 스코프는 팀 전원에게 상시 컨텍스트 비용을 강요한다. Claude Code 네이티브 스코프가 합의 모델과 일치해 위임이 소유권 충돌을 피한다. 선프레임워크는 첫 사용자 검증 전의 추상화다.

출처: ADR-007 · spec-22-01 walkthrough §결정 기록

---

## [[ADR-008]] — 외부 확장은 조건부 우선 사용 (2026-06-14)

**결정**: 확장이 설치돼 있고 작업이 그 도구의 강점 영역일 때만 raw grep 보다 우선한다. bash·단순 grep 에는 원칙 #2(MCP 최후)가 유지된다. 권장 노출은 `sdd status` drift 1곳으로 단일화한다.

**왜**: 설치만 하고 안 쓰면 상시 비용만 낸다. 강제는 원칙 #2 와 충돌한다.

출처: ADR-008 · spec-23-01 walkthrough §결정 기록

---

## [[ADR-009]] — 거버넌스를 신뢰도·blast-radius 로 재배분, auto 모드 (2026-06-19)

**결정**: 모델이 안정화돼 "못 미덥다"는 가정의 사전 ceremony(Plan Accept·작은 변경 spec 강제·결정 시 차단형 질문)는 세금이 됐다. 안전을 **사후 검증 + 정지규칙 + 결정 로그 + blast-radius 가드**로 옮기고 unattended `auto` 모드를 둔다. attended(turbo) 와 unattended(auto)는 질적으로 다른 축이다.

**왜**: ceremony 고정비가 작업 크기와 무관하다(ADR-002). 단 안전이 **사후 테스트 품질에 전적으로 의존**하게 되므로 테스트 신뢰 보강(#212)이 선결 조건이다(Addendum).

출처: ADR-009 · spec-24-01~05 walkthrough

---

## [[spec-24-03-stop-rules]] — 정지규칙: 좁게, 경고로 시작, 실패 커밋은 보존 (2026-06-21)

**결정**: ② 비가역 감지는 실행 *전* PreToolUse Bash 매처로, narrow 범위(`reset --hard`·`--force-with-lease` 제외)·경고 모드로 시작한다. ③ 반복 실패의 hard-stop 은 revert 하지 않고 **커밋을 보존**한다. 결정 로그는 별도 파일이 아니라 walkthrough 의 auto 섹션에 누적한다.

**왜**: 감지가 넓으면 자율성이 깎이고 좁으면 사고가 난다 — FP 최소화가 우선이며 경계는 테스트로 고정한다. N회 실패는 사람 개입 신호라 실패 상태를 사람이 보게 둔다. `settings.json` deny 와 부분 중복은 의도적이다(deny 는 정적 all-or-nothing, hook 은 mode-aware).

출처: spec-24-03 walkthrough §결정 기록

---

## [[spec-25-01-askquestion-redirect-hook]] — "hook 으로 못 막음" 전제를 정정 (2026-06-22)

**결정**: `AskUserQuestion` 은 PreToolUse 매처 대상이므로 auto 에서 호출되는 순간 exit 2 로 차단하고 stderr 로 `decision add`+턴 종료 채널로 안내한다. 이 hook 만 기본 block 이다(CLAUDE.md #5 의 의도적 예외).

**왜**: spec-24-04 는 "agent 행동이라 hook 으로 못 막는다"고 했으나 절반만 맞았다 — *호출 안 함*은 선제할 수 없지만 *호출되는 순간*은 가로챌 수 있다. 이 hook 은 차단이 곧 기능이라 warn 은 무의미하고, auto 한정이라 위험이 격리된다. 공식 문서와 라이브 spike 로 검증했다.

출처: spec-25-01 walkthrough §결정 기록 · ADR-009 Addendum

---

## [[spec-25-02-test-trust]] — 테스트 신뢰는 비용 사다리, 칸 0 은 정적 프록시 (2026-06-22)

**결정**: 칸 0(`check-test-trust.sh`)은 "구현 변경에 테스트 동반했나 / 단언 있나"의 정적 휴리스틱 경고, 칸 2(`/hk-refute`)는 코드가 아니라 spec 의도에 앵커한 적대적 반증 커맨드다. 칸 1(뮤테이션)은 컴퓨트 비용 때문에 Icebox.

**왜**: 자동 revert 는 컴퓨트(칸 1 영역)다. 적대적 반증은 LLM 구동이라 hook 이 될 수 없다. 칸 0 은 실제 sabotage→red 를 실행하지 않으므로 조건부 PASS 로만 평가한다.

출처: spec-25-02 walkthrough §결정 기록 · phase-25 phase-review 정정

---

## [[spec-26-01-settings-push-ssot]] — push 게이팅은 mode 토글에서 제거 (2026-06-30)

**결정**: mode-toggle 의 governed 분기가 `git push` 를 `ask` 로 올리는 로직을 제거한다. fragment baseline(ask 에 push 없음, force 는 deny)이 SSOT 이다.

**왜**: 토글이 constitution §5.7("Plan Accept 후 push 자동")을 위반하고 있었다. "SSOT sync 테스트"로 보였던 W3 가 실은 토글 로직 문제였고, drift 의 원천이 토글이었다. 도그푸딩 사본 sync 는 테스트가 강제한다.

출처: spec-26-01 walkthrough §결정 기록

---

## [[spec-27-01-adr-index-gen]] — 마커 기반 인덱스 생성·검사 (2026-07-02)

**결정**: `sdd adr-index [--check]` 로 ADR 인덱스를 마커 구간에 생성하고, doctor 는 이를 서브셸로 격리 호출한다(`exit 1` 이 doctor 전체를 죽이지 않도록). 마커 탐지는 regex substring 이 아니라 **정확한 라인 일치**다. 잔존 phase 탐지(`_backlog_completed_residue`)는 `sdd archive` 와 공유한다.

**왜**: 안내 문구가 마커 문법을 인용하면 substring 매치가 그 줄을 마커로 오인한다. macOS(BWK awk)는 `awk -v` 멀티라인에서 실패한다. doctor 는 순수 진단이라 exit code 를 바꾸지 않는다.

출처: spec-27-01/02 walkthrough §결정 기록
