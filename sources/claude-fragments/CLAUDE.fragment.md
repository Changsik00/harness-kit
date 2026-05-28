## 에이전트 운영 규약 (harness-kit)

이 프로젝트는 harness-kit 의 거버넌스를 따릅니다.
SDD 작업 시작 시 `/hk-align` 슬래시 커맨드를 호출하면 전체 거버넌스가 로드됩니다.

**핵심 규칙 요약**:
- Plan Accept 전에는 PLANNING 모드 (코드 편집 금지)
- One Task = One Commit
- Phase ID: `phase-{N}` (예: `phase-01`) — 디렉토리는 `backlog/phase-{N}/`
- Spec ID:  `spec-{phaseN}-{seq}` (예: `spec-01-01`) — 디렉토리는 `specs/spec-{phaseN}-{seq}-{slug}/`
- Branch: `spec-{phaseN}-{seq}-{slug}` (브랜치 = spec 디렉토리 이름, `feature/` prefix 없음)
- Commit subject: `<type>(spec-{phaseN}-{seq}): <설명>` (모두 소문자)
- 모든 산출물은 한국어
- main 브랜치 직접 작업 금지

자세한 내용은 `.harness-kit/agent/constitution.md` 와 `.harness-kit/agent/agent.md` 참조.

## 검증된 패턴 & 안티패턴 (빠른 참조)

> 상세 내용 및 출처 → `docs/wiki/patterns.md` (SoT)

**❌ 안티패턴 (피할 것):**
- **ceremony-over-work**: 1-2 commit 작업에 full SDD ceremony 금지. → FF (사용자 명시 승인) 또는 spec-x demote.
- **silent-inter-spec-drift**: 다음 spec 시작 전 직전 spec 실제 변경 영향 검토 의무. phase plan은 draft — 재검증 필수 (ADR-002).

**✅ 굿 패턴:**
- **bundle-before-spec-x**: 같은 테마 소규모 항목 3개+ → spec-x 여러 개 대신 하나로 묶기. phase 응집도 + ceremony 절감.
- **phase-FF**: 1-2 commit, 단일 파일, 가역적 변경 → spec 없이 phase base 브랜치 직접 커밋 (사용자 명시 승인 필요).
