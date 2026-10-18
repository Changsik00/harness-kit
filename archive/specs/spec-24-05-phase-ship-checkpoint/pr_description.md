# feat(spec-24-05): sdd decision list --phase (rollup) + phase-ship 연동

## 📋 Summary

### 배경 및 목적
ADR-009 auto 규약 4: "결정 로그가 **phase-ship 에서 사람에게 일괄 노출**". 24-03 의 `sdd decision add/list` 는 *현재 spec 하나만* 다룬다. auto 가 phase 전체를 fire-and-forget 으로 돌면 결정이 여러 spec walkthrough 에 흩어진다 — 사람이 복귀하는 단일 검토점(phase-ship)에서 한 번에 볼 방법이 없었다.

### 주요 변경 사항
- [x] `sdd decision list --phase` — active phase 전 spec(`specs/spec-{phaseN}-*/walkthrough.md`)의 결정 로그(auto) 행을 spec 라벨과 함께 rollup
- [x] 결정 없는 spec 스킵, 0건 graceful, 기존 `decision list`(현재 spec) 불변
- [x] `hk-phase-ship` 에 결정 로그 rollup 검토 단계(Step 4) + Go/No-Go 보고 + Phase PR 본문 "🤖 자율 결정 로그" 섹션 포함

### Phase 컨텍스트
- **Phase**: `phase-24` — **마지막 spec**. ADR-009 auto 규약 4(사후 검증 안전망)의 phase-ship 노출 구현.

## 🎯 Key Review Points

1. **`_decision_list_phase` 행 추출**: 24-03 의 고정 표 형식(`| 이슈 | 결정 | 근거 |`) 의존. grep 으로 데이터 행만(헤더·구분선 제외) 뽑아 spec 열 prepend.
2. **spec 사이 테스트 게이트는 의도적 제외**: 이미 post-commit-verify(24-03)+check-test-passed 가 담당. 24-05 는 rollup 에 집중.

## 🧪 Verification

```bash
bash tests/test-decision-phase.sh
```
**결과**: ✅ 5/5 (집계 / spec 라벨 / 결정없는 spec 스킵 / 기존 list 불변 / 0건 graceful), 전체 72/72

### 수동
- 실제 phase-24 `sdd decision list --phase` → `(결정 로그 없음)` (attended 로 구축돼 auto 결정 없음 — graceful 정상)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-decision-phase.sh`

### 🛠 Modified Files
- `sources/bin/sdd` (+ 미러): `decision list --phase` + `_decision_list_phase`
- `sources/commands/hk-phase-ship.md` (+ 미러): rollup Step 4 + PR 본문 연동

## ✅ Definition of Done
- [x] 모든 테스트 통과 (72/72)
- [x] walkthrough / pr_description ship commit
- [x] 사용자 검토 요청

## 🔗 관련 자료
- Phase: `backlog/phase-24.md` · 관련 ADR: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md`
- 선행: spec-24-03 (`decision add/list` 토대)
