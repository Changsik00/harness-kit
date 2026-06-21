---
description: Phase 완료 — 성공 기준 검증 + 통합 테스트 + go/no-go 후 main PR 생성
---

Phase의 모든 Spec이 merge된 후 이 명령으로 Phase Ship 절차를 시작합니다.
**Phase PR은 Spec PR과 본질적으로 다릅니다** — "코드가 맞는가?"가 아닌 "이 기능이 main에 들어가도 되는가?"를 판단합니다.

## 1. Pre-check (전제 조건 확인)

phase.md의 spec 표를 확인합니다:

```bash
./.harness-kit/bin/sdd status --json
```

확인 항목:
- Active Phase가 존재하는지
- phase.md spec 표에서 `Backlog` 또는 `In Progress` 상태 행이 **없는지** (모든 Spec이 Merged)
- phase base branch 모드인 경우 해당 브랜치가 존재하는지

**미완 Spec이 있으면 중단** — 사용자에게 남은 Spec 목록을 보고하고 멈춥니다.

## 2. Success Criteria Verification (성공 기준 검증)

phase.md의 **성공 기준 (Success Criteria)** 섹션을 읽습니다.

각 기준에 대해:
1. 실제 동작을 확인 (명령 실행, 파일 확인, git log 확인 등)
2. **PASS / FAIL** 판단
3. 증거 수집 (명령 출력, 스크린샷, 파일 내용 등)

결과를 다음 형식으로 정리합니다:

```
📋 성공 기준 검증
  1. ✅ PASS: <기준 1> — <증거 요약>
  2. ✅ PASS: <기준 2> — <증거 요약>
  3. ❌ FAIL: <기준 3> — <실패 사유>
```

**FAIL 항목이 있으면** 사용자에게 보고 후 계속 진행 여부를 확인합니다 (자동 중단하지 않음 — 사용자 판단).

## 3. Integration Test Execution (통합 테스트 실행)

phase.md의 **통합 테스트 시나리오** 섹션을 읽습니다.

각 시나리오에 대해:
1. Given/When/Then 조건에 따라 실행
2. 결과 기록 (PASS/FAIL + 증거)

통합 테스트 스크립트가 정의된 경우:
```bash
bash tests/test-phase{N}-integration.sh
```

정의되지 않은 경우 수동 검증으로 대체하고 증거를 기록합니다.

결과를 다음 형식으로 정리합니다:

```
🧪 통합 테스트 결과
  시나리오 1: ✅ PASS — <결과 요약>
  시나리오 2: ✅ PASS — <결과 요약>
```

## 4. 자율 결정 로그 rollup (auto 검토)

auto 모드(ADR-009)는 결정을 *멈추지 않고* 기본값+로그로 진행하므로, 그 결정들을 phase-ship 한 곳에서 일괄 검토합니다. phase 전체 spec 의 결정 로그를 모읍니다:

```bash
./.harness-kit/bin/sdd decision list --phase
```

- 출력된 각 결정(이슈·결정·근거 + 출처 spec)을 검토 — auto 가 내린 기본값 중 **재검토/되돌릴 것이 없는지** 확인.
- 되돌릴 결정이 있으면 Go/No-Go 전에 사용자에게 보고.
- `(결정 로그 없음)` 이면 auto 자율 결정이 없었다는 뜻 — 그대로 진행.
- **이 rollup 출력은 아래 Phase PR 본문의 "자율 결정 로그" 섹션에 그대로 포함**합니다 (Step 5a).

## 5. Go/No-Go Report (사용자 승인)

Step 2, 3, 4의 결과를 종합하여 사용자에게 보고합니다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Phase Ship Report: <phase-id>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 성공 기준: N/M PASS
🧪 통합 테스트: N/M PASS
📦 Spec 완료: N/N Merged
🤖 자율 결정: K건 (rollup 검토 완료 — 되돌릴 항목 없음 / [있으면 표시])

[FAIL 항목이 있으면 여기에 상세 표시]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
main 으로 merge 해도 될까요? [Y/n]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**에이전트는 반드시 사용자의 명시적 승인을 대기합니다.** 자동 진행 금지.

## 6. Phase 마무리 (승인 후) — mode 분기

`state.json` 의 `baseBranch` 필드로 mode 를 판별합니다.

```bash
./.harness-kit/bin/sdd status --json | jq -r '.baseBranch // "null"'
```

### 5a. Phase base branch 모드 (`baseBranch != null`)

Phase PR (phase-N-{slug} → main) 을 생성하고 **state 는 활성 상태로 유지**합니다. PR 머지 후 사용자 신호 시 `agent.md §6.3.2` 의 Post-Merge Protocol 에서 `sdd phase done` 이 실행됩니다.

1. **PR 본문 작성**: `.harness-kit/agent/templates/phase-ship.md` 템플릿을 읽고 Phase PR 본문을 작성합니다. Step 4 의 `sdd decision list --phase` 출력을 **"🤖 자율 결정 로그"** 섹션으로 본문에 포함합니다 (리뷰어가 auto 결정을 한눈에 보도록).

2. **PR 생성**:
```bash
gh pr create --base main --head {phase-branch} --title "{title}" --body "{body}"
```

3. **PR URL 보고** + 사용자에게 머지 후 알려달라 안내 ("phase 머지 했어" 등).

4. **`sdd phase done` 호출하지 않음**. state 가 review 기간 동안 살아있어야 컨텍스트 손실 없이 review 핑퐁 / 다중 디바이스 / 세션 재진입에 대응 가능 (→ constitution §3.1, agent.md §6.3.2).

### 5b. 일반 모드 (`baseBranch == null` 또는 미정)

Spec PR 들이 이미 main 에 직접 머지되어 phase 가 사실상 완성된 상태. 별도 Phase PR 불필요.

1. **`sdd phase done` 즉시 실행** — bookkeeping 만 수행:
```bash
./.harness-kit/bin/sdd phase done
```

2. **완료 알림** + 다음 phase 후보 또는 idle 안내. 회고 원하면 `/hk-phase-review` 제안.
