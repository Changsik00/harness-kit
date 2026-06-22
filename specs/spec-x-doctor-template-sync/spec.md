# spec-x-doctor-template-sync: doctor.sh 템플릿 목록 동기화 (plan.md 오탐 제거)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-doctor-template-sync` |
| **Phase** | 없음 (spec-x) |
| **Branch** | `spec-x-doctor-template-sync` |
| **Base 브랜치** | `main` |
| **상태** | Planning |
| **타입** | Fix |
| **작성일** | 2026-06-23 |
| **소유자** | dennis |
| **연관 이슈** | GitHub #204 |

## 배경 및 문제 정의

### 현재 상황

install.sh / update 말미의 루트 `doctor.sh` 점검 `[3/7] 거버넌스 + 템플릿` 단계에서:
```
✗ .harness-kit/agent/templates/plan.md 없음
PASS: 51  WARN: 0  FAIL: 1 → 진단 실패
```
그러나 `plan.md` 는 폐기됐습니다 (flat 레이아웃에서 spec.md 에 통합, agent.md §4.2 는 6종만 정의). 테스트·`sdd`·커맨드는 모두 plan.md 폐기를 반영하나 **루트 `doctor.sh` 만 stale**.

### 문제점

`doctor.sh:85` 의 필수 템플릿 목록이 **실제 템플릿과 양방향 drift**:
- ❌ **유령 체크**: `plan.md` (존재 안 하는데 필수 체크 → 오탐 FAIL, install/update 실패 종료)
- ⚠️ **누락**: `phase-ship.md` (실재 템플릿인데 미체크)

근본 원인은 "doctor.sh 목록 ≠ `sources/templates/*.md`". plan.md 한 줄만 빼면 재드리프트 여지가 남음 (이번처럼).

### 해결 방안

`doctor.sh` 의 필수 템플릿 목록을 **실제 `sources/templates/*.md` 와 동기화**(plan.md 제거 + phase-ship.md 추가)하고, 둘이 어긋나면 잡는 **회귀 테스트**를 추가해 재발을 봉인한다.

## 요구사항

1. `doctor.sh` 가 `plan.md` 를 필수 체크하지 않는다 (오탐 FAIL 제거).
2. `doctor.sh` 가 실재 템플릿 9종(adr·phase-ship·phase·pr_description·queue·rca·spec·task·walkthrough)을 체크한다.
3. 회귀 테스트: `doctor.sh` 의 필수 템플릿 목록 == `sources/templates/*.md` 파일명 집합. 어긋나면 FAIL.
4. 전체 회귀 PASS.

## Out of Scope

- `bin` `sdd doctor` 의 템플릿 처리 변경 (이미 plan.md 미체크 — 정상).
- 템플릿 추가/삭제 자체.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **doctor.sh 목록** | `for f in ...` 목록을 실제 템플릿셋으로 교체 | 유령(plan.md) 제거 + 누락(phase-ship.md) 보강 = 양방향 정합 |
| **재발 방지** | 목록 ↔ `sources/templates/*.md` 일치 테스트 | drift 가 다시 나면 회귀로 즉시 적발 (이번 버그의 *원인*을 봉인) |

## Proposed Changes

#### [MODIFY] `doctor.sh`
`[3/7]` 의 `for f in queue.md phase.md spec.md plan.md task.md walkthrough.md pr_description.md rca.md adr.md` 에서 `plan.md` 제거 + `phase-ship.md` 추가. 실재 템플릿 9종과 일치시킴.

#### [NEW] `tests/test-doctor-templates.sh`
`doctor.sh` 의 필수 템플릿 목록을 파싱해 `sources/templates/*.md` basename 집합과 정확히 일치하는지 검증 (유령·누락 양방향). plan.md 가 목록에 없음 + phase-ship.md 가 목록에 있음을 명시 케이스로 고정.

## 검증 계획

```bash
bash tests/test-doctor-templates.sh
bash doctor.sh        # FAIL 0 확인 (plan.md 오탐 사라짐)
bash tests/run.sh
```
수동: 격리 install 후 doctor `[3/7]` 가 plan.md FAIL 없이 PASS.

## 롤백 계획

- `git revert` — doctor.sh 목록 + 테스트만. 동작 영향 없음(점검 메시지 정합).

## ADR 후보

- [ ] 없음 (stale 목록 정합 — 새 결정 없음).

## ✅ Definition of Done

- [ ] `doctor.sh` plan.md 미체크 + phase-ship.md 체크
- [ ] `tests/test-doctor-templates.sh` 신규 PASS (목록 == 실제 템플릿)
- [ ] `bash doctor.sh` FAIL 0
- [ ] 전체 회귀 PASS
- [ ] `walkthrough.md` / `pr_description.md` (Closes #204) ship + push + PR
