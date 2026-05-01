# feat(spec-13-03): sdd run-test — 테스트 결과 자동 기록

## 요약

- `sdd run-test <cmd...>` wrapper subcommand 추가
- 테스트 명령 실행 후 exit code 0이면 `sdd test passed` 자동 호출
- exit code non-0이면 기록 없이 해당 exit code 그대로 반환
- stdout/stderr passthrough — 테스트 출력이 즉시 터미널에 표시됨

## 변경 파일

- `sources/bin/sdd`: `cmd_run_test()` 추가, case 분기, help 항목
- `.harness-kit/bin/sdd`: 동기화
- `tests/test-test-auto-record.sh`: 신규 — 7가지 시나리오

## 테스트

```
bash tests/test-test-auto-record.sh
→ ✅ ALL 7 CHECKS PASSED
```

전체 테스트 스위트 FAIL=0 확인.

## 관련 Spec

`specs/spec-13-03-test-auto-record/`
