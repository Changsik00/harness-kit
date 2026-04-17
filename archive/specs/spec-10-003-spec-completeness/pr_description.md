# feat(spec-10-003): sdd status에 산출물 완성도 체크리스트 추가

## 📋 Summary

### 배경 및 목적

`sdd status`는 active spec이 있을 때 task 진행률만 표시하고, 필수 산출물(spec.md, plan.md, task.md, walkthrough.md, pr_description.md)의 존재 여부를 확인하지 않아 archive 시점에야 누락을 발견했다. 산출물 체크리스트와 완성도 단계를 status에 추가하여 현재 작업 상태를 한눈에 파악할 수 있게 한다.

### 주요 변경 사항
- [x] `cmd_status()`에 Artifacts 라인 추가: `✓ spec ✓ plan ✓ task ✗ walkthrough ✗ pr_description`
- [x] 완성도 단계 레이블: Planning(spec+plan) → Executing(+task) → Ship-ready(+walkthrough+pr_description)
- [x] active spec 없으면 Artifacts 라인 미출력

### Phase 컨텍스트
- **Phase**: `phase-10` (sdd 상태 진단 신뢰성 강화)
- **본 SPEC 의 역할**: 산출물 누락을 조기에 감지하여 archive 실패를 방지

## 🎯 Key Review Points

1. **산출물 존재 검사**: `[ -f ]` 단순 존재 검사만 수행. 내용 품질 검증은 기존 `cmd_archive`에서 수행.
2. **단계 결정 로직**: walkthrough+pr_description 둘 다 있어야 Ship-ready. task만 있으면 Executing. spec/plan만 있으면 Planning.

## 🧪 Verification

```bash
bash tests/test-sdd-spec-completeness.sh
```

- ✅ Check 1: spec+plan만 → Planning
- ✅ Check 2: +task → Executing
- ✅ Check 3: +walkthrough+pr_description → Ship-ready
- ✅ Check 4: spec=null → 미출력
- ✅ 전체 회귀 16개 테스트 PASS

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-spec-completeness.sh`: 산출물 완성도 단위 테스트 (4 시나리오)

### 🛠 Modified Files
- `sources/bin/sdd` (+35): Artifacts 체크리스트 + 단계 레이블 출력
- `.harness-kit/bin/sdd` (+35): 도그푸딩 동기화

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-10.md`
- Walkthrough: `specs/spec-10-003-spec-completeness/walkthrough.md`
