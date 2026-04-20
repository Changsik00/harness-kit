# Walkthrough: spec-x-tool-comparison

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 리서치 범위 | 모든 CI/CD 툴 전수 vs 대표 툴 선별 | 대표 툴 7개 선별 | 컨텍스트 비용 절약, 핵심 포지셔닝 파악에 충분 |
| 워크 모드 | SDD-P vs SDD-x | SDD-x | 리서치 단발, 결과 보기 전 Phase 열면 방향 틀릴 위험 |

## 💬 사용자 협의

- **주제**: 다음 Phase 방향 — 프로젝트 자동 감지 vs 타 툴 비교 우선
  - **사용자 의견**: 두 방향 모두 가능하나 에이전트 추천 요청
  - **합의**: 비교 리서치 먼저, 결과로 다음 Phase 결정

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `for t in tests/test-*.sh; do bash "$t"; done`
- **결과**: ✅ 전체 18개 테스트 PASS (FAIL=0)

### 2. 수동 검증

1. **Action**: 비교 매트릭스 — 8개 기준 × 8개 툴
   - **Result**: harness-kit이 SDD 워크플로/상태 추적/AI 거버넌스 영역에서 유일한 툴임 확인
2. **Action**: Gap 분석 — 5개 Gap 도출
   - **Result**: Gap 4(staged linting), Gap 3(멀티포맷 export)이 규모 대비 가치 최상
3. **Action**: 다음 Phase 후보 우선순위 도출
   - **Result**: 5개 후보, 우선순위 1·2가 소규모로 즉시 착수 가능

## 🔍 발견 사항

- harness-kit의 포지셔닝이 명확히 차별화됨: AI 에이전트 행동 제약 레이어로 경쟁 툴 없음
- Cursor Rules / Copilot Instructions와 대립 구도가 아닌 SSOT(단일 진실 원천) 전략이 유효
- Gap 3(멀티포맷 export)은 install.sh에 옵션 추가만으로 구현 가능한 수준

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + changsik |
| **작성 기간** | 2026-04-20 |
| **최종 commit** | `6d4f10a` |
