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

- [x] `sources/hooks/check-kit-version.sh` 생성 (+x 권한)
- [x] 정적 검증: `bash -n sources/hooks/check-kit-version.sh` → PASS
- [x] 수동 검증 1: fake kitVersion=0.0.1 → 알림 출력 (`🆕 harness-kit 0.8.0 사용 가능 (현재 0.0.1)`) PASS
- [x] 수동 검증 2: HOOK_MODE_KIT_VERSION=off 및 DRIFT_FETCH=0 → silent exit 0 PASS
- [x] 수동 검증 3: 현재 본 프로젝트(latest==installed) → silent exit 0 PASS
- [x] Commit: `feat(spec-x-kit-update-hook): add check-kit-version SessionStart hook`

---

## Task 2: SessionStart 배열에 hook entry 등록

plan.md B 항목.

- [x] `sources/claude-fragments/settings.json.fragment` 의 SessionStart hooks 배열에 `check-kit-version.sh` entry 삽입 (2번째 위치)
- [x] 정적 검증: `jq '.hooks.SessionStart[0].hooks | length' ...fragment` → `3` PASS
- [x] Commit: `feat(spec-x-kit-update-hook): register check-kit-version hook in SessionStart`

---

## Task 3: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 정적 점검 모두 PASS (plan.md 검증 계획)
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] **Ship Commit**: `docs(spec-x-kit-update-hook): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-x-kit-update-hook`
- [x] **PR 생성**: `gh pr create`
- [x] **사용자 알림**: 푸시 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (작업 2 + Ship 1) |
| **예상 commit 수** | 3 (+ scaffold 1) |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-05-13 |
