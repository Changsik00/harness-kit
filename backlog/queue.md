# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 무엇을 하고 있고, 다음에 무엇을 해야 하는가"를 한눈에 보기 위함.
>
> **자동 갱신 마커**: `active`, `specx`, `done` — 마커 (`<!-- sdd:... -->`) 사이는 sdd 가 관리하므로 그대로 두세요.
> **사람 편집 섹션**: `🧊 Icebox`, `📋 대기 Phase` — 자유 메모.

## 📦 진행 중 Phase

<!-- sdd:active:start -->
- **phase-25** — auto-reliability (auto 신뢰성) — 4 spec — 다음: (spec 없음)
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

> 아이디어·보류 항목 보관소. 실행 불가. 관련 항목이 쌓이면 Phase로, 단발이면 spec-x로 승격.

- **GitHub #212 칸1 — 뮤테이션 테스트** — 비용 사다리의 중간 칸. "심은 버그를 테스트가 잡나"의 *수치* 답("테스트가 올바른가"의 정량 지표). 컴퓨트 비싸고 **중요 모듈 한정**이라 phase-25(칸0 상시 + 칸2 위험비례) 에 안 넣고 보류. **phase-26(테스트 신뢰 심화) 후보** — 칸0/칸2 운영 데이터가 쌓인 뒤 ROI 판단. (출처 #212 비용 사다리, 2026-06-22 phase-25 착수 시 분리)
- **PR 을 `sdd ship` 없이 머지하면 phase.md spec 이 `Active` 로 stale 잔존** — gh pr create 로 직접 머지 시 spec 표가 Merged 로 안 바뀌고, 비활성 spec 은 `sdd ship`(active spec 대상)으로도 못 고쳐 수동 보정 필요(phase-24 24-01·24-02 에서 2회 발생, 2026-06-21). `sdd status` 가 git↔phase.md 불일치는 감지하나 *자동 보정 명령*(예: `sdd reconcile` 또는 `sdd ship <spec-id>`)이 없음. 검토 권장
- kit 새 버전 알림이 `sdd status` drift 섹션 한 줄에 그쳐 사용자 도달이 약함 — SessionStart 시 자동 노출 또는 알림 시각 강화 필요
- **ADR 템플릿 footgun** — `adr.md` 템플릿이 `type:`/`status:` frontmatter 줄에 인라인 주석(`# decision | invariant | ...`)으로 허용값 안내 → 저자가 안 지우면 phase16 integration 의 type-closure 검사가 주석째 읽어 'out-of-closure' 적발(ADR-009 에서 실제 발생, spec-24-01 에서 수습). 허용값 힌트를 frontmatter 줄 밖으로 이동 검토
- **`sdd phase done` (및 state_set 호출부 전반) state 파일 부재 시 exit 1** — `.claude/state/current.json` 없으면 queue 갱신만 되고 state 리셋에서 죽는 부분 실패. graceful 처리(파일 없으면 자동 생성 또는 skip) 필요. 2026-06-01 도그푸딩 중 발견
- **릴리스 절차에 self `update.sh` re-sync 단계 검토** — version 만 올리고 자기 자신에 install 재실행을 안 하면 도그푸딩 `.harness-kit/`·`.claude/` 설치본이 `sources/` 원본보다 drift (0.15.x 에서 실제 발생, update.sh 로 수습). `docs/release-strategy.md` 에 self re-sync 또는 drift 검사 게이트 추가 검토
- **GitHub #167/#168** — stale ADR 오탐(npm/IAM) + docs integrity 도구군(ADR index 생성·integrity check·archive 잔여 감지). 둘 다 `sdd doctor`/stale 검사 영역 — 묶어서 doctor 강화 phase 로 승격 권장
- (phase-16 W9) ADR 승격 가이드 ROI metric — *측정 누적 (3 개월+) 선행 필요*. phase-17 종료 후 spec 의 ADR 승격 ratio 데이터 보고 결정
- `tests/test-uninstall-cmd-list.sh` Scenario 1 pre-existing FAIL — `find sources/commands -name 'hk-*.md'` 가 `hk.md` (no dash) 를 제외하는 반면 install.sh 는 `*.md` 로 모두 포함. 글롭 패턴 통일 필요 (phase-17 의 `hk.md` 도입 시점부터 노출됨)
- 거버넌스 문서 단어 수 한계 초과 — `sdd doctor` 7000w soft-warn 인데 현재 7786w (constitution+agent.md). 하드 한도 8000 은 미만이나 여유 적음. rule-prune(§13) 또는 상세의 ADR 이관 검토 (spec-23-01 에서 +106w 누적)
- **root CLAUDE.md 슬림화** — 릴리스 전략 등 저빈도 내용을 `docs/release-strategy.md` 로 분리, root 는 포인터만. 항상-온 컨텍스트 토큰 절감 (Claude Code harness 기사 인사이트 #1) → phase-19 spec-19-03 에서 처리
- **권한 프롬프트 줄이기 (settings)** — governed 모드에서 git/gh/jq 등 명령마다 권한 다이얼로그가 떠 불편. `/fewer-permission-prompts` 로 자주 쓰는 read-only/git 명령을 `.claude/settings.json` 허용목록에 추가. (2026-06-14 사용자 요청, 차후 진행)
- **기존 테스트 5건 pre-existing FAIL** — `test-drift-stale-adr`(ADR-003 stale path), `test-pr-merge-detect`, `test-update-stateful`, `test-version-bump`, `test-wiki-structure`(missing spec-19-01 walkthrough 참조). main 에서도 동일 실패 — extend 무관. 묶어서 테스트 그린화 spec-x 로 정리 권장 (2026-06-14 phase-22 작업 중 확인)
- **분기별 governance prune protocol** — 거버넌스 ratchet 누적 방지. `/hk-governance-refresh` 또는 sdd 진단에 "rule age > 6mo" 경고. 모델 진화에 맞춰 stale rule 제거 메커니즘 부재 (기사 인사이트 #2) → phase-19 spec-19-03 에서 처리
- **하위 디렉토리 CLAUDE.md** — `sources/CLAUDE.md` (키트 원본 시점) / `specs/CLAUDE.md` (작업 로그 시점) 분리로 두 시점 혼동 방지 (기사 인사이트 #3)
- **LSP/MCP 활용 가이드** — agent.md §6.5 (Static Analysis First) 확장. 적용 대상 프로젝트가 LSP 지원 언어일 때 grep 대신 심볼 기반 정의/참조 추적 권장 (기사 인사이트 #4)
- **queue.md 파생 파일 전환** — 다중 사용자/디바이스 환경에서 queue.md merge conflict 를 줄이기 위해 active/done 등을 파생 파일로 분리하는 리팩터링 아이디어 (2026-05-28 드래프트 미착수, 통합 테스트 필요)
- **lefthook 네이티브 hook 통합** — install 시 `.git/hooks/pre-commit` append 대신 `lefthook.yml` 에 harness 검사를 등록하는 방식. lefthook install 이 디스패처를 재생성하면 append 블록이 덮이는 fragility 해소 (issue #161 제안 #2). bash YAML 편집 비용·사용자 파일 침습으로 보류 — lefthook 타깃 수요 누적 시 승격
- ~~모델 오케스트레이션 3-tier + 디렉터 모드~~ → **phase-20** (director-mode) 승격 — 설계 문서 `backlog/phase-20.md` + [[ADR-006]] 초안. 2026-06-03
- **`sdd ship` base-mode 갭** — base 브랜치 모드인데 `sdd ship` 이 spec 을 PR *전에* 즉시 `Merged` 표시 + state 리셋(non-base 동작). base 모드에선 spec PR 이 base 에 머지된 *후* Merged 가 맞음. spec-20-01 도그푸딩 중 발견(2026-06-03). `sdd ship` 에 base 모드 분기 필요(PR 까지만, Merged 는 base 머지 신호 후). systemic: phase done/specx done 등 다른 state 전이도 base 모드 정합성 점검 권장

**[phase-17 으로 promote 된 항목 — 처리 진행 중]**:
- ~~접근성 개선~~ → phase-17 **spec-17-02** (accessibility-install-and-entry)
- ~~sdd marker 버그 (W5/W10)~~ → ✓ **spec-17-01** 머지로 종식 (RCA-001 prevention)
- ~~installed.json 캐시 (C3)~~ / ~~phase integration test (W2)~~ / ~~doctor 새 경로 (W6)~~ → phase-17 **spec-17-03** (internal-reliability-infra)
- ~~§6.4 표현 (W1)~~ / ~~stale ADR 회귀 마커 (W3)~~ / ~~ADR 가이드 (W4)~~ / ~~CHANGELOG 정책 (W7)~~ → phase-17 **spec-17-04** (governance-test-coherence)
- ~~sdd phase done title 버그~~ → ✓ **spec-17-01** 머지로 종식 (normalize)

## 📋 대기 Phase

> 다음에 진행할 phase 를 자유롭게 메모합니다 (사람이 직접 편집).
> 자동 갱신되지 않습니다 — Icebox 와 동일한 정책.

- **phase-25 (auto 신뢰성)** — draft `backlog/phase-25.md`. phase-24 가 auto *배관* 만 완성했고, auto 가 안전하게 자율하려면 ① `AskUserQuestion` 리다이렉트 hook(논블로킹 기계적 백스톱, 24-04 "hook 불가" 전제 정정), ② #212 칸0 사후 테스트 신뢰, ③ auto e2e(측정), ④ check-irreversible 차단 승격 이 선행돼야 함(→ ADR-009 Addendum). **phase-24 merge 후 `sdd phase activate phase-25` 로 시작.** auto 도그푸딩은 이 phase 종료 후.

## ✅ 완료

<!-- sdd:done:start -->
| Phase | 제목 | SPECs |
|-------|------|-------|
| [phase-01](phase-01.md) | 설치/운영 마찰 해소 | 2 (Merged) |
| [phase-02](phase-02.md) | 토큰 최적화 & 거버넌스 경량화 | 3 (Merged) |
| [phase-03](phase-03.md) | macOS 네이티브 설치 모드 | 1 (Merged) |
| [phase-04](phase-04.md) | 옵셔널 Sub-agent 리뷰 시스템 | 2 (Merged) |
| [phase-05](phase-05.md) | spec-kit 패턴 도입 & 크로스 에이전트 | 1 (Merged) |
| [phase-06](phase-06.md) | SDD UX 개선 및 커맨드 정리 | 2 (Merged) |
| [phase-07](phase-07.md) | SDD 프로세스 일관성 및 품질 강화 | 4 (Merged) |
- **phase-08** — 작업 관리 모델 재정립 — completed 2026-04-12
- **phase-09** — 설치 충돌 방어 — completed 2026-04-17
- **phase-10** — sdd 상태 진단 신뢰성 강화 — completed 2026-04-16
- **phase-11** — 식별자 체계 개선 및 디렉토리 아카이브 — completed 2026-04-17
- [x] spec-x-sdd-ux-fixes (완료)
- **phase-12** — 프로젝트 확장성 강화 — completed 2026-04-22
- **phase-13** — 개발자 경험(DX) 향상 — 자동화 & 온보딩 — completed 2026-04-25
- **phase-14** — 정합성 / 멱등성 버그 일괄 수정 — completed 2026-04-25
- [x] spec-x-phase-14-finalize (완료)
- [x] spec-x-update-preserve-state (완료)
- [x] spec-x-install-phase-ship-template (완료)
- [x] spec-x-sdd-phase-activate (완료)
- **phase-15** — upgrade-safety — 기존 사용자 update 경로 안전성 — completed 2026-04-30
- [x] spec-x-phase-15-finalize (완료)
- [x] spec-x-hk-align-drift-detect (완료)
- [x] spec-x-fix-archive-test-expectation (완료)
- [x] spec-x-install-fragment-fixes (완료)
- [x] spec-x-hook-bypass-fix (완료)
- [x] spec-x-output-ux (완료)
- [x] spec-x-confirm-ux (완료)
- [x] spec-x-precommit-chmod-fix (완료)
- [x] spec-x-kit-update-check (완료)
- [x] spec-x-doctor-hooks-path-fix (완료)
- [x] spec-x-archive-include-specx (완료)
- [x] spec-x-archive-clean-commit (완료)
- [x] spec-x-hook-allow-ff-when-no-spec (완료)
- [x] spec-x-phase-lifecycle-coherence (완료)
- [x] spec-x-governance-distribute-workflow-patterns (완료)
- [x] spec-x-hk-update-remote (완료)
- [x] spec-x-kit-update-hook (완료)
- [x] spec-x-readme-refresh (완료)
- [x] spec-x-phase-16-define (완료)
- **phase-16** — Reliability Layer 강화 — completed 2026-05-16
- [x] spec-x-phase-17-define (완료)
- **phase-17** — 운영 성숙도 (Operational Maturity) — completed 2026-05-17
- [x] spec-x-planning-economy (완료)
- [x] spec-x-sdd-state-guard (완료)
- [x] spec-x-ask-mode-toggle (완료)
- [x] spec-x-sdd-search (완료)
- [x] spec-x-claude-md-slim (완료)
- [x] spec-x-claude-md-nested (완료)
- [x] spec-x-kit-update-notify (완료)
- **phase-18** — Precheck Gate — 설정 기반 PR 사전 검증 자동화 — completed 2026-05-21
- [x] spec-x-check-secrets-dual-mode (완료)
- [x] spec-x-harness-footguns (완료)
- [x] spec-x-doctor-hookspath-lefthook (완료)
- **phase-19** — 문서 지식 그래프 (Doc Knowledge Graph) — completed 2026-06-01
- **phase-20** — 디렉터 모드 (Director Mode) — context-preserving orchestration — completed 2026-06-04
- **phase-21** — Ceremony 경량화 — Turbo 모드 + 문서 구조 개선 — completed 2026-06-13
- **phase-22** — extend — 외부 도구 opt-in 통합 — completed 2026-06-14
- [x] spec-x-align-mode-salience (완료)
- [x] spec-x-sdd-bugfix (완료)
- [x] spec-x-drift-stale-adr-glob (완료)
- **phase-23** — extension-first — completed 2026-06-14
- [x] spec-x-fix-failing-tests (완료)
- **phase-24** — auto-mode — completed 2026-06-22
<!-- sdd:done:end -->

---

## 📖 사용 방법

| 명령 | 동작 |
|---|---|
| `sdd phase new <slug>` | 새 Phase 생성 → 진행 중으로 등록 |
| `sdd phase new <slug> --base` | Phase base branch 모드로 생성 (opt-in) |
| `sdd spec new <slug>` | 진행 중 Phase에 다음 spec 등록 |
| `sdd plan accept` | spec Plan Accept → 실행 모드 진입 |
| `sdd ship` | spec 완료 처리 → Merged 갱신 + state 초기화 + NEXT 안내 |
| `sdd phase done <N>` | Phase 완료 → 완료 섹션으로 이동 |

자세한 사용법: `agent/constitution.md` §3 Work Type Model, `agent/agent.md`
