# Walkthrough: spec-01-01

> 본 문서는 *증거 로그* 입니다.

## 📋 실제 구현된 변경사항

- [x] agent.md에 "Bash Single-Command Principle" (§6.4) 추가 — `||`, `&&`, `;` 체이닝 금지
- [x] `sdd status`에 state 파일 미존재 시 자체 폴백 로직 추가 (git log + backlog/ + specs/)
- [x] settings.json.fragment에서 `./scripts/` prefix 중복 4건 제거
- [x] `/align` 슬래시 커맨드에서 복합 bash 폴백 블록을 `sdd status` 단일 호출로 대체
- [x] `agent/align.md`, `sources/governance/align.md` 동일 반영

## 🧪 검증 결과

### 1. 수동 검증

1. **Action**: `sdd status` 폴백 테스트 — state 파일을 `.bak`으로 이동 후 실행
   - **Result**: git log 5건, backlog/ 6파일, specs/ 1디렉토리 정상 출력. 폴백 동작 확인.

2. **Action**: settings.json.fragment 중복 규칙 검증 — `grep -c "scripts/harness"` 실행
   - **Result**: permissions에 4개 (중복 없음), hooks에 4개. 정상.

3. **Action**: JSON 출력 폴백 테스트 — state 파일 없이 `sdd status --json` 실행
   - **Result**: `{"phase":null,"spec":null,"branch":"...","planAccepted":false,"fallback":true}` 출력. 정상.

### 2. 증거 자료

- 폴백 테스트 결과는 Task 3 커밋(25a5cf8) 직전 세션에서 확인
- 중복 규칙 검증은 Task 4 커밋(8e103aa) 직전 세션에서 확인

## 🔍 발견 사항

- `sdd phase new` 가 기존 phase 파일을 감지하여 자동 번호를 증가시키는데, 수동으로 만든 phase 파일과 충돌 가능. phase 등록 시 번호 지정 옵션이 필요할 수 있음 → 향후 backlog 항목 후보
- permission matcher의 "quoted characters" 안전 검사는 Claude Code 내부 로직이므로, 에이전트 행동 규칙(단일 명령 원칙)으로 우회하는 것이 현실적인 해결책

## 🚧 이월 항목

- `sdd phase new --number=N` 옵션 → 향후 개선 backlog
- `.claude/settings.json`의 실시간 반영 여부 확인 필요 (현재 세션에서는 변경이 적용되지 않을 수 있음)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-10 |
| **최종 commit** | `356de67` |
