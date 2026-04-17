# phase-06: SDD UX 개선 및 커맨드 정리

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-06` |
| **상태** | Planning |
| **시작일** | — |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

1. harness-kit이 설치하는 슬래시 커맨드(`/align`, `/handoff`, `/spec-review` 등)가 prefix 없이 등록되어 있어, 사용자가 직접 만든 커맨드와 harness-kit이 제공하는 커맨드를 구분할 수 없다.
2. Task 실행 시 매 task마다 사용자 신호를 기다리는데, 이슈 없는 경우 불필요한 대기가 발생한다.

### 목표 (Goal)

- 모든 harness-kit 슬래시 커맨드에 `hk-` prefix를 부여하여 출처를 명확히 한다
- Task 자동 진행: 이슈 없으면 사용자 대기 없이 다음 task로 자동 진행, 체크박스 실시간 갱신

### 성공 기준 (Success Criteria)

1. 모든 harness-kit 슬래시 커맨드가 `hk-` prefix를 가짐
2. 거버넌스 문서(constitution, agent.md, align.md) 내 참조가 새 이름으로 갱신됨
3. `install.sh` 실행 후 대상 프로젝트에 `hk-` prefix 커맨드가 설치됨
4. agent.md의 Strict Loop 규칙이 "이슈 없으면 자동 진행"으로 갱신됨

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-06-01 | cmd-prefix-rename | P1 | Backlog | `specs/spec-06-01-cmd-prefix-rename/` |
| spec-06-02 | task-auto-proceed | P1 | Backlog | `specs/spec-06-02-task-auto-proceed/` |
<!-- sdd:specs:end -->

### spec-06-01 — 슬래시 커맨드 `hk-` prefix 일괄 변경

- **요점**: `sources/commands/` 내 모든 `.md` 파일명에 `hk-` prefix 부여, 관련 참조 일괄 갱신
- **방향성**:
  1. `sources/commands/*.md` 파일명 변경 (예: `align.md` → `hk-align.md`)
  2. `install.sh`의 commands 복사 로직 확인/갱신
  3. 거버넌스 문서 내 슬래시 커맨드 참조 갱신
  4. `sdd` CLI 내 커맨드 참조 갱신
  5. 도그푸딩 반영 (`.claude/commands/`)
- **연관 모듈**: `sources/commands/`, `install.sh`, `sources/governance/`, `sources/bin/sdd`

### spec-06-02 — Task 자동 진행

- **요점**: Strict Loop에서 이슈 없으면 사용자 대기 없이 다음 task로 자동 진행
- **방향성**:
  1. agent.md §6.1의 "Stop & Report + 대기" 규칙을 "이슈 없으면 자동 진행, 이슈 시 멈추고 보고"로 변경
  2. 매 task 완료 시 task.md 체크박스 실시간 갱신은 유지
  3. hand-off task 전에는 반드시 멈추고 사용자 확인 (push/PR은 여전히 명시적 승인 필요)
- **연관 모듈**: `sources/governance/agent.md`, `sources/templates/task.md`

## 🔗 의존성

- **선행 phase**: phase-04 완료 후 (신규 커맨드 추가 완료 후 일괄 변경이 효율적)
- **외부 시스템**: 없음

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge
- [ ] 모든 커맨드가 `hk-` prefix로 동작 확인
- [ ] 사용자 최종 승인
