## 에이전트 운영 규약 (harness-kit)

이 프로젝트는 harness-kit 거버넌스를 따릅니다. SDD 시작 시 `/hk-align` 으로 전체 로드.

**핵심 규칙 요약**:
- Plan Accept 전에는 PLANNING 모드 (코드 편집 금지)
- One Task = One Commit / main 직접 작업 금지 / 모든 산출물 한국어
- ID: Phase `phase-{N}`, Spec `spec-{phaseN}-{seq}-{slug}` (브랜치 = spec 디렉토리명, `feature/` prefix 없음)
- Commit subject: `<type>(spec-{phaseN}-{seq}): <설명>` (소문자)

상세: `.harness-kit/agent/constitution.md` · `agent.md`.

## 검증된 패턴 (요약 — 상세·출처 → `docs/wiki/patterns.md`)

- **right-size**: 1-2 commit 은 FF/phase-FF, full ceremony 금지. phase 안이라고 무조건 spec 금지 (ADR-004).
- **phase-FF (1급)**: 활성 phase(base 브랜치) 작은 항목 → spec 없이 직접 커밋, phase-ship PR 에서 리뷰.
- **bundle**: 같은 테마 소규모 3개+ 는 한 spec 으로 — 단 FF 회피용 억지 묶기 금지.
- **drift 재검증**: phase plan 은 draft — 다음 spec 전 직전 변경 영향 검토 (ADR-002).

<!-- hk-extend:serena BEGIN -->
## 확장 우선 — serena (LSP 코드 인텔리전스, opt-in)

LSP 지원 언어에서 심볼 정의·참조·구현·rename 은 grep 스윕 대신 serena MCP 도구를 우선 사용한다. 조건부 — bash·단발 grep·산문은 기존 도구 (context-cost-first). 상세 → `.harness-kit/agent/agent.md` Extension-First.
<!-- hk-extend:serena END -->
