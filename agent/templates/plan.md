# Implementation Plan: spec-{phaseN}-{seq}

## 📋 Branch Strategy

- 신규 브랜치: `spec-{phaseN}-{seq}-{slug}` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
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
# 스택별 명령은 stack adapter 또는 CLAUDE.md 참고
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
- [ ] (실행 후) walkthrough.md / pr_description.md archive
