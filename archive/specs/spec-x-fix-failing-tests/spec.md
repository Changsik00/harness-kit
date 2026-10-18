# spec-x-fix-failing-tests: 사전 실패 테스트 4건 정리

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-fix-failing-tests` |
| **Phase** | (없음 — spec-x) |
| **Branch** | `spec-x-fix-failing-tests` |
| **상태** | Planning |
| **타입** | Fix |
| **작성일** | 2026-06-15 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`bash tests/run.sh --fast` 에서 4개 테스트가 실패한다. spec-23-01 작업 중 main 대조로 **모두 본 변경과 무관한 사전 부채**임을 확인했다.

### 문제점 (4건, 근본 원인)

1. **test-version-bump** — README 에 리터럴 버전(`0.17.1`)이 없어 FAIL. 그러나 README 8번 줄은 `version.json` 을 읽는 **dynamic version badge** 를 쓰므로 하드코딩이 없는 게 정상. → 테스트 기대가 stale.
2. **test-update-stateful (S5)** — `plan` 템플릿 누락으로 FAIL. `plan` 은 폐기 산출물(agent.md §4.2 템플릿 표·§5: spec.md = spec+plan 통합)인데, `sdd specx new` 가 빈 plan.md 를 만들고 S5 가 `plan` 을 8개 기대 목록에 포함. → 잔재.
3. **test-wiki-structure (Check 6)** — wiki/ADR frontmatter `sources:` 가 archive 된 spec(`specs/spec-19-*/walkthrough.md`)을 가리켜 FAIL. 파일은 `archive/specs/` 에 실존(이동됨). → 검사가 archive 비인식.
4. **test-pr-merge-detect** — `gh` 부재 시 안내 없이 폴링 시작해 FAIL. → sdd 의 merge-detect 에 gh guard 누락.

### 해결 방안

각 항목을 *최소·정확* 하게 고친다 — 데이터 band-aid 가 아니라 근본을 고친다(테스트 stale 은 테스트 수정, 폐기 잔재는 제거, archive 이동은 검사 archive-aware, guard 누락은 guard 추가).

## 요구사항

1. **version-bump**: (a) 테스트가 README 의 dynamic version badge(`version.json` 링크)를 검증하도록 수정. (b) **Check 6 메타-러너 제거** — version-bump 은 버전 일관성만 검증, 전체 스위트 재실행은 run.sh 책임 (set -e 하 침묵 종료·재귀·중복의 취약 구조). [실행 중 발견]
7. **phase17-integration (5번째, 실행 중 발견)**: Scenario 4c 가 옛 위치 `CLAUDE.md` 에서 CHANGELOG draft 룰을 grep — 룰은 #135 슬림화로 `docs/release-strategy.md` 로 이동됨. 테스트를 이동 위치로 수정 (stale 테스트, CLAUDE.md 변경 불필요).
2. **update-stateful**: S5 기대 템플릿에서 `plan` 제거(8→7). `sdd specx new` scaffold 루프에서 `plan` 제거 → 더 이상 빈 plan.md 안 만듦. (`.harness-kit/bin/sdd` + `sources/bin/sdd` 미러)
3. **wiki-structure**: Check 6 경로 실존 검사를 archive-aware 로 — `specs/X` 부재 시 `archive/specs/X` fallback 인정.
4. **pr-merge-detect**: sdd merge-detect 에 `gh` 부재 guard 추가(부재 시 폴링 대신 안내). (미러)
5. **미러 무결성**: sdd 변경은 `.harness-kit/bin/sdd` ↔ `sources/bin/sdd` byte-identical.
6. **회귀 없음**: `run.sh --fast` 가 4건 해소 후 기존 통과 테스트 유지.

## Out of Scope

- "docs integrity 도구군"(ADR index 생성·integrity check·archive 잔여 감지) 전반 — Icebox #167/#168 유지. 본 spec 은 4개 실패만.
- 폐기 `plan` 의 `sdd spec show` 표시 루프(line 1482)는 `[ -f ]` 가드로 무해 — 선택적 정리(여력 시).

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] #1 은 README 하드코딩이 아니라 **테스트 수정**으로 처리(dynamic badge 보존).
> - [ ] #3 은 stale 경로 직접 수정이 아니라 **검사 archive-aware**(이동된 walkthrough 는 실존하므로 정당, 재발 방지).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **test-version-bump** | README 리터럴 버전 grep → dynamic badge/`version.json` 링크 검증으로 교체 | 수동 sync 부채 재도입 방지 |
| **sdd + test-update-stateful** | `plan` 잔재 제거(scaffold 루프 + S5 목록) | 폐기 산출물(§4.2·§5) 정합 |
| **test-wiki-structure** | `check_sources_paths` 에 archive fallback | 경로는 깨진 게 아니라 이동 — fallback 이 정확 |
| **sdd merge-detect** | `command -v gh` guard | 부재 시 폴링 무한대기 방지 |

## Proposed Changes

#### [MODIFY] `tests/test-version-bump.sh`
README 리터럴 버전 검사를 dynamic badge / `version.json` 링크 존재 검증으로 교체.

#### [MODIFY] `tests/test-update-stateful.sh`
S5 기대 템플릿 목록에서 `plan` 제거.

#### [MODIFY] `.harness-kit/bin/sdd` + `sources/bin/sdd`
(a) `cmd_specx_new` scaffold 루프에서 `plan` 제거. (b) merge-detect 에 `gh` 부재 guard 추가.

#### [MODIFY] `tests/test-wiki-structure.sh`
`check_sources_paths` 경로 실존 검사에 `archive/` fallback 추가.

## 검증 계획

```bash
bash tests/test-version-bump.sh
bash tests/test-update-stateful.sh
bash tests/test-wiki-structure.sh
bash tests/test-pr-merge-detect.sh
bash tests/run.sh --fast
diff -q .harness-kit/bin/sdd sources/bin/sdd
```

수동 검증 시나리오:
1. 4개 테스트 개별 실행 → 전부 PASS.
2. `run.sh --fast` → 기존 4 FAIL 해소, 신규 FAIL 없음.

## ADR 후보

- [x] 없음 — 기존 규약(§4.2 plan 폐기, archive 보존)에 정합시키는 fix. 신규 결정 없음.

## ✅ Definition of Done

- [ ] 4개 대상 테스트 + `run.sh --fast` PASS
- [ ] `.harness-kit/bin/sdd` == `sources/bin/sdd`
- [ ] `walkthrough.md` / `pr_description.md` ship commit
- [ ] `spec-x-fix-failing-tests` 브랜치 push 완료
