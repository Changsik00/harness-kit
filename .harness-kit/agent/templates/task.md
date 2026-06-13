# Task List: spec-{phaseN}-{seq}

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: <한글 제목>

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-{phaseN}-{seq}-{slug}`

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

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** → 모두 PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-{phaseN}-{seq}): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-{phaseN}-{seq}-{slug}`
- [ ] PR 생성 (`gh pr create` 또는 `/hk-pr-gh`)
