# Task List: spec-1-001

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (phase-1.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-1-001-permission-friction`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: agent.md에 단일 명령 원칙 추가

### 2-1. 거버넌스 규칙 추가
- [x] `sources/governance/agent.md` §6에 "Bash 호출 규칙" 서브섹션 추가
- [x] `agent/agent.md`에 동일 반영 (도그푸딩)
- [x] Commit: `docs(spec-1-001): add single-command principle to agent.md`

---

## Task 3: sdd status 자체 폴백 강화

### 3-1. sdd CLI 수정
- [x] `sources/bin/sdd`의 `cmd_status()` 함수에 폴백 로직 추가:
  - `.claude/state/current.json` 미존재 시 git/ls 기반 상태 자동 출력
- [x] `scripts/harness/bin/sdd`에 동일 반영 (도그푸딩)
- [x] 폴백 동작 확인: state 파일 임시 이동 후 `sdd status` 실행
- [x] Commit: `feat(spec-1-001): add self-contained fallback to sdd status`

---

## Task 4: settings.json.fragment 중복 규칙 정리

### 4-1. 중복 allow 규칙 제거
- [x] `sources/claude-fragments/settings.json.fragment`에서 `./scripts/` prefix 중복 제거
- [x] `.claude/settings.json`에 동일 반영 (도그푸딩)
- [x] 중복 0건 확인
- [x] Commit: `fix(spec-1-001): remove duplicate permission rules in settings.json`

---

## Task 5: /align 슬래시 커맨드 단순화

### 5-1. 폴백 체인 제거
- [x] `sources/commands/align.md`에서 복합 bash 폴백 블록 제거, `sdd status` 단일 호출로 변경
- [x] `.claude/commands/align.md`에 동일 반영 (도그푸딩)
- [x] `agent/align.md`에서도 폴백 예시 단순화
- [x] `sources/governance/align.md`에도 동일 반영
- [x] Commit: `fix(spec-1-001): simplify align command to single sdd status call`

---

## Task 6: Hand-off

- [x] 전체 변경 파일 검토
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] **Archive Commit**: `docs(spec-1-001): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-1-001-permission-friction`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 5 (Task 1은 브랜치 생성만) |
| **현재 단계** | Hand-off |
| **마지막 업데이트** | 2026-04-10 |
