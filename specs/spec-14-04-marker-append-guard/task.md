# Task List: spec-14-04

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-14.md SPEC 표 — 본 spec Task 1 에서 수동 보정. 이 작업이 본 spec 이 수정하는 버그의 직접 결과)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + spec planning + phase-14.md sync 보정 commit

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-14-04-marker-append-guard`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. phase-14.md sdd:specs 마커 수동 보정
- [x] 마커 안에 spec-14-04 행 추가:
  ```
  | spec-14-04 | marker-append-guard | P1 | In Progress | `specs/spec-14-04-marker-append-guard/` |
  ```
  > 본 spec 이 수정하는 버그의 정확한 결과 — sdd spec new 가 phase 본문 텍스트 매치로 update_row 만 호출하고 마커 안 추가 안 함.

### 1-3. spec planning + phase 보정 commit
- [x] `git add backlog/queue.md backlog/phase-14.md`
- [x] `git add specs/spec-14-04-marker-append-guard/`
- [x] Commit: `chore(spec-14-04): start spec — planning + phase specs marker fixup (last manual fixup)`

---

## Task 2: 회귀 테스트 작성 (TDD Red)

### 2-1. 테스트 스크립트 추가
- [x] 파일 생성: `tests/test-marker-append-guard.sh`
  - A-1: `sdd_marker_append` 같은 라인 두 번 → 1줄 (단위)
  - A-2: 다른 라인 두 번 → 두 라인 모두 (회귀 점검)
  - B: `sdd specx done <slug>` 두 번 → 1줄
  - C: `sdd phase done <id>` 두 번 → 1줄
  - D: phase-N.md 본문에 "spec-N-NN" 텍스트 미리 적힌 상태 + `sdd spec new` → 마커 안 행 정확히 1줄
- [x] 실행 권한 부여: `chmod +x tests/test-marker-append-guard.sh`

### 2-2. Fail 확인 (TDD Red)
- [x] 실행: `bash tests/test-marker-append-guard.sh`
- [x] 기대 결과: A-1, B, C, D 모두 FAIL (현재 가드/grep-범위 부재로 중복/누락). A-2 만 PASS.
- [x] Commit: `test(spec-14-04): add regression test for marker append idempotency + scoped grep`

---

## Task 3: 가드 + grep 범위 한정 구현 (TDD Green)

### 3-1. sdd_marker_append 멱등 가드 (sources)
- [x] `sources/bin/lib/common.sh:80-89` awk 본문 교체 — in-marker 동일 라인 검사

### 3-2. sdd_marker_grep 신규 헬퍼 (sources)
- [x] `sources/bin/lib/common.sh` `sdd_marker_update_row` 다음에 함수 추가

### 3-3. spec_new grep 범위 한정 (sources)
- [x] `sources/bin/sdd:745` `grep -q ... "$phase_file"` → `sdd_marker_grep "$phase_file" "specs" "${short_id}"`

### 3-4. 도그푸딩 동기화
- [x] `.harness-kit/bin/lib/common.sh` 동일 변경
- [x] `.harness-kit/bin/sdd` 동일 변경

### 3-5. Pass 확인 (TDD Green)
- [x] 실행: `bash tests/test-marker-append-guard.sh` → 모두 PASS
- [x] 회귀: `tests/test-sdd-queue-redesign.sh`, `test-sdd-phase-done-accuracy.sh`, `test-sdd-spec-completeness.sh` 모두 PASS
- [x] Commit: `fix(spec-14-04): make marker_append idempotent + scope spec_new grep to marker area`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 코드 품질 점검 — bash/markdown 만이라 lint/typecheck 대상 없음
- [x] 전체 테스트 실행 → 모두 PASS
  - `bash tests/test-marker-append-guard.sh`
  - phase-14 spec 별 회귀: `test-sdd-queued-marker-removed.sh`, `test-doctor-bash-version.sh`, `test-gitignore-idempotent.sh`
  - sdd 핵심 회귀: `test-sdd-queue-redesign.sh`, `test-sdd-phase-done-accuracy.sh`, `test-sdd-spec-completeness.sh`, `test-sdd-status-cross-check.sh`
- [x] **walkthrough.md 작성** — 결정/발견 위주 (특히 scope 확장 결정 및 phase-14.md sync 자가-회복 첫 사례)
- [x] **pr_description.md 작성** — 템플릿 준수
- [x] **Ship Commit**: `docs(spec-14-04): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-14-04-marker-append-guard`
- [x] **PR 생성**: `gh pr create` 사용
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고 후 사용자 머지 대기. **마지막 spec 머지 후 phase-14 done 안내 (`/hk-phase-ship` 또는 `sdd phase done`)**.

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (Pre-flight 별도) |
| **예상 commit 수** | 4 |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-04-25 |
