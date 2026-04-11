# spec-{phaseN}-{seq}: <한글 제목>

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-{phaseN}-{seq}` |
| **Phase** | `phase-{phaseN}` |
| **Branch** | `spec-{phaseN}-{seq}-{slug}` |
| **상태** | Planning / Plan Accepted / In Progress / Done |
| **타입** | Feature / Fix / Refactor / Research |
| **Integration Test Required** | yes / no |
| **작성일** | YYYY-MM-DD |
| **소유자** | <name> |

## 📋 배경 및 문제 정의

### 현재 상황
<!-- 현재 시스템/코드가 어떤 상태이고, 무엇이 동작하고 있는가? -->

### 문제점
<!-- 구체적으로 어떤 통증이 있는가? 어떤 사고/위험이 있었거나 가능한가? -->

### 해결 방안 (요약)
<!-- 본 SPEC 이 어떤 접근으로 문제를 해결하는가? 1~3 문장 -->

## 📊 개념도 (선택)

```mermaid
%% Mermaid 다이어그램 (있으면 좋음)
```

## 🎯 요구사항

### Functional Requirements
1. <요구사항 1>
2. <요구사항 2>

### Non-Functional Requirements
1. <성능/보안/호환성 등>
2. <예: 기존 API 와의 backward compatibility>

## 🚫 Out of Scope

<!-- 이 SPEC 에서 *명시적으로 다루지 않는* 것들. 범위 폭주 방지. -->
- <항목 1>
- <항목 2>

## 🔍 Critique 결과 (선택)

<!-- /hk-spec-critique 실행 후 핵심 발견사항을 요약합니다. 미실행 시 이 섹션 생략 가능. -->
<!-- 전체 결과: specs/<spec-dir>/critique.md -->

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = yes 인 경우) 선언된 통합 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-{phaseN}-{seq}-{slug}` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
