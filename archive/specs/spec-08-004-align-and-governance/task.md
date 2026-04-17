# Task List: spec-08-004

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`specs/spec-08-004-align-and-governance/`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (`backlog/phase-08.md` spec 표 — In Progress 마킹)
- [ ] 사용자 Plan Accept

---

## Task 1: hk-align NOW/NEXT 추가

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-08-004-align-and-governance phase-08-work-model`
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. hk-align.md 수정
- [ ] `sources/commands/hk-align.md` Step 4 상태 포맷에 NOW/NEXT 행 추가
- [ ] Commit: `feat(spec-08-004): add now/next display to hk-align status report`

---

## Task 2: agent.md 작업 유형별 행동 규칙 + 완료 체크리스트

### 2-1. agent.md 수정
- [ ] `sources/governance/agent.md` §3 Alignment Phase에 Work Type Behavior Table 추가
- [ ] `sources/governance/agent.md` §6.3에 Completion Checklists (FF/spec-x/phase) 추가
- [ ] `agent/agent.md` 동일 변경 반영
- [ ] Commit: `docs(spec-08-004): add work type behavior rules and completion checklists to agent.md`

---

## Task 3: README.md 최신화

### 3-1. README 갱신
- [ ] sdd 명령 표 갱신 (phase new --base, phase done, specx done, queue 등)
- [ ] 슬래시 커맨드 표 갱신 (현재 실제 커맨드명)
- [ ] 작업 유형 모델 섹션 추가
- [ ] 워크플로 요약 갱신
- [ ] 기타 오래된 정보 정리
- [ ] Commit: `docs(spec-08-004): update readme with phase-08 changes and work type model`

---

## Task 4: Hand-off (필수)

- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-08-004): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-08-004-align-and-governance`
- [ ] **PR 생성**: 타깃 `phase-08-work-model`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
