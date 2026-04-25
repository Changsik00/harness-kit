# Task List: spec-14-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-14.md SPEC 표 자동 갱신 by `sdd spec new`)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + phase-14 셋업 commit

> phase-14.md 신규 + queue.md active/done 갱신은 `sdd phase new/done` 결과로 main 의 working tree 에 있음. main 직접 commit 금지(constitution §10.1)이므로 spec 브랜치로 가져가서 함께 commit.

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-14-01-sdd-queued-marker`
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. phase-14 셋업 commit (working tree 의 phase 시작 변경분)
- [ ] `git add backlog/phase-14.md backlog/queue.md`
- [ ] `git add specs/spec-14-01-sdd-queued-marker/` (spec.md, plan.md, task.md)
- [ ] Commit: `chore(spec-14-01): start phase-14 — phase definition + spec planning`

---

## Task 2: 회귀 테스트 작성 (TDD Red)

### 2-1. 테스트 스크립트 추가
- [ ] 파일 생성: `tests/test-sdd-queued-marker-removed.sh`
  - Phase 1: `sources/templates/queue.md` 와 `.harness-kit/agent/templates/queue.md` 에 `sdd:queued` 마커가 없는지 grep 검증
  - Phase 2: 픽스처에서 (sdd:queued 마커 없는 queue.md 로) `sdd phase new`, `sdd phase done`, `sdd status` 가 모두 exit 0 인지 검증
- [ ] 실행 권한 부여: `chmod +x tests/test-sdd-queued-marker-removed.sh`

### 2-2. Fail 확인 (TDD Red)
- [ ] 실행: `bash tests/test-sdd-queued-marker-removed.sh`
- [ ] 기대 결과: Phase 1 에서 ❌ — 현재 두 템플릿에 마커가 남아 있어 fail
- [ ] Commit: `test(spec-14-01): add regression test for queued marker removal`

---

## Task 3: 템플릿 마커 제거 + 안내문 갱신 (TDD Green)

### 3-1. sources/templates/queue.md 정리
- [ ] `<!-- sdd:queued:start --> ~ <!-- sdd:queued:end -->` + 그 사이 표 헤더 제거
- [ ] "📋 대기 Phase" 섹션 본문에 "사람이 직접 편집" 안내문 추가 (Icebox 톤 통일)

### 3-2. sources/templates/queue.md 상단 안내문 갱신
- [ ] 기존 한 줄 ("sdd 가 마커 사이를 자동 갱신...") 을 "자동 갱신 마커: active/specx/done" + "사람 편집 섹션: Icebox/대기 Phase" 로 분리

### 3-3. .harness-kit/agent/templates/queue.md 동일 변경 (도그푸딩 동기화)
- [ ] sources/templates/queue.md 와 동일 내용으로 갱신

### 3-4. Pass 확인 (TDD Green)
- [ ] 실행: `bash tests/test-sdd-queued-marker-removed.sh`
- [ ] 기대 결과: Phase 1 + Phase 2 모두 PASS
- [ ] Commit: `fix(spec-14-01): remove dead sdd:queued marker from queue templates`

---

## Task 4: 본 프로젝트 backlog/queue.md 정리

### 4-1. backlog/queue.md 정리 (도그푸딩 적용)
- [ ] `<!-- sdd:queued:start --> ~ <!-- sdd:queued:end -->` + 표 헤더 제거
- [ ] "📋 대기 Phase" 섹션에 안내문 추가
- [ ] 상단 안내문을 템플릿과 동일하게 갱신
- [ ] active / specx / done / Icebox 데이터는 모두 보존

### 4-2. 검증
- [ ] `bash .harness-kit/bin/sdd status` 정상 동작 확인 (active phase = phase-14, NEXT = spec-14-01-sdd-queued-marker)
- [ ] `grep -r "sdd:queued" backlog/ sources/ .harness-kit/agent/` → 0 매치 (테스트 코드 내부 grep 패턴 제외)
- [ ] Commit: `chore(spec-14-01): apply queue.md cleanup to project backlog`

---

## Task 5: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 코드 품질 점검 — 본 spec 은 bash/markdown 만이라 lint/typecheck 대상 없음
- [ ] 전체 테스트 실행 → 모두 PASS
  - `bash tests/test-sdd-queued-marker-removed.sh`
  - `bash tests/test-sdd-queue-redesign.sh` (회귀 점검)
  - `bash tests/test-sdd-status-cross-check.sh` (회귀 점검)
- [ ] **walkthrough.md 작성** — `templates/walkthrough.md` 따름. 발견/결정 위주 (구현 나열 금지).
- [ ] **pr_description.md 작성** — `templates/pr_description.md` 따름.
- [ ] **Ship Commit**: `docs(spec-14-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-14-01-sdd-queued-marker` — push 보고 시 브랜치명 명시
- [ ] **PR 생성**: `gh pr create` 또는 `/hk-pr-gh` 사용
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고 후 사용자 머지 대기

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (Pre-flight 별도) |
| **예상 commit 수** | 5 (Task 1: 1 + Task 2~5: 각 1) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-25 |
