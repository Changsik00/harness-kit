# Walkthrough: spec-21-06

> 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| check-scope.sh 스코프 소스 | plan.md 유지 / spec.md 변경 | spec.md 변경 | plan.md가 사라지므로 Proposed Changes 섹션이 spec.md 하단으로 이동 |
| plan_accept 검증 대상 | plan+task → spec+task | spec+task | plan.md 없어지므로 spec.md 내용 확인으로 대체 |
| spec-21-06 spec.md 형식 | 구 형식(3파일) / 신 형식(2파일) | 신 형식 선행 적용 | 이 spec 자체가 첫 dogfooding 사례 — plan.md 없이 작성 |

## 💬 사용자 협의

- **주제**: plan.md 제거 범위 — bypass 모드 포함 여부
  - **합의**: spec+plan 통합은 mode-independent 영구 규칙 변경. bypass 모드 추가는 Claude Code permission layer 문제이므로 harness-kit 범위 밖. spec-21-06은 문서 구조만 담당.

- **주제**: phase-21 목표 불일치 ("Turbo 모드 추가" vs 실제 작업)
  - **합의**: phase-21 목표를 "Ceremony 경량화 — Turbo 모드 + 문서 구조 개선"으로 업데이트.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/run.sh`
- **결과**: ✅ PASS 56, FAIL 7 (신규 FAIL 없음 — 7개 모두 pre-existing)

TDD Red 단계 확인: `test-turbo-hooks.sh` T04 → FAIL (check-scope가 plan.md 읽는데 fixture는 spec.md로 변경)  
TDD Green 단계 확인: check-scope.sh + sdd 수정 후 → T04 PASS 회복

### 수동 검증
1. **Action**: `sdd spec new` 안내 메시지 확인
   - **Result**: "plan.md 작성" 단계가 제거되고 "spec.md — 배경/요구사항/전략/Proposed Changes 작성"으로 교체됨

## 🔍 발견 사항

- `plan_accept()` 함수도 `plan task` 루프를 검사했음 — `spec task`로 변경 필요 (이번에 처리)
- `specx new` 출력 텍스트(line 2026)도 plan.md 참조 있었음 — 이번에 처리
- test-wiki-structure 가 pre-existing 4건 FAIL 중이었음 (spec-19 walkthrough 파일 archive에 있음) — 이번 spec 범위 밖
