# chore(spec-x-phase-15-finalize): mark phase-15 done in queue.md

## 📋 Summary

### 배경 및 목적

PR #91 (`feat(phase-15): upgrade-safety`) 가 phase-level 통합 PR 로 머지된 후, `sdd phase done phase-15` 후처리가 누락되어 `backlog/queue.md` 의 active 섹션에 phase-15 가 잔존했습니다. 그 결과:

- `sdd status` 가 phase-15 를 여전히 active 로 보고 → 다음 작업 진입 시 컨텍스트 혼선
- multi-device 환경에서 pull 직후에도 동일하게 stale 상태로 보임
- spec-15-01 의 task.md 미체크 항목 30 개가 "pending" 으로 카운트되는 부수 효과

본 finalize spec 은 그 후처리를 단일 커밋으로 분리해 정리합니다.

### 주요 변경 사항

- [x] `sdd phase done phase-15` 실행 → `backlog/queue.md` active 섹션에서 phase-15 제거 + done 섹션에 등록 (completed 2026-04-30)
- [x] `bash .harness-kit/bin/sdd status` 가 `Active Phase: 없음` 을 깔끔하게 보고하도록 회복
- [x] untracked `.harness-kit/agent/templates/phase-ship.md` 출처 검증 (sources/templates/phase-ship.md 와 동일 — 정상 install 부산물로 확인, keep)

### Phase 컨텍스트

- **Phase**: 없음 (Solo Spec — finalize 전용)
- **본 SPEC 의 역할**: phase-15 의 거버넌스 마무리. 다음 spec (`spec-x-hk-align-drift-detect`) 진입을 위한 컨텍스트 정리.

## 🎯 Key Review Points

1. **`backlog/queue.md` diff 가 의도한 영역에만 한정**: active → done 이동, specx 대기 목록에 본 spec 항목 추가. 그 외 변경 없음.
2. **No code change**: `sources/`, `install.sh`, `update.sh`, `.harness-kit/bin/sdd` 등 키트 본체는 손대지 않음. 거버넌스 finalize 만 수행.
3. **부수 발견의 처리**: `phase-ship.md` tracked 일관성 깨짐을 walkthrough 에 발견사항으로 기록. 본 PR 에서는 plan 범위를 지키기 위해 처리하지 않고 후속 검토로 이월.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-sdd-spec-new-seq.sh
```

**결과 요약**:
- ✅ Test 1 (specs/ 04 할당): 통과
- ✅ Test 2 (archive 06 할당): 통과
- ✅ Test 3 (specs+archive 07 할당): 통과
- ✅ Test 4 (phase-04 할당): 통과
- ✅ Test 5 (phase-06 할당): 통과
- **PASS: 5  FAIL: 0**

본 spec 은 신규 코드 변경이 없어 신규 단위 테스트 추가는 없으며, sdd 자체 회귀만 검증.

### 수동 검증 시나리오

1. **finalize 전 상태**: `sdd status` → `Active Phase: phase-15` 확인 (꼬임 재현)
2. **finalize 실행**: `sdd phase done phase-15` → 종료 코드 0, queue.md 만 변경
3. **finalize 후 상태**: `sdd status` → `Active Phase: 없음` ✓
4. **untracked 검증**: `diff sources/templates/phase-ship.md .harness-kit/agent/templates/phase-ship.md` → empty (동일, keep)

## 📦 Files Changed

### 🛠 Modified Files
- `backlog/queue.md`: phase-15 active → done 이동 + specx 대기에 본 spec 등록

### 🆕 New Files
- `specs/spec-x-phase-15-finalize/spec.md`: 배경 + 요구사항 + DoD
- `specs/spec-x-phase-15-finalize/plan.md`: 브랜치 전략 + Proposed Changes + 검증 계획
- `specs/spec-x-phase-15-finalize/task.md`: 4 tasks
- `specs/spec-x-phase-15-finalize/walkthrough.md`: 결정 기록 + 수동 검증 + 발견사항
- `specs/spec-x-phase-15-finalize/pr_description.md`: 본 문서

**Total**: 6 files (1 modified + 5 new)

## ✅ Definition of Done

- [x] 회귀 테스트 통과 (`tests/test-sdd-spec-new-seq.sh`)
- [x] `sdd phase done phase-15` 실행 + 결과 검증
- [x] untracked `phase-ship.md` 처리 결정 (keep) + walkthrough 기록
- [x] `walkthrough.md` 작성 및 ship commit
- [x] `pr_description.md` 작성 및 ship commit
- [x] `spec-x-phase-15-finalize` 브랜치 push
- [x] PR 생성 + 사용자 검토 요청 알림

## 🔗 관련 자료

- 선행 PR: #91 (`feat(phase-15): upgrade-safety`) — 본 finalize 의 트리거
- 후속 spec 후보: `spec-x-hk-align-drift-detect` (multi-device drift 자동 감지)
- 후속 검토 후보: `hk-phase-ship` 가 phase done 까지 자동 호출하도록 보강
- Walkthrough: `specs/spec-x-phase-15-finalize/walkthrough.md`
