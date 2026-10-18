# Walkthrough: spec-x-doctor-template-sync

> #204 — 루트 doctor.sh 의 plan.md 오탐 FAIL 제거. 근본 원인(목록 drift)을 회귀 테스트로 봉인.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 수정 범위 | plan.md 한 줄 제거 / 목록 전체 동기화 | **전체 동기화 + 회귀 테스트** | 근본 원인은 "doctor.sh 목록 ≠ 실제 템플릿". 한 줄만 빼면 또 drift(이번처럼). 양방향 정합 + 테스트로 봉인 |
| phase-ship.md 추가 | scope 밖 / 포함 | **포함** | 실재 템플릿인데 doctor 가 미체크 — 같은 drift 의 반대 방향. 함께 고쳐야 정합 |

## 💬 사용자 협의

- **주제**: #204 plan.md 오탐 해결
  - **합의**: 단순 1줄 FF 대신 spec-x — 회귀 테스트로 재발(목록 drift) 봉인 + PR 로 이슈 close.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-doctor-templates.sh` + `bash doctor.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (doctor-templates 3/3, 전체 76/76)
```text
T1 plan.md 미체크 / T2 phase-ship.md 체크 / T3 목록 == sources/templates/*.md
doctor.sh [3/7]: PASS 53 / FAIL 0 (이전: FAIL 1 plan.md 없음)
```

### 수동 검증
1. **Action**: `bash doctor.sh` (도그푸딩 환경)
   - **Result**: `[3/7] 거버넌스 + 템플릿` FAIL 0. plan.md 오탐 사라짐, phase-ship.md PASS.

## 🔍 발견 사항

- **drift 가 양방향이었다**: doctor.sh 가 *유령*(plan.md, 없는데 체크)과 *누락*(phase-ship.md, 있는데 미체크)을 동시에 가졌다. 이슈는 plan.md 만 보고했지만 같은 원인의 반대 증상이 숨어 있었다.
- **테스트·sdd·커맨드는 이미 정합**: `test-install-layout` 이 "plan.md 제거됨"을 명시하고 bin `sdd doctor` 도 plan.md 미체크였다 — *루트 doctor.sh 만* 갱신에서 누락된 stale 지점이었다(여러 시점 파일 중 하나만 안 따라간 전형적 drift).
- **재발 방지의 핵심은 1줄 수정이 아니라 invariant 고정**: `doctor.sh 목록 == sources/templates/*.md` 를 테스트로 박아, 향후 템플릿 추가/삭제 시 doctor 갱신을 잊으면 즉시 빨개진다.

## 🚧 이월 항목

- 없음. (#204 종결)
