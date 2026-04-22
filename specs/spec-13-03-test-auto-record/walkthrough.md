# Walkthrough: spec-13-03

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 감지 방식 | PostToolUse hook vs sdd run-test wrapper | wrapper (exit code 기반) | hook 방식은 도구 출력 파싱 필요로 false positive 위험, exit code 기반이 신뢰성 높음 |
| stdout/stderr 처리 | 버퍼링 vs passthrough | passthrough (`"$@"` 직접 실행) | 테스트 출력이 즉시 터미널에 표시됨 |
| 실패 처리 | exit 0으로 통일 vs exit code 그대로 | exit code 그대로 전달 | 에이전트가 실패를 인지해 수정 가능, 투명성 유지 |
| Check 3 grep 패턴 | `"lastTestPass":"..."` vs `"lastTestPass": "..."` | 공백 허용 패턴 (`": *"`) | JSON pretty-print 포맷이 공백 포함 — 패턴 불일치로 오탐 방지 |

## 💬 사용자 협의

- **주제**: wrapper vs hook 방식
  - **사용자 의견**: plan.md에서 동의 (Plan Accept)
  - **합의**: `sdd run-test <cmd>` wrapper 방식으로 구현

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-test-auto-record.sh`
- **결과**: ✅ ALL 7 CHECKS PASSED
- **로그 요약**:
```text
═══════════════════════════════════════════
 run-test Verification (spec-13-03)
═══════════════════════════════════════════
  ✅ 사용법 안내 출력됨
  ✅ 인자 없이 실행 시 exit 0
  ✅ sdd help에 run-test 포함
  ✅ exit 0 명령 후 lastTestPass 갱신됨
  ✅ exit 1 명령 후 lastTestPass 변경 없음
  ✅ exit 1 명령 시 sdd run-test 도 exit 1 반환
  ✅ 두 파일 동일 (동기화됨)
═══════════════════════════════════════════
 ✅ ALL 7 CHECKS PASSED
═══════════════════════════════════════════
```

#### 전체 테스트 스위트
- **명령**: `for t in tests/test-*.sh; do bash "$t"; done`
- **결과**: FAIL=0 (23개 테스트 파일 전체 통과)

## 📦 변경 파일

| 파일 | 변경 내용 |
|---|---|
| `sources/bin/sdd` | `cmd_run_test()` 추가, `case` 분기, help 항목 |
| `.harness-kit/bin/sdd` | sources/bin/sdd 와 동기화 |
| `tests/test-test-auto-record.sh` | 신규 — 7가지 시나리오 검증 |
