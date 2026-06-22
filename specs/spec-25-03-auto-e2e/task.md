# Task List: spec-25-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 측정 spec — impl 변경 없음. e2e 가 기존 조각을 통합 구동.

---

## Task 0: Pre-flight

- [x] Plan Accept
- [x] `git checkout -b spec-25-03-auto-e2e`
- [x] **spec/task 계획 산출물 커밋** (`git add specs/.../spec.md task.md` — PR 포함 보장, 25-02 누락 교훈)

---

## Task 1: auto e2e 작성

### 1-1. test-e2e-auto-mode.sh
- [x] `tests/test-e2e-auto-mode.sh` 작성 (install fixture):
  - mode=auto 설정 + settings 패치 확인
  - askquestion hook: auto 차단 / governed 통과
  - decision add → list / list --phase 누적
  - check-test-trust 칸0 경고
  - check-irreversible 정지 감지
- [x] 실행 → PASS (통합 갭 발견 시 STOP·보고)
- [x] 전체 회귀 PASS
- [x] Commit: `test(spec-25-03): add auto-mode integration e2e`

---

## Task 2: phase 문서 갱신

### 2-1. phase-25.md 검증 메모
- [x] `backlog/phase-25.md` 에 시나리오 1·2 e2e 커버 + 행동 측정 한계 메모
- [x] Commit: `docs(spec-25-03): phase-25 e2e 커버리지 + 측정 한계 메모`

---

## Task 3: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] **전체 테스트 실행** (`bash tests/run.sh`) → 모두 PASS

### 📝 산출물 작성
- [ ] **walkthrough.md 작성** (e2e 가 측정한 것 / 못 한 것 — 행동은 #181)
- [ ] **pr_description.md 작성**
- [x] Commit: `docs(spec-25-03): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] `git push -u origin spec-25-03-auto-e2e` (base: phase-25-auto-reliability)
- [x] PR 생성 → #217 (base=phase-25-auto-reliability)
