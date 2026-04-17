# Task List: spec-08-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`specs/spec-08-01-queue-redesign/`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (`backlog/phase-08.md` spec 표 — In Progress 마킹)
- [x] 사용자 Plan Accept

---

## Task 1: constitution 작업 유형 모델 정의

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-08-01-queue-redesign`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. constitution 변경
- [x] `sources/governance/constitution.md` — §2 뒤에 §3 Work Type Model 추가 (Phase/Spec/spec-x/Icebox 정의)
- [x] 기존 §3 이후 섹션 번호 순차 변경
- [x] `agent/constitution.md` 동일 변경 반영 (도그푸딩)
- [x] Commit: `docs(spec-08-01): define work type model in constitution`

---

## Task 2: queue.md 템플릿 재설계

### 2-1. 템플릿 재설계
- [x] `sources/templates/queue.md` — NOW/NEXT/Icebox 구조로 교체 (신규 sdd 마커 포함)
- [x] Commit: `refactor(spec-08-01): redesign queue template with now-next-icebox structure`

### 2-2. phase.md 템플릿 갱신
- [x] `sources/templates/phase.md` — spec 표 상태 컬럼에 `In Progress` 추가, 메타에 `Base Branch` 행 추가
- [x] Commit: `refactor(spec-08-01): add in-progress state and base-branch field to phase template`

---

## Task 3: sdd status — NEXT 계산 추가

### 3-1. 테스트 작성 (TDD Red)
- [x] `tests/test-sdd-queue-redesign.sh` 신규 작성 (NEXT + queue 구조 검증 포함)
- [x] 테스트 실행 → Fail 확인
- [x] Commit: `test(spec-08-01): add failing tests for sdd status next computation and sdd queue output`

### 3-2. 구현 (TDD Green)
- [x] `sources/bin/sdd` — `compute_next_spec()` 함수 추가
- [x] `cmd_status()` — NEXT 행 출력 추가
- [x] `cmd_queue()` — 구조화 출력 + `--raw` 옵션 추가
- [x] 테스트 실행 → 5/5 Pass
- [x] Commit: `feat(spec-08-01): add next-spec computation to sdd status and structured sdd queue output`

---

## Task 4: sdd queue — 구조화 출력 개선

[-] Task 3에서 함께 구현됨 — 별도 커밋 불필요. (테스트 5종 + 구현이 단일 커밋으로 처리)

---

## Task 5: 도그푸딩 반영

### 5-1. 현재 프로젝트 반영
- [x] `backlog/queue.md` — 신규 마커 구조로 수동 재작성 (NOW=spec-08-01, NEXT=spec-08-02 반영)
- [x] `scripts/harness/bin/sdd` — sources/bin/sdd와 동일 파일 (이미 반영됨)
- [x] 테스트 실행 → 5/5 Pass
- [x] Commit: `chore(spec-08-01): apply queue redesign dogfooding to current project`

---

## Task 6: Hand-off (필수)

- [x] 전체 테스트 실행 → 5/5 PASS (`bash tests/test-sdd-queue-redesign.sh`)
- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Archive Commit**: `docs(spec-08-01): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-08-01-queue-redesign`
  - `phase-08-work-model` 브랜치 생성 + push 완료
  - PR 타깃: `phase-08-work-model`
- [x] **사용자 알림**: 푸시 완료 + PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 8 |
| **현재 단계** | Hand-off 완료 |
| **마지막 업데이트** | 2026-04-11 |
