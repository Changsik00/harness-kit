# Task List: spec-19-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-19.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + spec 산출물 커밋

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-19-02-hk-wiki-ingest` (base: `phase-19-doc-knowledge-graph`)
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. spec 산출물 커밋
- [ ] spec.md / plan.md / task.md 커밋
- [ ] Commit: `docs(spec-19-02): spec/plan/task 작성 — hk-wiki-ingest 슬래시 커맨드`

---

## Task 2: hk-wiki-ingest 슬래시 커맨드 작성

### 2-1. 커맨드 문서 작성
- [ ] `sources/commands/hk-wiki-ingest.md` 작성
- [ ] `.harness-kit/commands/hk-wiki-ingest.md` 동기화 (동일 내용 복사)
- [ ] Commit: `feat(spec-19-02): hk-wiki-ingest 슬래시 커맨드 신설`

---

## Task 3: sdd archive 후처리 힌트 추가

### 3-1. sdd archive 완료 출력에 힌트 1줄 추가
- [ ] `sources/bin/sdd` `cmd_archive()` 마지막에 힌트 출력 추가
- [ ] `tests/test-wiki-ingest.sh` 신규 작성 (archive 힌트 + log.md 시나리오 검증)
- [ ] 테스트 실행 → PASS 확인
- [ ] Commit: `feat(spec-19-02): sdd archive 완료 후 /hk-wiki-ingest 힌트 출력`

---

## Task 4: Ship

- [ ] `bash tests/test-wiki-structure.sh` → 45/45 PASS 확인
- [ ] `bash tests/test-wiki-ingest.sh` → PASS 확인
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-19-02): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-19-02-hk-wiki-ingest`
- [ ] **PR 생성**: `gh pr create --base phase-19-doc-knowledge-graph`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-27 |
