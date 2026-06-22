# Walkthrough: spec-25-03

> auto 안전장치 통합 e2e — 기계적 조각이 함께 작동함을 실증하고, 측정할 수 *없는* 것을 정직하게 구분.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| e2e 구동 방식 | 실제 에이전트 unattended / 기계적 조각 순차 구동 | **기계적 조각** | bash e2e 로 에이전트를 못 돌림. mode·hook·decision·정지규칙을 순서대로 구동해 *통합 배선* 을 증명 |
| 측정 한계 처리 | 침묵 / 명시 | **명시** | "e2e 가 다 증명한다"는 가짜 안심 회피(#212). 행동(기본값 선택)은 #181 영역으로 walkthrough·phase.md 에 못 박음 |
| right-size | phase-FF / lean spec | **lean spec** | 테스트 전용 ~1 커밋이나, "측정 가능/불가" 발견이 walkthrough 가치 + 성공기준 #3 capstone → spec 유지 (ceremony 최소) |

## 💬 사용자 협의

- **주제**: 25-03 right-size (test-only)
  - **합의**: phase-FF 도 가능하나 capstone 측정 + 측정한계 발견 기록 가치로 lean spec 유지.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-e2e-auto-mode.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (e2e 8/8, 전체 75/75, FAIL 0)
```text
① mode=auto + settings 패치(git push ask 제거)
② askquestion: auto 차단(exit2+리다이렉트) / governed 통과
③ decision add → list / list --phase 누적 (실데이터)
④ 칸0 구현-무테스트 경고  ⑤ 정지규칙 ② force push 감지
```

### 수동 검증
- 없음 — e2e 자체가 실제 install fixture 통합 구동.

## 🔍 발견 사항

- **phase-24 의 결정로그 0건은 "고장"이 아니라 "미사용"이었다** (③ 가 실데이터로 누적을 증명). `decision list --phase` 기능은 정상 — 단지 phase-24 가 attended(turbo)라 auto 결정이 0건이었을 뿐. phase-24 검증표의 의문 하나가 해소됨.
- **측정의 경계가 분명해졌다**: bash e2e 는 *기계적 보장*(차단·경고·누적)을 끝까지 증명하지만, **에이전트가 routine 을 안 묻고 합리적 기본값을 고르는 행동**은 측정 불가. 이것이 #181(행동 기반 평가)이 별도로 필요한 이유 — auto 도그푸딩 운영 데이터로만 닫힌다.
- **칸0 이 e2e/테스트 파일을 올바르게 분류**: `test-e2e-auto-mode.sh` 커밋 시 칸0 가 경고하지 않음(tests/* → 테스트). 25-02 의 분류 엄격화가 통합 환경에서도 유효.

## 🚧 이월 항목

- **행동 기반 e2e (#181)** — 실제 에이전트를 auto 로 짧게 돌려 "결정지점에서 안 멈추고 합리적 진행"을 행동으로 평가. bash 로는 불가 — 별도 하네스 필요. phase-26+ 또는 auto 도그푸딩 운영.
- phase-25 남은 spec: spec-25-04(정지규칙 ② 차단 승격).
