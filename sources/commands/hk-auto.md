---
description: Auto(자율·unattended) 모드 전환 — 현재 모드 확인 후 governed ↔ auto 토글
---

현재 모드를 확인하고 Auto 모드(phase 전체를 사람 없이 자율 수행)로 전환하거나 Governed 모드로 복귀합니다.

> Auto 는 turbo 의 *attended* 와 달리 **unattended** 입니다 — 결정 지점에서 멈추지 않고(기본값+로그), 안전은 정지규칙·사후 검증이 담당합니다 (ADR-009).

다음을 순서대로 실행하세요:

**Step 1 — 현재 모드 확인**

```bash
bash .harness-kit/bin/sdd mode status
```

**Step 2 — 모드 전환 안내**

현재 모드가 `auto` 가 아니면 (governed/turbo):
```bash
bash .harness-kit/bin/sdd mode auto
```
실행 후 사용자에게 알립니다:
> 🤖 Auto 모드 활성화 — phase 전체를 fire-and-forget 으로 자율 수행. 결정은 기본값+로그(논블로킹), `phase-ship` PR 에서 1회 일괄 검토.
> **안전 (사람 대신)**: ① 진짜 방향 모호 ② 비가역 행동(auto=실제 차단) ③ 반복 테스트 실패 — 이 세 정지규칙에서만 멈춥니다. 사후 검증(`post-commit-verify`·`check-test-trust` 검증 0단계)이 항상 작동.
> **고위험·비가역 변경**: `/hk-refute`(의도-앵커 적대적 반증, 검증 2단계) 권장.
> 결정 검토: `sdd decision list --phase`. 복귀: `sdd mode governed` 또는 `/hk-auto` 재호출.

현재 모드가 `auto` 이면:
```bash
bash .harness-kit/bin/sdd mode governed
```
실행 후 사용자에게 알립니다:
> 🔒 Governed 모드 복귀 — SDD 전체 절차(Plan Accept 게이트) 재적용.

**참고**
- Auto 는 *unattended* 자율 모드입니다 — "걸어두고 딴 일" 용. 사람이 붙어 빠르게 가려면 `/hk-turbo`(attended).
- ⚠️ auto 는 잘못된 기본값으로 *멀리* 진행할 위험이 있어, 안전이 정지규칙·사후 테스트 품질에 의존합니다. 아키텍처·교차 관심사 변경은 governed 를 권장합니다 (→ constitution §2.5, ADR-009).
