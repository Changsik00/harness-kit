# Task List: spec-14-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-14.md SPEC 표는 spec-14-04 에서 일괄 정리)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + spec planning + bug-02 + phase-14.md specs 마커 보정 commit

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-14-02-doctor-bash-version`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. phase-14.md specs 마커 수동 보정
- [x] `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이에 spec-14-01 (Merged), spec-14-02 (In Progress) 행 추가.
  ```
  | spec-14-01 | sdd-queued-marker | P1 | Merged | `specs/spec-14-01-sdd-queued-marker/` |
  | spec-14-02 | doctor-bash-version | P1 | In Progress | `specs/spec-14-02-doctor-bash-version/` |
  ```
  > 근본 원인 (sdd 가 sync 못한 이슈) 은 spec-14-04 marker_append guard 에서 다룸 — 본 spec 은 산물 정리만.

### 1-3. spec planning + 참조 자료 commit
- [x] `git add backlog/queue.md backlog/phase-14.md`
- [x] `git add specs/spec-14-02-doctor-bash-version/`
- [x] `git add docs/harness-kit-bug-02-doctor-bash-version-false-positive.md`
- [x] Commit: `chore(spec-14-02): start spec — planning + bug-02 reference + phase specs marker fixup`

---

## Task 2: 회귀 테스트 작성 (TDD Red)

### 2-1. 테스트 스크립트 추가
- [x] 파일 생성: `tests/test-doctor-bash-version.sh`
  - 검증 1 (lint-style): `sources/bin/sdd` 에 `_check_tool "bash" "4.0" "required"` 가 없음을 grep 으로 확인
  - 검증 2 (실행): `bash sources/bin/sdd doctor` 출력에 `❌ bash` 패턴이 없음
  - 검증 3 (실행): doctor 출력에 `bash` 항목이 ✅ 또는 ⚠️ 로 표시됨 (FAIL 대신 PASS/WARN)
- [x] 실행 권한 부여: `chmod +x tests/test-doctor-bash-version.sh`

### 2-2. Fail 확인 (TDD Red)
- [x] 실행: `bash tests/test-doctor-bash-version.sh`
- [x] 기대 결과: 검증 1, 2, 3 모두 FAIL (현재 sdd 가 4.0 required 이고 bash 3.2 환경에서 ❌ bash 출력)
- [x] Commit: `test(spec-14-02): add regression test for doctor bash version`

---

## Task 3: doctor + 정책 갱신 (TDD Green)

### 3-1. sources/bin/sdd:1427 완화
- [x] `_check_tool "bash" "4.0" "required"` → `_check_tool "bash" "3.2" "required" "macOS 기본 bash 로도 동작 — 4+ 권장 (일부 환경 일관성)"`

### 3-2. 도그푸딩 동기화
- [x] `.harness-kit/bin/sdd` 의 동일 라인을 sources 와 같이 갱신

### 3-3. CLAUDE.md 정책 갱신
- [x] line 9 의 "필수 도구" 행을 `bash 3.2+` 로 + 부연 설명
- [x] line 36 의 "bash 4.0+ 전용" 표현을 "bash 3.2+ 호환 + 4+ 전용 기능 사용 금지" 로

### 3-4. Pass 확인 (TDD Green)
- [x] 실행: `bash tests/test-doctor-bash-version.sh`
- [x] 실행: `bash .harness-kit/bin/sdd doctor` → 출력에 `✅ bash 3.x` 확인
- [x] Commit: `fix(spec-14-02): relax doctor bash requirement to match actual code support`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 코드 품질 점검 — bash/markdown 만이라 lint/typecheck 대상 없음
- [x] 전체 테스트 실행 → 모두 PASS
  - `bash tests/test-doctor-bash-version.sh`
  - `bash tests/test-hk-doctor.sh` (회귀 점검)
  - `bash tests/test-sdd-queued-marker-removed.sh` (회귀 점검)
- [x] **walkthrough.md 작성** — 결정/발견 위주
- [x] **pr_description.md 작성** — 템플릿 준수
- [x] **Ship Commit**: `docs(spec-14-02): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-14-02-doctor-bash-version`
- [x] **PR 생성**: `gh pr create` 사용
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고 후 사용자 머지 대기

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (Pre-flight 별도) |
| **예상 commit 수** | 4 |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-04-25 |
