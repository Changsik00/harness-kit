# Task List: spec-20-04

> One Task = One Commit. 매 commit 직후 체크박스 갱신.
> 번들 spec — 3 테마(모델 config / review 패널 / 중재 패턴)를 한 ceremony 유닛으로.

## Pre-flight
- [x] spec.md / plan.md / task.md 작성 (디렉터 직접)
- [x] 백로그 phase-20.md spec 표 등록 (sdd spec new)
- [ ] 사용자 Plan Accept

---

## Task 1: 검증 테스트 확장 (TDD Red)

- [x] `tests/test-director-mode.sh` 확장:
  - §6.6 역할 용어 grep (`director`, `worker`, `scout`)
  - `sdd config models` 출력에 3역할 매핑 포함
  - review 커맨드에 "페르소나 패널" 문구 존재
  - 미러 parity (기존 유지)
- [x] 실행 → 신규 케이스 FAIL 확인 (구현 전)
- [x] Commit: `test(spec-20-04): extend test for model roles and review panel`

---

## Task 2: 모델 역할 config (de-hardcode)

- [x] `sources/governance/agent.md` §6.6 → director/worker/scout 역할·책무 표로 재작성. 모델 이름 제거 + `harness.config.json models` 참조. §6.1/§6.8 과 일관성·중복 정리
- [x] `.harness-kit/agent/agent.md` 미러 동기화
- [x] `harness.config.json` 에 `models` 키 추가
- [x] `sources/bin/sdd` + `.harness-kit/bin/sdd`: `config models` 조회 서브커맨드 (기본값 fallback)
- [x] `wc -w` 합계 ≤8000 확인 (초과 시 멈추고 디렉터 보고) — 7515w
- [x] 관련 테스트 케이스 PASS
- [x] Commit: `feat(spec-20-04): role-based model config (de-hardcode §6.6)`

---

## Task 3: review 페르소나 패널 옵션

- [ ] `hk-code-review.md` · `hk-spec-critique.md` · `hk-phase-review.md` (sources + `.claude/` 미러) 에 페르소나 패널 절 추가 — 렌즈 목록 + 디렉터 종합·중재 + **소규모 diff 단일 리뷰어 fallback**
- [ ] `agent.md §6.7` review-orchestration 1줄 cross-ref (+ 미러)
- [ ] 관련 테스트 PASS
- [ ] Commit: `feat(spec-20-04): add persona review panel option`

---

## Task 4: 중재 패턴 기록

- [ ] `docs/wiki/patterns.md` good-pattern `mediated-design-dialogue` 추가 (front↔back 협상 + 디렉터 중재 / 종료조건 / 증류)
- [ ] Commit: `docs(spec-20-04): add mediated design dialogue pattern`

---

## Task 5: Ship

### Pre-Push Gate
- [ ] `test-director-mode.sh` + `test-director-protocol.sh` + `test-governance-dedup.sh` 전부 PASS
- [ ] 단어 예산 ≤8000 + 미러 parity + 모델 이름 하드코딩 0 확인

### 산출물
- [ ] walkthrough.md (결정·발견·증거 — 번들 통합 회고 포함)
- [ ] pr_description.md
- [ ] Ship commit → push → **base PR** (`phase-20-director-mode`)
- [ ] 머지 후 phase 전 spec Merged → `/hk-phase-ship` 로 phase-20 종결

---

## 진행 요약
| 항목 | 값 |
|---|---|
| 총 Task | 5 (T1-T4 + Ship) |
| 예상 commit | 5 (test/feat/feat/docs/ship) |
| 현재 단계 | Planning |
| 갱신 | 2026-06-04 |
