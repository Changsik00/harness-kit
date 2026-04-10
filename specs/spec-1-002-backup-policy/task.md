# Task List: spec-1-002

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-1-002-backup-policy`

---

## Task 2: install.sh에 --no-backup 옵션 + git-clean 스킵 추가

### 2-1. 인자 파싱 + 백업 로직 개선
- [ ] `--no-backup` 플래그 추가 (인자 파싱 섹션)
- [ ] 백업 섹션(§7)에 git-clean 감지 로직:
  - `git -C "$TARGET" status --porcelain` 이 비어있으면 스킵
- [ ] `--no-backup` 일 때 백업 전체 스킵
- [ ] install plan 출력에 no-backup 표시
- [ ] Commit: `feat(spec-1-002): add --no-backup option and git-clean skip to install.sh`

---

## Task 3: 보존 정책 추가 (최근 N개만 유지)

### 3-1. 오래된 백업 자동 삭제
- [ ] 백업 완료 후, `.harness-backup-*` 를 날짜순 정렬하여 최근 `HARNESS_BACKUP_KEEP` (기본 3)개만 유지
- [ ] 삭제 대상을 로그로 출력
- [ ] 5회 반복 실행 검증
- [ ] Commit: `feat(spec-1-002): add backup retention policy to install.sh`

---

## Task 4: Hand-off

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-1-002): archive walkthrough and pr description`
- [ ] **Push + PR 생성**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 (Task 1은 브랜치 생성만) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-10 |
