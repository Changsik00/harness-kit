# Task List: spec-17-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (sdd spec new)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] phase-17.md 의 spec table 재조정 (sdd 가 sequential 17-02 할당 → 설계 표 정렬)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-17-02-accessibility-install-and-entry` (from `phase-17-coherence-fix`)
- [ ] Commit: 없음

### 1-2. 기획 산출물 commit
- [ ] `git add backlog/phase-17.md backlog/queue.md specs/spec-17-02-accessibility-install-and-entry/`
- [ ] Commit: `chore(spec-17-02): add planning artifacts + reconcile phase-17 spec numbering`

---

## Task 2: `/hk` 슬래시 커맨드 작성

### 2-1. sources/commands/hk.md 신규 작성
- [ ] `sources/commands/hk.md` 작성 — plan.md §Proposed Changes 의 outline 그대로 (frontmatter + 7 상태 매핑 본문 + bash code block)
- [ ] 본문에 `sdd status --json` 호출 + jq 파싱 + 7 분기 + fallback 8 가지 모두 포함
- [ ] Commit: `feat(spec-17-02): add /hk single entry-point slash command`

### 2-2. install 미러 동기화
- [ ] `cp sources/commands/hk.md .claude/commands/hk.md`
- [ ] `diff sources/commands/hk.md .claude/commands/hk.md` → 빈 출력
- [ ] Commit: `feat(spec-17-02): sync /hk to install mirror`

---

## Task 3: README onboarding 갱신

### 3-1. README Step 1 에 /hk 안내 추가
- [ ] `README.md` 의 Step 1 (line 126 주변, `/hk-align` 설명 다음) 에 `/hk` 소개 섹션 3-5 줄 추가
- [ ] 영문 slogan / 한국어 부제 보존 (phase-16 결과)
- [ ] Commit: `docs(spec-17-02): add /hk to README onboarding Step 1`

---

## Task 4: install 검증

### 4-1. get.sh dry-run 시뮬레이션
- [ ] 임시 디렉토리 생성 + curl 로 get.sh 가져와 dry-run 실행 (실제 변경 없음)
- [ ] 출력에 변경 list 가 나오고 exit 0 인지 확인
- [ ] cleanup
- [ ] Commit: 없음 (검증만)

---

## Task 5: 단위 검증

### 5-1. plan.md §검증 계획 grep 항목
- [ ] hk.md 파일 존재 + install 미러 동일
- [ ] 7 상태 키워드 (Active phase 없음 / Plan Accept / /hk-ship / /hk-phase-ship) 모두 hit
- [ ] README 갱신 — `/hk` 안내 hit (≥2 곳)
- [ ] `/hk` 시연 (현 phase-17 상태 → "spec/plan/task 작성 필요" 또는 "Plan Accept 가능" 안내)
- [ ] 회귀: `bash tests/test-sdd-marker-idempotent.sh` 3/3 + `bash tests/test-drift-stale-adr.sh` 3/3
- [ ] Commit: 없음 (검증만)

---

## Task 6: Ship

- [ ] **walkthrough.md 작성** — 결정 기록 + 검증 로그 + /hk 디자인 발견
- [ ] **pr_description.md 작성** — 변경 파일 + PR target=phase-17-coherence-fix + Icebox "접근성 개선" closed 명시
- [ ] **Ship Commit**: `docs(spec-17-02): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-17-02-accessibility-install-and-entry`
- [ ] **PR 생성**: `gh pr create --base phase-17-coherence-fix`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 (Pre-flight 별도) |
| **예상 commit 수** | 5 (planning + hk.md + sync + README + ship) — Task 4/5 검증만 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-17 |
