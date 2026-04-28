# Task List: spec-15-01 (Research)

> Research Spec 이므로 task 는 "분석 단위" 로 끊습니다 — 각 task 의 산출물은 `spec.md` 의 한 섹션.
> One Task = One Commit. 단, Pre-flight 단계는 본 파일 작성 자체이므로 commit 없이 체크.

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd spec new upgrade-danger-audit` 완료)
- [x] spec.md §1~§3 작성 (배경, 질문, DoD)
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 — phase-15.md spec 표 자동 갱신됨 (sdd 가 처리)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-15-01-upgrade-danger-audit`
- [x] Commit: 없음

---

## Task 2: 과거 4건 버그 카탈로그 + 공통 패턴 (spec.md §4)

### 2-1. spec 디렉토리 정독
- [ ] `archive/specs/spec-x-update-preserve-state/` 또는 `specs/` 의 spec.md / walkthrough / pr_description 정독
- [ ] `spec-x-install-phase-ship-template` 동일
- [ ] `spec-x-sdd-phase-activate` 동일
- [ ] gitignore 중복 버그 — 관련 spec 디렉토리 또는 git log 검색으로 식별 + 정독

### 2-2. PR diff 확인
- [ ] `gh pr view <num>` 또는 `git show <merge-commit>` 으로 4건 PR 의 실제 코드 변경 확인
- [ ] 어느 layer 에서 깨졌는지 (state/파일/마커/사용자영역) + 공통 trigger 추출

### 2-3. spec.md §4 작성
- [x] §4.1 버그 카탈로그 (표 — Spec / Layer / Trigger / Fix 요지)
- [x] §4.2 공통 패턴 3개 (Schema Drift / User Content Blindness / Insufficient Idempotency)
- [x] §4.3 동일 패턴 잠재 위험 (3개 패턴별 후보 표)
- [ ] Commit: `docs(spec-15-01): catalog past 4 bugs and extract common pattern`

---

## Task 3: install.sh / update.sh 정책 단면 (spec.md §5)

### 3-1. install.sh 라인 단위 분류
- [ ] 각 처리 단위 (cp / sed / 마커 머지 / state 작성 등) 식별
- [ ] 각각 OVERWRITE / MERGE / SKIP-IF-EXISTS / APPEND-IDEMPOTENT 중 하나로 분류
- [ ] 정책 미명시 항목 식별

### 3-2. update.sh 동일
- [ ] 백업 / 복원 / 머지 / 갱신 처리 단위 분류
- [ ] state.json 백업/복원 키 명시 (현재 6개 필드 — phase, spec, branch, baseBranch, planAccepted, lastTestPass)
- [ ] claude-fragments 머지 정책 분석

### 3-3. spec.md §5 작성
- [x] §5.1 install.sh 정책 분류표 (12개 처리 단위)
- [x] §5.2 update.sh 보존 메커니즘
- [x] §5.3 uninstall.sh 청소 정책 + 🚨 KIT_COMMANDS stale Critical 발견
- [x] §5.4 P0/P1/P2 위험 등급 종합
- [ ] Commit: `docs(spec-15-01): map install/update/uninstall policy surface and find P0 latent bug`

---

## Task 4: Stateful Fixture 설계 옵션 비교 (spec.md §6)

### 4-1. 옵션 A (함수 합성) 설계
- [ ] 기존 `make_fixture()` (`tests/test-sdd-base-branch.sh`) 분석
- [ ] mixin 함수 후보 (`with_in_flight_phase`, `with_pre_defined_phases`, `with_dirty_queue`, `with_customized_fragment` 등) 의사코드 작성
- [ ] 5개 통합 테스트 시나리오 (phase-15.md §통합 테스트) 를 옵션 A 로 어떻게 표현할지 한 시나리오 시연 (의사코드)

### 4-2. 옵션 B (declarative manifest) 설계
- [ ] JSON 또는 YAML 시나리오 명세 예시 작성
- [ ] 파서/실행기 구조 의사코드
- [ ] 동일 시나리오 옵션 B 로 시연

### 4-3. Trade-off 비교 + 권고
- [x] §6.4 비교 표 (10 기준 × 3 옵션)
- [x] §6.5 권고: 옵션 A (함수 합성) — 단계적 적용 + B 마이그레이션 임계점 명시
- [x] §6.1~§6.3 의사코드 시연 (5개 mixin 함수 + 시나리오 1 사용 예)
- [ ] Commit: `docs(spec-15-01): compare fixture options and recommend function composition`

---

## Task 5: 후속 Spec 명세 + Go/No-Go (spec.md §7)

### 5-1. spec-15-02 / 15-03 명세 초안
- [ ] §6 권고를 기반으로 spec-15-02 (fixture 시스템 구현) 의 요점 / 방향성 / 산출물 / DoD 초안
- [ ] spec-15-03 (회귀 테스트 4건) 의 요점 / 시나리오별 task 구조 초안

### 5-2. spec-15-04+ 후보 (audit 발견)
- [ ] §4 / §5 에서 발견된 잠재 버그를 spec 후보로 정리
- [ ] P0 (즉시 픽스) / P1 (본 phase 흡수) / P2 (후속 phase 또는 Icebox) 분류

### 5-3. Go/No-Go 권고
- [ ] §7 에 "Go (본 phase 그대로 진행)" 또는 "No-Go (이유)" 명시
- [ ] phase-15.md 갱신 필요 시 같은 commit 에 포함
- [ ] Commit: `docs(spec-15-01): draft follow-up spec specs and go/no-go recommendation`

---

## Task 6: Ship

- [ ] 회귀 검증 — `bash tests/test-version-bump.sh` PASS (전체 스위트 자동 호출)
- [ ] **walkthrough.md 작성** — 결정 기록, 분석 중 발견 사항, 사용자 협의
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-15-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-15-01-upgrade-danger-audit`
- [ ] **PR 생성**: `gh pr create --base main`
- [ ] 사용자 머지 후 `sdd ship` 으로 phase-15.md spec 표 자동 Merged 갱신

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 5 (Task 1 은 브랜치 생성만, 커밋 없음) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-28 |
