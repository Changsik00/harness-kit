# Task List: spec-x-doctor-hookspath-lefthook

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new doctor-hookspath-lefthook`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 0: 브랜치 생성

- [ ] `git checkout -b spec-x-doctor-hookspath-lefthook` (main 에서)
- [ ] Commit: 없음

---

## Task 1: lefthook × core.hooksPath 충돌 감지 (sdd doctor)

### 1-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-doctor-hookspath-lefthook.sh` 신규 — fixture(git repo + lefthook.yml + core.hooksPath) + 4 케이스 (sdd doctor warn / 루트 doctor.sh warn / 정상 pass / lefthook 미사용 무경고)
- [ ] 실행 → Red 확인 (sdd doctor / doctor.sh 케이스 Fail)
- [ ] Commit: `test(spec-x-doctor-hookspath-lefthook): expect lefthook×hooksPath conflict warning`

### 1-2. 구현 — sdd cmd_doctor (TDD Green 일부)
- [ ] `sources/bin/sdd` `cmd_doctor` 에 `_check_lefthook_hookspath` 추가 + "훅 파일" 섹션에서 호출
- [ ] `.harness-kit/bin/sdd` 동기화
- [ ] `bash tests/test-doctor-hookspath-lefthook.sh` 의 sdd doctor 케이스 PASS 확인
- [ ] Commit: `fix(spec-x-doctor-hookspath-lefthook): detect lefthook×core.hooksPath conflict in sdd doctor`

---

## Task 2: 루트 doctor.sh 패리티

- [ ] `doctor.sh` §6 에 동일 감지 추가 (`$TARGET` 기준, check_warn/check_pass)
- [ ] `bash tests/test-doctor-hookspath-lefthook.sh` 전체 PASS (doctor.sh 케이스 포함)
- [ ] `bash tests/test-hk-doctor.sh` 회귀 PASS
- [ ] Commit: `fix(spec-x-doctor-hookspath-lefthook): add same detection to root doctor.sh`

---

## Task 3: Icebox 캡처 (#2 lefthook 네이티브 통합)

- [ ] `backlog/queue.md` Icebox 에 한 줄 추가 — "lefthook 네이티브 hook 통합 (.git/hooks append fragility 해소, issue #161 제안 #2)"
- [ ] Commit: `docs(spec-x-doctor-hookspath-lefthook): capture lefthook-native integration to icebox`

---

## Task 4: Ship (필수)

- [ ] `bash -n` 문법 점검 (sdd, doctor.sh)
- [ ] 관련 테스트 전체 PASS (신규 + hk-doctor + doctor-wiki 회귀)
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-doctor-hookspath-lefthook): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-doctor-hookspath-lefthook`
- [ ] **PR 생성**: `/hk-pr-gh` (본문에 `Closes #161` 또는 부분 대응 명시)
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (브랜치 포함 5) |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-30 |
