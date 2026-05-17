# docs(spec-x-phase-17-define): phase-17 (정합성 fix) 정식 정의

## 📋 Summary

### 배경 및 목적

phase-16 (Reliability Layer 강화) 직후 독립 Opus sub-agent 회고에서 **self-credibility 손상** 4 종 식별 — RCA-001 invariant 위반 4 회 재발 (W5), productivity tax 4 commit overhead (W10), 워킹트리 항상 dirty (C3), phase-level 자동화 부재 (W2/W6). reliability layer phase 가 자기 RCA 를 못 지키는 아이러니.

본 PR 은 위 4 가지를 해소할 **phase-17 (정합성 fix)** 을 정식 정의한다. spec 3 개 분해, base branch 처음부터 사용, 회고 W-번호 ref 추적성 명시.

### 주요 변경 사항

- [x] `backlog/phase-17.md` 신규 작성 (phase 템플릿 7 섹션 모두 채움)
- [x] SPECs 표 3 spec 등록 (spec-17-01/02/03, 모두 Backlog)
- [x] 결정 기록 표 4 결정 박음 (base branch 시점 / 묶음 단위 / Out of Scope / 접근성 분리)
- [x] 통합 테스트 시나리오 3 개 (정량 검증 형식)
- [x] phase-16 회고 ref (W5/W10/C3/W2/W6) 본문 4 곳 hit — closed 추적성

### Phase 컨텍스트

- **Mode**: spec-x (Phase 비소속, main 직 PR)
- **선행**: phase-16 (RCA/ADR/Stale/Positioning) 머지 완료
- **후속**: 본 PR 머지 → `sdd phase activate phase-17 --base` → spec-17-01 부터 진행

## 🎯 Key Review Points

1. **3 spec 묶음 — 추가/제거 의견** — sdd marker 3종 묶음 vs 분리, cache 분리 포함 여부, integration test + doctor 한 spec.
2. **Out of Scope 7 건 (W1/W3/W4/W7/W9 + 접근성 개선)** 의 Icebox 잔류가 *적절한 분리* 인지 *책임 회피* 인지.
3. **Base branch 처음부터 사용** — phase-16 mid-phase 전환 cost 의 학습 적용. 가벼운 phase 에 대해서도 base branch 가 정합한가.
4. **회고 ref 명시 패턴** — 본 phase 가 도입한 *closed/open 추적성* 이 후속 phase 정의에도 적용할 만한가.

## 🧪 Verification

### 자동 테스트 (단위 검증)
```bash
test -f backlog/phase-17.md
grep "Phase ID.*phase-17" backlog/phase-17.md
grep "Base Branch.*phase-17-coherence-fix" backlog/phase-17.md
grep -c "^| spec-17-0" backlog/phase-17.md   # → 3
grep -E "W5|W10|C3|W2|W6" backlog/phase-17.md | wc -l   # → 4
```

**결과 요약**: 5/5 PASS

### 통합 테스트
Integration Test Required = no. 본 spec 은 문서 작성만.

## 📦 Files Changed

### 🆕 New Files
- `backlog/phase-17.md` (164 줄) — phase-17 (정합성 fix) 정식 정의
- `specs/spec-x-phase-17-define/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md`

### 🛠 Modified Files
- `backlog/queue.md` — sdd specx new 가 자동 갱신 (specx 대기 entry 추가)

**Total**: 7 files changed (6 new + 1 modified)

## ✅ Definition of Done

- [x] `backlog/phase-17.md` 작성 — 7 섹션 모두 채움
- [x] SPECs 표 3 spec Backlog 등록
- [x] 결정 기록 표 4 결정 박음
- [x] 통합 시나리오 3 정량 검증 형식
- [x] `walkthrough.md` 와 `pr_description.md` ship commit
- [x] 사용자 검토 요청 알림 (PR 머지 대기)

## 🔗 관련 자료

- 선행 Phase: `backlog/phase-16.md` (Reliability Layer 강화)
- phase-16 회고: phase-16 PR #120 머지 commit (회고 결과 Icebox 11 항목으로 정착)
- 관련 RCA: `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` (spec-17-01 이 prevention 구현)
- 관련 ADR: `docs/decisions/ADR-001-knowledge-types.md` (phase-16 의 closure decision)

## ⏭ 다음 단계 (머지 후)

```bash
# 1. phase-17 활성화 + base branch 생성
sdd phase activate phase-17 --base

# 2. 첫 spec 시작
sdd spec new sdd-marker-bugs-fix
```

머지 후 사용자가 위 절차로 phase-17 본격 진입. 본 spec-x 는 *정의* 만 책임.
