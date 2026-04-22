# phase-13: 개발자 경험(DX) 향상 — 자동화 & 온보딩

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-13-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-13` |
| **상태** | In Progress |
| **시작일** | 2026-04-22 |
| **목표 종료일** | 2026-05-06 |
| **소유자** | changsik |
| **Base Branch** | `phase-13-dx-enhancements` |

## 🎯 배경 및 목표

### 현재 상황
phase-12까지 harness-kit의 핵심 설치/거버넌스/훅/식별자 체계가 완성됐다. 실사용 관점에서 점검해보니 툴 자체의 기능 완성도와 별개로, **워크플로우 마찰**이 여전히 높다는 점이 확인됐다.

주요 마찰 포인트:
1. 설치 후 환경이 올바른지 확인하는 방법이 없음 (`hk-doctor` 부재)
2. PR merge 후 사용자가 직접 "머지했어"라고 말해야 다음 단계로 넘어감
3. 테스트 실행 결과를 `sdd test passed`로 수동 기록해야 함
4. 대화가 길어질수록 거버넌스 규칙이 희석되는 컨텍스트 저하 문제
5. spec 간 의존성을 선언하고 순서를 강제하는 방법이 없음
6. 여러 프로젝트에 설치된 harness-kit 버전을 중앙에서 파악하기 어려움

이 문제들은 기능 버그가 아니라 **사용성 갭**이다. phase-13은 이 갭을 체계적으로 메우고, 완료 후 버전을 0.6.0으로 올린다.

### 목표 (Goal)
1. 설치 직후 환경 검증을 자동화해 온보딩 마찰 제거
2. PR merge 감지 자동화로 수동 신호 제거
3. 테스트 결과 자동 기록으로 상태 관리 마찰 제거
4. 세션 컨텍스트 저하 방어 훅 추가
5. spec 의존성 선언 + 순서 강제로 phase 내 실행 오류 방지
6. 설치 프로젝트 버전 레지스트리로 업데이트 가시성 확보
7. 위 개선을 반영한 버전 0.6.0 릴리스

### 성공 기준 (Success Criteria)
1. `hk-doctor` 실행 시 필수 도구(bash 4.0+, jq, git, gh) 및 설치 파일 체크리스트 출력 + PASS/FAIL 판정
2. `sdd pr-watch` 또는 hook으로 merge 감지 후 `sdd ship` 자동 트리거 (또는 안내 출력)
3. 테스트 실행 후 자동으로 `sdd test passed` 기록 (wrapper 또는 PostToolUse hook 방식)
4. 세션 중 컨텍스트 저하 감지 시 `sdd status` 자동 주입 (PostToolUse hook 방식)
5. `spec.md`에 `depends_on` 필드 선언 시 `sdd spec new`가 선행 spec Merged 여부 검증
6. `sdd update-check` 실행 시 설치된 프로젝트 목록 + 현재 버전 출력
7. `kitVersion` 0.6.0, CHANGELOG 갱신, 전체 테스트 FAIL=0

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-13-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-13-01` | onboarding-doctor | P? | Merged | `specs/spec-13-01-onboarding-doctor/` |
| `spec-13-02` | pr-merge-detect | P? | Merged | `specs/spec-13-02-pr-merge-detect/` |
| `spec-13-03` | test-auto-record | P? | Active | `specs/spec-13-03-test-auto-record/` |
| `spec-13-04` | context-refresh | P2 | Backlog | `specs/spec-13-04-context-refresh/` |
| `spec-13-05` | spec-dependency | P3 | Backlog | `specs/spec-13-05-spec-dependency/` |
| `spec-13-06` | update-registry | P3 | Backlog | `specs/spec-13-06-update-registry/` |
| `spec-13-07` | version-bump | P1 | Backlog | `specs/spec-13-07-version-bump/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`
> sdd가 ship 시 자동으로 `Merged`로 갱신합니다. `In Progress`는 active spec에 자동 마킹됩니다.

### spec-13-01 — 온보딩 닥터

- **요점**: `hk-doctor` 슬래시 커맨드 — 설치 환경 검증 체크리스트 자동 실행
- **방향성**: `sources/commands/hk-doctor.md` 추가. 체크 항목: bash 4.0+, jq, git, gh 설치 여부 / `.harness-kit/installed.json` 존재 / `constitution.md` 접근 가능 / hook 파일 실행 권한. 각 항목 PASS/FAIL 출력 후 종합 판정.
- **참조**: 없음
- **연관 모듈**: `sources/commands/`, `sources/hooks/_lib.sh`

### spec-13-02 — PR merge 자동 감지

- **요점**: PR merge 후 사용자가 수동으로 알리지 않아도 다음 단계 안내가 출력되도록 감지 자동화
- **방향성**: `sdd pr-watch <pr-number>` subcommand 추가 (또는 PostToolUse hook). `gh pr view <N> --json mergedAt`을 폴링해 merge 감지 시 post-merge 절차(`sdd ship`, NEXT 안내)를 자동 출력. 백그라운드 실행 방식이 아니라 "PR 생성 후 대기 중" 메시지와 함께 출력하는 방향 검토.
- **참조**: agent.md §6.3.1 Post-Merge Protocol
- **연관 모듈**: `sources/bin/sdd`, `sources/commands/`

### spec-13-03 — 테스트 결과 자동 기록

- **요점**: 테스트 실행 후 `sdd test passed`를 자동으로 기록 — 수동 호출 제거
- **방향성**: PostToolUse hook (`post-test-record.sh`) 방식. Bash 툴 실행 결과에서 테스트 PASS 패턴 감지 시 `sdd test passed` 자동 호출. 또는 `sdd run-test <cmd>` wrapper subcommand로 테스트 명령을 감싸는 방식 중 구현 난이도 검토 후 선택.
- **참조**: constitution §9.1, agent.md §6.4
- **연관 모듈**: `sources/hooks/`, `sources/bin/sdd`

### spec-13-04 — 컨텍스트 리프레시 훅

- **요점**: 세션 중 거버넌스 규칙 희석 방지 — 일정 조건에서 `sdd status`를 자동 주입
- **방향성**: PostToolUse hook (`context-refresh.sh`). N번째 툴 호출마다(또는 특정 조건에서) `sdd status --brief`를 stderr로 출력해 에이전트가 현재 상태를 재인지하도록 유도. 카운터는 `.claude/state/current.json`에 `toolCallCount` 필드로 관리.
- **참조**: agent.md §2 Bootstrap Protocol
- **연관 모듈**: `sources/hooks/`, `.claude/settings.json` hook 설정

### spec-13-05 — spec 의존성 선언

- **요점**: `spec.md`에 `depends_on` 필드 추가 + `sdd spec new` 시 선행 spec Merged 여부 검증
- **방향성**: spec.md 템플릿에 `depends_on: [spec-13-01, spec-13-02]` 형식 필드 추가. `sdd spec new <slug>` 실행 시 phase.md에서 depends_on 목록의 상태를 확인, Backlog/In Progress면 경고 출력(exit 0). 강제 차단은 phase 운영 경험 쌓인 후 고려.
- **참조**: constitution §5.1
- **연관 모듈**: `sources/bin/sdd`, `sources/templates/spec.md`

### spec-13-06 — 업데이트 레지스트리

- **요점**: `sdd update-check` — harness-kit이 설치된 프로젝트 목록과 버전을 출력
- **방향성**: `installed.json`에 `installedProjects` 배열 추가 방식은 중앙 추적이 안 되므로, 대신 `~/.harness-kit-registry.json` 파일에 설치 시 프로젝트 경로 + 버전을 append. `install.sh` 실행 시 레지스트리 자동 갱신. `sdd update-check`는 레지스트리를 읽어 현재 kitVersion과 비교 출력.
- **참조**: 없음
- **연관 모듈**: `install.sh`, `sources/bin/sdd`

### spec-13-07 — 버전 bump (0.5.0 → 0.6.0)

- **요점**: phase-13 완료를 반영한 kitVersion 0.6.0 릴리스
- **방향성**: `installed.json`, `sources/bin/sdd`, `install.sh` 내 버전 상수 일괄 갱신. `CHANGELOG.md` 추가 또는 갱신. 전체 테스트 PASS 확인 후 버전 커밋.
- **참조**: 없음
- **연관 모듈**: `install.sh`, `sources/bin/sdd`, `CHANGELOG.md`

## 🧪 통합 테스트 시나리오

### 시나리오 1: 온보딩 닥터
- **Given**: harness-kit이 설치된 프로젝트에서 `hk-doctor` 실행
- **When**: 필수 도구 중 하나(jq)가 없는 환경
- **Then**: 해당 항목 FAIL 표시, 전체 판정 FAIL 출력
- **연관 SPEC**: spec-13-01

### 시나리오 2: PR merge 자동 감지
- **Given**: spec 브랜치 PR이 생성된 상태
- **When**: `sdd pr-watch <pr-number>` 실행 중 PR이 merge됨
- **Then**: merge 감지 후 post-merge 안내 자동 출력
- **연관 SPEC**: spec-13-02

### 시나리오 3: 테스트 자동 기록
- **Given**: 테스트 스위트가 구성된 프로젝트
- **When**: 테스트 실행 후 PASS 결과 감지
- **Then**: `sdd test passed` 자동 호출, `lastTestPass` 갱신
- **연관 SPEC**: spec-13-03

### 시나리오 4: 버전 확인
- **Given**: phase-13 전체 완료 상태
- **When**: `sdd version` 실행
- **Then**: `0.6.0` 출력
- **연관 SPEC**: spec-13-07

### 통합 테스트 실행
```bash
for t in tests/test-*.sh; do bash "$t" 2>&1 | tail -1; done
```

## 🔗 의존성

- **선행 phase**: phase-12
- **외부 시스템**: `gh` CLI (spec-13-02 PR 감지에 필요)
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| `gh` CLI 미설치 환경에서 pr-merge-detect 동작 불가 | spec-13-02 기능 무효 | 미설치 감지 시 `hk-doctor`에서 경고 출력, graceful skip |
| PostToolUse hook이 Claude Code 버전에 따라 동작 방식 상이 | context-refresh, test-auto-record 오작동 | 경고 모드(exit 0)로 먼저 출시, 1주 운영 후 검토 |
| `~/.harness-kit-registry.json` 파일 권한 문제 | update-registry 기록 실패 | 실패 시 조용히 skip (warn 로그), 기록 실패가 install을 막지 않도록 |
| spec-dependency 검증이 너무 엄격해 워크플로우 방해 | 사용자 불만 | 첫 버전은 경고만(exit 0), 차단(exit 2)은 다음 phase로 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (각 spec → main)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 7항목 정량 측정 결과 기록
- [ ] `sdd version` → `0.6.0` 확인
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
