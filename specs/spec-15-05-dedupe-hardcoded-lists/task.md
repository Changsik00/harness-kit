# Task List: spec-15-05

> One Task = One Commit. 매 commit 직후 본 파일 체크박스 갱신.

## Pre-flight

- [x] Spec ID 확정 + 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성
- [x] phase-15.md spec 표 자동 갱신 (sdd 처리)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-15-05-dedupe-hardcoded-lists` (phase-15-upgrade-safety 에서 분기)

---

## Task 2: TDD Red — 신규 회귀 테스트 작성

### 2-1. tests/test-install-manifest-sync.sh
- [ ] governance 디렉토리 명단 vs install 결과 1:1 (count + content)
- [ ] templates 디렉토리 명단 vs install 결과 1:1 (count + content)
- [ ] ≥ 4 checks

### 2-2. tests/test-update-stateful.sh — Scenario 6 추가
- [ ] state.json 에 임의 `_testCustomField: "preserved"` 추가 → update → 보존 확인
- [ ] kitVersion 갱신 + installedAt 갱신 검증
- [ ] ≥ 2 checks

### 2-3. 실행 → Red 확인
- [ ] manifest-sync.sh: 현재 사진은 일치 (검증 통과 가능). 의도적 drift 시뮬레이션 어려움 — 본 테스트는 *향후 drift 감지* 용도라 Red 가 "동작 검증" 으로 변환. 시나리오 6: 현재 update.sh 가 inclusion (whitelist) 라 `_testCustomField` 보존 안 됨 → fail
- [ ] Commit: `test(spec-15-05): add manifest sync test and state exclusion scenario`

---

## Task 3: TDD Green — install.sh + update.sh 수정

### 3-1. install.sh
- [ ] line 257-259 governance 루프 → 디렉토리 glob
- [ ] line 262-264 templates 루프 → 디렉토리 glob

### 3-2. update.sh
- [ ] line 119-121 state 백업 inclusion → exclusion (`del(.kitVersion, .installedAt)`)
- [ ] 주석 갱신

### 3-3. 검증
- [ ] `bash tests/test-install-manifest-sync.sh` → 모두 PASS
- [ ] `bash tests/test-update-stateful.sh` → 시나리오 6 포함 PASS
- [ ] `bash tests/test-version-bump.sh` → 전체 스위트 FAIL=0
- [ ] Commit: `refactor(spec-15-05): replace hardcoded lists with directory glob and state exclusion`

---

## Task 4: Ship

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-15-05): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-15-05-dedupe-hardcoded-lists`
- [ ] **PR 생성**: `gh pr create --base phase-15-upgrade-safety`

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 (Task 1 브랜치 생성만) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-28 |
