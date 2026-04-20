# docs(spec-x-tool-comparison): harness-kit 유사 툴 비교 리서치 및 다음 Phase 방향 도출

## 📋 Summary

### 배경 및 목적
phase-11까지 완성 후 다음 Phase를 결정하기 위해, harness-kit과 유사 툴(Husky, Lefthook, pre-commit, lint-staged, commitlint, Cursor Rules, Copilot Instructions)을 8개 기준으로 비교 분석.

### 주요 변경 사항
- [x] 7개 툴 × 8개 기준 비교 매트릭스 작성
- [x] harness-kit Gap 5개 식별 (staged linting, 멀티포맷 export, 프로젝트 타입 감지, 훅 레지스트리, 병렬 훅 실행)
- [x] harness-kit 고유 강점 5개 정리 (Plan-Accept Gate, SDD 라이프사이클, AI 거버넌스 문서, 상태 추적, 통합 루프)
- [x] 다음 Phase 후보 5개 우선순위 도출

### Phase 컨텍스트
- **Phase**: 없음 (Solo Spec)
- **역할**: 다음 Phase의 방향을 결정하는 리서치 인풋

## 🎯 Key Review Points

1. **포지셔닝 확인**: harness-kit이 "AI 에이전트 행동 제약 거버넌스 레이어"라는 독자적 영역 점유 → 경쟁 툴 없음
2. **다음 Phase 우선순위 1·2**: staged linting 통합(소규모) + AI 인스트럭션 멀티포맷 export(소규모) — 즉시 착수 가능

## 🧪 Verification

### 자동 테스트
```bash
for t in tests/test-*.sh; do bash "$t" 2>&1 | tail -1; done
```
**결과**: 전체 18개 테스트 PASS (FAIL=0)

## 📦 Files Changed

### 🆕 New Files
- `specs/spec-x-tool-comparison/spec.md`: 리서치 스펙 정의
- `specs/spec-x-tool-comparison/plan.md`: 실행 계획
- `specs/spec-x-tool-comparison/task.md`: 작업 목록
- `specs/spec-x-tool-comparison/report.md`: 비교 리서치 결과물 (핵심 산출물)
- `specs/spec-x-tool-comparison/walkthrough.md`: 작업 기록
- `specs/spec-x-tool-comparison/pr_description.md`: 이 파일

**Total**: 6 files (신규)

## ✅ Definition of Done

- [x] report.md 작성 완료 (비교 매트릭스 + Gap 분석 + 다음 Phase 후보)
- [x] 전체 테스트 PASS
- [x] walkthrough.md ship commit 완료
- [x] pr_description.md ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- 리서치 결과: `specs/spec-x-tool-comparison/report.md`
- Walkthrough: `specs/spec-x-tool-comparison/walkthrough.md`
