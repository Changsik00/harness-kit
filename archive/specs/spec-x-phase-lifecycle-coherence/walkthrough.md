# Walkthrough: spec-x-phase-lifecycle-coherence

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Phase living doc 형태 | 별도 파일 (phase-walkthrough.md) / phase.md 안에 섹션 / PR body 만 | phase.md 안에 `📌 결정 기록 (Review)` 섹션 | YAGNI — 새 파일 신설 X. phase.md 가 이미 phase 의 중심 문서이므로 거기 누적이 자연스러움. Spec walkthrough.md 와 의미적 대칭. |
| `sdd phase done` 실행 시점 분기 | 항상 PR 후 / 항상 즉시 / mode 분기 | mode 분기 (base→PR 후, non-base→즉시) | base 모드는 phase PR 이 실제 머지 boundary 라 spec 패턴과 동일 처리. non-base 는 spec PR 들이 이미 main 에 들어갔으므로 즉시 bookkeeping 이 자연스러움. |
| ADR escalation 기준 | 별도 §13 신설 / 기존 §6.3 위치 정의에 한 줄 추가 | §6.3 한 줄 추가 | 거버넌스 비대화 방지 + 기존 정의 위치에서 자연스럽게 확장. |
| bullet 7 escalation 의 ADR/plan 분기 추가 | bullet 그대로 / 분기 추가 / 별도 섹션 | bullet 안에 압축 분기 표기 | review 시 갱신 대상 결정에 짧은 가이드 충분. 별도 섹션 만들면 bloat. |
| 거버넌스 word 한도 5000 초과 (5128w) | 한도 상향 / 더 압축 / scope 축소 | 추가 압축 → 정확히 5000w | 사용자가 "더 압축 시도" 선택. 압축 시도 결과 28w 초과까지 도달, 마지막에 §6.3.1 의 closing rationale 한 문장 (의미 중복) 제거 + §6.3.2 본문 한 번 더 squeeze 로 정확히 5000w 달성. |

## 💬 사용자 협의

- **주제**: PR 리뷰 중 핑퐁이 plan 을 뒤엎거나 ADR 가 만들어지는 시나리오에 대한 거버넌스 명시화
  - **사용자 의견**: "어찌저찌 ai agent 가 찾아다가 알려주는 느낌 — 거버넌스가 명시 가이드 하는지 의문"
  - **합의**: B (작은 보강) → 1차 FF commit 으로 §5.6 + §6.3 bullet 7 (Spec 레벨)
- **주제**: Phase Ship 후 PR 리뷰 핑퐁 / 컨텍스트 손실
  - **사용자 의견**: "phase pr 요청 후 새 세션 열면 다시 PR 만들겠다고 함" → 실제 실패 모드 보고
  - **합의**: 본 spec-x 로 Phase 레벨 lifecycle 일관성 회복. `sdd phase done` 시점 이동 + `phase.md` 의 review 섹션 + bullet 7 일반화 통합
- **주제**: hk-phase-review 회고 시점
  - **사용자 의견**: "현재 브랜치 최신이면 됨"
  - **합의**: 거버넌스 대상 아님 (도구 호출 시점은 사용자 판단)
- **주제**: 거버넌스 word 상한 충돌
  - **사용자 의견**: "상한 이상으로 더 압축 시도"
  - **합의**: 추가 압축으로 5000w 정확히 달성

## 🧪 검증 결과

### 단위 테스트
- `bash tests/test-governance-dedup.sh` → ✅ ALL 8 PASS (5000w 정확)
- `bash tests/test-two-tier-loading.sh` → ✅ ALL 7 PASS

### 수동 검증
1. **Action**: state.json `baseBranch` 검사로 mode 분기 의도 확인
   - **Result**: `state.baseBranch != null` ↔ `state.baseBranch == null` 명확 분기. 도그푸딩 가능.
2. **Action**: §6.3.2 가 §6.3.1 (Spec post-merge) 와 형식·의미 대칭인지 확인
   - **Result**: 둘 다 "사용자 머지 신호 → state 정리 → 다음 안내". Spec 은 sdd ship, Phase 는 sdd phase done. 패턴 일치.
3. **Action**: 거버넌스 word 카운트 압축
   - **Result**: 5128 → 5004 → 5000. §6.3.1 의 closing rationale 한 문장 제거 + §6.3.2 squeeze 로 한도 달성.

## 🔍 발견 사항

- **거버넌스 word 한도가 거의 가득 찬 상태에서 PR**: pre-branch 4989/5000 → 추가 가능 budget ~10w. 이런 상태에서 의미 있는 새 governance 추가는 항상 압축 vs 가독성 trade-off. 향후 governance 항목 추가 시 *기존 verbose section 정리* 도 함께 검토할 가치. 한도 자체를 5500 등으로 올리는 것은 사용자 보존 정책에 반함.
- **§6.3.1 closing rationale 문장이 의미 중복이었음**: "context continuity across PR boundaries — Agent always knows what's next" — 이미 step 1~4 절차에 내포. 압축 과정에서 발견하여 제거. 이게 28w 초과를 덮어줌.
- **§6.3.2 가 §6.3.1 와 형식적 대칭**: Phase post-merge 도 Spec 과 같은 패턴 (signal → state cleanup → next guidance). 통합 가능성도 있으나 trigger·도구가 달라 분리 유지가 명료.

## 🚧 이월 항목

- ε (`/hk-phase-ship` 도중 fail 처리 protocol) — 현재는 사용자 판단으로 OK, 데이터 더 모으면 거버넌스화.
- `sdd status` 의 open Phase PR 표시 — gh CLI 의존, 별개 spec-x 후보 (P3).

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 ~ 2026-05-10 |
| **최종 commit** | (Ship 후 갱신) |
