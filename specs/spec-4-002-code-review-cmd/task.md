# Task List: spec-4-002

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: /code-review 슬래시 커맨드 작성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-4-002-code-review-cmd`

### 1-2. 슬래시 커맨드 파일 작성
- [x] `sources/commands/code-review.md` 생성
- [x] 리뷰 관점 3개: spec 대비 구현 검증, 코드 품질(KISS/DRY/feature envy), 테스트 커버리지
- [x] 한국어 출력 지시
- [x] `code-review.md` 저장 지시
- [x] Commit: `feat(spec-4-002): add /code-review slash command`

### 1-3. 도그푸딩 반영
- [x] `.claude/commands/code-review.md`로 복사
- [x] Commit: `chore(spec-4-002): copy code-review command for dogfooding`

### 1-4. 검증
- [x] 파일 존재 + frontmatter 형식 검증

---

## Task 2: Hand-off (필수)

- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] **Archive Commit**: `docs(spec-4-002): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-4-002-code-review-cmd`
- [x] **사용자 알림**: 푸시 완료 + PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 2 |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-10 |
