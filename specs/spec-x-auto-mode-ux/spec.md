# spec-x-auto-mode-ux: /hk-auto 커맨드 + "검증 단계" 용어 개명

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-auto-mode-ux` |
| **Phase** | 없음 (spec-x) |
| **Branch** | `spec-x-auto-mode-ux` |
| **Base 브랜치** | `main` |
| **상태** | Planning |
| **타입** | Fix / Docs |
| **작성일** | 2026-06-23 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

0.20.0 으로 auto 모드를 출시했으나 사용자 검토에서 두 UX 결함이 드러남:
1. **auto 슬래시 커맨드 부재** — `/hk-turbo`(governed↔turbo)·`/hk-ask-mode` 는 있는데 **`/hk-auto` 가 없다**. auto 는 `sdd mode auto` 로만 진입 → 발견성·일관성 결여.
2. **"칸0/칸1/칸2" 용어가 불명확** — #212 "비용 사다리" 의 단계를 "칸N" 으로 옮겼는데, 한국어 원어민도 "space 2?" 로 오해. "사다리/칸" 비유 자체가 직관과 어긋남.

### 해결 방안

1. `/hk-auto` 커맨드 추가 — `/hk-turbo` 패턴(governed↔auto 토글) + unattended 경고.
2. "칸N / 비용 사다리" → **"검증 N단계 / 위험 비례 검증 단계"** 로 개명. 단계 번호 = 검증 강도·비용(높을수록 강하고 비쌈). live 운영·정규 문서 일괄 정리.

## 용어 정의 (확정)

| 신규 | 구 | 의미 |
|---|---|---|
| **위험 비례 검증 단계** | 비용 사다리 | 위험이 클수록 더 높은(비싼) 검증 단계를 적용 |
| **검증 0단계** | 칸0 | 정적 가짜-green 체크(`check-test-trust`). 토큰 0, 항상 |
| **검증 1단계** | 칸1 | 뮤테이션(심은 버그 잡나). 컴퓨트, 중요 모듈 (미구현·Icebox) |
| **검증 2단계** | 칸2 | 적대적 의도 반증(`/hk-refute`). LLM 토큰, 고위험만 |

## 요구사항

1. `/hk-auto` 커맨드: 현재 모드 확인 → governed↔auto 토글 안내 + auto 의 unattended 경고(정지규칙·사후검증이 안전 담당). `sources/commands/hk-auto.md` + `.claude/commands/` 미러 + `installed.json` 등록.
2. "칸N/비용 사다리" → "검증 N단계/위험 비례 검증 단계" 개명 — **운영·정규 문서**: README, `hk-refute.md`, `check-test-trust.sh`(주석+경고 메시지), `pre-commit.sh` 주석, `agent.md` §6.7, ADR-009 Addendum, CHANGELOG 0.20.0. 설치본 미러 동기.
3. 회귀 테스트: 위 운영 파일에 `칸[0-9]` 가 0건(개명 누락 봉인) + `/hk-auto.md` 존재.

## Out of Scope

- `backlog/phase-25.md`(완료 내부 backlog, 19곳) · 머지된 immutable walkthrough — 역사 기록이라 미개명(혼동 시 grep 으로 추적 가능).
- auto 모드 동작 변경 (커맨드는 안내·토글만, 엔진 불변).
- 검증 1단계(뮤테이션) 구현 (Icebox 유지).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **/hk-auto** | `hk-turbo.md` 구조 복제 + auto 경고 | 기존 패턴 일관 |
| **개명** | 운영/정규 문서만, 역사 기록 제외 | 사용자·에이전트가 *지금* 마주치는 곳을 정합. 완료 backlog 재작성은 저ROI |
| **재발 방지** | `칸[0-9]` 부재 테스트 | 일부만 바꿔 잔재 남는 것 방지 |

## Proposed Changes

#### [NEW] `sources/commands/hk-auto.md` (+ `.claude/commands/` 미러)
governed↔auto 토글 안내 커맨드. unattended 경고 포함.

#### [MODIFY] 개명 (live)
`README.md` · `sources/commands/hk-refute.md` · `sources/hooks/check-test-trust.sh` · `sources/hooks/pre-commit.sh` · `sources/governance/agent.md` · `docs/decisions/ADR-009-*.md` · `CHANGELOG.md` + 설치본 미러(`.harness-kit/`, `.claude/commands/`).

#### [MODIFY] `.harness-kit/installed.json`
`installedCommands` 에 `hk-auto` 추가.

#### [NEW] `tests/test-terminology.sh`
운영 파일에 `칸[0-9]` 0건 + `hk-auto.md` 존재 검증.

## 검증 계획

```bash
bash tests/test-terminology.sh
bash tests/run.sh
grep -rl "칸[0-9]" README.md sources/ .claude/commands/ docs/decisions/ADR-009-*.md   # → 없음
```
수동: `/hk-auto` 안내 흐름 1회 검토.

## 롤백 계획

- `git revert` — 커맨드 + 문서 개명 + 테스트만. 동작 불변.

## ADR 후보

- [ ] 없음 (용어 정리 + UX 커맨드 — 새 아키텍처 결정 없음).

## ✅ Definition of Done

- [ ] `/hk-auto` 커맨드 + 미러 + installed.json 등록
- [ ] 운영/정규 문서 "검증 N단계" 개명 + 미러 동기
- [ ] `tests/test-terminology.sh` PASS (`칸[0-9]` 0건)
- [ ] 전체 회귀 PASS
- [ ] `walkthrough.md` / `pr_description.md` ship + push + PR
