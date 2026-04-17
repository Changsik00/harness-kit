# phase-05: spec-kit 패턴 도입 & 크로스 에이전트 호환

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-05-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-05` |
| **상태** | Planning |
| **시작일** | — |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

GitHub Spec Kit(87K stars)이 SDD의 사실상 표준으로 자리잡고 있으며, AGENTS.md가 Linux Foundation 표준으로 크로스 에이전트 컨텍스트 공유의 기반이 되고 있다. harness-kit은 Claude Code 전용으로 시작했으나, 장기적으로 더 넓은 에코시스템과의 호환이 필요하다.

이 phase는 **리서치 중심**으로, 즉각적인 코드 변경보다는 전략 수립과 POC에 집중한다.

### 목표 (Goal)

- GitHub Spec Kit의 워크플로를 벤치마크하고 harness-kit에 적용 가능한 패턴 식별
- AGENTS.md 호환 레이어를 통해 Cursor/Copilot 등에서도 기본 컨텍스트 인식 가능하게
- 크로스 에이전트 전략 문서화

### 성공 기준 (Success Criteria) — 정량 우선

1. spec-kit 벤치마크 리포트 작성 완료 (Go/No-Go 결정)
2. AGENTS.md 자동 생성 POC 동작 확인
3. 전략 ADR 문서화 완료

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-05-001 | spec-kit-benchmark | P2 | Backlog | `specs/spec-05-001-spec-kit-benchmark/` |
| spec-05-002 | agents-md-compat | P2 | Backlog | `specs/spec-05-002-agents-md-compat/` |
<!-- sdd:specs:end -->

### spec-05-001 — spec-kit 워크플로 벤치마크 (Research Spec)

- **요점**: GitHub Spec Kit의 Specify → Plan → Tasks → Implement 워크플로를 실제로 사용해보고, harness-kit과의 차이점/장단점 분석
- **방향성**: (1) spec-kit을 테스트 프로젝트에 설치하여 동일 기능을 SDD로 구현. (2) 워크플로 마찰, 토큰 소모, 산출물 품질 비교. (3) harness-kit에 도입할 패턴과 도입하지 않을 패턴을 분리. (4) Research Report로 산출
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §1
  - GitHub Spec Kit: `github.com/github/spec-kit`
- **연관 모듈**: 없음 (리서치)

### spec-05-002 — AGENTS.md 호환 레이어

- **요점**: install.sh 실행 시 AGENTS.md 파일도 함께 생성하여 Cursor/Copilot/Codex 등에서 기본 프로젝트 컨텍스트 인식
- **방향성**: (1) AGENTS.md 표준 스펙 조사. (2) harness-kit 거버넌스 규칙 중 범용적인 것(브랜치 규칙, 커밋 형식, 테스트 요구)만 AGENTS.md에 포함. (3) Claude Code 전용 규칙은 CLAUDE.md + hooks에 유지. (4) `sources/claude-fragments/AGENTS.md.template` 생성
- **참조**:
  - AGENTS.md 표준: `agents.md`
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §5.2d
- **연관 모듈**: `sources/claude-fragments/`, `install.sh`

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: AGENTS.md 생성 검증
- **Given**: harness-kit이 설치된 프로젝트
- **When**: `install.sh` 실행 (AGENTS.md 호환 옵션 활성)
- **Then**: 프로젝트 루트에 AGENTS.md가 생성되고, 표준 형식 준수
- **연관 SPEC**: spec-05-002

### 통합 테스트 실행
```bash
./tests/test-phase-05.sh
```

## 🔗 의존성

- **선행 phase**: phase-02, phase-03 (기반 안정화 후)
- **외부 시스템**: GitHub Spec Kit, AGENTS.md 표준
- **연관 ADR**: 작성 예정

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| spec-kit이 빠르게 진화하여 벤치마크 결과가 금방 구식화 | 전략 문서의 유효기간 짧음 | 벤치마크 시점 명기, 정기 재검토 |
| AGENTS.md 표준이 아직 불안정 | 호환 레이어가 표준 변경 시 깨짐 | 최소 기능만 생성, 표준 안정화 후 확장 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge (또는 Research Report 완료)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
