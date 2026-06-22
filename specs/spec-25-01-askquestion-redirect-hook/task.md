# Task List: spec-25-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: Pre-flight

- [x] Plan Accept 완료
- [x] `git checkout -b spec-25-01-askquestion-redirect-hook`

---

## Task 1: Spike — exit 2 가 AskUserQuestion 을 실제로 차단하는지 실증

> phase-25 최상위 리스크 선검증. 문서로는 확인됐으나 경험적 1회 확인 후 본 구현.

### 1-1. 임시 더미 hook 으로 검증
- [x] 더미 `.claude/_spike-askq.sh`(무조건 exit 2 + stderr) 를 settings PreToolUse matcher `AskUserQuestion` 에 임시 등록 (hot-reload 확인 — claude-code-guide)
- [x] 실제 AskUserQuestion 호출 → **차단됨 + stderr 가 에이전트에 에러로 피드백** 확인. 질문이 사용자에 미도달
- [x] 결과: **PASS** — AskUserQuestion 은 PreToolUse matcher 대상, exit 2 차단, stderr 전달. 24-04 "hook 불가" 전제 실증 반증
- [x] 임시 변경 원복 (settings 블록 제거 + 스크립트 삭제, commit 없음)

> Spike PASS — exit 2 방식 확정. Task 2 진행.

---

## Task 2: hook 테스트 작성 (TDD Red)

### 2-1. 테스트 케이스 작성
- [ ] `tests/test-askquestion-auto.sh` 작성:
  - mode=auto → exit 2 + stderr 에 리다이렉트 문구(`decision add` / 턴 종료)
  - mode=governed → exit 0
  - mode=turbo → exit 0
  - `HARNESS_HOOK_MODE_ASKQUESTION=warn` → exit 0(경고)
- [x] 테스트 실행 → Fail 확인 (hook 미존재, rc=127)
- [x] Commit: `test(spec-25-01): add failing tests for askquestion auto-block hook`

---

## Task 3: hook 구현 (TDD Green)

### 3-1. hook 작성
- [ ] `sources/hooks/check-askquestion-auto.sh` 작성 (`_lib.sh` source, `hook_resolve_mode "ASKQUESTION" "block"`, `hook_state mode` 분기, `hook_violation` 리다이렉트 메시지)
- [x] 실행 권한 `chmod +x`
- [x] `tests/test-askquestion-auto.sh` 실행 → Pass 확인 (6/6)
- [x] Commit: `feat(spec-25-01): add check-askquestion-auto.sh (auto 논블로킹 백스톱)`

---

## Task 4: settings 등록 + 도그푸딩 미러

### 4-1. settings fragment + 설치본
- [x] `sources/claude-fragments/settings.json.fragment` PreToolUse 에 `AskUserQuestion` matcher 블록 추가
- [x] `.harness-kit/hooks/check-askquestion-auto.sh` 미러 (sources 와 byte-identical)
- [x] `.claude/settings.json` PreToolUse 에 동일 matcher 블록 추가
- [x] sync 테스트 + 전체 회귀 실행 → PASS
- [x] Commit: `chore(spec-25-01): register AskUserQuestion matcher + mirror 설치본`

---

## Task 5: agent.md 포인터 (최소)

### 5-1. §8.4 1줄 포인터
- [x] `sources/governance/agent.md` §8.4 auto 서술에 "기계적으로 `check-askquestion-auto.sh` 강제(spec-25-01)" 1줄 추가
- [x] `.harness-kit/agent/agent.md` 미러
- [x] 단어 예산 확인 (`sdd doctor` ≤8000) + 전체 회귀
- [x] Commit: `docs(spec-25-01): agent.md §8.4 기계적 백스톱 포인터`

---

## Task 6: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] **전체 테스트 실행** (`bash tests/run.sh`) → 모두 PASS
- [x] 수동 검증 시나리오 1·2 (auto 차단 / governed 통과) 1회 실행

### 📝 산출물 작성
- [x] **walkthrough.md 작성** (spike 결과 · 차단방식 결정 · 발견 사항)
- [x] **pr_description.md 작성**
- [x] Commit: `docs(spec-25-01): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] `git push -u origin spec-25-01-askquestion-redirect-hook` (base: phase-25-auto-reliability)
- [x] PR 생성 → #215
