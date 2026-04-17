# Task List: spec-10-05

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase.md SPEC 표 자동 갱신 완료)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + sdd spec new 수정

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-10-05-artifact-timing-fix` (base: `phase-10-status-reliability`)
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. sdd spec new에서 walkthrough/pr_description 생성 제외
- [x] `sources/bin/sdd` `spec_new()` 함수의 for 루프에서 `walkthrough pr_description` 제거
- [x] 전체 테스트 실행 → 17개 파일 PASS (기존 이슈 2건 동일)
- [x] Commit: `fix(spec-10-05): exclude walkthrough and pr_description from spec new`

---

## Task 2: walkthrough 템플릿 개선

### 2-1. 결정 기록 + 사용자 협의 섹션 추가
- [x] `sources/templates/walkthrough.md`에 `📌 결정 기록` 섹션 추가
- [x] `sources/templates/walkthrough.md`에 `💬 사용자 협의` 섹션 추가
- [x] `🔍 발견 사항`에서 Optional 라벨 제거
- [x] Commit: `feat(spec-10-05): improve walkthrough template with decision and discussion sections`

---

## Task 3: 도그푸딩 동기화

### 3-1. .harness-kit 동기화
- [x] `sources/bin/sdd` → `.harness-kit/bin/sdd` 복사
- [x] `sources/templates/walkthrough.md` → `.harness-kit/agent/templates/walkthrough.md` 복사
- [x] 전체 회귀 테스트 PASS
- [x] Commit: `chore(spec-10-05): sync sdd and templates to .harness-kit`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 실행 → 17개 파일 PASS
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-10-05): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-10-05-artifact-timing-fix`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
