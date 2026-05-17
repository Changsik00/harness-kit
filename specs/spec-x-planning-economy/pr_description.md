# feat(spec-x-planning-economy): Planning Economy & Inter-Spec Re-Validation

> ★ **PR Target**: `main` (spec-x — phase 없음)

## 📋 Summary

### 배경 및 목적

사용자 피드백 — "커밋 한두개 하는데 sdd 로 진행되어서 보니.. phase 에서 미리 계획 해 놔서 그런거였어. 다음 sdd 가 이전에 바뀐거에 의해서 검증이 되어야 하는데 그런거 없더라고. 너무 작은 단위로 pr 을 요청받고 하니 토큰 소모가 더 컸어. sdd 방식이 토큰소모가 크거든."

두 개의 빈 곳 식별:
1. **SDD 의 최소 경제 단위 미정의** — ceremony 고정비 (토큰 6-8천 + 사용자 시간) 가 작업 (1-2 commit) 보다 큰 경우 가이드 없음
2. **Inter-spec validation 부재** — phase.md spec 표가 *contract* 처럼 굳어, 직전 spec 변경으로 가정 깨졌는지 점검 단계 없음

직접 증거 (phase-17): spec-17-03 가 cache 분리 시 `install.sh:515-516` / `sources/commands/hk-update.md:108` 누수 *미발견* → spec-17-05 sweep 으로 뒤늦게 처리.

### 주요 변경 사항

- [x] **`sources/governance/agent.md` §11 신설** (영어, 5 subsection):
  - §11.1 Ceremony Cost — 토큰 고정비 인식
  - §11.2 Scope Economy Thresholds — FF / spec-x / spec / bundle 4 임계 표
  - §11.3 Inter-Spec Re-Validation — 매 spec 시작 시 4 항목 평가 의무
  - §11.4 Re-Adjustment Options — phase 안 drop / bundle / phase FF / 계속 4 옵션 (spec-x demote 회피)
  - §11.5 Tool Support — `sdd spec new` pre-flight 출력 설명
- [x] **`sources/bin/sdd` `_pre_spec_validation()` 신설 + `spec_new` 호출**:
  - phase 활성 + 직전 merged spec 존재 시 *주의 환기* 3 블록 출력 (gate 아님 — 비파괴)
  - 직전 walkthrough 발견/이월 / 잔여 spec 표 / 4 질문 재검증 안내
- [x] **`.harness-kit/agent/agent.md`, `.harness-kit/bin/sdd`** install 미러 sync
- [x] **`docs/decisions/ADR-002-planning-economy.md`** 신규 (type: invariant):
  - ADR-001 (knowledge types) 다음 *두 번째 ADR* — ADR 메커니즘 자기 강화 검증
  - 3 invariant 박음 (mode demote 의무 / phase plan = draft / bundle 우선)
  - phase-17 회고 증거 (spec-17-03 누수 미발견) 인용

### Mode

- **spec-x** (Mode B, phase 없음) — 본 spec 자체가 §11.2 의 *6+ task / cross-file invariant* 임계에 해당하여 spec 가치 (governance + CLI + ADR 묶음)

## 🎯 Key Review Points

1. **§planning-economy 의 영어 + ADR-002 의 한국어 혼합** — governance 영어 원칙 + ADR 한국어 일관 (ADR-001 패턴). 의도된 분리.
2. **pre-flight 가 gate 아닌 *주의 환기*** — 비파괴 변경. user 가 무시하면 기존 동작. 강제는 인지 부하 + cancel 부담 우려로 회피.
3. **phase 컨텍스트 spec-x demote 회피 원칙** — 응집도 + ceremony 절감. spec-x demote 는 *phase 가 끝났는데 잔재* 일 때만.
4. **ADR 메커니즘 두 번째 사용 사례** — ADR-001 (knowledge types) 후 첫 *실제 활용*. ADR 자산이 self-reinforcing 한지 검증.
5. **ADR-002 stale 경로 fix 도중 발견** — spec-17-04 W4 의 템플릿 Note 블록 (`예: src/foo.ts`) 자체가 stale 검사 trigger. 본 spec 의 walkthrough 에 *이월 항목* 으로 기록. 별 spec 으로 fix 예정.
6. **회귀 0** — marker-idempotent / drift-stale-adr / phase16-integration / phase17-integration 4 종 PASS + drift 깔끔.

## 🧪 Verification

### 단위 + 회귀

```bash
# Governance
grep -c "Planning Economy" sources/governance/agent.md .harness-kit/agent/agent.md   # 각 1
diff sources/governance/agent.md .harness-kit/agent/agent.md                          # 0 (sync)

# sdd
grep -c "_pre_spec_validation" sources/bin/sdd .harness-kit/bin/sdd                   # 각 2
diff sources/bin/sdd .harness-kit/bin/sdd                                             # 0 (sync)
bash -n sources/bin/sdd && bash -n .harness-kit/bin/sdd                               # syntax ok

# ADR-002
grep -q "^id: ADR-002" docs/decisions/ADR-002-planning-economy.md                     # PASS
grep -q "^type: invariant" docs/decisions/ADR-002-planning-economy.md                 # PASS

# 회귀 4 종
bash tests/test-sdd-marker-idempotent.sh   # 3/3 PASS
bash tests/test-drift-stale-adr.sh          # 3/3 PASS (ADR-002 포함 clean state)
bash tests/test-phase16-integration.sh      # 3/3 PASS
bash tests/test-phase17-integration.sh      # 3 passed / 1 skipped
```

### 비파괴 검증
- main 또는 spec-x 상태 (phase 없음) 에서 `_pre_spec_validation` 호출 시 early-exit (출력 없음). 기존 `spec_new` 동작 무영향.
- 실 시연은 본 PR 머지 후 *다음 phase 의 첫 spec 진행 시점* 에 자연 발현.

## 📦 Files

### sources/governance/
- `sources/governance/agent.md` — §11 Planning Economy 신설 (영어, 5 subsection)

### sources/bin/
- `sources/bin/sdd` — `_pre_spec_validation()` helper + `spec_new` 호출

### .harness-kit/ (install mirrors)
- `.harness-kit/agent/agent.md` (sync §11)
- `.harness-kit/bin/sdd` (sync `_pre_spec_validation`)

### docs/decisions/
- `docs/decisions/ADR-002-planning-economy.md` (신규 — type: invariant)

### specs/
- `specs/spec-x-planning-economy/{spec,plan,task,walkthrough,pr_description}.md`

## 🔁 Rollback

본 PR revert. 3 묶음 모두 *추가* — 기존 동작 변경 0.
- `_pre_spec_validation` 가 *출력만* 이라 revert 시 자동 사라짐.
- ADR-002 는 status `accepted` → `deprecated` 또는 revert 로 처리.
- 본 PR 머지 후 새 spec 진행 시 §11 적용 — 즉시 효력.

## 🔗 Related

- **출처**: 사용자 피드백 (planning 가이드 부재) + phase-17 회고 증거 (spec-17-03 → spec-17-05 sweep 패턴)
- **선행 ADR**: ADR-001 (#119, knowledge types) — 본 ADR-002 가 두 번째 ADR
- **선행 phase**: phase-17 (#127 — 운영 성숙도)
- **메모리**: `feedback-sdd-economy`
- **이월 항목**: spec-17-04 W4 의 ADR 템플릿 Note 블록 stale 경로 fix (별 spec)
