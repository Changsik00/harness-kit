# phase-1: 설치/운영 마찰 해소

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-1-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-1` |
| **상태** | Planning |
| **시작일** | 2026-04-10 |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

도그푸딩 첫 세션에서 두 가지 즉각적 마찰이 확인됨:

**1. 권한 프롬프트 피로**
`.claude/settings.json`에 `Bash(mkdir:*)`, `Bash(curl:*)`, `Bash(git:*)` 등 68개 allow 규칙이 설정되어 있으나, 에이전트가 복합 명령(`||`, `&&`, `"..."` 포함)을 보내면 Claude Code의 "Command contains quoted characters in flag names" 안전 검사에 걸려 매번 사용자 확인을 요구한다. 권한을 풀어줬는데도 묻는 것은 사용자에게 혼란과 피로를 유발.

- 근본 원인: permission matcher는 첫 단어 기준 prefix match. 복합 명령/셸 구문은 별도 안전 검사 트리거
- 해결 방향: (A) 에이전트가 복합 명령 대신 단일 명령을 보내도록 거버넌스 규칙 추가, (B) settings.json.fragment의 allow 규칙을 복합 명령에도 커버되도록 최적화, (C) 슬래시 커맨드/sdd CLI가 자체적으로 복합 로직을 처리하여 에이전트는 단일 호출만

**2. .harness-backup 무한 누적**
`install.sh` 실행마다 `.harness-backup-TIMESTAMP/` 디렉토리를 무조건 생성. 하루 만에 6개(804KB) 누적. git history에 이미 모든 이력이 있으므로 실효성 의문. 보존 정책 없고, 사용자가 직접 삭제해야 함.

### 목표 (Goal)

- 에이전트가 보내는 명령으로 인한 **불필요한 권한 프롬프트를 0에 가깝게** 줄임
- `.harness-backup` 누적을 **최근 N개만 유지** 또는 **git-aware 정책으로 전환**
- 설치/운영 과정의 UX 마찰을 체감 수준에서 제거

### 성공 기준 (Success Criteria) — 정량 우선

1. `/align` 실행 시 사용자 확인 프롬프트 0회 (단일 명령 정책 준수)
2. `install.sh` 반복 실행 후 `.harness-backup-*` 최대 3개 유지
3. 도그푸딩 1시간 세션에서 불필요한 권한 프롬프트 0회

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-1-001 | permission-friction | P0 | Backlog | `specs/spec-1-001-permission-friction/` |
| spec-1-002 | backup-policy | P0 | Backlog | `specs/spec-1-002-backup-policy/` |
<!-- sdd:specs:end -->

### spec-1-001 — 권한 프롬프트 마찰 해소

- **요점**: 에이전트가 복합 명령을 보내지 않도록 거버넌스 규칙을 추가하고, sdd CLI가 복합 로직을 내부 처리하도록 개선
- **방향성**:
  1. **agent.md에 규칙 추가**: "Bash 호출 시 반드시 단일 명령만 사용. `||`, `&&` 체이닝 금지. 여러 명령이 필요하면 순차 호출 또는 sdd CLI 위임"
  2. **`sdd status`를 자족적으로 개선**: 현재 에이전트가 `sdd status 2>&1 || echo ... && git branch ...` 같은 폴백 체인을 직접 구성함. `sdd status`가 실패 시 자체 폴백 로직을 포함하도록 개선하면 에이전트는 `./scripts/harness/bin/sdd status` 한 줄만 호출
  3. **settings.json.fragment 점검**: 불필요한 중복 규칙 정리 (예: `./scripts/harness/bin/sdd:*`와 `scripts/harness/bin/sdd:*` 이중 등록)
  4. **슬래시 커맨드 점검**: `/align` 등에서 복합 명령을 지시하는 부분을 단일 명령으로 변경
- **참조**:
  - 도그푸딩 세션에서 발생한 프롬프트 사례 3건 (이 phase 문서 상단)
  - `.claude/settings.json` permissions.allow 배열
- **연관 모듈**: `sources/governance/agent.md`, `sources/bin/sdd`, `sources/claude-fragments/settings.json.fragment`, `sources/commands/align.md`

### spec-1-002 — .harness-backup 보존 정책

- **요점**: install.sh의 백업 전략을 "무조건 생성"에서 "스마트 보존"으로 변경
- **방향성**:
  1. **최근 N개만 유지**: install.sh 끝에 오래된 백업을 자동 삭제 (기본 N=3)
  2. **git-aware 스킵**: `git status`로 워킹 트리가 clean이면 백업 스킵 (git history가 이미 보호)
  3. **`--no-backup` 옵션 추가**: 사용자가 명시적으로 백업을 건너뛸 수 있도록
  4. **`install.sh --force`일 때 정리**: 기존 `--force`는 백업 안 함인데, 기존 백업도 정리하는 옵션 추가 검토
- **참조**:
  - `install.sh` L192~L210 (백업 로직)
  - `.gitignore`의 `.harness-backup-*/` 패턴
- **연관 모듈**: `install.sh`

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: 단일 명령 정책 준수
- **Given**: harness-kit이 설치된 프로젝트에서 `/align` 호출
- **When**: 에이전트가 컨텍스트 점검을 위해 Bash 명령 실행
- **Then**: 모든 Bash 호출이 단일 명령이며, 권한 프롬프트 0회
- **연관 SPEC**: spec-1-001

### 시나리오 2: 백업 보존 정책
- **Given**: install.sh를 5회 반복 실행
- **When**: 실행 완료
- **Then**: `.harness-backup-*` 디렉토리가 최대 3개만 존재
- **연관 SPEC**: spec-1-002

### 통합 테스트 실행
```bash
./tests/test-phase-1.sh
```

## 🔗 의존성

- **선행 phase**: 없음 (독립 실행 가능, 최우선)
- **외부 시스템**: 없음
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| 단일 명령 정책이 에이전트 효율을 떨어뜨림 | 순차 호출로 latency 증가 | sdd CLI가 복합 로직을 내부 처리하여 보상 |
| 백업 자동 삭제로 롤백 불가 | 설치 실패 시 복원 불가 | git history가 1차 보호, 최근 3개 유지 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge (위 표의 상태 = Merged)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
