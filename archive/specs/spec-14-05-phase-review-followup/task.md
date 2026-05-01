# Task List: spec-14-05

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-14.md SPEC 표 — sdd 가 자동 추가, spec-14-04 fix 효과 검증됨)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + spec planning commit

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-14-05-phase-review-followup`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. spec planning commit
- [x] `git add backlog/queue.md backlog/phase-14.md`
- [x] `git add specs/spec-14-05-phase-review-followup/`
- [x] Commit: `chore(spec-14-05): start spec — phase-14 review followup planning`

---

## Task 2: 회귀 테스트 작성 (TDD Red)

### 2-1. test-marker-edge-cases.sh
- [x] 파일 생성: `tests/test-marker-edge-cases.sh`
  - A-1: 다중 마커 쌍 + 같은 라인 두 번 append → 각 영역 1줄 (M1)
  - A-2: 다중 마커 쌍 + 다른 라인 추가 정상 (M1 회귀)
  - B: 마커 부재 파일 append → rc=1 + stderr (M2)
  - C-1: marker 안 `spec-14-011` 만 + needle `\`spec-14-01\`` → false (m1)
  - C-2: marker 안 `\`spec-14-01\`` + needle `\`spec-14-01\`` → true (m1 회귀)
- [x] `chmod +x tests/test-marker-edge-cases.sh`

### 2-2. test-bash-policy-headers.sh
- [x] 파일 생성: `tests/test-bash-policy-headers.sh`
  - "bash 4.0+" / "bash 4.0 전용" 표현 0 매치 (M3)
- [x] `chmod +x tests/test-bash-policy-headers.sh`

### 2-3. Fail 확인 (TDD Red)
- [x] 실행: `bash tests/test-marker-edge-cases.sh` → A-1, B, C-1 fail (현재 가드 부재)
- [x] 실행: `bash tests/test-bash-policy-headers.sh` → fail (8 파일 매치)
- [x] Commit: `test(spec-14-05): add regression tests for marker edge cases + bash policy headers`

---

## Task 3: M1 + M2 — sdd_marker_append 보강 (TDD Green)

### 3-1. sources 변경
- [x] `sources/bin/lib/common.sh:80-99` awk 패턴 보강
  - 마커 부재 사전 체크 (start/end grep) → `warn + return 1`
  - awk: `in_section` 게이트 + 첫 end 직후 `found` reset

### 3-2. 도그푸딩 동기화
- [x] `.harness-kit/bin/lib/common.sh` 동일 변경

### 3-3. Pass 확인 (부분)
- [x] `bash tests/test-marker-edge-cases.sh` → A-1, A-2, B PASS (C 는 m1 task 후)
- [x] Commit: `fix(spec-14-05): make sdd_marker_append safe for multi-marker pairs and missing markers`

---

## Task 4: m1 — spec_new 정확 토큰 매칭 (TDD Green 계속)

### 4-1. sources 변경
- [x] `sources/bin/sdd:745` needle 을 `\`${short_id}\`` (백틱 포함) 으로

### 4-2. 도그푸딩 동기화
- [x] `.harness-kit/bin/sdd` 동일 변경

### 4-3. Pass 확인
- [x] `bash tests/test-marker-edge-cases.sh` → 모든 검증 PASS
- [x] Commit: `fix(spec-14-05): scope spec_new marker grep to backtick-bounded ID token`

---

## Task 5: M3 — bash 정책 헤더 주석 일괄 갱신 (TDD Green 계속)

### 5-1. sources 변경
- [x] `sources/bin/lib/common.sh:3` 헤더 주석 갱신
- [x] `sources/bin/bb-pr:4` 헤더 주석 갱신
- [x] `sources/bin/sdd:5` 헤더 주석 갱신
- [x] `sources/hooks/_lib.sh:19` 헤더 주석 갱신
- [x] `install.sh:24` 헤더 주석 갱신

### 5-2. 도그푸딩 동기화 (4 파일)
- [x] `.harness-kit/bin/lib/common.sh:3`
- [x] `.harness-kit/bin/bb-pr:4`
- [x] `.harness-kit/bin/sdd:5`
- [x] `.harness-kit/hooks/_lib.sh:19`

### 5-3. Pass 확인
- [x] `bash tests/test-bash-policy-headers.sh` → PASS
- [x] `grep -rn "bash 4\.0+" sources/ install.sh .harness-kit/` → 0 매치 (단, .harness-kit/agent/templates/ 제외)
- [x] Commit: `chore(spec-14-05): align bash version comments with 3.2+ policy across all scripts`

---

## Task 6: M4 — install.sh sed 견고화

### 6-1. install.sh 변경
- [x] `install.sh:419, 422` 의 `sed && rm` → `sed || die` + 별 줄 `rm`

### 6-2. Pass 확인
- [x] `bash tests/test-gitignore-idempotent.sh` → 22/22 PASS (회귀)
- [x] Commit: `fix(spec-14-05): harden install.sh sed-toggle against silent failures`

---

## Task 7: m2 — phase-14.md row 정규화

### 7-1. backlog/phase-14.md 갱신
- [x] sdd:specs 마커 안 4 row (spec-14-01 ~ 04) 를 sdd auto-gen 양식으로 정규화 (백틱 포함)

### 7-2. Pass 확인
- [x] `bash .harness-kit/bin/sdd status` 정상
- [x] `bash .harness-kit/bin/sdd phase show phase-14` 정상 (phase show 명령 있다면)
- [x] Commit: `chore(spec-14-05): normalize phase-14.md spec rows to sdd auto-gen format`

---

## Task 8: Ship

- [x] 코드 품질 점검 — bash/markdown 만이라 lint/typecheck 대상 없음
- [x] 전체 테스트 실행 → 모두 PASS
  - `bash tests/test-marker-edge-cases.sh`
  - `bash tests/test-bash-policy-headers.sh`
  - phase-14 회귀: queued-marker, doctor-bash, gitignore-idempotent, marker-append-guard
  - sdd 핵심 회귀: queue-redesign, phase-done-accuracy, spec-completeness, status-cross-check
- [x] **walkthrough.md 작성** — phase 회고 → 본 spec 의 직접 결과 추적, 각 잔재 처리 결정 기록
- [x] **pr_description.md 작성** — 6 변경 + 통합 회귀 PASS 수치 요약
- [x] **Ship Commit**: `docs(spec-14-05): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-14-05-phase-review-followup`
- [x] **PR 생성**: `gh pr create`
- [x] **사용자 알림**: 푸시 완료 + PR URL. **본 PR 머지 후 phase-14 의 모든 잔재 클린 + `/hk-phase-ship` 으로 phase 마무리 가능**.

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 (Pre-flight 별도) |
| **예상 commit 수** | 7 (Task 1~7 각 1, Task 8 ship 1, 단 1 은 브랜치 생성 + commit 통합) |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-04-25 |
