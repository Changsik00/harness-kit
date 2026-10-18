# Task List: spec-x-auto-mode-ux

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

---

## Task 0: Pre-flight

- [x] Plan Accept
- [x] `git checkout -b spec-x-auto-mode-ux`
- [x] **spec/task 계획 산출물 커밋** (첫 task 전)

---

## Task 1: 용어 회귀 테스트 (TDD Red)

- [x] `tests/test-terminology.sh` — 운영 파일에 `칸[0-9]` 0건 + `sources/commands/hk-auto.md` 존재 검증
- [x] 실행 → Fail (현재 칸N 잔존 + hk-auto 미존재)
- [x] Commit: `test(spec-x-auto-mode-ux): 용어/커맨드 정합 검증 (Red)`

---

## Task 2: "검증 N단계" 개명 (TDD Green 일부)

- [x] README · hk-refute.md · check-test-trust.sh · pre-commit.sh · agent.md · ADR-009 · CHANGELOG 의 칸N/비용 사다리 → 검증 N단계/위험 비례 검증 단계
- [x] 설치본 미러 동기(`.harness-kit/`, `.claude/commands/`)
- [x] `grep 칸[0-9]` → 0건 확인
- [x] Commit: `docs(spec-x-auto-mode-ux): 칸N → "검증 N단계" 개명 (운영/정규 문서)`

---

## Task 3: /hk-auto 커맨드 (TDD Green 완료)

- [x] `sources/commands/hk-auto.md` (governed↔auto 토글 + unattended 경고)
- [x] `.claude/commands/hk-auto.md` 미러 + `installed.json` 등록
- [x] `tests/test-terminology.sh` → Pass
- [x] 전체 회귀 PASS
- [x] Commit: `feat(spec-x-auto-mode-ux): /hk-auto 커맨드 추가`

---

## Task 4: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] **전체 테스트 실행** → PASS

### 📝 산출물 작성
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] Commit: `docs(spec-x-auto-mode-ux): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] `git push -u origin spec-x-auto-mode-ux`
- [x] PR 생성 → #223 (base=main)
- [ ] `sdd specx done auto-mode-ux` (머지 후)
