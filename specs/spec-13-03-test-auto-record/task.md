# Task List: spec-13-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-13.md SPEC 표 갱신)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [x] `git checkout -b spec-13-03-test-auto-record` (base: phase-13-dx-enhancements)

---

## Task 2: 테스트 작성 (TDD Red)

- [x] `tests/test-test-auto-record.sh` 작성 — 5가지 시나리오:
  - 인자 없이 실행 시 사용법 안내 출력 확인
  - `sdd help`에 `run-test` 항목 포함 확인
  - exit 0 명령 실행 시 `lastTestPass` 갱신 확인
  - exit 1 명령 실행 시 `lastTestPass` 갱신 안 됨 확인
  - `sources/bin/sdd` ↔ `.harness-kit/bin/sdd` 동기화 확인
- [x] 테스트 실행 → FAIL 확인
- [x] Commit: `test(spec-13-03): add failing tests for sdd run-test command`

---

## Task 3: sdd run-test 구현

- [x] `cmd_run_test()` 함수 추가 — passthrough 실행, exit code 감지, 자동 기록
- [x] `case` 분기 + `cmd_help()` 항목 추가
- [x] `.harness-kit/bin/sdd` 동기화
- [x] 테스트 전체 PASS 확인
- [x] Commit: `feat(spec-13-03): add sdd run-test subcommand`

---

## Task 4: Ship

- [ ] 전체 테스트 실행 → FAIL=0
- [ ] walkthrough.md 작성
- [ ] pr_description.md 작성
- [ ] Ship Commit: `docs(spec-13-03): ship walkthrough and pr description`
- [ ] Push: `git push -u origin spec-13-03-test-auto-record`
- [ ] PR 생성 (→ phase-13-dx-enhancements)
- [ ] 사용자 알림 완료

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (+ Pre-flight + Ship) |
| **예상 commit 수** | 2 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-22 |
