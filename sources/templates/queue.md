# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 어느 phase 에 있고, 다음 무엇을 할지" 를 한눈에 보기 위함.
> sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요.
> 사람이 직접 적는 곳: 각 phase/spec 항목의 *메모* 칸 (옵션).

## 🎯 진행 중

<!-- sdd:active:start -->
(active phase 없음. `bin/sdd phase new <slug>` 로 시작)
<!-- sdd:active:end -->

## 📋 대기 (Backlog)

> 다음에 진행할 phase 들. 우선순위 순.
> phase 는 sdd 가 만들면서 자동 등록되므로, 새 phase 가 생기면 여기 대기에 들어옵니다.

<!-- sdd:queued:start -->
(없음)
<!-- sdd:queued:end -->

## ✅ 완료

<!-- sdd:done:start -->
(없음)
<!-- sdd:done:end -->

---

## 📖 사용 방법

- `sdd phase new <slug>` → "진행 중" 으로 들어감, 이전 active 는 "대기" 로 밀림 (선택)
- `sdd spec new <slug>` → 진행 중 phase 의 다음 spec 으로 자동 등록
- `sdd plan accept` → 해당 spec 의 상태 표시 갱신
- `sdd archive` → spec 머지 표시 (수동으로 phase 의 상태도 Merged 로 갱신 권장)
- `sdd phase done <N>` → phase 를 "완료" 로 이동 (모든 spec 이 merge 된 후)

자세한 사용법: `agent/agent.md`, `docs/USAGE.md`
