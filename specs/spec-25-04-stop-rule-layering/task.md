# Task List: spec-25-04

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

---

## Task 0: Pre-flight

- [x] Plan Accept
- [x] `git checkout -b spec-25-04-stop-rule-layering`
- [x] **spec/task 계획 산출물 커밋** (첫 task 전 — PR 포함 보장)

---

## Task 1: 감지 확장 테스트 (TDD Red)

### 1-1. test-stop-rules.sh 갱신
- [x] `git reset --hard`·`git rebase --onto` → 경고(warn) 케이스 추가
- [x] 기존 "reset --hard 미감지" 경계 단언 갱신(이제 감지)
- [x] block 모드(exit 2)에서 새 명령 차단 케이스 추가
- [x] 실행 → Fail 확인 (hook 미감지)
- [x] Commit: `test(spec-25-04): reset --hard / rebase --onto 감지 + block 경로 고정`

---

## Task 2: hook 감지 확장 + 모델 명문화 (TDD Green)

### 2-1. check-irreversible.sh
- [x] `git reset --hard`·`git rebase --onto` 감지 패턴 추가 (warn, force-push narrow 제외 유지)
- [x] 헤더에 2층 모델 분류표(deny=never-justify / hook=context-dependent) + W3 데드락 + 승격 적격일(2026-06-26) + 플립 시 deny→hook 이관 메모
- [x] `tests/test-stop-rules.sh` → Pass
- [x] `.harness-kit/hooks/check-irreversible.sh` 미러 (byte-identical)
- [x] 전체 회귀 PASS
- [x] Commit: `fix(spec-25-04): check-irreversible context-dependent 감지 + 2층 모델 명문화`

---

## Task 3: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] **전체 테스트 실행** (`bash tests/run.sh`) → 모두 PASS
- [x] 수동: `git reset --hard` 경고 확인 + 플립/deny 미변경 확인

### 📝 산출물 작성
- [ ] **walkthrough.md 작성** (2층 모델 결정 · 플립 미룬 이유 · ADR 판단)
- [ ] **pr_description.md 작성**
- [x] Commit: `docs(spec-25-04): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] `git push -u origin spec-25-04-stop-rule-layering` (base: phase-25-auto-reliability)
- [x] PR 생성 → #218 (base=phase-25-auto-reliability)
