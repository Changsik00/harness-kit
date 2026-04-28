# Task List: spec-15-06

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (`backlog/phase-15.md` SPEC 표에 spec-15-06 추가)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + phase-15.md 백로그 업데이트

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-15-06-user-hook-preserve` (base: `phase-15-upgrade-safety`)
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. 백로그 업데이트
- [ ] `backlog/phase-15.md` sdd:specs 마커 영역에 spec-15-06 행 추가
- [ ] Commit: `chore(spec-15-06): add spec-15-06 row to phase-15 spec table`

---

## Task 2: sdd spec_new() archive 스캔 버그 수정

### 2-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-sdd-spec-new-seq.sh` 작성 — archive/specs에 phase-N spec이 있을 때 seq 번호 중복 없음 검증
- [ ] 테스트 실행 → Fail 확인 (`bash tests/test-sdd-spec-new-seq.sh`)
- [ ] Commit: `test(spec-15-06): add failing test for spec_new archive seq collision`

### 2-2. sdd 수정 (TDD Green)
- [ ] `sources/bin/sdd` `spec_new()` — `find` 경로에 `"$SDD_ROOT/archive/specs"` 추가
- [ ] `.harness-kit/bin/sdd` 동일하게 수정 (install된 버전)
- [ ] 테스트 실행 → Pass 확인 (`bash tests/test-sdd-spec-new-seq.sh`)
- [ ] Commit: `fix(spec-15-06): spec_new scan archive/specs for seq collision prevention`

---

## Task 3: hook 보존 단위 테스트 작성 (TDD Red)

### 3-1. 테스트 파일 신규 작성
- [ ] `tests/test-install-settings-hook.sh` 작성 — 4개 시나리오 (kit hook 갱신 / 사용자 hook 보존 / 멱등성 / hook 없음)
- [ ] 테스트 실행 → Fail 확인 (`bash tests/test-install-settings-hook.sh`)
- [ ] Commit: `test(spec-15-06): add failing hook preservation tests`

---

## Task 4: install.sh 수정 (TDD Green)

### 4-1. jq 머지 로직 변경
- [ ] `install.sh` jq 표현 변경: `.hooks = ($kit.hooks // $user.hooks)` → kit-key 우선 + user-전용 key 보존
- [ ] 단위 테스트 실행 → Pass 확인 (`bash tests/test-install-settings-hook.sh`)
- [ ] Commit: `fix(spec-15-06): preserve user-defined hook event types on install`

---

## Task 5: Scenario 3 활성화 (통합 테스트)

### 5-1. test-update-stateful.sh Scenario 3 skip 해제
- [ ] `tests/test-update-stateful.sh` Scenario 3의 `skip` 라인을 `with_user_hook` 기반 실제 검증으로 교체
- [ ] 통합 테스트 전체 실행 → Pass 확인 (`bash tests/test-update-stateful.sh`)
- [ ] Commit: `test(spec-15-06): activate scenario 3 - user hook preserved on update`

---

## Task 6: Ship

- [ ] 전체 테스트 실행 → 모두 PASS
  ```bash
  bash tests/test-install-settings-hook.sh
  bash tests/test-update-stateful.sh
  ```
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-15-06): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-15-06-user-hook-preserve`
- [ ] **PR 생성**: `gh pr create` 또는 `/hk-pr-gh` (base: `phase-15-upgrade-safety`)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 6 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-28 |
