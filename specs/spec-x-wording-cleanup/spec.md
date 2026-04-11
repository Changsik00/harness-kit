# spec-x-wording-cleanup: 커맨드·거버넌스 문서 워딩 최적화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-wording-cleanup` |
| **Phase** | — (Solo Spec) |
| **Branch** | `spec-x-wording-cleanup` |
| **상태** | Planning |
| **타입** | Docs |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sources/commands/` 의 슬래시 커맨드 파일 9개와 `sources/governance/` 의 거버넌스 파일 3개는 phase-4 ~ phase-7 에 걸쳐 점진적으로 추가/수정되었습니다. 파일마다 작성 시점이 달라 동일한 개념에 대해 서로 다른 단어와 표현이 혼재하게 되었습니다.

### 문제점

다음 5가지 유형의 워딩 문제가 확인되었습니다:

1. **공통 워딩 불일치**: `사전 조건` / `사전 점검` / `사전 검증`, `본 명령` / `이 명령`, `멈춤` / `멈춥니다` 가 파일별로 혼재
2. **언어 혼용**: `sub-agent` / `서브에이전트`, `active spec` / `활성 spec`, `Test Fail` / `테스트 실패` 등 한국어 문서 내 영어가 불필요하게 섞임
3. **중복 내용**: 긍정/거부 규칙이 constitution §4.2 SSOT 임에도 각 커맨드 파일에서 예시 목록을 반복 기술, `hk-plan-accept.md` 에 Strict Loop 8단계가 agent.md §6.1 과 중복
4. **누락 내용**: `hk-code-review.md` 에 서브에이전트 model 지정 없음 (`hk-spec-critique.md` 는 `model: "opus"` 명시), `hk-spec-new.md` 에 slug 인자 누락 시 처리 없음
5. **constitution §4.2 제목 혼란**: "Plan Rules" 제목인데 Critique 진입 조건도 포함

### 해결 방안 (요약)

각 파일에 대해 용어·표현을 통일 기준에 맞게 정비하고, SSOT 문서(constitution)를 참조하는 방식으로 중복을 제거합니다. 누락된 설명과 기능(model 지정, 인자 처리)은 추가합니다.

## 🎯 요구사항

### Functional Requirements

1. 커맨드 파일 내 공통 표현을 통일 기준에 따라 일관되게 수정한다
2. 한국어 문서에서 불필요한 영어 혼용을 한국어로 정리한다
3. 긍정/거부 규칙은 constitution §4.2 참조로 대체한다 (중복 제거)
4. `hk-plan-accept.md` Strict Loop 8단계를 agent.md §6.1 참조 한 줄로 대체한다
5. `hk-code-review.md` 서브에이전트에 `model: "opus"` 를 추가한다
6. `hk-spec-new.md` 에 slug 인자 누락 처리를 추가한다
7. `constitution.md` §4.2 제목을 내용을 반영한 이름으로 변경한다
8. `sources/` 와 `.claude/commands/` 는 항상 쌍으로 수정한다 (내용 동기화)

### Non-Functional Requirements

1. 기능 변경 없음 — 문서만 수정
2. 테스트 없음 — 변경 전후 내용을 사람이 직접 검토

## 🚫 Out of Scope

- 커맨드 파일의 기능(절차) 변경
- 거버넌스 정책 변경
- 새 커맨드 추가
- `agent/` 와 `sources/governance/` 간 구조 차이 해소

## ✅ Definition of Done

- [ ] 8개 수정 항목이 모두 반영됨
- [ ] `sources/` 와 `.claude/commands/` 의 동일 파일 내용이 일치함
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-x-wording-cleanup` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료

## 📐 통일 기준 (워딩 결정)

| 항목 | 채택 표현 | 근거 |
|---|---|---|
| 에이전트가 수행하는 실행 전 체크 | `사전 점검` | 점검 = 실행 전 확인 행위 |
| 사용자가 미리 준비할 것 | `사전 조건` | 조건 = 선행 준비 요건 |
| 실행 조건 불충족 시 리스트 | `→ 중단` | 리스트 항목에는 명사형 |
| 오류 발생 시 서술 | `사용자에게 보고하고 멈춥니다` | 서술문에는 서술형 |
| 슬래시 커맨드 도입 문장 | `이 명령은` | 더 자연스러운 한국어 |
| 영문 sub-agent | `서브에이전트` | 한국어 문서 원칙 |
| 영문 active spec/phase | `활성 spec`, `활성 phase` | 한국어 문서 원칙, 기술 용어는 영어 유지 |
| Test Fail/Pass | `테스트 실패`, `테스트 통과` | 한국어 문서 원칙 |
