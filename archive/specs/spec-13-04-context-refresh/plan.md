# Implementation Plan: spec-13-04

## 📋 Branch Strategy

- 신규 브랜치: `spec-13-04-context-refresh`
- 시작 지점: `phase-13-dx-enhancements` (phase base branch)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] PostToolUse 훅 방식 동의 여부 (모든 툴 호출 후 실행)
> - [ ] 기본 간격 20 동의 여부 (`HARNESS_CONTEXT_REFRESH_INTERVAL` 로 조정 가능)

> [!NOTE]
> - PostToolUse 훅은 비차단 (exit 0 강제) — 기존 작업 방해 없음
> - 카운터가 state.json에 저장되므로 세션 재시작 시 초기화됨

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **훅 타입** | PostToolUse | 비차단, 모든 툴 후 실행 |
| **출력 채널** | stderr | 에이전트 컨텍스트에 주입, 기존 툴 출력 오염 없음 |
| **카운터 저장** | `toolCallCount` in state.json | 세션 내 지속, jq로 단순 read/write |
| **간격** | 20 (기본, 환경변수 조정) | 너무 잦으면 노이즈, 너무 드물면 효과 없음 |
| **오류 처리** | jq 없거나 쓰기 실패 시 skip | 훅 오류가 작업 방해 금지 |

## 📂 Proposed Changes

### [훅]

#### [NEW] `sources/hooks/context-refresh.sh`
PostToolUse 훅:
```text
source _lib.sh
# toolCallCount 읽기 → +1 증가 → 저장
# count % INTERVAL == 0 이면: sdd status --brief >&2
# 항상 exit 0
```

### [설정]

#### [MODIFY] `sources/claude-fragments/settings.json.fragment`
PostToolUse 섹션 추가:
```json
"PostToolUse": [
  {
    "matcher": ".*",
    "hooks": [
      {
        "type": "command",
        "command": ".harness-kit/hooks/context-refresh.sh"
      }
    ]
  }
]
```

#### [MODIFY] `.claude/settings.json` (dogfooding)
동일한 PostToolUse 섹션을 현재 프로젝트 settings.json 에도 추가

### [테스트]

#### [NEW] `tests/test-context-refresh.sh`
1. `context-refresh.sh` 파일 존재 + 실행 권한 확인
2. 실행 시 `toolCallCount` 증가 확인
3. 인터벌 도달 전 출력 없음 확인
4. 인터벌 도달 시 `sdd status` 출력 포함 확인
5. `sources/claude-fragments/settings.json.fragment`에 PostToolUse 항목 포함 확인
6. `.claude/settings.json`에 PostToolUse 항목 포함 확인

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-context-refresh.sh
```

### 수동 검증 시나리오
1. `bash sources/hooks/context-refresh.sh` → exit 0, toolCallCount 증가
2. `HARNESS_CONTEXT_REFRESH_INTERVAL=1 bash sources/hooks/context-refresh.sh` → sdd status 출력

## 🔁 Rollback Plan

- `sources/claude-fragments/settings.json.fragment` / `.claude/settings.json` 에서 PostToolUse 섹션 제거
- `sources/hooks/context-refresh.sh` 삭제 → install.sh 재실행

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
