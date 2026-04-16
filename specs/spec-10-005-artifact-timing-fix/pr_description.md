# fix(spec-10-005): 산출물 생성 시점 수정 + walkthrough 템플릿 개선

## 📋 Summary

### 배경 및 목적

`sdd spec new`가 walkthrough.md/pr_description.md를 미리 생성하여 Artifacts 체크에서 `Ship-ready`로 오판되었다. walkthrough 템플릿은 검증 결과 위주여서 작업 중 결정/협의 기록이 부족했다.

### 주요 변경 사항
- [x] `sdd spec new`에서 walkthrough/pr_description 생성 제외 (spec, plan, task만)
- [x] walkthrough 템플릿에 `📌 결정 기록` + `💬 사용자 협의` 섹션 추가
- [x] `🔍 발견 사항` Optional → 일반 섹션으로 승격

### Phase 컨텍스트
- **Phase**: `phase-10` (sdd 상태 진단 신뢰성 강화)
- **본 SPEC 의 역할**: Artifacts 단계 판단 정확도 확보 + walkthrough를 작업 컨텍스트 보존 도구로 강화

## 🎯 Key Review Points

1. **spec new for 루프 축소**: `spec plan task walkthrough pr_description` → `spec plan task`. `sdd spec show`의 for 루프는 존재하는 파일만 표시하므로 변경 불필요.
2. **walkthrough 새 섹션**: 결정 기록(테이블 형식)과 사용자 협의(주제-의견-합의 구조).

## 🧪 Verification

전체 회귀 17개 테스트 PASS (기존 이슈 2건 동일)

## 📦 Files Changed

### 🛠 Modified Files
- `sources/bin/sdd` (+2, -1): spec_new() for 루프에서 walkthrough/pr_description 제거
- `sources/templates/walkthrough.md` (+18, -12): 결정 기록 + 사용자 협의 섹션 추가
- `.harness-kit/bin/sdd` (+2, -1): 도그푸딩 동기화
- `.harness-kit/agent/templates/walkthrough.md` (+18, -12): 도그푸딩 동기화

**Total**: 4 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-10.md`
- Walkthrough: `specs/spec-10-005-artifact-timing-fix/walkthrough.md`
