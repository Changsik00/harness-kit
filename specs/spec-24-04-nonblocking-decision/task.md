# Task List: spec-24-04

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: 브랜치 생성

- [x] `git checkout -b spec-24-04-nonblocking-decision` (커밋 없음 — setup)

---

## Task 1: effective ux-mode resolver (TDD)

### 1-1. Red
- [x] `tests/test-ask-mode-auto.sh` — `sdd config ux-mode effective`: auto→text(저장값 무관), governed+interactive→interactive, governed+text→text, 기존 조회/toggle 회귀
- [x] 실행 → Fail 확인 (E1-E4 FAIL)
- [x] Commit: `test(spec-24-04): add failing effective ux-mode resolver test` (3f8b882)

### 1-2. Green
- [x] `sources/bin/sdd` — `_config_ux_mode` 에 `effective` 분기 + help 한 줄 (+ `.harness-kit/` 미러)
- [x] 실행 → 5/5 Pass, `test-sdd-config` 7/7 회귀 없음
- [x] Commit: `feat(spec-24-04): add effective ux-mode resolver (auto=text)` (f4797f4)

---

## Task 2: agent.md auto 논블로킹 결정 서술

- [x] `sources/governance/agent.md` §8.4 — auto 행동 규칙 린 서술 (기본값+`sdd decision` 로깅·미대기, ① 방향 모호 hard stop, ask-mode=effective) + ADR-009 포인터 (+ `.harness-kit/agent/agent.md` 미러)
- [x] 단어수 확인 → 7850 ≤ 8000
- [x] Commit: `docs(spec-24-04): add auto non-blocking decision rule to agent.md` (1ec2d3c)

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] 전체 테스트 실행 → 71/71 PASS + 단어수 7850 ≤ 8000

### 📝 산출물 작성
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] Commit: `docs(spec-24-04): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-24-04-nonblocking-decision`
- [ ] PR 생성 (`/hk-pr-gh`)
