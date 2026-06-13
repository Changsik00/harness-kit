---
description: Turbo 모드 전환 — 현재 모드 확인 후 governed ↔ turbo 토글
---

현재 모드를 확인하고 Turbo 모드로 전환하거나 Governed 모드로 복귀합니다.

다음을 순서대로 실행하세요:

**Step 1 — 현재 모드 확인**

```bash
bash .harness-kit/bin/sdd mode status
```

**Step 2 — 모드 전환 안내**

현재 모드가 `governed` 이면:
```bash
bash .harness-kit/bin/sdd mode turbo
```
실행 후 사용자에게 알립니다:
> ⚡ Turbo 모드 활성화 — Plan Accept 게이트 없음. 커밋마다 `post-commit-verify` 가 자동 실행됩니다.
> 세션 목표를 등록하려면: `sdd intent "<목표>" [--test <커맨드>]`
> 복귀하려면: `sdd mode governed` 또는 `/hk-turbo` 재호출.

현재 모드가 `turbo` 이면:
```bash
bash .harness-kit/bin/sdd mode governed
bash .harness-kit/bin/sdd intent clear
```
실행 후 사용자에게 알립니다:
> 🔒 Governed 모드 복귀 — SDD 전체 절차 재적용. Intent 삭제됨.

**참고**
- Turbo 모드는 빠른 탐색·수정·실험에만 사용합니다 (→ constitution §2.5 Mode D).
- 아키텍처 변경, 교차 관심사 리팩터, PR 리뷰 필요 작업은 Governed 모드를 사용합니다.
