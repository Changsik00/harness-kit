# phase-27: docs-integrity

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-27-{seq}-docs-integrity/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-27` |
| **상태** | Planning |
| **시작일** | 2026-07-02 |
| **목표 종료일** | - |
| **소유자** | changsik |
| **Base Branch** | `phase-27-docs-integrity` |

## 🎯 배경 및 목표

### 현재 상황

harness-kit 이 정의한 문서 규약(ADR 번호/frontmatter, backlog 레이아웃)은 도구가 없어 수기로만 유지되며, 실사용(도그푸딩 + 다운스트림 사용자 리포트)에서 두 갈래 문제가 확인됐다.

1. **stale ADR 오탐 (GitHub #167)**: `sdd status` 의 `_drift_stale_adr` 휴리스틱이 npm 스코프 패키지(`@scope/pkg@6.7.1`)나 IAM role(`roles/speech.editor`) 같은 비-경로 토큰을 파일 경로로 오인해 stale 로 잘못 보고한다. ADR 은 "작성 시점 스냅샷"이라는 본질과도 맞지 않는다.
2. **문서 무결성 도구 부재 (GitHub #168)**: 다운스트림(docs-heavy 모노레포) 도그푸딩에서 ADR 인덱스 수기 유지 drift, ADR 번호/frontmatter 무결성 미검증, `sdd archive` 가 오래된 완료 phase 를 놓치고 잔여를 남기는 문제가 로컬 스크립트로 해결됐다 — harness-kit 원본으로 승격 요청.

두 이슈 모두 `sdd doctor` / stale 검사 영역이라 queue.md Icebox 에서 "묶어서 doctor 강화 phase 로 승격 권장"으로 이미 합의된 바 있다.

### 목표 (Goal)

- stale ADR 검사의 오탐(npm/IAM 패턴)을 제거한다.
- ADR 인덱스를 frontmatter 로부터 자동 생성/검증할 수 있게 한다.
- ADR 번호 유일성·frontmatter 존재·인덱스 drift·backlog 레이아웃을 한 번에 점검하는 docs integrity 체크를 제공한다.
- `sdd archive` 가 완료된 오래된 phase 잔여(backlog/phase-N.md)를 놓치지 않고 경고하게 한다.

### 성공 기준 (Success Criteria) — 정량 우선

1. `sdd status` 가 npm 스코프 패키지 / IAM role 토큰에 대해 stale ADR 오탐을 0건 보고한다 (회귀 테스트로 고정).
2. `gen-adr-index` 로 `docs/decisions/README.md` (또는 동등 인덱스 파일) 를 마커 구간 재생성할 수 있고, `--check` 모드가 drift 시 non-zero exit 한다.
3. docs integrity check 가 ADR 번호 중복 / frontmatter 누락 / 인덱스 drift / backlog 레이아웃 위반 4항목을 각각 탐지하는 테스트를 갖는다.
4. `sdd archive` 가 `queue.md` 완료 표시 phase 인데 `backlog/phase-N.md` 가 잔존하면 경고를 출력한다.

## 🧩 작업 단위 (SPEC + phase-FF)

> 본 절은 phase 의 *작업 지도* 입니다. phase 설계 시 각 작업을 크기에 맞게 미리 배치합니다 — 실질적/불확실 → **SPEC**(아래 표), 작고 가역적인 1–2 commit → **phase-FF**(맨 아래 목록, spec 산출물 없음, → ADR-004).
> SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다. 자세한 spec/task 는 `specs/spec-27-{seq}-docs-integrity/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`
> sdd가 ship 시 자동으로 `Merged`로 갱신합니다. `In Progress`는 active spec에 자동 마킹됩니다.

### spec-27-01 — adr-index-gen

- **요점**: ADR frontmatter(`id`/`type`/`date`/`status`)를 SoT 로 읽어 `docs/decisions/README.md` 의 마커 구간(`<!-- adr-index:start -->` ~ `end`) 테이블을 재생성하는 `gen-adr-index` 를 추가한다.
- **방향성**: 기본 모드는 재생성(다른 섹션 보존), `--check` 모드는 drift 시 exit 1 (CI/doctor 게이트용). bash 3.2+/macOS 호환 — `awk -v var="multi\nline"` 개행 이슈 회피를 위해 bash 라인 루프로 마커 치환.
- **참조**:
  - GitHub #168 (제안 1)
  - `.harness-kit/agent/constitution.md` §6.4 (Knowledge Type Vocabulary — frontmatter `type:` 폐쇄집합)
- **연관 모듈**: `.harness-kit/bin/sdd`, `docs/decisions/README.md` (신규 또는 갱신)

### spec-27-02 — docs-integrity-check

- **요점**: ADR 번호 유일성 / frontmatter 존재 / ADR 인덱스 drift(spec-27-01 의 `--check` 호출) / backlog 레이아웃(완료 phase 파일이 `backlog/` 루트에 잔존하는지)을 한 번에 점검하는 `sdd doctor` 확장(또는 `docs-integrity-check` 서브커맨드)을 추가한다.
- **방향성**: 비차단 정보성 항목과 차단 항목을 구분 — ADR 번호 중복/frontmatter 누락은 차단급, backlog 레이아웃/인덱스 drift 는 경고급으로 시작 (hook 단계론, constitution 원칙 5 준용).
- **참조**:
  - GitHub #168 (제안 2)
  - spec-27-01 (`gen-adr-index --check` 의존)
- **연관 모듈**: `.harness-kit/bin/sdd` (`doctor` 서브커맨드)

### spec-27-03 — archive-residue-detect

- **요점**: `queue.md` 에 완료로 표시된 phase 인데 `backlog/phase-N.md` 가 여전히 남아있으면 `sdd archive` (또는 `sdd status` 진단)가 경고하도록 한다.
- **방향성**: 기존 archive 로직은 최근 phase 만 정리하고 오래된 것을 놓치는 사례가 있었음(다운스트림 리포트) — 완료 phase 전수 스캔으로 잔여 탐지, 자동 삭제는 하지 않고 경고만 (사용자 명시 결정 후 `sdd archive` 실행).
- **참조**:
  - GitHub #168 (제안 3)
- **연관 모듈**: `.harness-kit/bin/sdd` (`archive`, `status` 진단)

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 phase base 브랜치에 직접 커밋(phase-FF, → ADR-004). phase 승인이 항목 실행을 위임하므로 항목별 재승인 불필요. 착수 시 §11.3 재검증으로 크기를 재확인하고, 커질 경우 SPEC 으로 승격합니다. (draft — 진행 중 조정 가능)

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| stale-adr-fp-fix | `_drift_stale_adr` 에 npm 스코프 패키지(`^@`/`@[0-9]`)·IAM role(`^roles/`) 제외 패턴 추가 (GitHub #167) + 회귀 테스트 1건 | 1 |

## 📌 결정 기록 (Review)

> Phase PR review 중 발생한 결정·합의·발견을 누적합니다. Spec walkthrough 의 결정 기록과 동일 패턴이며 Phase 레벨 living decision log 역할 (→ agent.md §6.3.2).
> review 핑퐁으로 success criterion / 통합 테스트 시나리오 / spec 구성이 바뀌면 본 문서 해당 섹션을 직접 갱신하고, *왜* 그렇게 결정했는지의 이유를 본 표에 추가로 남깁니다.
> PR body 동기화가 필요하면 `gh pr edit --body-file` 사용.

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| #167 을 spec vs phase-FF | 단독 spec-x / phase-FF | **phase-FF** | 예외 패턴 1줄 + 테스트 1건 수준(1-2 commit) — Icebox 권장대로 #168 과 한 phase 로 묶되, ceremony 는 크기에 맞게 최소화 (agent.md §11.4) |
| #168 세 제안 spec 분리 여부 | 1 spec 통합 / 3 spec 분리 | **3 spec 분리** | index 생성·integrity check·archive 잔여 감지가 각각 독립 테스트 가능한 단위이고 spec-27-02 가 spec-27-01 산출물에 의존하므로 순서 있는 분리가 명확함 |

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 의 Done 조건 중 하나. 자세한 구현은 `tests/` (harness-kit 은 bash 기반 `tests/test-*.sh`).

### 시나리오 1: stale ADR 오탐 제거 + 인덱스 drift 검출 공존
- **Given**: `docs/decisions/` 에 npm 패키지/IAM role 토큰을 포함한 ADR 과, 실제로 파일 경로가 깨진 ADR 이 함께 존재
- **When**: `sdd status` 및 `gen-adr-index --check` 를 실행
- **Then**: npm/IAM 토큰은 stale 로 보고되지 않고, 실제 깨진 경로만 보고된다
- **연관 SPEC**: phase-FF(stale-adr-fp-fix), spec-27-01

### 시나리오 2: docs integrity check 가 4항목을 각각 탐지
- **Given**: ADR 번호 중복 1건, frontmatter 누락 1건, 인덱스 drift 1건, backlog 레이아웃 위반(완료 phase 파일 잔존) 1건을 인위적으로 구성
- **When**: docs integrity check 를 실행
- **Then**: 4건 모두 개별적으로 보고되고, 차단급(번호 중복/frontmatter 누락)과 경고급(인덱스 drift/레이아웃)이 구분된다
- **연관 SPEC**: spec-27-01, spec-27-02, spec-27-03

### 통합 테스트 실행
```bash
bash tests/run.sh
```

## 🔗 의존성

- **선행 phase**: 없음
- **외부 시스템**: 없음 (bash + 표준 유틸만 사용, GitHub #168 다운스트림 제안 원칙 준수)
- **연관 ADR**:
  - 없음 (필요 시 spec 진행 중 ADR-0NN 신설 검토)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| stale ADR 오탐 수정이 과도하게 넓은 예외 패턴을 만들어 진짜 stale 을 놓칠 위험 | 회귀 감지력 저하 | 예외 패턴을 이슈에 명시된 `^@`/`@[0-9]`/`^roles/` 로 좁게 한정, 테스트로 진짜 stale 케이스도 함께 고정 |
| docs integrity check 신규 차단 항목이 기존 ADR 에 대해 대량 오탐 발생 | 도입 즉시 워크플로 마찰 | 경고 모드로 먼저 배포 후 실제 ADR 세트에 대해 오탐 0 확인 후 차단 승격 검토 (hook 단계론) |
| `sdd archive` 잔여 감지가 대규모 backlog 에서 성능 저하 | archive 실행 지연 | 완료 phase 목록은 이미 `queue.md` done 섹션에 있으므로 O(완료 phase 수) 스캔으로 제한 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (`phase-27-docs-integrity` → main) + phase-FF 항목 커밋 완료
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
