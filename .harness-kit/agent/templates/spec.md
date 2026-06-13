# spec-{phaseN}-{seq}: <한글 제목>

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-{phaseN}-{seq}` |
| **Phase** | `phase-{phaseN}` |
| **Branch** | `spec-{phaseN}-{seq}-{slug}` |
| **상태** | Planning |
| **타입** | Feature / Fix / Refactor / Research |
| **작성일** | YYYY-MM-DD |
| **소유자** | <name> |

## 배경 및 문제 정의

### 현재 상황
<!-- 현재 시스템/코드가 어떤 상태이고, 무엇이 동작하고 있는가? -->

### 문제점
<!-- 구체적으로 어떤 통증이 있는가? -->

### 해결 방안
<!-- 본 Spec 이 어떤 접근으로 문제를 해결하는가? 1~3 문장 -->

## 요구사항

<!-- Functional + Non-Functional 을 자유롭게 기재. 항목이 적으면 단순 번호 목록으로. -->
1. <요구사항 1>
2. <요구사항 2>

## Out of Scope

- <항목 1>
- <항목 2>

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] <중대 결정 1>

> [!WARNING]
> - [ ] <잠재적 breaking change 1>

## 핵심 전략

<!-- 다이어그램이 필요하면 여기에 Mermaid 블록을 추가 -->

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **A** | Option X | <이유> |

## Proposed Changes

<!-- 변경 파일·컴포넌트를 [MODIFY]/[NEW]/[DELETE] 로 기재 -->

#### [MODIFY] `path/to/file.ext`
<!-- 무엇을, 왜 변경하는지 -->

## 검증 계획

```bash
# 검증 명령
```

수동 검증 시나리오:
1. <단계 1> — 기대 결과: ...

## ADR 후보

- [ ] ADR 가치 있는 결정 있음 → 후보: `<slug>` (type: decision / invariant / convention / tradeoff)
- [ ] 없음

## ✅ Definition of Done

- [ ] 모든 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-{phaseN}-{seq}-{slug}` 브랜치 push 완료
