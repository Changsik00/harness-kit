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
- [x] `git checkout -b spec-x-claude-md-slim` (main 기준) — 본 spec 정렬 전 이미 분기되어 있었음
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 참조 사전 검색

### 2-1. 다른 곳의 인용 검색
- [x] `grep -rn "릴리스 전략" --include="*.md" .` 실행
- [x] `grep -rn "현재 단계" --include="*.md" .` 실행
- [x] 발견된 참조 목록을 walkthrough 초안에 메모 (실제 갱신은 Task 4 에서) — 결과: archive immutable + 동음이의만 발견. CHANGELOG 의 과거 사실 기록은 유지. **갱신 필요 0건**.
- [x] Commit: 없음 (조사 단계, 결과는 메모리 / walkthrough 에 기록)

---

## Task 3: `docs/release-strategy.md` 신규 생성

### 3-1. 새 파일 작성
- [x] `docs/release-strategy.md` 생성 — CLAUDE.md 의 "릴리스 전략" 섹션 (현재 line 49-84) 내용을 무손실 복사
- [x] 헤더 `## 릴리스 전략 (이 프로젝트 전용)` → `# 릴리스 전략 (이 저장소 전용)` 으로 격상 (h1, 단독 문서)
- [x] 부제목 `### 절차` / `### 룰` / `### .harness-kit/installed.json 동기화 주의` → h2 로 격상 (단독 문서이므로 한 단계 위로)
- [x] 검증: `diff` 로 sed h2→h1 / h3→h2 변환 후 본문 일치 확인 (출력 없음)
- [x] Commit: `docs(spec-x-claude-md-slim): extract release strategy to docs/release-strategy.md` (b88fa16)

---

## Task 4: `CLAUDE.md` 슬림화

### 4-1. 릴리스 전략 섹션을 포인터로 대체
- [x] line 49-84 "## 릴리스 전략 (이 프로젝트 전용)" 섹션을 1문장 포인터로 축소
- [x] "## 현재 단계" 섹션 (line 93-95) 삭제 — stale (Phase 4 표기 vs 실제 phase-17 완료)
- [x] 검증:
  - `wc -l CLAUDE.md` = 71 (≤ 75 ✓)
  - `grep -c "릴리스 전략" CLAUDE.md` = 1 ✓
  - `grep "현재 단계" CLAUDE.md` 결과 없음 ✓
  - `@.harness-kit/CLAUDE.fragment.md` import 1건 보존 ✓
  - `HARNESS-KIT:BEGIN` / `HARNESS-KIT:END` 마커 보존 ✓
- [x] Commit: `docs(spec-x-claude-md-slim): slim root CLAUDE.md (release strategy → pointer, drop stale phase note)` (626ecf0)

---

## Task 5: 외부 참조 갱신 (조건부)

### 5-1. Task 2 검색 결과 처리
- [-] Task 2 에서 발견한 참조 중 실제 갱신이 필요한 항목 처리 — **갱신 대상 0건** (archive immutable + CHANGELOG 의 과거 사실 기록 + 동음이의만)
- [-] 발견 0건이면 본 task 는 `[-]` 처리하고 walkthrough 에 기록
- [-] Commit (필요 시): `docs(spec-x-claude-md-slim): update references to release strategy location` — 변경 없음

---

## Task 6: 회귀 테스트

### 6-1. 회귀 테스트 실행
- [x] **발견**: `tests/run-all.sh` 부재 (plan 의 문서 오류, icebox 후보). 대신 본 변경 (CLAUDE.md docs-only) 과 관련된 핵심 테스트 3개 직접 실행
- [x] `bash tests/test-install-claude-import.sh` → ✅ ALL PASS (6/6)
- [x] `bash tests/test-marker-append-guard.sh` → ✅ ALL 5 CHECKS PASSED
- [x] `bash tests/test-marker-edge-cases.sh` → ✅ ALL 8 CHECKS PASSED
- [x] `bash .harness-kit/bin/sdd test passed` → 2026-05-18T06:30:39Z
- [x] Commit: 없음 (테스트 실행만)

---

## Task 7: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] **walkthrough.md 작성** — 결정 기록 (3건), 사용자 협의 (2건), 검증 결과, 발견 사항 (3건), 이월 항목
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Ship Commit**: `docs(spec-x-claude-md-slim): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-x-claude-md-slim`
- [x] **PR 생성**: `/hk-pr-gh` 로 자동 생성
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight 제외) |
| **예상 commit 수** | 3-4 (조사·검증 task 는 무 commit, Task 5 조건부) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-18 |
