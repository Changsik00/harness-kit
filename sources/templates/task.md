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

### 🚦 Pre-Push Quality Gate (push 전 필수 — CI 재현)

> **이 단계를 건너뛰면 push 금지.** 로컬에서 GREEN 확인 후 push한다.

- [ ] **전체 CI 재현** (root `pnpm run ci` 또는 동등 명령):
  ```
  pnpm run ci
  ```
  → 출력 마지막 줄이 `Tasks: N successful, N total` 이어야 함. `Failed:` 행 있으면 중단.

- [ ] **prettier 전체 체크** (turbo lint 캐시 false-pass 방지):
  ```
  pnpm run format:check
  ```
  → 포맷 오류 파일 있으면 `pnpm run format` 후 커밋 추가.

- [ ] (Integration Test Required = yes 인 경우) 통합 테스트 실행 → PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-{phaseN}-{seq}): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-{phaseN}-{seq}-<slug>`
- [ ] **PR 생성**: 에이전트가 `gh pr create` 또는 `/hk-pr-gh` 로 생성 (사용자 승인 후)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | N |
| **예상 commit 수** | M |
| **현재 단계** | Planning / Execution / Ship |
| **마지막 업데이트** | YYYY-MM-DD HH:MM |
