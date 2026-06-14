# Walkthrough: spec-20-04

> phase-20 디렉터 모드의 마감 번들 — 모델 역할 config(de-hardcode) + review 페르소나 패널 + 중재 패턴. **3 테마를 1 ceremony 유닛으로** 묶은 spec 이자, 그 묶음 결정을 촉발한 *ceremony 비용 교훈*의 산물.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 잔여 3 항목 구조 | 각각 spec / 1 번들 / phase-FF | **1 spec 번들** | 88~172w 변경 6개를 full spec 으로 쪼개니 형식 채우기가 작업을 압도(사용자 지적). 같은 파일(agent.md) 반복 편집 = bundle 신호 |
| 모델 매핑 위치 | 거버넌스 본문 / config | **`harness.config.json` `models`** | 모델 이름 churn → 거버넌스는 *역할*만, 이름은 config. 성공기준 4 달성 |
| review 패널 | 전면 교체 / 옵션 | **옵션 + 소규모 단일 fallback** | 단일 Opus 깊이 손실·over-kill 방지. 디렉터 모드 off 면 기존 동작 |
| 중재 대화(구 20-05) | research POC / 패턴 기록 | **patterns.md 기록만** | harness-kit 에 front/back 앱 부재 — POC 대상 없음. 통찰을 패턴으로 보존이 현 단계 올바른 산출 |

### ADR 승격 가이드
- [x] 없음 — ADR-005/006 의 운영 구체화. §6.6 + config 로 충분.

## 💬 사용자 협의 (이 spec 의 핵심 — 프로세스 교훈)

- **주제 1 — ceremony 비용의 정체**:
  - **사용자**: "실제 코드는 별건데 우리 양식 채우는 과정이 더 많다. 산출물이 코드의 10배. 이 전부가 SDD 하나로 됐을 일이다."
  - **합의**: phase 안 작은 항목을 *전부 full spec* 으로 만든 게 잘못. 작은 작업은 **유닛을 묶어**(번들/phase-FF) 작업:형식 비율을 작업 쪽으로.
- **주제 2 — "문서를 짧게"는 오답**:
  - **사용자**: "문서를 짧게 쓰라는 게 아니다. 짧으면 내가 못 알아보고 너도 역추적 못 한다."
  - **합의**: 비용은 *형식 유닛 수*로 줄이고, **문서 품질(이해+역추적)은 유지**. (내가 한 번 문서를 얇게 썼다가 이 spec 의 spec/plan/task 를 제대로 다시 씀.)
- **주제 3 — 한 파일 반복 편집**:
  - **사용자**: "하나의 파일을 계속 조금씩 수정하고 있다. 괜찮나?"
  - **합의**: 순차라 충돌은 없으나 *분절 신호*. 본 spec 에서 §6.6 재작성 시 §6.1/§6.7/§6.8 일관성 점검(워커가 "worker sub-agent" 로 정리, 중복 제거).

## 🧪 검증 결과

- **단위 테스트**: `test-director-mode.sh` 22/22 · `test-director-protocol.sh` 10/10 · `test-governance-dedup.sh` 8/8 PASS
- **수동**:
  - `sdd config models` → `director:opus / worker:sonnet / scout:haiku` 출력
  - `grep -cE "Opus|Sonnet|Haiku|claude-" sources/governance/agent.md` → **0** (de-hardcode 달성)
  - 단어 합계 7563/8000w, 미러 parity 동일

## 🔍 발견 사항

- **발견2 재발(형태 변화)**: spec-20-01 에선 *워커*가 spec/plan 을 미커밋했고, 이번엔 *디렉터(내)*가 직접 작성한 spec/plan 을 커밋 task 에 안 넣어 미커밋으로 남김 → ship 에서 수습. **교훈: "산출물 커밋"은 작성 주체(워커/디렉터) 무관하게 ship 전 체크. spec-20-03 §6.1 규칙을 디렉터 자신에게도 적용.**
- **번들이 옳았던 증거**: 이 spec 하나가 구 20-04/05/06 세 테마를 담았고, 실제 코드 변경(config + sdd subcommand + 3 command + §6.6 + 패턴)은 *충분한 분량*이라 full ceremony 1회가 정당. 작업:형식 비율 정상.
- **scout 티어 실효성**: director/worker 는 §6.1 에 이미 있었고 scout 만 신규 — 검색·grep sweep·로그 triage 의 저비용 위임 경로가 비로소 1급 정의됨.

## 🚧 이월 항목

- phase-FF: README "모델 분배" 표를 역할 기반으로 동기화 (phase.md phase-FF 항목).
- Icebox: `sdd ship` base-mode 갭 / governance §13 prune (단어 7563, 여유 437w — 다음 거버넌스 변경 전 판단).
- 다음: phase-20 전 spec Merged → `/hk-phase-ship`.

## 🔗 관련 문서
- 관련 ADR: [[ADR-005]], [[ADR-006]]
- 관련 wiki: [[wiki/patterns]] (mediated-design-dialogue 추가)
- 관련 메모: [[feedback-sdd-economy]] (본 spec 이 그 교훈의 실사례)

## 📅 메타
| 항목 | 값 |
|---|---|
| **작성자** | Director(Opus) + dennis, 구현 Sonnet 워커 |
| **작성 기간** | 2026-06-04 |
| **최종 commit** | (ship 직전) |
