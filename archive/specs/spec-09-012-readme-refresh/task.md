# Task List: spec-09-012

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight

- [x] spec.md / plan.md / task.md 작성
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-09-012-readme-refresh` (from `phase-09-install-conflict-defense`)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: README.md v0.4.0 전면 갱신

- [ ] 버전 배지 `0.3.0` → `0.4.0`
- [ ] 설치 레이아웃 트리 `.harness-kit/` 구조로 교체
- [ ] CLAUDE.md 안내 `@import` 방식으로 갱신
- [ ] 구 경로 참조 일괄 교체 (`agent/`, `scripts/harness/`, `bin/sdd`)
- [ ] queue.md NOW/NEXT 언급 → `sdd status` 실시간 계산으로 교체
- [ ] 슬래시 커맨드 표에 `/hk-cleanup` 추가
- [ ] install.sh 옵션에 `--no-gitignore` 추가
- [ ] 명령 요약에 `cleanup.sh` 추가
- [ ] sdd archive 설명 갱신 (state 초기화 + NEXT 안내)
- [ ] 워크플로 다이어그램에 Post-Merge 흐름 추가
- [ ] grep 검증: `scripts/harness` 0건, `.harness-kit/` prefix 없는 `agent/constitution` 0건
- [ ] Commit: `docs(spec-09-012): update README.md for v0.4.0 layout`

---

## Task 3: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-012): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-012-readme-refresh`
- [ ] **PR 생성**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 2 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
