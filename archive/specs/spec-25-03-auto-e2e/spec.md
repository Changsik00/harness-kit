# spec-25-03: auto 안전장치 e2e (측정 — routine 안 멈춤 + 정지 + 결정로그 누적)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-25-03` |
| **Phase** | `phase-25` |
| **Branch** | `spec-25-03-auto-e2e` |
| **Base 브랜치** | `phase-25-auto-reliability` (base 모드) |
| **상태** | Planning |
| **타입** | Research/Test (측정) |
| **작성일** | 2026-06-22 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

phase-25 가 auto 안전장치를 쌓았다 — spec-25-01(AskUserQuestion 차단 hook), spec-25-02(칸0 test-trust + 칸2 골격). 각각 단위 테스트 + 라이브 1회 검증을 거쳤다. 그러나 phase-24 가 남긴 carry-over(C1)는 **"auto 한 사이클에서 조각들이 함께 작동하는지"를 실제 실행으로 증명하는 e2e** 가 부재하다는 것이었다. phase-24 성공기준 #2·#3 가 ⚠️ 부분 충족으로 남은 직접 원인.

### 문제점

- 조각들이 *개별* 로는 검증됐지만 **통합 흐름**(mode=auto → 결정지점 차단·리다이렉트 → 결정로그 누적 → 정지규칙)으로 한 번도 안 돌아봤다.
- 특히 **결정 로그가 실제로 쌓이는지** 미검증 — phase-24 의 `decision list --phase` 가 0건이었던 게 "기능 부재"인지 "안 써봐서"인지 구분 안 됨.

### 해결 방안

실제 install 한 격리 환경에서 auto 사이클의 **기계적 안전장치**를 끝까지 구동하는 e2e(`test-e2e-auto-mode.sh`)를 추가한다. 무엇을 측정할 수 있고 *없는지*를 정직하게 구분한다.

## 요구사항

1. 실제 `install.sh` 격리 fixture 에서 `sdd mode auto` → state.mode=auto + settings 패치(git push ask 제거) 확인.
2. **routine 안 멈춤의 기계적 보장**: mode=auto 에서 `check-askquestion-auto.sh` 가 차단(exit 2)+리다이렉트. (governed 에선 통과.)
3. **결정 로그 누적**: 활성 spec 에 `sdd decision add` → `decision list` 및 `list --phase` 가 그 행을 노출 (0건이 *안 써서*였음을 실증).
4. **칸0 발동**: auto 사이클의 구현-무테스트 커밋에 `check-test-trust` 경고.
5. **정지규칙 ②**: auto 에서 비가역 명령에 `check-irreversible` 감지.
6. 측정 한계 명시: bash e2e 는 *기계적 보장*(차단/경고/누적)을 증명하지, **에이전트가 실제로 좋은 기본값을 고르는 행동**은 증명 못 함 — 그건 본질적으로 행동 평가(#181) 영역.

## Out of Scope

- 실제 에이전트를 unattended 로 돌리는 행동 e2e (#181 행동 기반 평가 — 별도).
- 새 기능 — 본 spec 은 기존 25-01/25-02/24-03 조각의 *통합 측정* 만. impl 변경 없음.
- 칸2(`hk-refute`) 의 LLM 디스패치 실행 — 골격 존재만 smoke.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **격리** | `test-e2e-lifecycle.sh` 패턴 — 실제 install + temp dir + `HARNESS_DRIFT_FETCH=0` | 설치본 hook·sdd·settings 를 진짜로 구동 |
| **구동** | mode 전환 → hook 직접 호출 → `sdd decision add/list` → 정지규칙 명령 | 에이전트 없이 *기계적* 조각을 순서대로 |
| **정직성** | 측정 가능(기계)/불가(행동)을 walkthrough 에 명시 | "e2e 가 다 증명한다"는 가짜 안심 회피(#212 정신) |

## Proposed Changes

#### [NEW] `tests/test-e2e-auto-mode.sh`
실제 install fixture 기반 e2e. 검증: mode=auto 설정 / askquestion 차단(auto)·통과(governed) / decision add→list·list --phase 누적 / check-test-trust 칸0 경고 / check-irreversible 정지 감지. bash 3.2 호환, 외부 네트워크 회피.

#### [MODIFY] `backlog/phase-25.md` (검증 결과 메모)
시나리오 1·2 가 e2e 로 *기계적* 커버됨을 기록 + 행동 측정 한계 명시.

## 검증 계획

```bash
bash tests/test-e2e-auto-mode.sh
bash tests/run.sh   # 전체 (e2e 포함)
```

수동: 없음 (e2e 자체가 통합 구동).

## 롤백 계획

- `git revert` — 테스트 파일 + 문서만. impl·state 영향 없음.

## ADR 후보

- [ ] 없음 (측정 spec — 새 결정 없음). 단 "bash e2e 의 측정 한계 = 행동은 #181 영역" 은 walkthrough 발견으로 기록.

## ✅ Definition of Done

- [ ] `tests/test-e2e-auto-mode.sh` PASS + 전체 회귀 PASS
- [ ] 결정 로그 누적이 실데이터로 증명 (0건 원인 = 미사용 확정)
- [ ] 측정 한계(행동 미측정) walkthrough 명시
- [ ] `walkthrough.md` / `pr_description.md` ship commit
- [ ] `spec-25-03-auto-e2e` 브랜치 push
