---
description: 현재 SPEC 의 spec.md + plan.md 를 독립 sub-agent 로 비판적 리뷰
---

현재 활성 SPEC 의 `spec.md` 와 `plan.md` 를 **독립적인 관점**에서 비판적으로 리뷰합니다.

## 1. 대상 파일 확인

현재 활성 spec 디렉토리를 확인합니다:

```bash
bash scripts/harness/bin/sdd status --json
```

출력에서 `spec` 필드로 spec 디렉토리를 특정합니다. spec 이 없으면 사용자에게 알리고 멈춥니다.

## 2. 독립 리뷰 수행

Agent tool (subagent_type: general-purpose) 을 사용하여 **별도 컨텍스트**에서 리뷰를 수행합니다.

sub-agent 에게 전달할 프롬프트:

> 당신은 독립적인 시니어 아키텍트 리뷰어입니다. 아래 두 파일을 읽고 비판적으로 리뷰하세요.
>
> - `specs/<spec-dir>/spec.md`
> - `specs/<spec-dir>/plan.md`
>
> 다음 5가지 관점에서 각각 평가하고, 발견된 문제마다 심각도(Critical/Major/Minor)를 매기세요:
>
> 1. **요구사항 빈틈**: 명시되지 않은 전제 조건, 암묵적 가정, 불완전한 요구사항
> 2. **모호한 Definition of Done**: 검증 불가능하거나 주관적인 완료 조건
> 3. **누락된 엣지 케이스**: 에러 핸들링, 경계값, 동시성, 빈 입력 등
> 4. **과도한 범위**: 이 SPEC 에서 다룰 필요 없는 항목, YAGNI 위반
> 5. **아키텍처 리스크**: 기술 부채, 확장성 문제, 보안 취약점, 의존성 리스크
>
> 출력 형식 (한국어):
> ```
> # Spec Review: <spec-id>
>
> ## 요약
> - 전체 평가: (Go / Conditional Go / No-Go)
> - Critical 이슈 수: N
> - Major 이슈 수: N
> - Minor 이슈 수: N
>
> ## 상세 리뷰
>
> ### 1. 요구사항 빈틈
> - [심각도] 내용
>
> ### 2. 모호한 Definition of Done
> - [심각도] 내용
>
> ### 3. 누락된 엣지 케이스
> - [심각도] 내용
>
> ### 4. 과도한 범위
> - [심각도] 내용
>
> ### 5. 아키텍처 리스크
> - [심각도] 내용
>
> ## 권고사항
> - (수정 제안 목록)
> ```
>
> 리뷰는 반드시 **한국어**로 작성하세요. 발견된 것이 없는 관점은 "발견 없음"으로 표기하세요.

## 3. 결과 저장

리뷰 결과를 `specs/<spec-dir>/review.md` 에 저장합니다.

## 4. 사용자에게 보고

```
✅ Spec Review 완료: <spec-id>
- 결과: specs/<spec-dir>/review.md
- 전체 평가: (Go / Conditional Go / No-Go)
- Critical: N / Major: N / Minor: N
```

Critical 이슈가 있으면 Plan Accept 전에 해결을 권고합니다.
