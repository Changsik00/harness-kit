# spec-1-001: 권한 프롬프트 마찰 해소

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-1-001` |
| **Phase** | `phase-1` |
| **Branch** | `spec-1-001-permission-friction` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`.claude/settings.json`에 68개 allow 규칙이 설정되어 있음에도, 도그푸딩 세션에서 3건의 불필요한 권한 프롬프트가 발생했다:

1. `./scripts/harness/bin/sdd status 2>&1 || echo "---FALLBACK---" && git branch ...` — "Command contains quoted characters in flag names"
2. `for repo in ... do ... done` — 셸 구문이 단일 명령으로 인식되지 않음
3. `mkdir -p .../backlog` — 허용된 명령이지만 디렉토리 생성 시 별도 확인

### 문제점

- **사용자 피로**: 이미 허용한 명령인데 반복 확인 요구 → 신뢰 저하
- **근본 원인이 이중적**: (A) Claude Code의 permission matcher가 복합 명령을 첫 단어로만 매칭하지 못함, (B) 에이전트(AI)가 복합 명령을 생성하는 습관
- **settings.json만으로 해결 불가**: 복합 명령의 "quoted characters" 검사는 permission allow와 별개의 안전 레이어

### 해결 방안 (요약)

3방향 동시 접근:
1. **에이전트 규칙**: agent.md에 "단일 명령 원칙" 추가 → 복합 명령 생성 자체를 방지
2. **sdd CLI 자족화**: `sdd status`가 폴백 로직을 내부에 포함하여 에이전트가 한 줄만 호출
3. **settings.json 정리**: 중복 규칙 제거, 슬래시 커맨드의 복합 명령 지시 제거

## 🎯 요구사항

### Functional Requirements

1. `agent.md`에 Bash 단일 명령 원칙 규칙 추가: "Bash 호출 시 `||`, `&&`, `;` 체이닝 금지. 파이프(`|`)만 허용. 여러 명령이 필요하면 순차 호출 또는 sdd CLI 위임"
2. `sdd status`가 실패 시 자체 폴백 (git branch + git log + ls backlog/ + ls specs/) 수행하여 에이전트가 단일 호출만 하면 됨
3. `settings.json.fragment`에서 중복 allow 규칙 제거 (`./scripts/` vs `scripts/` 이중 등록)
4. `/align` 슬래시 커맨드에서 복합 명령 체인 지시를 제거하고 `sdd status` 단일 호출로 변경

### Non-Functional Requirements

1. 기존 프로젝트에 이미 설치된 settings.json과의 호환성 유지 (규칙 제거는 안전)
2. `sdd status` 폴백 출력이 기존 출력 포맷과 동일

## 🚫 Out of Scope

- Claude Code 자체의 permission matcher 로직 변경 (우리가 제어할 수 없음)
- 새로운 permission 카테고리 추가
- settings.json의 deny/ask 규칙 변경

## ✅ Definition of Done

- [ ] `/align` 실행 시 권한 프롬프트 0회
- [ ] `sdd status`가 sdd 미설치 환경에서도 단독으로 폴백 출력 제공
- [ ] settings.json.fragment에 중복 규칙 0건
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-1-001-permission-friction` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
