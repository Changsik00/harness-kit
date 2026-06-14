# Task List: spec-x-align-mode-salience

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> doc 변경이라 TDD red/green 없음 — 변경 후 정합 회귀로 검증.

---

## Task 0: Pre-flight
- [ ] Plan Accept 확인

## Task 1: 브랜치 생성
- [ ] `git checkout -b spec-x-align-mode-salience` (main 에서 분기)

---

## Task 2: align.md 모드 부각 + intent 잔재 정리

- [ ] `sources/governance/align.md` 편집:
  - §5 상태 보고 블록에 `- Active Mode: governed / turbo` 추가
  - "모드 부각" 지시 추가 (governed + 기능/PR 착수 시 Plan Accept/turbo 비대상 사전 고지)
  - "Intent 잔재 점검" 지시 추가 (`Active Intent` 감지 → `sdd intent clear` 제안, 자동 금지)
- [ ] `.harness-kit/agent/align.md` 동일 내용 미러링 (도그푸딩 sync)
- [ ] `diff -q sources/governance/align.md .harness-kit/agent/align.md` → 동일 확인
- [ ] Commit: `docs(spec-x-align-mode-salience): surface active mode and stale-intent cleanup in align`

---

## Task 3: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] `bash tests/test-install-manifest-sync.sh` PASS
- [ ] `bash tests/run.sh --fast` → 신규 회귀 0 (기존 실패 5건만 잔존 확인)

### 📝 산출물 작성
- [ ] walkthrough.md 작성
- [ ] pr_description.md 작성
- [ ] Commit: `docs(spec-x-align-mode-salience): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-x-align-mode-salience`
- [ ] PR 생성 (`/hk-pr-gh`) → main
- [ ] 머지 후 `sdd specx done align-mode-salience`
