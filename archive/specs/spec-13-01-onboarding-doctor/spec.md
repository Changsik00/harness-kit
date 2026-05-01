# spec-13-01: 온보딩 닥터 (hk-doctor)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-13-01` |
| **Phase** | `phase-13` |
| **Branch** | `spec-13-01-onboarding-doctor` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-22 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
harness-kit 설치 후 실제 사용 전에 환경이 올바르게 구성됐는지 확인하는 방법이 없다. `bash 4.0+`, `jq`, `git`, `gh` 등 필수 의존 도구가 빠져 있거나, hook 파일 실행 권한이 없거나, `constitution.md`가 누락됐을 때 에러가 어디서 나는지 알기 어렵다.

### 문제점
- 설치 직후 어떤 항목이 정상/비정상인지 한눈에 파악할 수 없음
- 필수 도구 미설치 시 hook이 cryptic error를 내뱉어 원인 추적이 오래 걸림
- 신규 팀원 온보딩 시 "왜 hook이 안 되죠?" 질문이 반복됨

### 해결 방안 (요약)
`sdd doctor` CLI 서브커맨드와 `/hk-doctor` 슬래시 커맨드를 추가한다. 실행 시 필수 항목을 체크리스트 형식으로 출력하고 PASS/WARN/FAIL을 판정한다. FAIL 시 구체적인 해결 안내도 출력한다.

## 🎯 요구사항

### Functional Requirements
1. `sdd doctor` 실행 시 다음 항목을 순서대로 점검한다:
   - 필수 도구: `bash` (>= 4.0), `jq`, `git`
   - 선택 도구: `gh` (없으면 WARN, FAIL 아님)
   - 설치 파일: `.harness-kit/installed.json` 존재 여부
   - 거버넌스 파일: `.harness-kit/agent/constitution.md` 읽기 가능 여부
   - 훅 파일: `scripts/harness/hooks/*.sh` 실행 권한 여부
   - Claude Code 설정: `.claude/settings.json` 존재 여부
2. 각 항목에 `✅ PASS`, `⚠️  WARN`, `❌ FAIL` 표시
3. 마지막에 종합 판정: `ALL PASS` / `WARN N건` / `FAIL N건`
4. FAIL 항목에 해결 안내 1줄 출력 (예: "brew install jq 로 설치 가능")
5. `/hk-doctor` 슬래시 커맨드는 `sdd doctor`를 실행하는 얇은 wrapper

### Non-Functional Requirements
1. 점검 항목 추가/제거가 쉬운 구조 (함수 기반)
2. FAIL이 있어도 exit 0 — doctor는 보고 도구, 차단 도구가 아님
3. `sources/bin/sdd`에 `doctor` 서브커맨드로 추가 (독립 스크립트 대신 CLI 통합)

## 🚫 Out of Scope

- 자동 수정(auto-fix) 기능 — doctor는 진단만 함
- 네트워크 연결 확인 (GitHub API 등)
- OS 버전 체크
- 의존 버전의 최신 여부 확인 (설치 여부만 확인)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-hk-doctor.sh`)
- [ ] `sdd doctor` 실행 시 체크리스트 출력 확인
- [ ] `/hk-doctor` 슬래시 커맨드 파일 존재 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-13-01-onboarding-doctor` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
