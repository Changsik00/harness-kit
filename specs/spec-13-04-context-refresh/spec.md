# spec-13-04: 컨텍스트 리프레시 훅 (context-refresh)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-13-04` |
| **Phase** | `phase-13` |
| **Branch** | `spec-13-04-context-refresh` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-22 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
세션 시작 시 `SessionStart` 훅이 `sdd status --brief`를 출력하지만, 이후 대화가 길어지면 이 컨텍스트가 희석된다. 에이전트가 현재 spec, planAccepted 여부, 마지막 테스트 통과 시점을 잊고 거버넌스 규칙에서 이탈하는 경우가 발생한다.

### 문제점
- 긴 세션에서 에이전트가 현재 state를 잊고 잘못된 phase/spec 이름 사용
- planAccepted=false 상태에서 코드 편집 시도 (hook이 잡지만 마찰 발생)
- 에이전트가 "지금 어느 단계인지" 재질문하거나 stale 정보로 응답

### 해결 방안 (요약)
`PostToolUse` 훅 `context-refresh.sh`를 추가한다. 모든 툴 호출 후 카운터를 증가시키고, N번째(기본: 20)마다 `sdd status --brief`를 출력해 에이전트가 현재 상태를 재인지하도록 유도한다. 카운터는 `.claude/state/current.json`의 `toolCallCount` 필드로 관리한다.

## 🎯 요구사항

### Functional Requirements
1. `PostToolUse` 훅으로 모든 툴 호출(Bash, Edit, Write, Read 등) 후 실행
2. `.claude/state/current.json`의 `toolCallCount` 를 매 호출마다 +1 증가
3. `toolCallCount % INTERVAL == 0` 일 때 `sdd status --brief` 출력
   - 기본 간격: 20 (환경변수 `HARNESS_CONTEXT_REFRESH_INTERVAL` 로 조정)
4. 출력은 stderr — 에이전트의 컨텍스트에 주입됨
5. 항상 exit 0 (PostToolUse는 비차단)

### Non-Functional Requirements
1. state.json 쓰기 실패 시 조용히 skip (훅 오류가 작업 방해 금지)
2. `sdd` 바이너리 없어도 카운터 증가는 정상 동작
3. `jq` 없는 환경에서는 훅 전체 skip (exit 0)

## 🚫 Out of Scope

- PostToolUse에서 특정 툴만 선택적으로 카운트 (모든 툴 카운트)
- 컨텍스트 저하 자동 감지 (고정 간격 방식)
- 훅에서 에이전트 행동 수정 또는 차단

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-context-refresh.sh`)
- [ ] `context-refresh.sh` 훅 파일 존재 + 실행 권한 확인
- [ ] `sources/claude-fragments/settings.json.fragment`에 PostToolUse 항목 추가 확인
- [ ] `.claude/settings.json` (dogfooding) 동기화 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-13-04-context-refresh` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
