# Walkthrough: spec-23-01

> 외부 확장 조건부 우선 사용 거버넌스 + 권장 유도 작업 기록.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 우선 사용 강도 | 무조건 / 조건부 | 조건부 | "설치됨 + 강점 영역"일 때만. 원칙 #2(MCP 최후)와 양립 — bash·단순 grep 까지 강제하면 충돌 |
| 일반화 범위 | serena 전용 / 확장 일반 | 확장 일반 | 규칙은 확장 일반으로, serena 는 현재 인스턴스. 향후 확장 재사용 |
| 권장 노출 지점 | align 본문 / status drift / 둘 다 | status drift 1곳 | 노출 단일화로 잡음 최소화 (Out of Scope: align 본문) |
| ADR 필요 여부 | spec 내 기록 / 정식 ADR | ADR-008 | 명시 원칙(#2)을 정교화하는 long-lived 결정 → tradeoff ADR. spec-x 부적격 사유도 해소 |

## 💬 사용자 협의

- **주제**: serena 가 설치됐는데도 안 쓰임 → 어떻게 개선할까
  - **합의**: (1) 거버넌스에 우선 사용 규칙, (2) extend 를 recommend 톤으로, (3) 설치 유도 가이드. 단 "외부 기능도 같이 써야 좋다"는 취지로 확장 일반화.
- **충돌 surfacing**: 요청이 CLAUDE.md #2(MCP 최후) 및 extend 의 opt-in 철학과 부분 충돌함을 먼저 고지 → "조건부" 프레이밍으로 합의.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-drift-extension-recommend.sh`
- **결과**: ✅ 3 PASS (코드+미설치→권장 / 비코드→무출력 / 설치됨→무출력)
- `tests/run.sh --fast` 전체 회귀 확인 (T1 Red→Green TDD)
- 미러 3쌍 `diff -q` 동일: agent.md / sdd / hk-extend.md

### 수동 검증
1. **Action**: `HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status` (본 저장소)
   - **Result**: 권장 라인 0개 — 본 저장소는 serena 설치됨 + bash 위주라 미출력. overfit 없음 확인.

## 🔍 발견 사항

- **워드 버짓 soft-warn 은 사전 존재**: agent.md 규칙 추가(+106w)로 거버넌스 총 7786w. `sdd doctor` 가 7000w soft-warn 을 띄우나, 이는 추가 전(~7680w)부터 이미 초과 상태였고 하드 한도 8000 은 미만. → 별도 rule-prune 검토는 Icebox 후보(이번 spec 범위 밖).
- **detection 은 tracked 파일 기준**: `git ls-files` 로 코드 판정 → node_modules 등 비추적 잡음 회피. 단 갓 init 된(파일 미추적) 프로젝트에선 코드가 있어도 미출력될 수 있음(의도된 보수적 동작).

## 🚧 이월 항목

- 거버넌스 워드 버짓 prune 검토 (7000 soft-warn) → `backlog/queue.md` Icebox 후보.
