# spec-27-02: docs integrity check (`sdd doctor` 확장)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-27-02` |
| **Phase** | `phase-27` |
| **Branch** | `spec-27-02-docs-integrity-check` |
| **Base 브랜치** | `phase-27-docs-integrity` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-07-02 |
| **소유자** | changsik |

## 배경 및 문제 정의

### 현재 상황

spec-27-01 에서 `sdd adr-index [--check]` 가 추가돼 ADR 인덱스 drift 는 단독으로 검사할 수 있게 됐다. 그러나 ADR 번호 중복, frontmatter 누락, 완료 phase 의 backlog 잔존 같은 다른 문서 무결성 문제는 여전히 점검 도구가 없다.

### 문제점

`sdd doctor` 는 도구/설치 파일/훅 권한/wiki layer 는 점검하지만 ADR·backlog 레이아웃 규약은 점검하지 않는다(GitHub #168). 다운스트림 도그푸딩에서 이 4항목을 로컬 스크립트로 만들어 썼던 사례가 harness-kit 원본 승격을 요청한 배경이다.

### 해결 방안

`sdd doctor` 에 4개 검사를 추가한다: ADR 번호 유일성 / frontmatter 존재 / ADR 인덱스 drift(spec-27-01 재사용) / 완료 phase 의 backlog 잔존. 차단급(번호 중복·frontmatter 누락)은 `_doc_fail`, 경고급(인덱스 drift·backlog 잔존)은 `_doc_warn` 으로 구분한다.

## 요구사항

1. `sdd doctor` 실행 시 새 섹션 "docs 무결성" 아래 4개 검사 결과를 출력한다.
2. **ADR 번호 유일성**: `docs/decisions/ADR-*.md` 의 `id:` frontmatter 값 중복 시 `_doc_fail` — 중복된 id 나열.
3. **ADR frontmatter 존재**: 각 ADR 파일의 1번째 줄이 `---` 가 아니면 `_doc_fail` — 대상 파일 나열.
4. **ADR 인덱스 drift**: `cmd_adr_index --check` 를 서브셸로 호출(→ `exit` 격리) 해 실패 시 `_doc_warn`.
5. **backlog 완료 phase 잔존**: `backlog/queue.md` 의 `<!-- sdd:done:start -->`~`end` 구간에서 `phase-NN` 패턴을 추출해, 해당 `backlog/phase-NN.md` 가 여전히 존재하면 `_doc_warn` — 잔존 개수와 목록.
6. **Non-functional**: 5번(잔존 탐지)은 별도 헬퍼 함수(`_backlog_completed_residue`)로 분리해, spec-27-03(`sdd archive`)이 동일 로직을 재사용할 수 있게 한다 (GitHub #168 제안 2/3 이 같은 잔존 개념을 공유하므로 중복 구현 방지).

## Out of Scope

- `sdd archive` 자체가 잔존을 경고하도록 만드는 것 — spec-27-03 담당 (본 spec 은 재사용 가능한 헬퍼만 제공).
- doctor 의 exit code 를 fail 여부에 따라 non-zero 로 바꾸는 것 — 현재 doctor 는 순수 진단 도구(정보 출력)이고 다른 검사 항목도 그렇게 동작함. 실제 차단은 향후 별도 hook 화 검토 대상.
- backlog 레이아웃의 "표준 파일명 외 존재" 같은 포괄적 검사 — GitHub #168 이 명시한 "완료 phase 잔존"만 구현.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 없음 — 골격 수준 기능 추가.

> [!WARNING]
> - [ ] `sdd doctor` 출력에 새 섹션이 추가되어 기존 파서/스크립트가 doctor 출력을 텍스트로 파싱하고 있다면 영향 가능(현재 그런 소비자 없음 확인).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **통합 위치** | 신규 서브커맨드 대신 기존 `cmd_doctor()` 확장 | context-cost-first — `doctor` 가 이미 진단 전용 진입점, 새 명령 불필요 |
| **`adr-index --check` 재사용 방식** | `( cmd_adr_index --check )` 서브셸 호출 | `cmd_adr_index` 는 실패 시 `exit 1` 하는데, 이를 함수 그대로 doctor 안에서 부르면 doctor 전체가 죽는다 — `( )` 서브셸로 격리해 exit 이 서브프로세스만 종료하게 함 |
| **잔존 탐지 재사용성** | 독립 헬퍼 함수로 분리 | spec-27-03 이 같은 로직을 `sdd archive` 에서 재사용 — 중복 구현 방지 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd`
`cmd_doctor()` 에 "docs 무결성" 섹션 + `_check_adr_id_uniqueness` / `_check_adr_frontmatter` / `_check_adr_index_drift` / `_backlog_completed_residue`(+ doctor 용 wrapper) 추가.

#### [MODIFY] `.harness-kit/bin/sdd`
동일 변경 미러.

#### [NEW] `tests/test-doctor-docs-integrity.sh`
4항목 각각을 개별 fixture 로 탐지하는 회귀 테스트.

## 검증 계획

```bash
bash tests/test-doctor-docs-integrity.sh
bash tests/run.sh
```

수동 검증 시나리오:
1. `bash .harness-kit/bin/sdd doctor` 실행 — 기대 결과: "docs 무결성" 섹션에 4개 항목 출력(본 저장소는 ADR 중복/frontmatter 누락 없음·adr-index 정합이라 PASS, backlog 잔존은 phase-23~26 미아카이브로 실제 WARN 발생 예상 — 실 데이터로 검증 가치 있음).
2. 임시 ADR 에 중복 id 부여 후 doctor 재실행 — 기대 결과: ❌ FAIL 로 보고, 원복 후 정상.

## 롤백 계획

- `git revert` — state 영향 없음. doctor 는 순수 진단 출력이라 롤백 리스크 없음.

## ADR 후보

- [ ] ADR 가치 있는 결정 있음 → 후보: 없음
- [x] 없음

## ✅ Definition of Done

- [ ] 모든 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-27-02-docs-integrity-check` 브랜치 push 완료
