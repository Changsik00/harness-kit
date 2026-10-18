# spec-28-01: wiki 신선도 검사

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-28-01` |
| **Phase** | `phase-28` |
| **Branch** | `spec-28-01-wiki-freshness-check` |
| **Base 브랜치** | `phase-28-docs-freshness` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-10-19 |
| **소유자** | changsik |

## 배경 및 문제 정의

### 현재 상황
`docs/wiki/` 는 `/hk-wiki-ingest` 수동 실행으로만 갱신된다. `sdd doctor` 의 wiki layer 점검(`_check_wiki_layer`)은 디렉토리 존재(W-1), 고아 wikilink(W-2), decisions/rca 90일 미참조(W-3)만 본다. wiki 자체가 *낡았는지* 는 보지 않는다.

### 문제점
2026-10-19 점검에서 wiki 가 2026-06-03 이후 방치돼 `decisions.md` 에 ADR-005~009 가 0건이었고, phase 20~27 의 walkthrough 25개가 미반영이었다. 4개월간 아무 신호가 없었다. wiki 는 에이전트가 맥락 복원에 쓰는 문서라 낡으면 거짓 맥락을 준다.

### 해결 방안
결정론적 신호 두 가지로 wiki 낡음을 판정해 `sdd doctor` 가 경고하고 `sdd status` 진단에 한 줄을 띄운다. 경고(exit 0)로 시작하는 휴리스틱이므로 hook 단계론을 따른다.

## 요구사항

1. **신호 A — 미반영 ADR**: `docs/decisions/ADR-NNN-*.md` 중 `docs/wiki/decisions.md` 와 `docs/wiki/patterns.md` 어디에도 `ADR-NNN` 이 등장하지 않는 것을 센다. (`index.md` 는 인벤토리가 전부 나열하므로 판정에서 제외.) 1개 이상이면 경고.
2. **신호 B — 인제스트 이후 archive 된 spec**: `docs/wiki/log.md` 의 가장 최근 `### YYYY-MM-DD` 날짜 이후 `archive/specs/*/walkthrough.md` 가 git 이력에 추가(A) 또는 이동(R)된 spec 디렉토리 수를 센다. 5개 이상이면 경고. 인제스트 당일은 포함하지 않는다(당일 archive→ingest 순서 허용).
3. 경고 문구는 `/hk-wiki-ingest` 를 안내하고 A 의 미반영 ADR id 목록(최대 5개)을 보여준다.
4. 공유 헬퍼 `_wiki_freshness_report` 하나를 `cmd_doctor` 와 `_status_diagnose` 가 함께 쓴다. 헬퍼는 낡았을 때만 한 줄을 출력하고 최신이면 침묵한다.
5. 다음 환경에서는 침묵한다: `docs/wiki/` 없음(W-1 이 이미 경고), `docs/decisions/` 없음, `archive/` 없음, git 저장소 아님.
6. bash 3.2+ 호환, `set -euo pipefail` 하에서 비정상 종료하지 않는다(헬퍼 내부 실패는 침묵으로 처리).

## Out of Scope

- 인제스트 자동 실행 (경고와 안내까지만)
- spec-x walkthrough 의 미반영 판정 (인용 이름이 달라 오탐 → phase-28 의 `spec-x-ingest-dedup` 항목에서 별도 검증)
- wiki 본문의 의미적 정확성 검증
- 차단(exit ≠ 0) 승격 (운영 데이터 이후 별도 판단)
- wikilink 검사기 ADR 접두 매칭 (phase-FF `wikilink-adr-prefix`)

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 임계값: 신호 A = 1개, 신호 B = 5개로 시작해도 되는가 (보수적 시작, 운영 후 조정)
> - [ ] 신호 B 의 기준일을 `log.md` 마지막 인제스트 날짜로 두는 방식 (wiki 페이지 frontmatter `updated` 대신) — `updated` 는 사람이 수정해도 바뀌어 신뢰도가 낮다고 판단

> [!WARNING]
> - [ ] 신호 B 는 git 이력에 의존한다. shallow clone 이면 과소 집계될 수 있다(침묵 쪽으로 실패하므로 허용).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| 신호 A | 파일명의 `ADR-NNN` 을 wiki 페이지에서 grep | 결정적이고 비용 낮음. ADR 은 드물고 중대해 1개부터 경고 |
| 신호 B | `git log --after --name-only --diff-filter=AR` 한 번 | spec 디렉토리명 grep 방식은 인제스트 직후에도 대부분 "미참조"로 오탐(실제로 25개 인제스트 후 10여개만 인용됨). 날짜 기준이면 인제스트 행위 자체가 신호를 리셋 |
| 통합 | `adr-index` / `_backlog_completed_residue` 처럼 공유 헬퍼 | spec-27-02 선례. doctor 와 status 중복 구현 방지 |
| 강도 | 경고만 | 휴리스틱 (CLAUDE.md #5) |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd`
- `_wiki_freshness_report` 헬퍼 추가 (`_backlog_completed_residue` 근처). 낡았을 때만 한 줄 출력.
- `cmd_doctor` 의 `_check_wiki_layer` 에 W-4 로 호출: 출력이 있으면 `_doc_warn`, 없으면 `_doc_pass "wiki 최신"`.
- `_status_diagnose` 에 `💡` 한 줄 추가.

#### [NEW] `tests/test-wiki-freshness.sh`
- 임시 git 저장소 fixture 로 격리 (실제 레포 변조 없음).

#### [MODIFY] `.harness-kit/bin/sdd`
- 도그푸딩 사본 동기화 (`sources/bin/sdd` 와 동일하게).

## 검증 계획

```bash
bash tests/test-wiki-freshness.sh
bash tests/test-doctor-wiki.sh
bash tests/test-doctor-docs-integrity.sh
bash tests/test-status-backlog-residue.sh
bash tests/run.sh
```

수동 검증 시나리오:
1. 본 저장소에서 `sdd doctor` — 2026-10-19 인제스트 직후이므로 wiki 최신 판정 (신호 A 0개 이상 확인: ADR-001~009 는 decisions.md/patterns.md 에 등장).
2. fixture 에서 새 ADR 파일만 추가 후 `sdd doctor` — 미반영 ADR 경고와 id 목록 표시.

## 롤백 계획
- `git revert` (state·마이그레이션·외부 부수효과 없음).

## ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — 단일 spec 범위의 검사 추가. 신호 정의는 walkthrough 에 기록.

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (기존 포함 회귀 0)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-28-01-wiki-freshness-check` 브랜치 push 완료
