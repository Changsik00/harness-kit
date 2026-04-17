# fix(spec-10-04): phase 완료 판단 정확도 개선

## 📋 Summary

### 배경 및 목적

`_check_phase_all_merged()`가 Done 상태를 완료로 오판하여 archive 안 된 spec이 있어도 "모든 Spec Merged" 메시지를 출력했다. `compute_next_spec()`은 Backlog만 검색하여 Done(archive 누락) spec을 건너뛰었다. 두 함수를 수정하여 phase 완료 판단과 NEXT 안내의 정확도를 개선한다.

### 주요 변경 사항
- [x] `_check_phase_all_merged()`: `$5` 필드 비교로 전환 + Done 포함 미완료 카운트 + git 교차 확인
- [x] `compute_next_spec()`: Done 우선 검색 (Done > Backlog)
- [x] `_status_diagnose()`: git 기반 phase done 안내 추가

### Phase 컨텍스트
- **Phase**: `phase-10` (sdd 상태 진단 신뢰성 강화)
- **본 SPEC 의 역할**: phase 완료 시점 판단과 NEXT 안내의 마지막 정확도 개선 (phase-10 최종 spec)

## 🎯 Key Review Points

1. **`_check_phase_all_merged` awk 전환**: `$0 ~ /\| Backlog \|/` → `$5` 필드 직접 비교. `-F'|'`에서 `$0`의 `|`가 제거되는 문제 해결.
2. **Done 우선 로직**: `compute_next_spec`에서 Done spec이 Backlog보다 우선. archive만 하면 되므로 빨리 처리 가능.
3. **git 교차 확인**: `_check_phase_all_merged`와 `_status_diagnose` 양쪽에서 phase.md non-Merged + git 모두 머지 → 적절한 안내.

## 🧪 Verification

```bash
bash tests/test-sdd-phase-done-accuracy.sh
```

- ✅ Check 1: Done 잔류 → "모든 Merged" 미출력
- ✅ Check 2: 모든 Merged → "모든 Merged" 출력
- ✅ Check 3: Done + Backlog → NEXT = Done spec
- ✅ Check 4: git 모두 머지 + Done 잔류 → phase done 안내
- ✅ 전체 회귀 17개 테스트 PASS

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-phase-done-accuracy.sh`: phase 완료 판단 테스트 (4 시나리오)

### 🛠 Modified Files
- `sources/bin/sdd` (+80, -9): `_check_phase_all_merged`, `compute_next_spec`, `_status_diagnose` 수정
- `.harness-kit/bin/sdd` (+80, -9): 도그푸딩 동기화

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-10.md`
- Walkthrough: `specs/spec-10-04-phase-done-accuracy/walkthrough.md`
