---
description: 현재 SPEC 브랜치의 코드 변경을 독립 서브에이전트로 리뷰 (spec 대비 구현 + 코드 품질 + 테스트 커버리지)
---

현재 브랜치의 코드 변경사항을 **독립적인 관점**에서 리뷰합니다.

## 1. 대상 확인

현재 활성 spec 과 diff 범위를 확인합니다:

```bash
bash .harness-kit/bin/sdd status --json
```

출력에서 `spec` 필드로 spec 디렉토리를 특정합니다. spec 이 없으면 사용자에게 알리고 멈춥니다.

diff 범위 확인:

```bash
git diff main...HEAD --stat
```

변경 파일이 없으면 "리뷰할 코드 변경이 없습니다" 를 알리고 멈춥니다.

## 2. 독립 리뷰 수행

Agent tool (`subagent_type: general-purpose`, `model: "opus"`) 을 사용하여 **별도 컨텍스트**에서 리뷰를 수행합니다.

서브에이전트에게 전달할 프롬프트:

> 당신은 독립적인 시니어 개발자 코드 리뷰어입니다.
>
> **입력 자료**:
> 1. spec 문서: `specs/<spec-dir>/spec.md` 를 읽어서 요구사항을 파악하세요.
> 2. 코드 변경: `git diff main...HEAD` 를 실행해서 전체 변경사항을 확인하세요.
> 3. 변경된 파일들의 전체 내용이 필요하면 해당 파일을 직접 읽으세요.
>
> 다음 3가지 관점에서 리뷰하고, 발견된 문제마다 심각도(Critical/Major/Minor)를 매기세요:
>
> ### 1. Spec 대비 구현 검증
> - spec.md 의 Functional Requirements 가 모두 구현되었는가?
> - Definition of Done 항목이 충족되었는가?
> - spec 에 없는 기능이 추가되지 않았는가? (scope creep)
>
> ### 2. 코드 품질
> - **KISS**: 불필요하게 복잡한 로직이 있는가? 더 단순한 방법이 있는가?
> - **DRY**: 중복 코드가 있는가? 기존 유틸리티를 재사용할 수 있는가?
> - **Feature Envy**: 다른 모듈의 데이터를 과도하게 참조하는가?
> - **Dead Code**: 사용되지 않는 코드, 주석 처리된 코드가 남아있는가?
> - **네이밍**: 변수/함수/파일 이름이 의도를 명확히 전달하는가?
> - **에러 처리**: 적절한 에러 처리가 되어있는가? (시스템 경계에서)
>
> ### 3. 테스트 커버리지
> - 변경된 코드에 대한 테스트가 존재하는가?
> - 핵심 경로(happy path)가 테스트되는가?
> - 엣지 케이스(빈 입력, 경계값, 에러 상황)가 테스트되는가?
> - 테스트가 구현 세부사항이 아닌 동작을 검증하는가?
>
> 출력 형식 (한국어):
> ```
> # Code Review: <spec-id>
>
> ## 요약
> - 전체 평가: (Approve / Request Changes / Comment)
> - Critical 이슈 수: N
> - Major 이슈 수: N
> - Minor 이슈 수: N
>
> ## 상세 리뷰
>
> ### 1. Spec 대비 구현 검증
> - [심각도] `파일:라인` — 내용
>
> ### 2. 코드 품질
> - [심각도] `파일:라인` — 내용 (위반 원칙: KISS/DRY/등)
>
> ### 3. 테스트 커버리지
> - [심각도] 내용
>
> ## 권고사항
> - (수정 제안 목록, 파일:라인 참조 포함)
> ```
>
> 리뷰는 반드시 **한국어**로 작성하세요.
> 코드 참조 시 반드시 `파일경로:라인번호` 형식으로 위치를 명시하세요.
> 발견된 것이 없는 관점은 "발견 없음"으로 표기하세요.

## 3. 결과 저장

리뷰 결과를 `specs/<spec-dir>/code-review.md` 에 저장합니다.

## 4. 사용자에게 보고

```
✅ Code Review 완료: <spec-id>
- 결과: specs/<spec-dir>/code-review.md
- 전체 평가: (Approve / Request Changes / Comment)
- Critical: N / Major: N / Minor: N
```

Critical 이슈가 있으면 ship 전에 해결을 권고합니다.
