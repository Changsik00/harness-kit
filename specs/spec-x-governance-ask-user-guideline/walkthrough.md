# Walkthrough: spec-x-governance-ask-user-guideline

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 수정 강도 | A) MUST 강제 / B) SHOULD 권장 | B | 환경(CLI/IDE/Web)마다 AskUserQuestion 렌더링이 다를 수 있어 강제 불가 |
| 기존 텍스트 포맷 처리 | A) 삭제 / B) fallback으로 유지 | B | constitution §5.2·§5.7 하위 호환성 유지, 거버넌스 breaking change 없음 |
| 수정 범위 | A) §5.2·§5.7 포맷 직접 교체 / B) 가이드라인 섹션만 추가 | B | 사용자 선택 — 기존 포맷 유지하면서 툴 사용 권장 수준으로 진행 |
| 위치 | §8 커뮤니케이션 규칙 내 §8.4 신설 | §8.4 | 사용자 입력/출력 관련 규칙이 §8에 집중되어 응집성 높음 |

## 💬 사용자 협의

- **주제**: AskUserQuestion UX 불일치 원인 분석
  - **사용자 관찰**: 동일한 거버넌스 흐름에서도 텍스트 목록(1/2), [Y/n], 화살표 선택 UI가 혼재
  - **원인**: 거버넌스가 `AskUserQuestion` 툴을 인지하지 않고 텍스트 포맷만 명시한 채 작성됨
- **주제**: 수정 범위
  - **사용자 의견**: 가이드라인만 추가 (기존 포맷 변경 없이)
  - **합의**: `agent.md §8.4` 신설, SHOULD 수준 권장, 기존 텍스트 fallback 유지

## 🧪 검증 결과

### 1. 자동화 테스트

#### 거버넌스 중복/동기화 검사
- **명령**: `bash tests/test-governance-dedup.sh`
- **결과**: ✅ ALL 8 CHECKS PASSED

```text
▶ Check 1: 중복 문장 검출 — ✅ 0건
▶ Check 2: sources ↔ .harness-kit 동기화 — ✅ agent.md OK
▶ Check 3: 토큰 카운트 — ✅ 5400w (상한 6000w 이하)
▶ Check 4: Dead letter 제거 — ✅
▶ Check 5: 섹션 번호 중복 — ✅
▶ Check 6: sdd 경로 — ✅
```

### 2. 수동 검증

1. **Action**: `sources/governance/agent.md` §8.4 섹션 존재 확인
   - **Result**: §8.3 이후, §9 이전에 정상 삽입됨

2. **Action**: `.harness-kit/agent/agent.md` §8.4 동일 내용 확인
   - **Result**: 동기화 완료, 두 파일 내용 동일

## 🔍 발견 사항

- 이 가이드라인이 정착되면 주요 결정 포인트에서 `AskUserQuestion` 툴 사용 빈도가 높아질 것. 실제 사용 패턴을 보며 향후 §5.2·§5.7 포맷 자체를 툴 기반으로 교체하는 후속 spec-x 가능.
- `AskUserQuestion` 옵션 수 제한(2~4개)을 가이드라인에 명시해 Agent가 지나치게 많은 선택지를 제공하는 것을 방지.

## 🚧 이월 항목

- §5.2 Plan Accept/Critique, §5.7 PR 확인 포맷을 `AskUserQuestion` 기반으로 교체 → 향후 필요시 spec-x

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + changsik |
| **작성 기간** | 2026-05-12 ~ 2026-05-12 |
| **최종 commit** | `8de6a50` |
