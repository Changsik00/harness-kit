# fix(spec-10-001): archive 상태 전이에 Done 매칭 추가

## 📋 Summary

### 배경 및 목적
`sdd archive`의 awk 패턴이 `| In Progress |`와 `| Active |`만 매칭하여, `| Done |` 상태의 spec이 `| Merged |`로 전환되지 않는 버그 수정. Phase-9에서 13개 spec 중 10개가 "Done"으로 잔류한 실제 사례 발생.

### 주요 변경 사항
- [x] awk 조건에 `|| /\| Done \|/` 추가 + `sub(/\| Done \|/, "| Merged |")` 추가
- [x] 상태 전이 모델 주석 문서화: `Backlog → Active → In Progress → Done → Merged`
- [x] Done → Merged 전환 테스트(Check 2b) 추가

### Phase 컨텍스트
- **Phase**: `phase-10` (sdd 상태 진단 신뢰성 강화)
- **본 SPEC 의 역할**: 상태 전이의 가장 기본적인 버그를 수정하여, 후속 spec(교차 검증, 완성도 검증)의 기반을 확보

## 🎯 Key Review Points

1. **awk 패턴 변경**: `sources/bin/sdd:688` — 기존 Active/In Progress 매칭에 Done 추가. 단순 OR 조건 확장.
2. **양쪽 sdd 동기화**: `sources/bin/sdd`와 `.harness-kit/bin/sdd` 동일 변경 적용 (도그푸딩 환경)

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-archive-completion.sh
```

**결과 요약**:
- ✅ Check 1: In Progress → Merged
- ✅ Check 2: Active → Merged
- ✅ Check 2b: Done → Merged (신규)
- ✅ Check 3~6: state 초기화, phase done 유도, NEXT 안내, specx done

## 📦 Files Changed

### 🛠 Modified Files
- `sources/bin/sdd` (+5, -1): awk 패턴에 Done 매칭 + 상태 전이 주석
- `.harness-kit/bin/sdd` (+5, -1): 동일 변경
- `tests/test-sdd-archive-completion.sh` (+30): Done → Merged 테스트 추가

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (7/7)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-10.md`
- Walkthrough: `specs/spec-10-001-archive-status-fix/walkthrough.md`
