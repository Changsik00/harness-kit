# Task List: spec-x-sdd-ux-fixes

> One Task = One Commit.

## Pre-flight

- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: sdd specx new 명령 구현

- [x] 브랜치 생성: `git checkout -b spec-x-sdd-ux-fixes`
- [x] `sources/bin/sdd`: `cmd_specx`에 `new` 서브커맨드 추가 + phase done archive fallback + archive spec-x
- [x] `.harness-kit/bin/sdd`: 동기화
- [x] Commit: `feat(spec-x-sdd-ux-fixes): add sdd specx new command + phase done archive fallback + archive spec-x`

---

## Task 3: queue.md done 제목 수정

- [x] `backlog/queue.md`: phase-08~11 done 항목 제목 수정
- [x] Commit: `fix(spec-x-sdd-ux-fixes): fix queue done titles for phase-08 through phase-11`

---

## Task 4: README 개발자용 섹션 제거

- [ ] `README.md`: "프로젝트 구조 (개발자용)" 섹션 삭제
- [ ] Commit: `chore(spec-x-sdd-ux-fixes): remove redundant developer structure section from README`

---

## Task 5: Ship

- [x] 전체 테스트 실행 → 18/18 PASS
- [x] walkthrough.md 작성
- [x] pr_description.md 작성
- [ ] Ship Commit
- [ ] Push + PR

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (구현 4 + Ship 1) |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
