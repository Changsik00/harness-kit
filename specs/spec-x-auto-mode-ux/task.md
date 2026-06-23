# Task List: spec-x-auto-mode-ux

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

---

## Task 0: Pre-flight

- [ ] Plan Accept
- [ ] `git checkout -b spec-x-auto-mode-ux`
- [ ] **spec/task 계획 산출물 커밋** (첫 task 전)

---

## Task 1: 용어 회귀 테스트 (TDD Red)

- [ ] `tests/test-terminology.sh` — 운영 파일에 `칸[0-9]` 0건 + `sources/commands/hk-auto.md` 존재 검증
- [ ] 실행 → Fail (현재 칸N 잔존 + hk-auto 미존재)
- [ ] Commit: `test(spec-x-auto-mode-ux): 용어/커맨드 정합 검증 (Red)`

---

## Task 2: "검증 N단계" 개명 (TDD Green 일부)

- [ ] README · hk-refute.md · check-test-trust.sh · pre-commit.sh · agent.md · ADR-009 · CHANGELOG 의 칸N/비용 사다리 → 검증 N단계/위험 비례 검증 단계
- [ ] 설치본 미러 동기(`.harness-kit/`, `.claude/commands/`)
- [ ] `grep 칸[0-9]` → 0건 확인
- [ ] Commit: `docs(spec-x-auto-mode-ux): 칸N → "검증 N단계" 개명 (운영/정규 문서)`

---

## Task 3: /hk-auto 커맨드 (TDD Green 완료)

- [ ] `sources/commands/hk-auto.md` (governed↔auto 토글 + unattended 경고)
- [ ] `.claude/commands/hk-auto.md` 미러 + `installed.json` 등록
- [ ] `tests/test-terminology.sh` → Pass
- [ ] 전체 회귀 PASS
- [ ] Commit: `feat(spec-x-auto-mode-ux): /hk-auto 커맨드 추가`

---

## Task 4: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] **전체 테스트 실행** → PASS

### 📝 산출물 작성
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-x-auto-mode-ux): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-x-auto-mode-ux`
- [ ] PR 생성 (base=main)
- [ ] `sdd specx done auto-mode-ux` (머지 후)
