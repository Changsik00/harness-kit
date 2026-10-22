## 에이전트 운영 규약 (harness-kit)

이 프로젝트는 harness-kit 거버넌스를 따릅니다. SDD 시작 시 `/hk-align` 으로 전체 로드.

**핵심 규칙 요약**:
- Plan Accept 전에는 PLANNING 모드 (코드 편집 금지)
- One Task = One Commit / main 직접 작업 금지 / 모든 산출물 한국어
- ID: Phase `phase-{N}`, Spec `spec-{phaseN}-{seq}-{slug}` (브랜치 = spec 디렉토리명, `feature/` prefix 없음)
- Commit subject: `<type>(spec-{phaseN}-{seq}): <설명>` (소문자)

상세: `.harness-kit/agent/constitution.md` · `agent.md`.

## 검증된 패턴 · wiki 질의

"왜 이렇게 결정했나"·유사 작업 여부·spec/plan 착수 전엔 `archive/` 를 뒤지기 전에 `docs/wiki/decisions.md`·`patterns.md` 를 먼저 읽는다 (규칙 → `docs/wiki/schema.md`).

- **right-size**: 1-2 commit 은 FF/phase-FF (ADR-004).
- **phase-FF**: 활성 phase 작은 항목 → spec 없이 직접 커밋.
- **bundle**: 같은 테마 소규모 3개+ 는 한 spec (억지 묶기 금지).
- **drift 재검증**: 다음 spec 전 직전 변경 영향 검토 (ADR-002).
