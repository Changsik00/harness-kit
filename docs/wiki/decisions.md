---
kind: synthesis
sources:
  - docs/decisions/ADR-001-knowledge-types.md
  - docs/decisions/ADR-002-planning-economy.md
  - docs/rca/RCA-001-sdd-ship-spec-add-missing.md
linked:
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
  - "[[ADR-002]]"
  - "[[RCA-001]]"
updated: 2026-05-27
---

# 핵심 결정 증류

> raw ADR/RCA에서 추출한 의사결정 요약. 세부 근거는 원본 참조.

---

## [[ADR-001]] — Knowledge Type Vocabulary (2026-05-16)

**결정**: ADR/RCA frontmatter의 `type:` 슬롯에 5어휘 closure 도입.

| type | 의미 |
|---|---|
| `decision` | 비자명한 설계 선택 |
| `invariant` | 시스템이 보존해야 할 속성 |
| `failure-pattern` | 재발하는 실패 (재현+예방) |
| `convention` | 일관성을 위한 명명/구조 규칙 |
| `tradeoff` | 기각된 안에 명시적 비용이 있는 선택 |

**왜**: 결정과 실패가 grep 가능한 자산으로 누적되지 않던 문제. `grep -rh "^type:" docs/rca docs/decisions`로 type별 추출 가능.

**주의**: closure 변경 자체가 ADR 대상. vocabulary 밖 값은 거버넌스 위반.

---

## [[ADR-002]] — Planning Economy & Inter-Spec Re-Validation (2026-05-17)

**결정**: SDD ceremony 비용을 인식하고 3개 invariant 박음.

**Invariant 1 — ceremony 비용 의식**:
- 1-2 task + 단일 파일 + 가역적 → **FF** (사용자 명시 승인 필요)
- 3-5 task + 단일 영역 → **spec-x** 또는 **bundle/phase FF**
- 6+ task / cross-file / 통합 테스트 → **spec**

**Invariant 2 — phase plan은 draft, 매 spec 시작 시 재검증**:
직전 merged spec의 walkthrough(이월/발견) + `git diff --stat` 점검 후 잔여 spec 재평가.

**Invariant 3 — phase 내에서는 bundle/phase FF 우선 (spec-x demote 보다)**:
spec-x demote는 phase가 끝난 후 잔재일 때만.

**왜**: phase-17에서 spec-17-03이 install.sh 누수를 미발견 → spec-17-05 sweep으로 뒤늦게 처리. pre-spec 재검증으로 사전 차단 가능했음.

---

## [[RCA-001]] — sdd ship이 spec/plan/task를 git add 안 함 (2026-05-15)

**증상**: `sdd ship` 후 spec.md/plan.md/task.md가 untracked으로 남아 수동 add 필요. 2회 연속 발생.

**근인**: sdd ship의 git add 매트릭스가 walkthrough/pr_description만 포함. spec-x 운영에서 pre-flight commit이 없는 것이 일반적이라는 전제 누락.

**교훈**: "암묵적 전제"가 가장 위험한 버그 경로. sdd ship의 add 매트릭스는 spec 디렉토리 전체를 포함해야 함.

**Invariant**: `sdd ship` 후 해당 spec 디렉토리 내 신규 산출물 untracked이 남으면 안 됨.
