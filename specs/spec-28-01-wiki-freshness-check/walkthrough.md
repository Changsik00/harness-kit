# Walkthrough: spec-28-01

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 신호 B 판정 기준 | spec 디렉토리명이 wiki 에 인용됐는지 / `log.md` 마지막 인제스트 날짜 이후 archive 된 walkthrough 수 | **날짜 기준 (git 이력)** | 이름 기준은 인제스트 직후에도 오탐: 25개를 인제스트했지만 wiki 에 이름이 인용된 건 10여 개뿐. 날짜 기준이면 인제스트 행위가 신호를 초기화 |
| 신호 A 대상 페이지 | wiki 전체 / decisions.md + patterns.md | **decisions.md + patterns.md** | `index.md` 는 ADR 인벤토리가 전부 나열해 어떤 ADR 이든 "반영됨"으로 오판. `log.md` 도 제외 |
| 기준일 출처 | wiki 페이지 frontmatter `updated` / `log.md` 마지막 `### YYYY-MM-DD` | **`log.md`** | `updated` 는 사람이 사소한 수정을 해도 바뀌어 신뢰도 낮음. 인제스트 이벤트만 log 에 기록됨 |
| 당일 처리 | 인제스트 당일 포함 / 제외 | **제외** (`--after "<날짜> 23:59:59"`) | archive → ingest 순서로 같은 날 하는 것이 정상 흐름 (이번 세션이 그 사례) |
| 강도 | 경고 / 차단 | **경고(exit 0)** | 휴리스틱 (CLAUDE.md #5). 임계값(A=1, B=5)은 운영 후 조정 |
| 헬퍼 공유 | doctor 와 status 각자 구현 / 공유 헬퍼 | **`_wiki_freshness_report` 공유** | spec-27-02 의 `_backlog_completed_residue` 선례. 낡았을 때만 출력하고 아니면 침묵 |

<!-- ADR 승격: 단일 spec 범위의 검사 추가 — 승격 대상 없음 -->

## 💬 사용자 협의

- **주제**: Plan Accept vs Critique
  - **합의**: 범위가 작고 경고 수준이며 롤백이 `git revert` 한 번이라 Critique 생략, Plan Accept (2026-10-19)

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/run.sh`
- **결과**: ✅ PASS: 82 / FAIL: 0 / SKIP: 0
- **신규**: `tests/test-wiki-freshness.sh` 6 케이스 (임시 git 저장소 fixture — 실제 레포 변조 없음)
- **회귀 확인**: `test-doctor-wiki`, `test-doctor-docs-integrity`, `test-status-backlog-residue`, `test-hook-modes`, `test-test-auto-record`, `test-pr-merge-detect`, `test-director-mode`, `test-update` 통과

### 수동 검증
1. **Action**: 도그푸딩 사본 동기화 후 본 저장소에서 `sdd doctor`
   - **Result**: `wiki 낡음: 미반영 ADR 1개 (ADR-004)` 경고. 정상 동작 — 실제로 ADR-004 요약이 `decisions.md` 에 없음
2. **Action**: 같은 저장소에서 `sdd status`
   - **Result**: 🔍 진단에 동일 문구가 `💡` 로 표시됨

## 🔍 발견 사항

- **도그푸딩 첫 실행에서 실제 누락을 적발**: 2026-10-19 인제스트 직후인데도 ADR-004(phase-FF) 가 decisions.md/patterns.md 어디에도 없었다. ADR-005~009 만 다루고 004 를 빠뜨린 것 → 검사가 의도대로 작동. 보강은 phase-FF `spec-x-ingest-dedup` 에서 함께 처리 예정.
- **`_status_diagnose` 의 base 모드 오탐 (기존 결함)**: `spec-28-01: phase.md(Active) ↔ git(머지됨) → sdd ship 실행 권장` 이 표시됨. phase 브랜치 git log 에서 spec ID 를 단순 grep 하기 때문에, 본 spec 의 spec/task 작성 커밋(`docs(spec-28-01): ...`)이 phase 브랜치에 있다는 이유로 "머지됨"으로 오판한다. 머지 커밋(`(#NNN)`)만 보거나 active spec 을 제외해야 함 → phase-FF `diagnose-msg-fix` 범위에 포함.
- **칸 0(test-trust) 경고**: Task 2·3 구현 커밋에서 "동반 테스트 없음" 경고. Task 1 에 테스트를 별도 커밋(red)으로 둔 TDD 분리 때문이며 spec-25-04 에서 이미 기록된 알려진 coarseness. 비차단.
- **shellcheck 미설치**: staged-lint 가 Shell lint 를 건너뜀. 이번 변경은 lint 미검증.

## 🚧 이월 항목

- ADR-004 wiki 반영 + spec-x 인제스트 중복 검증 → phase-28 phase-FF `spec-x-ingest-dedup`
- `_status_diagnose` base 모드 오탐 교정 → phase-28 phase-FF `diagnose-msg-fix` 에 범위 추가
