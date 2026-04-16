# spec-04-002: /code-review 슬래시 커맨드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-04-002` |
| **Phase** | `phase-04` |
| **Branch** | `spec-04-002-code-review-cmd` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

에이전트가 자기가 작성한 코드를 자기가 검증하는 구조. handoff 전에 독립적인 코드 리뷰 단계가 없어서, spec 요구사항 대비 구현 누락이나 코드 품질 문제를 잡아내기 어렵다.

### 문제점

- spec 요구사항과 실제 구현의 불일치를 확인하는 체계적 절차 없음
- KISS, DRY, feature envy 등 코드 품질 원칙 위반을 자체 점검하기 어려움
- 테스트 커버리지 누락을 구조적으로 검출할 수 없음

### 해결 방안 (요약)

`/code-review` 슬래시 커맨드를 만들어, 독립 sub-agent가 현재 브랜치의 코드 변경을 spec 대비 검증하고 코드 품질을 리뷰한다.

## 🎯 요구사항

### Functional Requirements
1. `/code-review` 실행 시 독립 sub-agent가 현재 브랜치의 `git diff main...HEAD`를 분석한다
2. 리뷰 관점:
   - **spec 대비 구현 검증**: 요구사항 누락/불일치, DoD 미충족
   - **코드 품질**: KISS, DRY, feature envy, 불필요한 복잡도
   - **테스트 커버리지**: 변경된 코드에 대한 테스트 존재 여부, 엣지 케이스 누락
3. 리뷰 결과를 해당 spec 디렉토리의 `code-review.md`에 저장한다
4. 커맨드를 호출하지 않으면 추가 토큰 소모가 없다 (옵셔널)

### Non-Functional Requirements
1. 리뷰는 한국어로 작성한다 (constitution §4.4)
2. 기존 슬래시 커맨드 구조와 동일한 패턴을 따른다
3. `install.sh` 실행 시 대상 프로젝트로 자동 복사된다

## 🚫 Out of Scope

- 자동 호출 또는 hook 기반 강제 리뷰
- 리뷰 결과에 따른 자동 코드 수정
- 보안 취약점 전문 분석 (별도 도구 영역)

## ✅ Definition of Done

- [ ] `sources/commands/code-review.md` 슬래시 커맨드 파일 작성
- [ ] `install.sh` 실행 후 `.claude/commands/code-review.md`로 복사 확인
- [ ] 수동 검증: `/code-review` 호출 시 리뷰 결과가 `code-review.md`에 저장됨
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-04-002-code-review-cmd` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
