# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 무엇을 하고 있고, 다음에 무엇을 해야 하는가"를 한눈에 보기 위함.
>
> **자동 갱신 마커**: `active`, `specx`, `done` — 마커 (`<!-- sdd:... -->`) 사이는 sdd 가 관리하므로 그대로 두세요.
> **사람 편집 섹션**: `🧊 Icebox`, `📋 대기 Phase` — 자유 메모.

## 📦 진행 중 Phase

<!-- sdd:active:start -->
없음
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

> 아이디어·보류 항목 보관소. 실행 불가. 관련 항목이 쌓이면 Phase로, 단발이면 spec-x로 승격.
> 이 섹션은 sdd가 건드리지 않습니다. 자유롭게 편집하세요.

<!-- 예시:
- [ ] 아이디어: sdd stale detection 자동화
- [ ] 보류: spec-05-02 (dependency 해소 후 재검토)
-->

## 📋 대기 Phase

> 다음에 진행할 phase 를 자유롭게 메모합니다 (사람이 직접 편집).
> 자동 갱신되지 않습니다 — Icebox 와 동일한 정책.

없음

## ✅ 완료

<!-- sdd:done:start -->
없음
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
