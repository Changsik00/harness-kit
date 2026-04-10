# Task List: spec-4-001

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (phase-4.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: /spec-review 슬래시 커맨드 작성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-4-001-spec-review-cmd`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 슬래시 커맨드 파일 작성
- [x] `sources/commands/spec-review.md` 생성
- [x] frontmatter (description) + 리뷰 프롬프트 작성
- [x] 리뷰 관점 5개 항목 포함: 요구사항 빈틈, 모호한 DoD, 누락된 엣지 케이스, 과도한 범위, 아키텍처 리스크
- [x] 한국어 출력 지시
- [x] `review.md` 저장 지시
- [x] Commit: `feat(spec-4-001): add /spec-review slash command`

### 1-3. 도그푸딩 반영
- [x] `.claude/commands/spec-review.md`로 복사
- [x] Commit: `chore(spec-4-001): copy spec-review command for dogfooding`

### 1-4. 검증
- [x] `sources/commands/spec-review.md` 파일 존재 확인
- [x] frontmatter 형식 검증
- [x] Commit: 없음 (검증만)

---

## Task 2: Hand-off (필수)

> 모든 작업 task 완료 후 수행합니다.

- [x] 전체 파일 점검
- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Archive Commit**: `docs(spec-4-001): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-4-001-spec-review-cmd`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 2 |
| **예상 commit 수** | 3 |
| **현재 단계** | Execution — Task 1 완료, Task 2 (Hand-off) 대기 |
| **마지막 업데이트** | 2026-04-10 |
