# Task List: spec-x-phase-15-finalize

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 및 finalize 사전 검증

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-phase-15-finalize`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 사전 상태 캡처
- [x] `bash .harness-kit/bin/sdd status` → "Active Phase: phase-15" 확인 (이후 walkthrough 증빙용)
- [x] `git status` 깨끗한지 확인 (untracked `phase-ship.md` 외 변경 없음)
- [x] Commit: 없음 (read-only 검증)

---

## Task 2: phase-15 done 처리

### 2-1. sdd phase done 실행
- [ ] `bash .harness-kit/bin/sdd phase done phase-15` → 종료 코드 0 확인
- [ ] `git diff backlog/queue.md` → phase-15 가 active → done 으로 이동만 한 것 확인 (의도 외 변경 없음)
- [ ] `bash .harness-kit/bin/sdd status` → "Active Phase: 없음" 확인

### 2-2. 검증 및 commit
- [ ] sdd 가 자동 commit 했으면 메시지 확인 (수정 필요 시 amend) / 안 했으면 수동 stage + commit
- [ ] Commit: `chore(spec-x-phase-15-finalize): mark phase-15 done in queue.md`

---

## Task 3: untracked `phase-ship.md` 처리 결정

### 3-1. 출처 비교
- [ ] `diff sources/templates/phase-ship.md .harness-kit/agent/templates/phase-ship.md`
- [ ] 동일 → 정상 install 부산물, 그대로 유지 (commit 대상 아님). walkthrough 에 "동일 — keep" 기록
- [ ] 차이 → 로컬 임시 변경 의심, `rm .harness-kit/agent/templates/phase-ship.md`. walkthrough 에 diff 발췌 + "폐기" 기록

### 3-2. Commit
- [ ] keep 의 경우 — 본 task 는 commit 없음 (workingtree 만 검증됨)
- [ ] 폐기의 경우 — Commit 없음 (untracked 삭제는 git history 와 무관)
- [ ] 결정 결과를 walkthrough 에 명시

---

## Task 4: Ship (walkthrough + pr_description)

> spec-x 의 ship 절차 — 일반 spec 과 동일.

- [ ] 회귀 테스트: `bash tests/test-sdd-spec-new-seq.sh` PASS 확인
- [ ] **walkthrough.md 작성**: finalize 전후 sdd status 비교 + queue.md diff 발췌 + `phase-ship.md` 처리 결정 기록 (예상 못한 발견이 있으면 부각)
- [ ] **pr_description.md 작성**: 본 spec 의 의도 (post-merge 정리) 와 변경 요약을 단일 PR 본문으로
- [ ] **Ship Commit**: `docs(spec-x-phase-15-finalize): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-phase-15-finalize`
- [ ] **PR 생성**: `/hk-pr-gh` 또는 `gh pr create` 자동 진행 (사용자 추가 확인 없음 — auto-ship 메모리 §)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 2 (Task 2 cleanup + Task 4 ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-30 |
