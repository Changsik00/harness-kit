# Walkthrough: spec-20-02

> agent.md §6.8 Director Mode Protocol 추가 — 디렉터 모드의 *행동 규약*을 명문화. spec-20-01 도그푸딩 발견을 직접 되먹임한 spec.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 단어 예산 | §6.8 ≤300w + 나중 prune / 먼저 §6.6·6.7 prune | **≤300w 유지 + prune 보류** | 합계 7507/8000 (여유 493w). §6.8 실측 172w — 여유 안. prune 은 별도 Icebox |
| 검증 불변식 위치 | ADR-006 흡수 / ADR-007 신규 | **ADR-006 흡수** (proposed→accepted) | 본 spec 이 ADR-006 의 운영 산출물. 결정 분절 회피 |
| §6.8 규칙 수 | 통합 축소 / 6개 유지 | **6개 유지(간결)** | 172w 로 예산 내 — 개념 통합 불필요 |

### ADR 승격 가이드

- [x] ADR 승격 대상 있음 → `docs/decisions/ADR-006-director-mode.md` **accepted** 로 전환 + `director-verification-invariant`(transcript 전문 재흡수 금지) 흡수.
- [ ] 없음

## 💬 사용자 협의

- **주제**: spec-20-01 발견을 다음 spec 으로 되먹임 (§11.3 inter-spec re-validation)
  - **합의**: 발견1(검증=행동/증류)을 §6.8 규칙 4 로, 발견2(워커 커밋 범위)를 T1 "기획 산출물 커밋"으로 반영하고 진행.

## 🧪 검증 결과

### 단위 테스트
- **명령**: `bash tests/test-director-protocol.sh` · `test-governance-dedup.sh` · `test-director-mode.sh`
- **결과**: ✅ 7/7 · 8/8 · 10/10 PASS
- **로그 요약**:
```text
✅ ALL 7 CHECKS PASSED   (director-protocol)
✅ ALL 8 CHECKS PASSED   (governance-dedup — 단어예산 + 미러 parity)
```

### 수동 검증
1. **Action**: `grep "6.8 Director Mode Protocol"` + `diff sources↔.harness-kit agent.md`
   - **Result**: §6.8 존재(L288), 미러 동일, ADR-006 `status: accepted`. 합계 7507/8000w, §6.8 172w.

## 🔍 발견 사항

- **발견2 해소 확인**: spec-20-01 에서 워커가 spec/plan 을 안 커밋한 갭을, 이번엔 T1("기획 산출물 커밋")을 워커 브리핑 범위에 명시 → 워커가 spec/plan/task 를 빠짐없이 커밋. inter-spec re-validation 이 실제로 품질을 끌어올림.
- **불변식 자기적용**: 디렉터(나)의 검수를 *전문 재흡수 없이* 테스트 재실행 + 타깃 grep 으로 수행 — 방금 §6.8 규칙 4 로 박은 불변식을 같은 턴에 실천. context 보존이 검수 단계에서도 유지됨.
- **거버넌스 단어 예산 압박**은 누적된다 — spec-20-03/04 도 agent.md 절을 건드린다. §13 Rule Prune 을 phase-20 후반 또는 별도 spec-x 로 당길 필요 (Icebox 기존 항목과 연계).

## 🚧 이월 항목

- spec-20-03(ceremony 분업) ~ 20-06(review 패널) — phase.md 참조. 단어 예산 prune 은 누적 압박이므로 20-03 착수 시 §11.3 재평가.

## 🔗 관련 문서

- 관련 ADR: [[ADR-005]], [[ADR-006]] (본 spec 으로 accepted)
- 관련 wiki: [[wiki/patterns]] (dual-binary-dogfood-sync)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Director(Opus) + dennis, 구현 Sonnet 워커 |
| **작성 기간** | 2026-06-03 ~ 2026-06-04 |
| **최종 commit** | (ship 직전) |
