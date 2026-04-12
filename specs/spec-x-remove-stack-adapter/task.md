# Task List: spec-x-remove-stack-adapter

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: stacks 디렉토리 삭제 + install.sh에서 stack 로직 제거

### 1-1. 파일 삭제 및 스크립트 수정
- [x] `stacks/generic.sh` 삭제
- [x] `stacks/nodejs.sh` 삭제
- [x] `stacks/` 디렉토리 삭제
- [x] `scripts/harness/lib/stack.sh` 삭제
- [x] `install.sh`에서 `--stack` 옵션, `detect_stack()`, stack 복사 로직 제거
- [x] `install.sh --help` 출력에서 확인
- [x] Commit: `refactor(spec-x-remove-stack-adapter): remove stacks dir and install.sh stack logic`

---

## Task 2: update.sh + doctor.sh + sdd에서 stack 참조 제거

### 2-1. 스크립트 수정
- [x] `update.sh`에서 stack 복원 로직 제거
- [x] `doctor.sh`에서 stack 검증 항목 제거
- [x] `scripts/harness/bin/sdd`에서 stack 변수/출력 제거
- [x] `.claude/state/current.json`에서 `stack` 필드 제거
- [x] `sdd status` 실행하여 stack 출력 없음 확인
- [x] Commit: `refactor(spec-x-remove-stack-adapter): remove stack refs from update, doctor, sdd`

---

## Task 3: hk-ship 명령 + 거버넌스/템플릿에서 stack 참조 제거

### 3-1. 명령 및 거버넌스 수정
- [x] `sources/commands/hk-ship.md`에서 환경변수 → 에이전트 직접 판단 안내로 변경
- [x] `.claude/commands/hk-ship.md` 동기화
- [x] `sources/governance/agent.md`에서 §6.7 Stack Awareness 삭제 (영문)
- [x] `agent/agent.md` 동기화
- [x] `sources/templates/plan.md`에서 stack adapter 참조 수정
- [x] `agent/templates/plan.md` 동기화
- [x] Commit: `refactor(spec-x-remove-stack-adapter): remove stack refs from commands and governance`

---

## Task 4: 문서 정리

### 4-1. 문서 수정
- [x] `CLAUDE.md`에서 stacks 관련 설명 제거
- [x] `README.md`에서 stack.sh 참조 제거
- [x] `docs/REFERENCE.md`에서 stack 옵션/환경변수/어댑터 섹션 제거
- [-] `docs/USAGE.md`에서 `--stack` 옵션 설명 제거 — stack 관련 내용 없음, skip
- [x] Commit: `docs(spec-x-remove-stack-adapter): remove stack adapter documentation`

---

## Task 5: 검증 + 잔여 참조 확인

### 5-1. 최종 검증
- [x] `grep -r "HARNESS_STACK\|HARNESS_TEST_CMD\|HARNESS_LINT_CMD\|..." .` → spec 문서 외 잔여 참조 없음 확인
- [x] `doctor.sh` 실행 → PASS 36 / WARN 1 / FAIL 0
- [x] `sdd status` 실행 → stack 출력 없음 확인
- [-] 잔여 참조 발견 시 정리 — 잔여 없음, 별도 커밋 불필요
- [-] Commit — 정리할 항목 없어 skip

---

## Task 6: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 검증 최종 확인
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-x-remove-stack-adapter): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-remove-stack-adapter`
- [ ] **PR 생성**: 에이전트가 `gh pr create` 또는 `/hk-pr-gh` 로 생성 (사용자 승인 후)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 5~6 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-12 |
