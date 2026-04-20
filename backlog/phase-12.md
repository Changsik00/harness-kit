# phase-12: 프로젝트 확장성 강화

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-12-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-12` |
| **상태** | In Progress |
| **시작일** | 2026-04-20 |
| **목표 종료일** | 2026-04-27 |
| **소유자** | changsik |
| **Base Branch** | 없음 |

## 🎯 배경 및 목표

### 현재 상황
phase-11까지 harness-kit의 핵심 설치/거버넌스/식별자 체계가 완성됐다. 유사 툴 비교 리서치(spec-x-tool-comparison)를 통해 두 가지 즉시 착수 가능한 Gap이 식별됐다: staged 파일 기반 선택적 linting 미지원, AI 인스트럭션 포맷 상호운용성 부재.

### 목표 (Goal)
1. pre-commit 속도 개선: 변경된 파일에만 lint/format을 실행해 commit 대기 시간 단축
2. 멀티 AI IDE 지원: harness-kit 거버넌스를 Cursor, Copilot 환경에서도 자동으로 반영

### 성공 기준 (Success Criteria)
1. `git diff --cached` 기반 staged-only linting 훅이 install.sh에 포함되어 동작
2. `sdd export-instructions` 또는 install.sh 옵션으로 `.cursorrules` / `copilot-instructions.md` 자동 생성
3. 전체 테스트 PASS (FAIL=0)

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-12-01` | staged-lint | P? | Active | `specs/spec-12-01-staged-lint/` |
<!-- sdd:specs:end -->

### spec-12-001 — staged linting 훅

- **요점**: pre-commit 훅에서 `git diff --cached --name-only`로 스테이징된 파일만 선별해 lint/format 실행
- **방향성**: `sources/hooks/`에 `check-staged-lint.sh` 추가. 프로젝트 타입(Node.js/Python/Go) 감지 후 해당 linter 실행. 파일 없으면 skip.
- **참조**: `specs/spec-x-tool-comparison/report.md` Gap 4
- **연관 모듈**: `sources/hooks/`, `install.sh`

### spec-12-002 — AI 인스트럭션 멀티포맷 export

- **요점**: `install.sh --export-instructions` 옵션 또는 `sdd export-instructions` 명령으로 constitution.md 요약본을 `.cursorrules` / `.github/copilot-instructions.md`로 자동 생성
- **방향성**: constitution.md에서 핵심 규칙 섹션을 추출해 각 포맷에 맞게 변환. `sources/bin/` 또는 `install.sh` 옵션으로 구현.
- **참조**: `specs/spec-x-tool-comparison/report.md` Gap 3
- **연관 모듈**: `sources/bin/sdd`, `install.sh`

## 🧪 통합 테스트 시나리오

### 시나리오 1: staged linting — Node.js 프로젝트
- **Given**: `package.json`이 있는 프로젝트에 harness-kit 설치
- **When**: ESLint 오류가 있는 파일을 stage 후 commit 시도
- **Then**: check-staged-lint.sh가 해당 파일만 lint 실행 → 오류 감지 → commit 차단
- **연관 SPEC**: spec-12-001

### 시나리오 2: AI 인스트럭션 export
- **Given**: harness-kit이 설치된 프로젝트
- **When**: `sdd export-instructions` 실행
- **Then**: `.cursorrules`와 `.github/copilot-instructions.md` 생성, constitution.md 핵심 규칙 포함
- **연관 SPEC**: spec-12-002

### 통합 테스트 실행
```bash
for t in tests/test-*.sh; do bash "$t" 2>&1 | tail -1; done
```

## 🔗 의존성

- **선행 phase**: phase-11
- **외부 시스템**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| staged lint이 프로젝트 타입 미감지 시 skip | 기능 미동작 | 경고 출력 후 exit 0 (훅 단계론 준수) |
| constitution.md 포맷 변경 시 export 깨짐 | 잘못된 인스트럭션 생성 | 고정 섹션 마커 기반 추출로 의존성 최소화 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (base branch 모드: `phase-12` → main / 일반 모드: 각 spec → main)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
