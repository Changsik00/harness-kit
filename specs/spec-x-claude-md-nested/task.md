# Task List: spec-x-claude-md-nested

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new`)
- [x] spec.md 작성 (scaffold Branch 필드 버그 수동 보정)
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — spec-x specx 섹션은 `sdd plan accept` 시 자동 갱신
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-claude-md-nested` (main 기준)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 스펙 산출물 등록

### 2-1. 초기 docs commit
- [ ] spec.md / plan.md / task.md / walkthrough.md (템플릿) + backlog/queue.md (sdd 자동 갱신분) staging
- [ ] Commit: `docs(spec-x-claude-md-nested): add spec/plan/task`

---

## Task 3: `sources/CLAUDE.md` 신규 생성

### 3-1. 새 파일 작성
- [ ] `sources/CLAUDE.md` 생성 — 키트 원본 시점 룰 (수정 영향, update 메커니즘, bash 호환, 디렉토리 매핑 테이블)
- [ ] 검증: `wc -l sources/CLAUDE.md` ≤ 25
- [ ] Commit: `docs(spec-x-claude-md-nested): add sources/CLAUDE.md (kit-origin context)`

---

## Task 4: `specs/CLAUDE.md` 신규 생성

### 4-1. 새 파일 작성
- [ ] `specs/CLAUDE.md` 생성 — 작업 로그 시점 룰 (한국어 산출물, 템플릿 강제, immutable 정책, archive 정책)
- [ ] 검증: `wc -l specs/CLAUDE.md` ≤ 25
- [ ] Commit: `docs(spec-x-claude-md-nested): add specs/CLAUDE.md (work-log context)`

---

## Task 5: 회귀 테스트

### 5-1. 핵심 테스트 실행
- [ ] `bash tests/test-install-claude-import.sh` PASS 확인 (root CLAUDE.md 만 검사하므로 영향 없을 것)
- [ ] `bash tests/test-marker-append-guard.sh` PASS 확인
- [ ] `bash tests/test-marker-edge-cases.sh` PASS 확인
- [ ] `git diff main..HEAD -- CLAUDE.md` → 출력 없음 (root 무변경 검증)
- [ ] `bash .harness-kit/bin/sdd test passed` 로 lastTestPass 갱신
- [ ] Commit: 없음 (테스트 실행만)

---

## Task 6: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] **walkthrough.md 작성** — 결정 이유 / 분량 정책 검증 / nested CLAUDE.md auto-load 동작 메모
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-claude-md-nested): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-claude-md-nested`
- [ ] **PR 생성**: `gh pr create` 자동
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 (Pre-flight 제외) |
| **예상 commit 수** | 4 (Task 2/3/4 + Ship; Task 1/5 무 commit) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-18 |
