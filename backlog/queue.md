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
- [ ] spec-x-fix-archive-test-expectation — fix-archive-test-expectation
<!-- sdd:specx:end -->

## 🧊 Icebox

> 아이디어·보류 항목 보관소. 실행 불가. 관련 항목이 쌓이면 Phase로, 단발이면 spec-x로 승격.

- [ ] 크로스 에이전트 호환 (AGENTS.md) — Cursor/Copilot/Codex 등에서 프로젝트 컨텍스트를 인식할 수 있도록 install.sh에서 AGENTS.md 자동 생성. 현재 Claude Code 전용으로 충분하나, 멀티 에이전트 환경이 보편화되면 재검토. (보류 2026-04-11)
- [ ] 크로스 플랫폼 지원 — 현재 macOS + bash 4.0+ 전용. Linux CI 환경(GitHub Actions 등)은 bash 호환이라 즉시 가능하나, Windows는 WSL2 필수. 검토 사항: (1) GitHub Actions CI에서 테스트 자동화 (2) Linux 공식 지원 선언 (3) WSL2 설치 가이드 추가. macOS 외 실사용자가 나타나면 승격.
- [ ] **install.sh 의 self-host gitignore 충돌** — install.sh 가 항상 `.harness-kit/` 를 .gitignore 에 추가하지만, 본 프로젝트(harness-kit 자체)는 도그푸딩 결과물 `.harness-kit/` 를 git 추적함. 결과: 도그푸딩 시 .gitignore 에 중복 라인이 매번 추가됨. self-host 감지 로직 또는 `install.sh --no-gitignore-harness-kit` 옵션 검토. (관찰 2026-04-27, spec-x-update-preserve-state 도그푸딩 중)
- [ ] **install.sh 가 phase-ship.md 템플릿을 복사하지 않음** — `sources/templates/phase-ship.md` 는 존재하지만 install.sh 의 템플릿 복사 루프 (install.sh:262) 에 누락. `/hk-phase-ship` 슬래시 커맨드가 이 템플릿을 참조한다면 신규 설치 환경에서 동작하지 않을 가능성. 영향 범위 조사 후 fix. (관찰 2026-04-27, spec-x-update-preserve-state 도그푸딩 중)
- [ ] **install.sh 가 settings.json 의 ask 리스트에 git push 자동 추가** — 도그푸딩 시 settings.json 에 `Bash(git push)` / `Bash(git push:*)` 가 ask 섹션에 추가됨. allow 에 이미 있어도 ask 가 우선이라면 매번 권한 프롬프트가 뜨는 경험 영향. 의도적 동작인지 확인 필요. (관찰 2026-04-27, spec-x-update-preserve-state 도그푸딩 중)

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
