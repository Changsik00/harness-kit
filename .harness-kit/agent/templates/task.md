# Task List: spec-{phaseN}-{seq}

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [ ] Spec ID 확정 및 디렉토리 생성
- [ ] spec.md 작성
- [ ] plan.md 작성
- [ ] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (해당 phase 의 phase.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: <한글 제목>

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-{phaseN}-{seq}-<slug>` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [ ] 테스트 케이스 작성: `<test/path/to/test.spec.*>`
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-{phaseN}-{seq}): add failing test for ...`

### 1-3. 구현 (TDD Green)
- [ ] 코드 구현: `<src/path/to/file.*>`
- [ ] 테스트 실행 → Pass 확인
- [ ] Commit: `feat(spec-{phaseN}-{seq}): implement ...`

---

## Task 2: <한글 제목>

### 2-1. <단계>
- [ ] ...
- [ ] Commit: `<type>(spec-{phaseN}-{seq}): ...`

---

## Task N: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 코드 품질 점검 (lint / type check) — 스택별 명령
- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] (Integration Test Required = yes 인 경우) 통합 테스트 실행 → PASS
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-{phaseN}-{seq}): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-{phaseN}-{seq}-<slug>`
- [ ] **PR 생성**: 에��전트가 `gh pr create` 또는 `/hk-pr-gh` 로 생성 (사용자 승인 후)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | N |
| **예상 commit 수** | M |
| **현재 단계** | Planning / Execution / Ship |
| **마지막 업데이트** | YYYY-MM-DD HH:MM |
