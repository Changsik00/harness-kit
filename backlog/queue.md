# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 어느 phase 에 있고, 다음 무엇을 할지" 를 한눈에 보기 위함.
> sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요.
> 사람이 직접 적는 곳: 각 phase/spec 항목의 *메모* 칸 (옵션).

## 🎯 진행 중

<!-- sdd:active:start -->
- **phase-6** — SDD UX 개선 및 커맨드 정리 — 1 spec — 다음: spec-6-001-cmd-prefix-rename
<!-- sdd:active:end -->

## 📋 대기 (Backlog)

> 다음에 진행할 phase 들. 우선순위 순.

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
<!-- sdd:done:end -->

---

## 📖 사용 방법

- `sdd phase new <slug>` → "진행 중" 으로 들어감, 이전 active 는 "대기" 로 밀림 (선택)
- `sdd spec new <slug>` → 진행 중 phase 의 다음 spec 으로 자동 등록
- `sdd plan accept` → 해당 spec 의 상태 표시 갱신
- `sdd archive` → spec 머지 표시 (수동으로 phase 의 상태도 Merged 로 갱신 권장)
- `sdd phase done <N>` → phase 를 "완료" 로 이동 (모든 spec 이 merge 된 후)

자세한 사용법: `agent/agent.md`, `docs/USAGE.md`
