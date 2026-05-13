# Task List: spec-x-kit-update-hook

> One Task = One Commit. 매 commit 직후 체크박스를 갱신합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new kit-update-hook`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 브랜치 생성 (`spec-x-kit-update-hook`)
- [ ] 사용자 Plan Accept

---

## Task 1: check-kit-version.sh 신규 작성

plan.md A 항목의 본문을 그대로 작성합니다.

- [ ] `sources/hooks/check-kit-version.sh` 생성 (+x 권한)
- [ ] 정적 검증: `bash -n sources/hooks/check-kit-version.sh` → no syntax error
- [ ] 수동 검증 1·2·3 (plan.md 검증 계획) 실행 → 기대대로 동작
- [ ] Commit: `feat(spec-x-kit-update-hook): add check-kit-version SessionStart hook`

---

## Task 2: SessionStart 배열에 hook entry 등록

plan.md B 항목.

- [ ] `sources/claude-fragments/settings.json.fragment` 의 SessionStart hooks 배열에 `check-kit-version.sh` entry 삽입
- [ ] 정적 검증: `jq '.hooks.SessionStart[0].hooks | length' sources/claude-fragments/settings.json.fragment` → `3`
- [ ] Commit: `feat(spec-x-kit-update-hook): register check-kit-version hook in SessionStart`

---

## Task 3: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 정적 점검 모두 PASS (plan.md 검증 계획)
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-kit-update-hook): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-kit-update-hook`
- [ ] **PR 생성**: `gh pr create`
- [ ] **사용자 알림**: 푸시 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (작업 2 + Ship 1) |
| **예상 commit 수** | 3 (+ scaffold 1) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-13 |
