# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 무엇을 하고 있고, 다음에 무엇을 해야 하는가"를 한눈에 보기 위함.
> sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요.
> 🧊 Icebox 섹션만 사람이 직접 편집합니다.

## 📦 진행 중 Phase

<!-- sdd:active:start -->
- **phase-9** — 설치 충돌 방어 — 디렉토리 은닉 + CLAUDE.md @import + 충돌 감지 — 13 spec — 다음: (spec 없음)
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

> 아이디어·보류 항목 보관소. 실행 불가. 관련 항목이 쌓이면 Phase로, 단발이면 spec-x로 승격.

- [ ] spec-5-002 (deferred — dependency 해소 후 재검토)

## 📋 대기 Phase

<!-- sdd:queued:start -->
| Phase | 제목 | 상태 | SPECs |
|-------|------|------|-------|
<!-- sdd:queued:end -->

## ✅ 완료

<!-- sdd:done:start -->
| Phase | 제목 | SPECs |
|-------|------|-------|
| [phase-1](phase-1.md) | 설치/운영 마찰 해소 | 2 (Merged) |
| [phase-2](phase-2.md) | 토큰 최적화 & 거버넌스 경량화 | 3 (Merged) |
| [phase-3](phase-3.md) | macOS 네이티브 설치 모드 | 1 (Merged) |
| [phase-4](phase-4.md) | 옵셔널 Sub-agent 리뷰 시스템 | 2 (Merged) |
| [phase-5](phase-5.md) | spec-kit 패턴 도입 & 크로스 에이전트 | 1 (Merged, spec-5-002 icebox) |
| [phase-6](phase-6.md) | SDD UX 개선 및 커맨드 정리 | 2 (Merged) |
| [phase-7](phase-7.md) | SDD 프로세스 일관성 및 품질 강화 | 4 (Merged) |
- **phase-8** — 작업 관리 모델 재정립 — Queue·Phase base branch·완료 흐름 강제 — completed 2026-04-12
<!-- sdd:done:end -->

---

## 📖 사용 방법

| 명령 | 동작 |
|---|---|
| `sdd phase new <slug>` | 새 Phase 생성 → 진행 중으로 등록 |
| `sdd phase new <slug> --base` | Phase base branch 모드로 생성 (opt-in) |
| `sdd spec new <slug>` | 진행 중 Phase에 다음 spec 등록 |
| `sdd plan accept` | spec Plan Accept → 실행 모드 진입 |
| `sdd archive` | spec 완료 처리 → Merged 갱신 + state 초기화 + NEXT 안내 |
| `sdd phase done <N>` | Phase 완료 → 완료 섹션으로 이동 |

자세한 사용법: `agent/constitution.md` §3 Work Type Model, `agent/agent.md`
