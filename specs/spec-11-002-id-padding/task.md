# Task List: spec-11-002

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

## Task 1: sdd CLI 패딩 로직 수정

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-11-002-id-padding`

### 1-2. phase ID 생성 패딩 적용
- [x] `sources/bin/sdd`: `phase_new` 함수의 `local id="phase-${next}"` → `local id="phase-$(printf '%02d' "$next")"`
- [x] `.harness-kit/bin/sdd`: 동기화
- [x] 기존 테스트 실행 → PASS 확인 (8/8)
- [x] Commit: `refactor(spec-11-002): add 2-digit zero padding to phase id generation`

---

## Task 2: 기존 디렉토리/파일 일괄 마이그레이션

### 2-1. backlog 파일 리네이밍
- [ ] `git mv backlog/phase-{1..9}.md` → `backlog/phase-{01..09}.md` (9개)

### 2-2. spec 디렉토리 리네이밍
- [ ] `git mv specs/spec-{1..9}-*` → `specs/spec-{01..09}-*` (33개)

### 2-3. backlog 파일 내부 참조 갱신
- [ ] 각 `phase-0N.md`의 헤딩, spec 표, 디렉토리 참조 패딩
- [ ] `queue.md` 완료 섹션의 phase 참조 패딩

### 2-4. spec 디렉토리 내부 파일 참조 갱신
- [ ] spec.md, plan.md, task.md 등의 `spec-N-` → `spec-0N-`, `phase-N` → `phase-0N` 참조

### 2-5. state.json 갱신
- [ ] `.claude/state/current.json`의 phase/spec 값 패딩 (해당 시)

### 2-6. Icebox 항목 제거
- [ ] `backlog/queue.md` Icebox의 "식별자 2자리 패딩" 항목 제거

- [ ] Commit: `refactor(spec-11-002): migrate all phase/spec ids to 2-digit padding`

---

## Task 3: 거버넌스·문서 예시 갱신

### 3-1. 거버넌스 원본
- [ ] `sources/governance/constitution.md`: §6 예시 패딩 (`phase-1` → `phase-01` 등)
- [ ] `sources/governance/agent.md`: §4.1 레이아웃 예시 패딩
- [ ] `sources/claude-fragments/CLAUDE.fragment.md`: 핵심 규칙 예시 패딩

### 3-2. 도그푸딩 동기화
- [ ] `.harness-kit/agent/constitution.md`: 동기화
- [ ] `.harness-kit/agent/agent.md`: 동기화
- [ ] `.harness-kit/CLAUDE.fragment.md`: 동기화

- [ ] Commit: `docs(spec-11-002): update governance examples to 2-digit padded ids`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] `sdd status` 정상 동작 확인
- [ ] `ls specs/` 정렬 확인
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-11-002): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-11-002-id-padding`
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
