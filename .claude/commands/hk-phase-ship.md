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

## 4. Go/No-Go Report (사용자 승인)

Step 2, 3의 결과를 종합하여 사용자에게 보고합니다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Phase Ship Report: <phase-id>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 성공 기준: N/M PASS
🧪 통합 테스트: N/M PASS
📦 Spec 완료: N/N Merged

[FAIL 항목이 있으면 여기에 상세 표시]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
main 으로 merge 해도 될까요? [Y/n]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**에이전트는 반드시 사용자의 명시적 승인을 대기합니다.** 자동 진행 금지.

## 5. Phase PR Creation (승인 후)

사용자 승인을 받은 후:

1. **PR 본문 작성**: `.harness-kit/agent/templates/phase-ship.md` 템플릿을 읽고 Phase PR 본문을 작성합니다.

2. **PR 생성**:
```bash
# phase base branch 모드
gh pr create --base main --head {phase-branch} --title "{title}" --body "{body}"

# 일반 모드 (base branch 없는 경우)
# 이미 main에 직접 merge되는 구조이므로 별도 PR 불필요할 수 있음 — 사용자에게 확인
```

3. **State 업데이트**:
```bash
./.harness-kit/bin/sdd phase done
```

4. **사용자 알림**: PR URL 보고 + phase 완료 축하 메시지
