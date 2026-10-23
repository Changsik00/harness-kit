---
kind: synthesis
sources:
  - CLAUDE.md
  - README.md
  - archive/backlog/phase-02.md
  - archive/backlog/phase-05.md
  - docs/decisions/ADR-004-phase-ff-first-class.md
  - docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md
  - archive/specs/spec-x-governance-distribute-workflow-patterns/walkthrough.md
  - archive/specs/spec-x-phase-lifecycle-coherence/walkthrough.md
  - CHANGELOG.md
linked:
  - "[[wiki/components/hooks]]"
  - "[[ADR-004]]"
  - "[[ADR-009]]"
updated: 2026-10-23
---

# 방향 — 무엇을 하려는 프로젝트이고, 의도대로 가고 있나

> **시범 페이지 (3층 구조 중 "방향" 층).** 사람이 "이 프로젝트 지금 잘 가고 있나?"를 물을 때 가장 먼저 여는 페이지.
> "판단" 표시가 붙은 칸은 증거를 근거로 한 *해석*이며 사람이 검토해야 한다. 나머지는 출처 문서/코드에서 확인한 사실.

## 한 줄 의도

**"AI 코딩 프레임워크가 아니라, AI 보조 개발의 신뢰성 레이어."** 규칙을 문서로 적는 데서 끝나지 않고 hook·CLI·슬래시 커맨드로 *강제까지 코드로 박는다*. 이해 부채(나중에 그 코드를 설명하지 못하는 비용)를 쌓지 않게 하는 것이 목적. (출처: README §이 키트는 무엇인가)

## 원칙 대비 현황 (의도 vs 현실)

CLAUDE.md "작업 원칙" 6개를 기준으로 점검한다. 확인일 2026-10-22.

| # | 원칙 | 현실 (확인한 사실) | 판단 |
|---|---|---|---|
| 1 | 도그푸딩 — 모든 변경은 실제로 설치·사용되어 검증 | 이 저장소가 자기 자신을 설치해 쓴다(`.harness-kit/` 사본). phase-28 의 원본↔사본 drift 검사가 사본이 뒤처진 실제 사례를 잡았다. 단 원칙이 명시한 외부 첫 사용자(nextmarket-api) 검증 여부는 이 저장소에서 확인할 수 없다 | 자기 도그푸딩 ✅ / 외부 검증 **미확인** |
| 2 | 컨텍스트 비용 0 우선 (bash > slash > skill > MCP) | 수단 선택은 지켜짐: `sdd` 단일 bash CLI(3,380줄), hook 스크립트 16개(+공유 헬퍼 `_lib.sh`·`_plan_accept_paths.sh`), 슬래시 커맨드 23개(2026-10-23 실측). 반면 *항상 로드되는 거버넌스*는 constitution+agent.md 7,902w 로 doctor 의 soft 상한 7,000w 초과(hard 8,000w) | 수단 ✅ / 거버넌스 분량 ⚠️ |
| 3 | bash 3.2+ 호환 | 규칙으로 존재하고(셸 정책은 zsh 네이티브 → bash 4.0+ → 3.2+ 로 번복 후 수렴, 아래 §반복되는 방향 이슈 2) 작업 시 지켜지나(이번 세션의 신규 테스트도 3.2 호환 명시), 이를 자동으로 검증하는 lint 는 확인되지 않음(shellcheck 미설치로 staged-lint 도 건너뜀) | 준수는 관행에 의존 ⚠️ |
| 4 | 한국어 산출물 | 전 산출물 한국어 유지 | ✅ |
| 5 | Hook 단계론 (휴리스틱은 경고→1주 후 차단) | 0.20.0 에서 "결정론적·fail-safe hook 은 즉시/모드 차등" 으로 정제. 그러나 *경고로 시작한 hook 의 차단 승격이 실제로 일어난 기록*이 없다 → [[wiki/components/hooks]] §반복·미결 | 정제는 ✅ / 승격 이행 ⚠️ |
| 6 | No Over-engineering, NestJS 1차 타깃 | stack adapter 는 제거(spec-x-remove-stack-adapter)돼 스택 분기가 없다. 과설계 방지는 ADR-004(right-size, phase-FF)로 제도화. 반면 최근 3 phase(27~29)가 모두 *문서 정리 도구* 계열 | 판단: 아래 §쏠림 참조 |

## 연혁 (phase 흐름)

| 구간 | phase | 주제 | 읽는 법 |
|---|---|---|---|
| 기초 | 01~08 | 설치 마찰 해소, 토큰 최적화·거버넌스 경량화(02), queue·phase base branch 모델(08) | 최소 동작 + 작업 관리 모델 확립 |
| 방어 | 09~15 | 설치 충돌 방어, 상태 진단 신뢰성, 식별자·아카이브, DX, 정합성·멱등성 버그 일괄(14), 업데이트 안전성(15) | **설치/업데이트 버그가 주 비용** — 사용자 환경 침범과 정합성 |
| 신뢰성 | 16~19 | Reliability Layer, 운영 성숙도, 문서 지식 그래프(19) | 지식 계층(ADR/wiki) 도입 |
| 자율화 | 20~26 | 디렉터 모드(20), ceremony 경량화·turbo(21), extend(22~23), auto 모드(24~26) | **사전 게이트 → 사후 검증**으로 무게중심 이동 (ADR-009) |
| 문서 도구 | 27~29 | docs-integrity, docs-freshness, doctor-accuracy | 지식 계층을 *도구로 지키는* 단계 |

## 반복되는 방향 이슈 (스레드)

1. **"경량화"가 세 번 나온다.** phase-02(토큰 최적화·거버넌스 경량화) → phase-21(ceremony 경량화, turbo) → ADR-004/009(right-size, 사후 검증 이동). 그 사이 거버넌스·의식이 다시 늘었기 때문에 재경량화가 필요했던 것으로 보인다. 거버넌스 단어 상한도 5,000w → 6,000w(*"무절제 상향 금지"* 코멘트와 함께, spec-x-governance-distribute-workflow-patterns) → 현재 7,000w soft 로 상향돼 왔고, 지금 7,902w. **판단**: 경량화는 일회성 작업이 아니라 반복 부채. 상한 상향이 되풀이되는지 추적 필요.
2. **셸 정책이 3단계로 번복됐다 (zsh 네이티브 → bash 4.0+ → bash 3.2+).** phase-03 의 spec-03-01 이 `--shell=zsh` 네이티브 모드를 구현(#7)했다가 `spec-x-remove-zsh-compat`(#59)에서 "zsh 호환 코드 전부 제거, bash 4.0+ 전용"으로 되돌렸고, 다시 spec-14-02(#77)에서 "정책과 코드가 모순(코드는 실제로 3.2+ 호환)"이라며 CLAUDE.md 를 **bash 3.2+** 로 갱신했다. 계획됐던 spec-03-02(macOS 가이드)·03-03(Linux CI)은 만들어지지 않았고 Linux CI 는 지금도 없다(`.github/workflows` 없음). **상태: 수용(3.2+ 로 수렴). Linux CI 는 미결.**
3. **크로스 에이전트 호환은 검토 후 No-Go 로 결정됐다.** phase-05 의 spec-05-01(spec-kit 벤치마크)이 병렬 태스크 표시는 Go, 다중 산출물 구조는 Conditional Go, 커뮤니티 extension·Python CLI 의존·프롬프트 기반 거버넌스·**멀티 에이전트 지원은 No-Go(현재)** 로 결론냈고 spec-05-02(AGENTS.md 호환)는 그에 따라 만들어지지 않았다("AGENTS.md 는 Linux Foundation 표준이 아님, 커뮤니티 프로젝트"). 결정은 있으나 *phase 파일에는 반영되지 않았다.* **상태: 결정됨(No-Go, 재검토 조건 미기록).**
4. **phase 파일 상태가 현실과 어긋난다.** phase-03~06 은 `Planning` 으로 archive 됐지만 실제로는 spec 6개가 실행돼 walkthrough 까지 남아 있다(03-01 구현 후 철회, 04-01/02 → 이후 `hk-spec-critique`·`hk-code-review` 로 개명, 05-01 리서치 완료, 06-01/02 완료). 즉 *실행이 안 된 게 아니라 phase 메타가 갱신되지 않았다.* 처분: 각 archive phase 파일의 상태 정정(phase-30 F5).


## 쏠림 점검 (판단)

최근 phase 27→28→29 는 모두 "문서/지식 계층을 도구로 정리·검사"이다. 이는 의도(신뢰성 레이어)와 맞지만, **측정 대상이 '문서가 정리됐는가'에 머물고 '지식이 맞는가'로 가지 못했다**는 지적이 2026-10-22 에 제기됨(wiki 가 요약 색인에 그친다는 점). 다음 방향은 이 wiki 구조 개편(3층)으로 이어진다. 이 진단 자체가 *의도 대비 현실* 점검의 사례이므로 방향 층에 기록한다.

## 열린 질문

- 외부 프로젝트(nextmarket-api)에서의 실제 적용 결과는 어디에 기록되는가? (원칙 1 의 근거가 이 저장소 밖에 있음)
- spec-05-01 의 No-Go("멀티 에이전트 지원, 현재")를 재검토할 조건은 무엇인가? (재검토 트리거가 기록돼 있지 않음)
- Linux CI 는 계속 없이 가는가? (macOS 전용 선언인지, 미결인지)
- 거버넌스 분량 상한을 더 올리는 대신 줄일 것인가(rule prune)? 현재 7,902w, hard 8,000w.
