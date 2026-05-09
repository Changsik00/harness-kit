# Task List: spec-x-archive-include-specx

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-archive-include-specx`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 회귀 테스트 추가 (TDD Red)

### 2-1. 테스트 케이스 작성
- [x] `tests/test-sdd-dir-archive.sh` Check 4 주석 갱신: "done 섹션 미등록 spec-x 디렉토리는 보존됨"
- [x] `tests/test-sdd-dir-archive.sh` 신규 Check 7 추가: "done 섹션 등록 spec-x 는 archive 됨"
- [x] `tests/test-sdd-dir-archive.sh` 신규 Check 8 추가: "done 섹션 등록 + dry-run 시 이동 안 됨"
- [x] 테스트 실행 → Check 7, 8 Fail 확인 (3 fail, 11 pass)
- [x] Commit: `test(spec-x-archive-include-specx): add failing tests for spec-x archive support`

---

## Task 3: cmd_archive 수정 (TDD Green)

### 3-1. sources/bin/sdd cmd_archive 확장
- [ ] `done` 섹션 awk 파싱에 spec-x 슬러그 추출 추가 (`done_specx` 변수)
- [ ] spec-x 디렉토리 수집 루프 추가 (디렉토리 존재 시에만)
- [ ] 빈 검사 / 요약 출력 / dry-run / 실제 이동 / 커밋 메시지에 spec-x 통합
- [ ] 기존 phase 루프 내 spec-x 스킵 로직은 유지 (안전망)
- [ ] `bash tests/test-sdd-dir-archive.sh` → 모든 Check (1~8) PASS 확인
- [ ] `bash tests/test-sdd-archive-search.sh` → PASS 확인 (회귀 검증)
- [ ] Commit: `fix(spec-x-archive-include-specx): include done spec-x dirs in sdd archive`

---

## Task 4: installed 파일 동기화

### 4-1. .harness-kit/bin/sdd 동기화
- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [ ] `diff sources/bin/sdd .harness-kit/bin/sdd` → 차이 없음 확인
- [ ] Commit: `chore(spec-x-archive-include-specx): sync installed sdd binary`

---

## Task 5: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차.

- [ ] 코드 품질 점검 — bash 스크립트이므로 별도 lint 없음. `bash -n sources/bin/sdd` 로 syntax 확인
- [ ] 전체 테스트 실행 — 본 spec 영향 범위:
  - `bash tests/test-sdd-dir-archive.sh`
  - `bash tests/test-sdd-archive-search.sh`
  - `bash tests/test-sdd-status-cross-check.sh`
- [ ] **walkthrough.md 작성** (증거 로그 — 메모리 feedback_walkthrough_content 준수: 발견·결정·이슈만, 구현 나열 금지)
- [ ] **pr_description.md 작성** (템플릿 준수, Claude Code 배지 금지)
- [ ] **Ship Commit**: `docs(spec-x-archive-include-specx): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-archive-include-specx`
- [ ] **PR 생성**: `gh pr create` (메모리 feedback_auto_ship_no_ask — Plan Accept 후 push/PR 자동)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 4 (test / fix / chore sync / docs ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-09 |
