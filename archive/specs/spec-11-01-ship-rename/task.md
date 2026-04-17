# Task List: spec-11-01

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-11.md SPEC 표 — sdd 자동 갱신 완료)
- [ ] 사용자 Plan Accept

---

## Task 1: sdd CLI 핵심 리네이밍

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-11-01-ship-rename`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. sdd 원본 + 도그푸딩 복사본 수정
- [x] `sources/bin/sdd`: `cmd_archive` → `cmd_ship` 리네이밍, help 텍스트, dispatch, 커밋 메시지, 내부 참조 일괄 변경
- [x] `sources/bin/sdd`: `archive)` dispatch에 deprecation 경고 + `cmd_ship` 위임 추가
- [x] `.harness-kit/bin/sdd`: 동일 변경 동기화
- [x] Commit: `refactor(spec-11-01): rename sdd archive to sdd ship`

---

## Task 2: 거버넌스·템플릿·커맨드 갱신

### 2-1. 거버넌스 문서
- [x] `sources/governance/constitution.md`: `sdd archive` → `sdd ship` (3곳)
- [x] `sources/governance/agent.md`: `sdd archive` → `sdd ship` (4곳)
- [x] `.harness-kit/agent/constitution.md`: 동기화
- [x] `.harness-kit/agent/agent.md`: 동기화

### 2-2. 템플릿
- [x] `sources/templates/`: spec.md, plan.md, task.md, queue.md, phase.md, pr_description.md — archive → ship 참조 변경
- [x] `.harness-kit/agent/templates/`: 동기화

### 2-3. 슬래시 커맨드
- [x] `sources/commands/hk-ship.md`: `sdd archive` → `sdd ship`, 섹션 제목 변경
- [x] `.claude/commands/hk-ship.md`: 동기화

- [x] Commit: `docs(spec-11-01): update governance, templates, and commands for ship rename`

---

## Task 3: 테스트·문서·백로그 갱신

### 3-1. 테스트
- [x] `tests/test-sdd-archive-completion.sh` → `tests/test-sdd-ship-completion.sh` 리네이밍
- [x] 내부 `sdd archive` 호출 → `sdd ship` 변경
- [x] deprecated 경로 테스트 추가: `sdd archive` 호출 시 stderr 경고 + 정상 동작 확인
- [x] 테스트 실행 → PASS 확인 (8/8 PASS)

### 3-2. 문서
- [x] `docs/REFERENCE.md`: archive → ship 섹션 변경
- [x] `docs/USAGE.md`: 참조 변경
- [x] `README.md`: 참조 변경
- [x] `CHANGELOG.md`: ship rename 항목 추가

### 3-3. 백로그
- [x] `backlog/queue.md`: Icebox의 "`sdd archive` 리네이밍 검토" 항목 제거 (Task 2에서 처리)

- [x] Commit: `test(spec-11-01): rename and update tests for sdd ship`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-11-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-11-01-ship-rename`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: push 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (구현 3 + Ship 1) |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
