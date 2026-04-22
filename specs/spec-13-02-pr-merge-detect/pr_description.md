# feat(spec-13-02): sdd pr-watch — PR merge 자동 감지

## 요약

- `sdd pr-watch <pr-number>` 서브커맨드 추가
- `gh pr view` 폴링(30초 간격, 60분 타임아웃)으로 merge 감지
- merge 시 PR 제목 + `sdd status --brief` + 다음 명령 안내 자동 출력
- `gh` 미설치 환경: graceful 안내 + exit 0 (차단 없음)
- Ctrl+C(SIGINT): 정상 종료 메시지 + exit 0

## 변경 파일

- `sources/bin/sdd`: `cmd_pr_watch()` 추가, case 분기, help 항목
- `.harness-kit/bin/sdd`: 동기화
- `tests/test-pr-merge-detect.sh`: 신규 — 5가지 시나리오

## 테스트

```
bash tests/test-pr-merge-detect.sh
→ ✅ ALL 5 CHECKS PASSED
```

전체 테스트 스위트 FAIL=0 확인.

## 관련 Spec

`specs/spec-13-02-pr-merge-detect/`
