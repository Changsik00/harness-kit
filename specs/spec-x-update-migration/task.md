# Task List: spec-x-update-migration

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec 디렉토리 생성: `specs/spec-x-update-migration/`
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + constitution spec-x 패턴 추가

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-update-migration`

### 1-2. constitution 수정
- [ ] `sources/governance/constitution.md` — §4.1, §5.2에 spec-x 패턴 추가
- [ ] `agent/constitution.md` — 동일 변경 반영 (도그푸딩 설치본)
- [ ] Commit: `refactor(spec-x-update-migration): add spec-x solo spec pattern to constitution`

---

## Task 2: VERSION 0.4.0 + CHANGELOG.md

- [ ] `VERSION` → `0.4.0` (이미 완료, 커밋만)
- [ ] `CHANGELOG.md` 신설 (이미 완료, 커밋만)
- [ ] Commit: `chore(spec-x-update-migration): bump version to 0.4.0 and add CHANGELOG`

---

## Task 3: 마이그레이션 스크립트 추가

- [ ] `sources/migrations/0.4.0.sh` 신설 (이미 완료, 커밋만)
- [ ] Commit: `feat(spec-x-update-migration): add migration script for 0.4.0`

---

## Task 4: update.sh 버전 인식 재작성

- [ ] `update.sh` 재작성 (이미 완료, 커밋만)
- [ ] Commit: `feat(spec-x-update-migration): rewrite update.sh with version-aware migration system`

---

## Task 5: Hand-off

- [ ] syntax 검증: `bash -n update.sh && bash -n sources/migrations/0.4.0.sh`
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-x-update-migration): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-update-migration`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (+ Hand-off) |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
