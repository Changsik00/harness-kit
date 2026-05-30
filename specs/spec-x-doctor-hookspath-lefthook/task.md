# Task List: spec-x-doctor-hookspath-lefthook

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new doctor-hookspath-lefthook`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 0: 브랜치 생성

- [x] `git checkout -b spec-x-doctor-hookspath-lefthook` (main 에서)
- [x] Commit: 없음

---

## Task 1: lefthook × core.hooksPath 충돌 감지 (sdd doctor)

### 1-1. 테스트 작성 (TDD Red)
- [x] `tests/test-doctor-hookspath-lefthook.sh` 신규 (4 케이스)
- [x] 실행 → Red 확인 (Case 1·2 Fail)
- [x] Commit: `test(spec-x-doctor-hookspath-lefthook): expect lefthook×hooksPath conflict warning`

### 1-2. 구현 — sdd cmd_doctor
- [x] `sources/bin/sdd` `cmd_doctor` 에 `_check_lefthook_hookspath` 추가 + 호출
- [x] `.harness-kit/bin/sdd` 동기화, Case 1 PASS
- [x] Commit: `fix(spec-x-doctor-hookspath-lefthook): detect lefthook×core.hooksPath conflict in sdd doctor`

---

## Task 2: 루트 doctor.sh 패리티

- [x] `doctor.sh` §6 에 동일 감지 추가
- [x] `bash tests/test-doctor-hookspath-lefthook.sh` 4/4 PASS, `test-hk-doctor.sh`·`test-doctor-wiki.sh` 회귀 PASS
- [x] Commit: `fix(spec-x-doctor-hookspath-lefthook): add same detection to root doctor.sh`

---

## Task 3: Icebox 캡처 (#2 lefthook 네이티브 통합)

- [x] `backlog/queue.md` Icebox 에 한 줄 추가
- [x] Commit: `docs(spec-x-doctor-hookspath-lefthook): capture lefthook-native integration to icebox`

---

## Task 4: Ship (필수)

- [ ] `bash -n` 문법 점검 (sdd, doctor.sh)
- [ ] 관련 테스트 전체 PASS (신규 + hk-doctor + doctor-wiki 회귀)
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-doctor-hookspath-lefthook): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-doctor-hookspath-lefthook`
- [ ] **PR 생성**: `References #161`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (브랜치 포함 5) |
| **예상 commit 수** | 5 |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-05-30 |
