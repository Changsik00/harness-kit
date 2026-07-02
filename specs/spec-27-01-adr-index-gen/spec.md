# spec-27-01: ADR 인덱스 자동 생성 (`sdd adr-index`)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-27-01` |
| **Phase** | `phase-27` |
| **Branch** | `spec-27-01-adr-index-gen` |
| **Base 브랜치** | `phase-27-docs-integrity` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-07-02 |
| **소유자** | changsik |

## 배경 및 문제 정의

### 현재 상황

`docs/decisions/` 아래 ADR 은 각각 `id`/`type`/`date`/`status` frontmatter 를 갖지만(constitution §6.4), 이를 한눈에 보는 인덱스 파일은 존재하지 않는다 (`docs/decisions/README.md` 없음). 현재 ADR 은 9개.

### 문제점

ADR 이 늘어날수록 "어떤 결정이 있었는지" 를 파악하려면 파일을 하나씩 열어야 한다. 인덱스를 사람이 수기로 유지하면 frontmatter 와 어긋나는 drift 가 발생한다 (GitHub #168 — 다운스트림 도그푸딩에서 실제 발생, 로컬 스크립트로 해결했던 사례).

### 해결 방안

ADR frontmatter 를 SoT 로 삼아 `docs/decisions/README.md` 의 마커 구간(`<!-- adr-index:start -->`~`<!-- adr-index:end -->`) 테이블을 재생성하는 `sdd adr-index` 서브커맨드를 추가한다. `--check` 모드는 CI/`doctor` 게이트로 쓸 수 있게 drift 시 non-zero exit.

## 요구사항

1. `sdd adr-index` — `docs/decisions/ADR-*.md` 전수를 스캔해 `id`/`type`/`status`/`date` frontmatter 와 `# ADR-NNN: <title>` 제목행에서 title 을 추출, ADR 번호 오름차순으로 마커 구간에 `| # | title | type | status | date |` 테이블을 (재)생성한다.
2. `docs/decisions/README.md` 가 없으면 마커 구간을 포함한 최소 파일을 새로 만든다. 마커 밖의 기존 내용(다른 섹션)은 보존한다.
3. `sdd adr-index --check` — 생성될 테이블과 파일의 현재 마커 구간을 비교해 다르면(또는 파일 자체가 없으면) drift 로 보고하고 exit 1. 같으면 exit 0.
4. frontmatter 필드 순서에 의존하지 않고 각 필드를 개별 파싱한다.
5. **Non-functional**: bash 3.2+/macOS 호환. 멀티라인 콘텐츠를 `awk -v var="...\n..."` 로 넘기지 않는다 — 이 시스템의 macOS awk(BWK awk)는 `-v` 값에 개행이 있으면 `newline in string` 으로 즉시 실패함을 실측 확인(GitHub #168 이 지적한 함정과 동일). 대신 bash 라인 루프로 마커 구간을 치환한다.

## Out of Scope

- ADR 번호 중복 / frontmatter 누락 등 무결성 검사 — spec-27-02 (docs-integrity-check) 담당.
- `sdd doctor` 로의 통합 — spec-27-02 에서 `adr-index --check` 를 호출하는 방식으로 연결.
- 인덱스 테이블 이외 섹션(예: 카테고리별 그룹핑, 요약) — 향후 확장 여지로 남김.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 없음 — 골격 수준 기능 추가, 아키텍처 결정 없음.

> [!WARNING]
> - [ ] `docs/decisions/README.md` 를 신규 생성한다 — 기존에 동일 경로에 다른 용도 파일이 있는지 확인 필요(현재 없음 확인 완료).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **명령 위치** | `sdd adr-index [--check]` 신규 서브커맨드 | 기존 `sdd` 단일 진입점 설계(context-cost-first) 유지 — 별도 bin 스크립트 신설 안 함 |
| **마커 치환 방식** | 기존 `sdd_marker_replace`(awk `-v content`) 재사용 안 함, 신규 bash 라인 루프 헬퍼 작성 | `-v` 멀티라인 인자가 macOS awk 에서 깨짐을 실측 확인 (요구사항 5) — 기존 헬퍼를 고치는 건 범위 밖, 이 기능만 안전한 방식으로 신설 |
| **정렬** | ADR 번호 zero-pad 3자리 기준 텍스트 정렬 | 파일명 규약(`ADR-{NNN}`)이 이미 zero-pad 라 `sort` 만으로 번호순 보장 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd`
`cmd_adr_index()` 함수 추가 + `case "$cmd"` 디스패치에 `adr-index) cmd_adr_index "$@" ;;` 등록.

#### [MODIFY] `.harness-kit/bin/sdd`
동일 변경 미러 (본 저장소 도그푸딩 설치본).

#### [NEW] `tests/test-adr-index.sh`
fixture ADR 로 생성/`--check`/drift 감지/README 신규 생성 시나리오 검증.

#### [NEW] `docs/decisions/README.md`
실제 9개 ADR 로 최초 생성 (Task 4).

## 검증 계획

```bash
bash tests/test-adr-index.sh
bash tests/run.sh
```

수동 검증 시나리오:
1. `bash .harness-kit/bin/sdd adr-index` 실행 후 `docs/decisions/README.md` 를 열어 9개 ADR 이 번호순으로 나열됐는지 확인 — 기대 결과: 테이블에 ADR-001~ADR-009(또는 현재 존재하는 번호) 전부 등장.
2. 같은 명령을 다시 실행해도 파일 diff 없음(idempotent) — 기대 결과: `git diff` 무변화.
3. `bash .harness-kit/bin/sdd adr-index --check` — 기대 결과: exit 0, 별다른 출력 없음.
4. ADR 하나의 `type:` 값을 임시로 바꾼 뒤 `--check` — 기대 결과: exit 1 + drift 보고, 원복 후 정상.

## 롤백 계획

- `git revert` — state 영향 없음. `docs/decisions/README.md` 생성 자체를 되돌려도 다른 기능에 영향 없음(신규 파생 파일).

## ADR 후보

- [ ] ADR 가치 있는 결정 있음 → 후보: 없음
- [x] 없음 (골격 기능 추가, 아키텍처 결정 아님)

## ✅ Definition of Done

- [ ] 모든 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-27-01-adr-index-gen` 브랜치 push 완료
