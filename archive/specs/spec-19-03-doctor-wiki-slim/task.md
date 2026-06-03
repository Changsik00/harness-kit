# Task List: spec-19-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-19.md SPEC 표 갱신)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + spec 산출물 커밋

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-19-03-doctor-wiki-slim` (base: `phase-19-doc-knowledge-graph`)
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. spec 산출물 커밋
- [ ] spec.md / plan.md / task.md 커밋
- [ ] Commit: `docs(spec-19-03): spec/plan/task 작성 — doctor wiki 점검 + CLAUDE.md 슬림화`

---

## Task 2: sdd doctor wiki 점검 4종 + 테스트

### 2-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-doctor-wiki.sh` 작성 (Check 1~5)
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-19-03): test-doctor-wiki.sh — wiki layer 점검 실패 케이스`

### 2-2. 구현 (TDD Green)
- [ ] `sources/bin/sdd` cmd_doctor()에 wiki layer 섹션 추가 (W-1~W-4)
- [ ] `.harness-kit/bin/sdd` 동기화
- [ ] 테스트 실행 → PASS 확인
- [ ] Commit: `feat(spec-19-03): sdd doctor wiki layer 점검 4종 추가`

---

## Task 3: CLAUDE.md 슬림화

### 3-1. docs/project-guide.md 생성 + CLAUDE.md 포인터 교체
- [ ] `docs/project-guide.md` 신규 작성 (이동 내용: 대상 환경 + 디렉토리 의미)
- [ ] `CLAUDE.md` 두 섹션 제거 + 포인터 추가
- [ ] 테스트 (test-doctor-wiki.sh Check 3~4) PASS 확인
- [ ] Commit: `refactor(spec-19-03): CLAUDE.md 슬림화 — 저빈도 섹션 docs/project-guide.md 분리`

---

## Task 4: governance prune 기준 추가

### 4-1. constitution.md rule prune 기준 섹션 추가
- [ ] `sources/governance/constitution.md` 끝에 "Rule Prune Guidance" 섹션 추가
- [ ] 테스트 (test-doctor-wiki.sh Check 5) PASS 확인
- [ ] Commit: `docs(spec-19-03): constitution.md rule prune 권고 기준 섹션 추가`

---

## Task 5: Ship

- [ ] `bash tests/test-wiki-structure.sh` → 45/45 PASS 확인
- [ ] `bash tests/test-doctor-wiki.sh` → PASS 확인
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-19-03): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-19-03-doctor-wiki-slim`
- [ ] **PR 생성**: `gh pr create --base phase-19-doc-knowledge-graph`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 6 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-27 |
