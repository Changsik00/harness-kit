# phase-11: 식별자 체계 개선 및 디렉토리 아카이브

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-11-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-11` |
| **상태** | Planning |
| **시작일** | 2026-04-16 |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

Phase 번호가 10을 넘으면서 파일 시스템 정렬이 깨지기 시작했다. `phase-10`이 `phase-02` 앞에 오고, `spec-10-*`이 `spec-02-*` 앞에 위치한다. 또한 `specs/` 디렉토리에 41개의 폴더가 쌓여 있어 탐색이 어렵고, 완료된 오래된 항목을 정리할 수단이 없다.

추가로 기존 `sdd archive` 명령은 실제로 "spec 완료 처리 + 상태 전이 + 커밋"을 수행하는데, 이번 phase에서 도입할 "디렉토리 아카이브" 기능과 이름이 충돌한다. 리네이밍이 선행되어야 한다.

### 목표 (Goal)

1. 식별자 2자리 패딩 적용으로 파일 시스템 정렬 보장
2. `sdd archive` → `sdd ship` 리네이밍으로 의미 정합성 확보
3. 완료 항목을 `archive/` 디렉토리로 이동하는 새 `sdd archive` 명령 도입
4. 아카이브 후에도 sdd 검색·진단이 정상 동작

### 성공 기준 (Success Criteria) — 정량 우선

1. `ls specs/` 출력이 phase/seq 순으로 정렬됨 (lexicographic = numeric)
2. `sdd ship`이 기존 `sdd archive` 와 동일 기능 수행, 기존 `sdd archive` 호출 시 안내 메시지 출력
3. `sdd archive` 실행 후 `specs/` 에는 최신 phase 만 남고, 이전 항목은 `archive/specs/`에 존재
4. `sdd status`가 `archive/` 디렉토리도 탐색하여 이력 접근 가능
5. `sdd align` (부트스트랩) 시 디렉토리 수 기준으로 아카이브 제안

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-11-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

### spec-11-001 — sdd archive → sdd ship 리네이밍

- **요점**: 기존 `sdd archive` 명령을 `sdd ship`으로 변경하여 네이밍 충돌 선제 해소
- **방향성**: cmd_archive → cmd_ship 함수 이름 변경, dispatch 업데이트, 하위 호환용 `sdd archive` → deprecation 안내, 관련 템플릿·거버넌스·테스트·문서 전면 갱신
- **참조**:
  - `backlog/queue.md` Icebox — "`sdd archive` 리네이밍 검토"
- **연관 모듈**: `sources/bin/sdd`, `sources/commands/hk-ship.md`, `sources/governance/`, `sources/templates/`, `tests/test-sdd-archive-completion.sh`

### spec-11-002 — 식별자 2자리 패딩

- **요점**: phase/spec 번호를 2자리 제로패딩으로 통일 (`phase-01`, `spec-01-001`) — 파일 정렬 보장
- **방향성**: constitution §6 패딩 규칙 변경, sdd 파싱 로직(sed/awk) 갱신, 기존 디렉토리·파일 일괄 마이그레이션 스크립트 제공
- **참조**:
  - `backlog/queue.md` Icebox — "식별자 2자리 패딩"
- **연관 모듈**: `sources/bin/sdd` (식별자 파싱 전반), `sources/governance/constitution.md` §6, 기존 `backlog/phase-*.md`, `specs/spec-*-*/`

### spec-11-003 — 디렉토리 아카이브 기능

- **요점**: 완료된 오래된 spec/phase를 `archive/` 디렉토리로 이동하는 `sdd archive` 명령 신설
- **방향성**: `archive/specs/`, `archive/backlog/` 레이아웃 정의. 현재 active phase 이외의 완료 항목을 일괄 이동. `--keep=N` 옵션으로 최근 N개 phase 유지 가능. align 시 디렉토리 수 임계값 초과 시 아카이브 제안 표시.
- **참조**: 없음 (신규 기능)
- **연관 모듈**: `sources/bin/sdd` (신규 cmd_archive), `sources/governance/agent.md` (align 프로토콜), `sources/governance/align.md`

### spec-11-004 — 아카이브 검색 통합

- **요점**: sdd 명령들이 `archive/` 디렉토리도 탐색하여 이력 접근 보장
- **방향성**: `sdd status`, `compute_next_spec`, `phase_show`, `spec_list` 등에서 `archive/` fallback 탐색 추가. 아카이브된 항목은 읽기 전용으로 표시. `sdd status` 진단에 아카이브 항목 수 표시.
- **참조**: 없음 (신규 기능)
- **연관 모듈**: `sources/bin/sdd` (status, spec_list, phase_show 등), `sources/governance/align.md`

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 의 Done 조건 중 하나.

### 시나리오 1: 리네이밍 하위 호환

- **Given**: `sdd ship`이 정상 동작하는 상태
- **When**: `sdd archive` (구 명령)를 실행
- **Then**: deprecation 경고 + `sdd ship` 안내 메시지 출력 (실행은 차단하지 않음)
- **연관 SPEC**: spec-11-001

### 시나리오 2: 패딩 마이그레이션 후 정렬

- **Given**: 기존 `phase-01` ~ `phase-11`, `spec-01-001` ~ `spec-10-005` 디렉토리 존재
- **When**: 마이그레이션 스크립트 실행
- **Then**: `phase-01` ~ `phase-11`, `spec-01-001` ~ `spec-10-005`로 변환, `ls` 정렬이 숫자 순서와 일치
- **연관 SPEC**: spec-11-002

### 시나리오 3: 아카이브 후 NEXT 검색 정상

- **Given**: phase-01 ~ phase-10 완료, phase-11 진행 중, `sdd archive` 로 구 항목 이동 완료
- **When**: `sdd status` 실행
- **Then**: active phase-11의 NEXT spec을 정확히 표시, 아카이브 항목 수 진단 포함, `specs/`에는 phase-11 관련만 존재
- **연관 SPEC**: spec-11-003, spec-11-004

### 시나리오 4: align 시 아카이브 제안

- **Given**: `specs/` 디렉토리에 30개 이상의 폴더 존재
- **When**: `/hk-align` 또는 새 세션 시작
- **Then**: 상태 요약에 "완료된 항목이 많습니다. `sdd archive`로 정리하시겠습니까?" 유사 안내 표시
- **연관 SPEC**: spec-11-003

### 통합 테스트 실행
```bash
bash tests/test-sdd-ship-rename.sh
bash tests/test-sdd-id-padding.sh
bash tests/test-sdd-dir-archive.sh
bash tests/test-sdd-archive-search.sh
```

## 🔗 의존성

- **선행 phase**: phase-10 (완료) — sdd 상태 진단 로직이 안정화된 상태에서 진행
- **외부 시스템**: 없음
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| 기존 디렉토리 대량 rename 시 git history 추적 손실 | blame/log 추적 어려워짐 | `git mv` 사용으로 rename detection 유지, 단일 커밋으로 묶어 diff 최소화 |
| `sdd archive` 이름 재사용으로 인한 혼동 | 기존 사용자가 구 동작 기대 | spec-11-001에서 deprecation 경고 + 전환기간 확보 (구 명령 호출 시 안내) |
| 패딩 변경이 constitution·테스트·문서 전면 영향 | 누락된 참조로 런타임 오류 | grep 기반 전수 검색으로 모든 참조 갱신, 기존 테스트 전체 실행으로 검증 |
| 아카이브된 항목의 상대 경로 참조 깨짐 | walkthrough 등 내부 링크 무효화 | 아카이브는 디렉토리 구조 보존 (`archive/specs/`, `archive/backlog/`), 경로 prefix만 변경 |

## 🏁 Phase Done 조건

- [x] 모든 SPEC 이 main 에 merge (5/5 — PR #51~#55)
- [x] 통합 테스트 전 시나리오 PASS (28/28)
- [x] 성공 기준 정량 측정 결과 (아래 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과

### 성공 기준

| # | 기준 | 결과 | 증거 |
|:---:|---|:---:|---|
| 1 | `ls specs/` 정렬 = numeric 순서 | ✅ PASS | spec-01 ~ spec-11 순서 |
| 2 | `sdd ship` 정상 + `sdd archive` 교체 | ✅ PASS | help 텍스트 확인 |
| 3 | `sdd archive` → archive/ 이동 | ✅ PASS | test-sdd-dir-archive 10/10 |
| 4 | `sdd status` archive 탐색 | ✅ PASS | test-sdd-archive-search 11/11 |
| 5 | align 시 아카이브 제안 | ✅ PASS | specs/ 47개 → 진단 메시지 출력 |

### 통합 테스트

| 테스트 파일 | 결과 |
|---|---|
| test-sdd-ship-completion.sh | 7/7 PASS |
| test-sdd-dir-archive.sh | 10/10 PASS |
| test-sdd-archive-search.sh | 11/11 PASS |
| **합계** | **28/28 PASS** |
