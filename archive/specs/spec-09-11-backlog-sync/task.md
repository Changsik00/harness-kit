# Task List: spec-09-11

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight

- [x] spec.md / plan.md / task.md 작성
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [x] `git checkout -b spec-09-11-backlog-sync` (from `phase-09-install-conflict-defense`)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: cmd_archive 후처리 보강

- [x] `sources/bin/sdd` `cmd_archive` awk 패턴에 `| Active |` 추가
- [x] `cmd_archive` 끝에 state.json 초기화 (`spec=null`, `planAccepted=false`)
- [x] `cmd_archive` 끝에 `queue_set_active_progress` 호출
- [x] `cmd_archive` 완료 메시지에 NEXT spec 안내 출력
- [x] `queue_set_active_progress` 미사용 변수 정리
- [x] 테스트 실행 → PASS 확인
- [x] Commit: `fix(spec-09-11): reinforce cmd_archive post-processing`

---

## Task 3: queue.md NOW/NEXT dead code 제거

- [x] `sources/templates/queue.md`에서 NOW/NEXT 마커 섹션 제거
- [x] `.harness-kit/agent/templates/queue.md` 도그푸딩 사본 동기화
- [x] `backlog/queue.md`에서 NOW/NEXT 섹션 제거
- [x] 테스트 실행 → PASS 확인
- [x] Commit: `chore(spec-09-11): remove dead NOW/NEXT markers from queue template`

---

## Task 4: agent.md PR 머지 후 절차 추가

- [x] `sources/governance/agent.md` §6.3 뒤에 "Post-Merge Protocol" 서브섹션 추가
- [x] `.harness-kit/agent/agent.md` 도그푸딩 사본 동기화
- [x] Commit: `docs(spec-09-11): add post-merge protocol to agent.md`

---

## Task 5: 도그푸딩 sdd 동기화 + 통합 테스트

- [x] `.harness-kit/bin/sdd`를 `sources/bin/sdd`로 동기화
- [x] 통합 테스트 실행 → PASS 확인
- [x] Commit: `chore(spec-09-11): sync dogfooding sdd binary`

---

## Task 6: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] 통합 테스트 실행 → PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-11): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-11-backlog-sync`
- [ ] **PR 생성**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 5 |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-04-16 |
