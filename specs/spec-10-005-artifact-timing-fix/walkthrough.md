# Walkthrough: spec-10-005

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| spec new에서 어떤 파일을 제외할지 | walkthrough만 / pr_description만 / 둘 다 | 둘 다 제외 | 두 파일 모두 Ship 시점에만 의미 있음. 조기 생성 시 spec-10-003 Artifacts 체크가 `Ship-ready`로 오판 |
| `sdd spec show`의 for 루프도 수정할지 | 수정 / 유지 | 유지 | show는 `[ -f ]`로 존재하는 파일만 표시 — walkthrough/pr_description이 없으면 아예 출력 안 됨 |
| walkthrough 템플릿 구조 | 기존 유지 / 섹션 추가 / 전면 개편 | 섹션 추가 | `📌 결정 기록` + `💬 사용자 협의`만 추가. 기존 검증 결과 섹션은 유지하되, `🔍 발견 사항`에서 Optional 제거하여 필수 기록으로 승격 |

## 💬 사용자 협의

- **주제**: walkthrough가 기록하는 내용의 가치
  - **사용자 의견**: "구현 내용 나열은 diff를 보면 되니 의미 없다. 정작 남겨야 할 것 — 예상 못한 발견, 디버깅 과정, 결정 이유, 기존 이슈 발견 — 을 다 놓쳤다"
  - **합의**: walkthrough의 핵심 가치를 "작업 중 예상 못한 발견 + 왜 그렇게 결정했는지"로 재정의. `📋 실제 구현된 변경사항` 섹션은 최소화하고, 결정 기록/사용자 협의/발견 사항에 실질적 내용 집중.

- **주제**: `sdd archive` 네이밍
  - **사용자 의견**: "이 워딩이 맞는가? hk가 왜 안 붙었나?"
  - **합의**: `sdd`는 CLI, `hk-`는 슬래시 커맨드. 네이밍은 일관적이지만 "archive"보다 "ship/finalize"가 더 정확할 수 있음 → Icebox 후보로 기록

- **주제**: pr_description 생성 타이밍
  - **사용자 의견**: PR 직전에 만들어지는 게 맞는지 확인
  - **합의**: Ship task에서 생성 → archive 커밋 → push → PR. 타이밍 정확함. 변경 불필요.

## 🔍 발견 사항

- **phase-10.md 중복 행 반복 발생**: `sdd spec new`가 Active 행 추가 → `sdd archive`가 Merged 행 추가 → 같은 spec이 2행. 이 현상이 spec-10-002, 003, 004에서 반복됨. phase.md 정리 커밋을 매번 수동으로 해야 했음. `sdd archive`의 상태 전이 로직이 기존 행을 업데이트하지 않고 새 행을 추가하는 것으로 보임 → **별도 수정 필요 (Icebox)**
- **기존 테스트 실패 2건**: `test-hook-modes.sh` (1/12 FAIL), `test-zsh-compat.sh` (1/20 FAIL). exit code는 0이라 전체 스위트는 통과하지만 실제 실패가 있음. spec-10-005 변경과 무관한 기존 이슈. 조사되지 않은 채 방치 중 → **별도 조사 필요 (Icebox)**
- **walkthrough 작성 타이밍 문제**: 현재 에이전트는 Ship task에서 한 번에 walkthrough를 작성. 하지만 작업 중 실시간으로 갱신해야 의미 있는 내용이 담김. `sdd spec new`에서 walkthrough를 안 만드므로, 에이전트가 첫 Task 시작 시 빈 walkthrough를 생성하고 작업 중 갱신하는 흐름이 필요 → **agent.md Strict Loop에 walkthrough 갱신 규칙 추가 필요 (Icebox)**

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + ck |
| **작성 기간** | 2026-04-16 |
| **최종 commit** | `74f784b` |
