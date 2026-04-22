# Task List: spec-13-01

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

- [x] `git checkout -b spec-13-01-onboarding-doctor`

---

## Task 2: 테스트 작성 (TDD Red)

- [x] `tests/test-hk-doctor.sh` 작성 (5 checks)
- [x] 테스트 실행 → FAIL 확인
- [x] Commit: `test(spec-13-01): add failing tests for sdd doctor command`

---

## Task 3: sdd doctor 서브커맨드 구현

- [x] `cmd_doctor()` 함수 추가 (bash/jq/git/gh/설치파일/훅/settings.json 체크)
- [x] `case` 분기 + `cmd_help()` doctor 항목 추가
- [x] 테스트 전체 PASS 확인
- [x] Commit: `feat(spec-13-01): add sdd doctor subcommand`

---

## Task 4: hk-doctor 슬래시 커맨드 추가

- [x] `sources/commands/hk-doctor.md` 작성
- [x] `.harness-kit/bin/sdd` 동기화
- [x] 테스트 전체 PASS 확인
- [x] Commit: `feat(spec-13-01): add hk-doctor slash command`

---

## Task 5: Ship

- [x] 전체 테스트 실행 → FAIL=0
- [x] walkthrough.md 작성
- [x] pr_description.md 작성
- [x] Ship Commit: `docs(spec-13-01): ship walkthrough and pr description`
- [x] Push: `git push -u origin spec-13-01-onboarding-doctor`
- [x] PR 생성: #71 (→ phase-13-dx-enhancements)
- [x] 사용자 알림 완료

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (+ Pre-flight + Ship) |
| **예상 commit 수** | 3 |
| **현재 단계** | Ship 완료 |
| **마지막 업데이트** | 2026-04-22 |
