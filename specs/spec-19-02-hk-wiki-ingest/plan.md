# Implementation Plan: spec-19-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-19-02-hk-wiki-ingest`
- 시작 지점: `phase-19-doc-knowledge-graph` (phase base branch 모드)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] `/hk-wiki-ingest`가 Claude에게 wiki 갱신을 **지시**하는 커맨드임을 확인 (bash 스크립트 X, 슬래시 커맨드 문서)
> - [ ] `sdd archive` 힌트는 기존 출력 맨 끝 1줄 추가 — 기존 동작 변경 없음

## 🎯 핵심 전략

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **hk-wiki-ingest** | 슬래시 커맨드 문서 (Claude 지시서) | bash가 아닌 Claude가 실제 wiki 편집. 커맨드는 "무엇을 어떻게 읽고 어떻게 갱신하라"를 명세 |
| **인제스트 기준** | `docs/wiki/log.md` 마지막 항목 날짜 이후 archived spec | log.md가 진행 상태를 추적하는 SoT |
| **sdd archive 힌트** | `ok` 출력 뒤 1줄 `echo` 추가 | 기존 cmd_archive() 마지막에 비파괴적 추가 |

### 📑 ADR 후보
- [ ] 없음

## 📂 Proposed Changes

### [NEW] `sources/commands/hk-wiki-ingest.md`
wiki 인제스트 슬래시 커맨드. Claude에게:
1. `docs/wiki/log.md`의 마지막 인제스트 날짜 읽기
2. `archive/specs/` 에서 해당 날짜 이후 archived walkthrough.md 목록 수집
3. 각 walkthrough에서 결정/패턴 항목 추출 → `decisions.md`, `patterns.md` 증분 갱신
4. `log.md`에 인제스트 이벤트 기록
5. 갱신 결과 보고

### [NEW] `.harness-kit/commands/hk-wiki-ingest.md`
sources/ 동기화본 (동일 내용)

### [MODIFY] `sources/bin/sdd` — `cmd_archive()` 마지막
archive 완료 후 `/hk-wiki-ingest` 힌트 1줄 추가:
```
→ wiki 갱신: /hk-wiki-ingest
```

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-wiki-structure.sh   # 45/45 PASS 회귀 없음
```

### 통합 테스트
```bash
# sdd archive 힌트 출력 확인 (dry-run 제외, 실제 실행)
bash tests/test-wiki-ingest.sh  # 신규 작성
```

### 수동 검증 시나리오
1. `sdd archive --dry-run` 실행 → 힌트 없음 확인
2. `sdd archive` 실행 → 마지막 줄에 `→ wiki 갱신: /hk-wiki-ingest` 출력 확인
3. `/hk-wiki-ingest` 실행 → `docs/wiki/log.md` 항목 추가 확인

## 🔁 Rollback Plan

- `sources/commands/hk-wiki-ingest.md` 삭제 — 커맨드만 제거, wiki 내용 무영향
- `sdd archive` 힌트 라인 1줄 제거 — 기존 동작 완전 복원

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship

- 신규 브랜치: `spec-19-02-hk-wiki-ingest` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main` (또는 명시된 base)
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> 본 Plan 을 Accept 하기 전에 사용자가 명시적으로 확인해야 할 항목들.

> [!IMPORTANT]
> - [ ] <중대 결정 1>
> - [ ] <중대 결정 2>

> [!WARNING]
> - [ ] <잠재적 breaking change 1>
> - [ ] <외부 시스템 영향>

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```mermaid
%% 시퀀스/플로우/컴포넌트 다이어그램
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **A** | Option X | <이유> |
| **B** | Option Y | <이유> |

### 📑 ADR 후보

> 위 결정 중 *장기 자산* 으로 박을 가치 있는 것이 있는가? (constitution §6.3)
> 후보가 있으면 본 spec 머지 시점에 `docs/decisions/ADR-{NNN}-hk-wiki-ingest.md` 로 작성합니다.
> 비강제 — 미체크여도 plan accept / ship 차단 없음.

- [ ] ADR 가치 있는 결정 있음 → 후보 한 줄 요약: `<slug-후보>` (type: decision / invariant / convention / tradeoff)
- [ ] 없음

## 📂 Proposed Changes

### [컴포넌트명]

#### [MODIFY] `path/to/file.ext`
<!-- 무엇을, 왜 변경하는지 -->

```text
# (선택) 코드 스니펫 또는 의사코드
```

#### [NEW] `path/to/new_file.ext`
<!-- 목적 + 인터페이스 요약 -->

#### [DELETE] `path/to/old_file.ext`
<!-- 삭제 사유 + 영향 범위 -->

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
# 본 SPEC 의 단위 테스트 실행 명령
# 프로젝트 설정 파일(package.json, Makefile 등)을 확인하여 적절한 명령 사용
```

### 통합 테스트 (Integration Test Required = yes 인 경우)
```bash
# 통합 테스트 실행 명령
```

### 수동 검증 시나리오
1. <단계 1> — 기대 결과: ...
2. <단계 2> — 기대 결과: ...

## 🔁 Rollback Plan

- <문제 발생 시 어떻게 되돌릴 것인가>
- <롤백 시 데이터/상태 영향>

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
