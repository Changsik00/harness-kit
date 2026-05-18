# Task List: spec-x-claude-md-slim

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — spec-x 는 phase 미소속, queue.md specx 섹션이 sdd 에 의해 자동 갱신됨
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-claude-md-slim` (main 기준)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: 참조 사전 검색

### 2-1. 다른 곳의 인용 검색
- [ ] `grep -rn "릴리스 전략" --include="*.md" .` 실행
- [ ] `grep -rn "현재 단계" --include="*.md" .` 실행
- [ ] 발견된 참조 목록을 walkthrough 초안에 메모 (실제 갱신은 Task 4 에서)
- [ ] Commit: 없음 (조사 단계, 결과는 메모리 / walkthrough 에 기록)

---

## Task 3: `docs/release-strategy.md` 신규 생성

### 3-1. 새 파일 작성
- [ ] `docs/release-strategy.md` 생성 — CLAUDE.md 의 "릴리스 전략" 섹션 (현재 line 49-84) 내용을 무손실 복사
- [ ] 헤더 `## 릴리스 전략 (이 프로젝트 전용)` → `# 릴리스 전략 (이 저장소 전용)` 으로 격상 (h1, 단독 문서)
- [ ] 부제목 (### 절차, ### 룰, ### .harness-kit/installed.json 동기화 주의) 그대로 유지
- [ ] 검증: `diff <(원본 섹션 추출) <(새 파일 본문)` 또는 시각 검사로 내용 일치 확인
- [ ] Commit: `docs(spec-x-claude-md-slim): extract release strategy to docs/release-strategy.md`

---

## Task 4: `CLAUDE.md` 슬림화

### 4-1. 릴리스 전략 섹션을 포인터로 대체
- [ ] line 49-84 "## 릴리스 전략 (이 프로젝트 전용)" 섹션을 다음으로 축소:
  ```
  ## 릴리스 전략 (이 프로젝트 전용)

  새 버전 출시 절차는 [`docs/release-strategy.md`](docs/release-strategy.md) 참조. "배포하자" 명령 시 그 문서의 절차를 alignment 없이 즉시 수행한다.
  ```
- [ ] "## 현재 단계" 섹션 (line 93-95) 삭제 — stale (Phase 4 표기 vs 실제 phase-17 완료)
- [ ] 검증:
  - `wc -l CLAUDE.md` ≤ 75
  - `grep -c "릴리스 전략" CLAUDE.md` ≥ 1 (포인터 존재)
  - `grep "현재 단계" CLAUDE.md` 결과 없음
  - `grep -E "^@\.harness-kit/CLAUDE\.fragment\.md" CLAUDE.md` 1건 (import 보존)
  - `HARNESS-KIT:BEGIN` / `HARNESS-KIT:END` 마커 보존
- [ ] Commit: `docs(spec-x-claude-md-slim): slim root CLAUDE.md (release strategy → pointer, drop stale phase note)`

---

## Task 5: 외부 참조 갱신 (조건부)

### 5-1. Task 2 검색 결과 처리
- [ ] Task 2 에서 발견한 참조 중 실제 갱신이 필요한 항목 처리
- [ ] 발견 0건이면 본 task 는 `[-]` 처리하고 walkthrough 에 기록
- [ ] Commit (필요 시): `docs(spec-x-claude-md-slim): update references to release strategy location`

---

## Task 6: 회귀 테스트

### 6-1. 전체 테스트 실행
- [ ] `bash tests/run-all.sh` 실행
- [ ] 결과 확인 — 모두 PASS 또는 기존과 동일 (pre-existing FAIL 만 잔존, icebox 에 기록된 것들)
- [ ] `bash .harness-kit/bin/sdd test passed` 로 lastTestPass 갱신
- [ ] Commit: 없음 (테스트 실행만)

---

## Task 7: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] **walkthrough.md 작성** — 발견사항·결정 이유·외부 참조 검색 결과·기존 이슈
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-claude-md-slim): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-claude-md-slim`
- [ ] **PR 생성**: `/hk-pr-gh` 로 자동 생성
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight 제외) |
| **예상 commit 수** | 3-4 (조사·검증 task 는 무 commit, Task 5 조건부) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-18 |
