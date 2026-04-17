# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 무엇을 하고 있고, 다음에 무엇을 해야 하는가"를 한눈에 보기 위함.
> sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요.
> 🧊 Icebox 섹션만 사람이 직접 편집합니다.

## 📦 진행 중 Phase

<!-- sdd:active:start -->
(active phase 없음. `bin/sdd phase new <slug>` 로 시작)
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

> 아이디어·보류 항목 보관소. 실행 불가. 관련 항목이 쌓이면 Phase로, 단발이면 spec-x로 승격.

- [ ] 크로스 에이전트 호환 (AGENTS.md) — Cursor/Copilot/Codex 등에서 프로젝트 컨텍스트를 인식할 수 있도록 install.sh에서 AGENTS.md 자동 생성. 현재 Claude Code 전용으로 충분하나, 멀티 에이전트 환경이 보편화되면 재검토. (보류 2026-04-11)
- [ ] 크로스 플랫폼 지원 — 현재 macOS + bash 4.0+ 전용. Linux CI 환경(GitHub Actions 등)은 bash 호환이라 즉시 가능하나, Windows는 WSL2 필수. 검토 사항: (1) GitHub Actions CI에서 테스트 자동화 (2) Linux 공식 지원 선언 (3) WSL2 설치 가이드 추가. macOS 외 실사용자가 나타나면 승격.

## 📋 대기 Phase

<!-- sdd:queued:start -->
| Phase | 제목 | 상태 | SPECs |
|-------|------|------|-------|
<!-- sdd:queued:end -->

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
- **phase-08** — 작업 관리 모델 재정립 — Queue·Phase base branch·완료 흐름 강제 — completed 2026-04-12
- **10** — ? — completed 2026-04-16
- **11** — ? — completed 2026-04-17
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
