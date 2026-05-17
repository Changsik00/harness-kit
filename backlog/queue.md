# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 무엇을 하고 있고, 다음에 무엇을 해야 하는가"를 한눈에 보기 위함.
>
> **자동 갱신 마커**: `active`, `specx`, `done` — 마커 (`<!-- sdd:... -->`) 사이는 sdd 가 관리하므로 그대로 두세요.
> **사람 편집 섹션**: `🧊 Icebox`, `📋 대기 Phase` — 자유 메모.

## 📦 진행 중 Phase

<!-- sdd:active:start -->
(active phase 없음. `bin/sdd phase new <slug>` 로 시작)
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
- [ ] spec-x-planning-economy — planning-economy
<!-- sdd:specx:end -->

## 🧊 Icebox

> 아이디어·보류 항목 보관소. 실행 불가. 관련 항목이 쌓이면 Phase로, 단발이면 spec-x로 승격.

- kit 새 버전 알림이 `sdd status` drift 섹션 한 줄에 그쳐 사용자 도달이 약함 — SessionStart 시 자동 노출 또는 알림 시각 강화 필요
- (phase-16 W9) ADR 승격 가이드 ROI metric — *측정 누적 (3 개월+) 선행 필요*. phase-17 종료 후 spec 의 ADR 승격 ratio 데이터 보고 결정

**[phase-17 으로 promote 된 항목 — 처리 진행 중]**:
- ~~접근성 개선~~ → phase-17 **spec-17-02** (accessibility-install-and-entry)
- ~~sdd marker 버그 (W5/W10)~~ → ✓ **spec-17-01** 머지로 종식 (RCA-001 prevention)
- ~~installed.json 캐시 (C3)~~ / ~~phase integration test (W2)~~ / ~~doctor 새 경로 (W6)~~ → phase-17 **spec-17-03** (internal-reliability-infra)
- ~~§6.4 표현 (W1)~~ / ~~stale ADR 회귀 마커 (W3)~~ / ~~ADR 가이드 (W4)~~ / ~~CHANGELOG 정책 (W7)~~ → phase-17 **spec-17-04** (governance-test-coherence)
- ~~sdd phase done title 버그~~ → ✓ **spec-17-01** 머지로 종식 (normalize)

## 📋 대기 Phase

> 다음에 진행할 phase 를 자유롭게 메모합니다 (사람이 직접 편집).
> 자동 갱신되지 않습니다 — Icebox 와 동일한 정책.

없음

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
