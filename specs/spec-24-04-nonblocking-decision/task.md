# Task List: spec-24-04

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: 브랜치 생성

- [ ] `git checkout -b spec-24-04-nonblocking-decision` (커밋 없음 — setup)

---

## Task 1: effective ux-mode resolver (TDD)

### 1-1. Red
- [ ] `tests/test-ask-mode-auto.sh` — `sdd config ux-mode effective`: auto→text(저장값 무관), governed+interactive→interactive, governed+text→text, 기존 조회/toggle 회귀
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-24-04): add failing effective ux-mode resolver test`

### 1-2. Green
- [ ] `sources/bin/sdd` — `_config_ux_mode` 에 `effective` 분기 + help 한 줄 (+ `.harness-kit/` 미러)
- [ ] 실행 → Pass, `test-sdd-config` 회귀 없음
- [ ] Commit: `feat(spec-24-04): add effective ux-mode resolver (auto=text)`

---

## Task 2: agent.md auto 논블로킹 결정 서술

- [ ] `sources/governance/agent.md` §8.4 — auto 행동 규칙 린 서술 (기본값+`sdd decision` 로깅·미대기, ① 방향 모호 hard stop, ask-mode=effective) + ADR-009 포인터 (+ `.harness-kit/agent/agent.md` 미러)
- [ ] 단어수 확인 → `wc -w` ≤ 8000
- [ ] Commit: `docs(spec-24-04): add auto non-blocking decision rule to agent.md`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] 전체 테스트 실행 → 모두 PASS + 단어수 ≤ 8000

### 📝 산출물 작성
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-24-04): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-24-04-nonblocking-decision`
- [ ] PR 생성 (`/hk-pr-gh`)
