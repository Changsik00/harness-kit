# Task List: spec-25-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: Pre-flight

- [ ] Plan Accept (또는 critique 먼저)
- [ ] `git checkout -b spec-25-02-test-trust`

---

## Task 1: 칸0 테스트 작성 (TDD Red)

### 1-1. 테스트 케이스
- [x] `tests/test-test-trust.sh` 작성:
  - 구현 파일 변경 ∧ 테스트 무변경 → 경고
  - 구현 + 테스트 동반 변경 → 무경고
  - 단언 없는 테스트 추가 → 경고
  - 안전 경로(docs/·*.md·backlog/) → 무경고
- [x] 실행 → Fail 확인 (hook 미존재)
- [x] Commit: `test(spec-25-02): add failing tests for 칸0 test-trust hook`

---

## Task 2: 칸0 hook 구현 + 등록 (TDD Green)

### 2-1. hook
- [x] `sources/hooks/check-test-trust.sh` (commit-time, staged diff 휴리스틱, 경고, 안전경로 화이트리스트)
- [x] `chmod +x` + `tests/test-test-trust.sh` → Pass
- [x] Commit: `feat(spec-25-02): add check-test-trust.sh (칸0 가짜 green 휴리스틱)`

### 2-2. pre-commit 등록 + 미러
- [x] git pre-commit 에 commit-time 호출 등록 (`check-scope` commit-mode 패턴)
- [x] `.harness-kit/hooks/check-test-trust.sh` 미러 (byte-identical)
- [x] sync + 전체 회귀 → PASS
- [x] Commit: `chore(spec-25-02): register 칸0 commit-time + mirror 설치본`

---

## Task 3: 칸2 골격 (커맨드 + 트리거 + 절차)

### 3-1. hk-refute 커맨드 + 거버넌스
- [ ] `sources/commands/hk-refute.md` — spec.md 의도 앵커 적대적 반증 서브에이전트 디스패치 절차
- [ ] `sources/governance/agent.md` §6.7 에 위험비례 refute 렌즈 1줄 (≤8000)
- [ ] `.claude/commands/hk-refute.md` + `.harness-kit/agent/agent.md` 미러
- [ ] 단어 예산 확인 + 전체 회귀
- [ ] Commit: `feat(spec-25-02): add hk-refute 커맨드 + agent.md 칸2 렌즈 (골격)`

---

## Task 4: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] **전체 테스트 실행** (`bash tests/run.sh`) → 모두 PASS
- [ ] 수동 검증 1·2 (칸0 경고 / 칸2 권고 노출) 1회

### 📝 산출물 작성
- [ ] **walkthrough.md 작성** (칸0 휴리스틱 결정 · 칸2 골격 범위 · 분할 판단)
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-25-02): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-25-02-test-trust` (base: phase-25-auto-reliability)
- [ ] PR 생성 (`/hk-pr-gh`, base=phase-25-auto-reliability)
