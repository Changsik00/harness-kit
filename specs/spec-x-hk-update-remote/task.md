# Task List: spec-x-hk-update-remote

> One Task = One Commit. 매 commit 직후 체크박스를 갱신합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new hk-update-remote`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 브랜치 생성 (`spec-x-hk-update-remote`)
- [ ] 사용자 Plan Accept

---

## Task 1: /hk-update 슬래시 커맨드 본문 갱신

§5 "업데이트 실행" 섹션을 원격 curl 1차 + 로컬 fallback 형태로 교체합니다.

- [x] `sources/commands/hk-update.md` §5 본문 교체 (plan.md A 항목)
- [x] grep 검증:
  - `grep -qF 'get.sh) --update' sources/commands/hk-update.md` → PASS
  - `grep -qF 'bash <kit-dir>/update.sh' sources/commands/hk-update.md` → PASS
- [x] Commit: `docs(spec-x-hk-update-remote): /hk-update 안내를 원격 실행 1차로 전환`

---

## Task 2: sdd status 의 kit 업데이트 알림 문구 일관화

- [ ] `sources/bin/sdd` 라인 338 의 알림 문구를 `/hk-update` 하나로 단순화 (plan.md B 항목)
- [ ] grep 검증: `grep -n '/hk-update' sources/bin/sdd`
- [ ] Commit: `chore(spec-x-hk-update-remote): sdd status 알림 문구 단순화`

---

## Task 3: README 키트 진입점 표 보완

- [ ] `README.md` 의 키트 진입점 표에 원격 갱신 명령 행 추가 (plan.md C 항목)
- [ ] grep 검증: `grep -q 'curl .* get.sh) --update' README.md`
- [ ] Commit: `docs(spec-x-hk-update-remote): README 키트 진입점 표에 원격 갱신 명령 추가`

---

## Task 4: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 정적 점검 grep 4종 모두 PASS (plan.md 검증 계획)
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-hk-update-remote): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-hk-update-remote`
- [ ] **PR 생성**: `gh pr create` (또는 `/hk-pr-gh`)
- [ ] **사용자 알림**: 푸시 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (작업 3 + Ship 1) |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-13 |
