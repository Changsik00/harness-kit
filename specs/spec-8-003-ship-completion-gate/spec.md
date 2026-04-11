# spec-8-003: 완료 흐름 강제 (hk-ship 재설계)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-8-003` |
| **Phase** | `phase-8` |
| **Branch** | `spec-8-003-ship-completion-gate` |
| **Base** | `phase-8-work-model` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd archive` 는 walkthrough/pr_description을 commit으로 묶는다. hk-ship은 이를 Step 1 (`--check`)과 Step 3 (실제 archive)으로 나누어 사용한다. 그러나:

- `sdd archive` 성공 후 phase.md의 spec 상태가 자동으로 `Merged`로 바뀌지 않는다 — 수동 갱신에 의존.
- 모든 spec이 Merged 되어도 `sdd phase done` 을 수동으로 호출해야 한다 — 유도 없음.
- spec-x 완료 시 queue.md 완료 섹션 갱신이 hk-ship 절차에 포함되지 않는다.

### 문제점

- backlog stale의 근본 원인: spec merge 후 phase.md 상태 갱신을 수동으로 해야 해서 자주 잊혀짐
- phase 완료 타이밍을 놓침: 모든 spec이 Merged인데도 phase done을 안 한 채 방치됨
- spec-x 완료 흐름 미표준화: queue.md 완료 섹션 갱신이 agent 재량에 맡겨짐

### 해결 방안 (요약)

`sdd archive` 가 commit 후 phase.md spec 상태를 자동 `Merged`로 갱신한다. 갱신 후 해당 phase의 모든 spec이 Merged이면 `phase done` 유도 메시지를 출력한다. hk-ship Step 6에 spec-x용 queue.md 완료 갱신 단계를 추가한다.

## 📊 개념도

```
sdd archive (기존)
  → walkthrough/pr_description commit

sdd archive (신규)
  → walkthrough/pr_description commit
  → phase.md spec 상태 → Merged 자동 갱신  ← NEW
  → 모든 spec Merged? → phase done 유도    ← NEW

hk-ship Step 6 (spec-x 한정)              ← NEW
  → queue.md 완료 섹션에 spec-x 항목 이동
```

## 🎯 요구사항

### Functional Requirements

1. **`sdd archive` — phase.md spec 상태 자동 Merged 갱신**
   - archive commit 완료 후, active phase의 `phase.md` spec 표에서 현재 spec 행의 상태를 `In Progress` → `Merged`로 교체
   - phase base branch 모드 여부와 관계없이 동작

2. **`sdd archive` — 모든 spec Merged 시 phase done 유도**
   - spec 상태 갱신 후 phase.md spec 표를 스캔
   - `Backlog` 또는 `In Progress` 상태 행이 없으면 다음 메시지 출력:
     ```
     🎉 모든 Spec이 Merged 상태입니다.
        sdd phase done 을 실행하여 phase를 완료하세요.
     ```
   - 자동 실행하지 않음 — 사용자가 직접 `sdd phase done` 호출

3. **`hk-ship` Step 6 — spec-x 완료 시 queue.md 갱신**
   - spec-x (`spec-x-{slug}`) 인 경우 hk-ship Step 6에 queue.md 완료 섹션 갱신 단계 추가:
     - queue.md `specx` 섹션에서 해당 항목 제거
     - queue.md `done` 섹션에 항목 추가

### Non-Functional Requirements

1. phase.md 파일이 없거나 spec 행을 찾지 못하면 warn 출력 후 계속 진행 (archive 실패로 이어지지 않음)
2. spec-x가 아닌 일반 spec의 hk-ship에는 Step 6 변경 없음 (하위 호환)

## 🚫 Out of Scope

- hk-ship에서 `sdd archive` 미실행 시 hook 차단 (→ 이미 Step 1 `--check`로 커버됨)
- `sdd phase done` 자동 실행 (유도 메시지만, 실행은 사용자)
- phase.md 외 다른 파일의 자동 갱신

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-8-003-ship-completion-gate` 브랜치 push 완료 (→ `phase-8-work-model`)
- [ ] 사용자 검토 요청 알림 완료
