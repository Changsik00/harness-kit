# Walkthrough: spec-24-04

> auto 모드의 핵심 동작 — 결정 지점에서 멈추지 않기 — 를 resolver + 거버넌스 서술로 규율.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 논블로킹 결정 강제 방식 | hook 으로 AskUserQuestion 차단 / 거버넌스 서술 + resolver | **서술 + resolver** | `AskUserQuestion` 호출 여부는 agent 행동 — hook 으로 못 막음. ux-mode effective(SSOT) + agent.md 규약으로 규율, 사후는 `sdd decision` |
| effective 노출 형태 | 신규 `sdd ask-mode` / `config ux-mode effective` 서브값 | **config ux-mode effective** | 기존 ux-mode 개념의 *해석* 이라 같은 명령 아래 둠. 조기 return 으로 기존 경로 불변 |
| ① 방향 모호 처리 | 본 spec / 24-03 | **본 spec** | ②③(기계적)은 24-03, ①(agent 판단 — 기본값 정당화 불가)은 행동 규약이라 24-04(논블로킹 결정)와 결합 |

## 💬 사용자 협의

- **주제**: 24-04 범위 (24-03 carry-over 흡수)
  - **합의**: ① 방향 모호 + agent.md auto 행동 서술을 24-04 에 포함(24-03 에서 분리됐던 것).

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-ask-mode-auto.sh` + 전체 + 단어수
- **결과**: ✅ Passed (ask-mode-auto 5/5, 전체 71/71, 거버넌스 7850/8000)
```text
test-ask-mode-auto: PASS=5  (auto=text ×2 / governed 저장값 ×2 / 무인자 조회 회귀)
회귀: test-sdd-config 7/7, test-mode-auto 6/6
거버넌스 단어수: 7850 ≤ 8000
전체: 71/71 (FAIL 0)
```

### 수동 검증
1. **Action**: `sdd mode auto` 상태에서 `sdd config ux-mode effective`
   - **Result**: `text` (저장 uxMode 가 interactive 여도) → auto 는 미대기·기본값.
2. **Action**: `sdd mode governed` + uxMode=interactive → `effective`
   - **Result**: `interactive` (저장값 그대로).

## 🔍 발견 사항

- **논블로킹 결정은 본질적으로 agent 행동 규약.** ②비가역·③반복실패는 hook 으로 기계적 강제가 되지만, "결정 지점에서 기본값 채택"은 agent 가 `AskUserQuestion` 을 *안 부르는* 행위라 hook 으로 못 막는다. 그래서 본 spec 은 (1) 해석 SSOT(`ux-mode effective`)와 (2) 거버넌스 서술로 규율하고, 사후 검토는 `sdd decision`(24-03) + phase-ship(24-05)에 맡긴다.
- **단어 예산 준수.** agent.md 추가 +64w(7786→7850), 한도 8000 미만. ADR-009 포인터로 상세를 위임해 린 유지.

## 🚧 이월 항목

- 결정 로그 phase-ship 일괄 노출 + spec 전환 테스트 게이트 + auto e2e(`test-e2e-auto-mode.sh`) → spec-24-05.
