# Task List: spec-14-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-14.md SPEC 표 — 본 spec Task 1 에서 수동 보정)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + spec planning + phase-14.md 보정 commit

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-14-03-gitignore-idempotent`
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. phase-14.md sdd:specs 마커 보정
- [ ] 마커 안에 spec-14-03 행 추가:
  ```
  | spec-14-03 | gitignore-idempotent | P1 | In Progress | `specs/spec-14-03-gitignore-idempotent/` |
  ```
  > sdd 가 sync 못한 잔재 — 근본 원인은 spec-14-04.

### 1-3. spec planning + phase 보정 commit
- [ ] `git add backlog/queue.md backlog/phase-14.md`
- [ ] `git add specs/spec-14-03-gitignore-idempotent/`
- [ ] Commit: `chore(spec-14-03): start spec — planning + phase specs marker fixup`

---

## Task 2: 회귀 테스트 작성 (TDD Red)

### 2-1. 테스트 스크립트 추가
- [ ] 파일 생성: `tests/test-gitignore-idempotent.sh`
  - D-1~D-4: 첫 install 후 4 라인 (헤더 + .harness-kit/ + .harness-backup-*/ + .claude/state/) 각각 1 회
  - D-5~D-8: 재install (동일 옵션) 후 4 라인 각각 1 회
  - E: 헤더만 수동 삭제 → 재install → 4 라인 각각 1 회 (헤더 복원, 라인 중복 없음)
  - F: 사용자가 미리 `.harness-kit/` 적은 후 첫 install → 그 라인 1 회 + 헤더 + 다른 2 라인
  - G: `.harness-backup-*/` 만 지운 후 재install → 보강 + 다른 라인 변화 없음
  - H: --gitignore → --no-gitignore 토글 → `.harness-kit/` 부재 + `!.harness-kit/` 1 회
- [ ] 실행 권한 부여: `chmod +x tests/test-gitignore-idempotent.sh`

### 2-2. Fail 확인 (TDD Red)
- [ ] 실행: `bash tests/test-gitignore-idempotent.sh`
- [ ] 기대 결과: D-1~D-8 + H 는 PASS (현재 install.sh 도 `.harness-kit/` 라인은 라인별 처리), E + F + G 가 FAIL (헤더 누락 / 사전 라인 / 라인 일부 누락 케이스)
- [ ] Commit: `test(spec-14-03): add idempotency regression test for .gitignore`

---

## Task 3: install.sh 멱등화 (TDD Green)

### 3-1. install.sh:402-445 재작성
- [ ] `_gi_ensure()` 헬퍼 함수 도입 (블록 스코프)
- [ ] 헤더 단독 라인별 grep + ensure
- [ ] 4 라인 각각 라인별 grep + ensure
- [ ] 토글 (`.harness-kit/` ↔ `!.harness-kit/`) sed 변환 + ensure

### 3-2. Pass 확인 (TDD Green)
- [ ] 실행: `bash tests/test-gitignore-idempotent.sh`
- [ ] 기대 결과: 모든 시나리오 (D, E, F, G, H) PASS
- [ ] 회귀: `bash tests/test-gitignore-config.sh` PASS (기존 A~G 시나리오 영향 없음)
- [ ] Commit: `fix(spec-14-03): make .gitignore idempotent at line level`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 코드 품질 점검 — bash/markdown 만이라 lint/typecheck 대상 없음
- [ ] 전체 테스트 실행 → 모두 PASS
  - `bash tests/test-gitignore-idempotent.sh`
  - `bash tests/test-gitignore-config.sh` (회귀)
  - `bash tests/test-install-layout.sh` (회귀)
  - `bash tests/test-doctor-bash-version.sh` (회귀)
- [ ] **walkthrough.md 작성** — 결정/발견 위주
- [ ] **pr_description.md 작성** — 템플릿 준수
- [ ] **Ship Commit**: `docs(spec-14-03): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-14-03-gitignore-idempotent`
- [ ] **PR 생성**: `gh pr create` 사용
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고 후 사용자 머지 대기

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (Pre-flight 별도) |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-25 |
