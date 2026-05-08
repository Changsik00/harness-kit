# Task List: spec-x-get-sh-installer

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-get-sh-installer`
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: get.sh 테스트 작성

### 2-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-get-sh.sh` 작성
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-x-get-sh-installer): add failing tests for get.sh`

---

## Task 3: get.sh 구현

### 3-1. 구현 (TDD Green)
- [ ] `get.sh` 작성
- [ ] 테스트 실행 → Pass 확인
- [ ] Commit: `feat(spec-x-get-sh-installer): add remote installer get.sh`

---

## Task 4: README 업데이트

### 4-1. 설치 섹션 교체
- [ ] README.md 설치 섹션을 curl 한 줄 방식으로 교체
- [ ] 기존 clone 방식은 "개발자용" 섹션으로 이동
- [ ] Commit: `docs(spec-x-get-sh-installer): update README install section`

---

## Task 5: Ship

- [ ] 전체 테스트 실행 → PASS (`bash tests/test-get-sh.sh`)
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-get-sh-installer): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-get-sh-installer`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-09 |
