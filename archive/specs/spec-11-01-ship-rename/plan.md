# Implementation Plan: spec-11-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-11-01-ship-rename`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 커밋 메시지 형식 변경: `docs(...): archive ...` → `docs(...): ship ...` — 기존 커밋 히스토리와 달라짐
> - [ ] `sdd archive` deprecated 경고 방식: stderr 출력 후 정상 실행 (차단하지 않음)

> [!WARNING]
> - [ ] 이미 설치된 대상 프로젝트는 `update.sh`를 실행해야 변경 반영됨 — 즉시 호환성 문제 없음 (deprecated 경로 유지)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **함수명** | `cmd_archive` → `cmd_ship` | "ship"이 실제 동작(완료 처리 + 상태 전이)을 정확히 반영 |
| **하위 호환** | `sdd archive` → stderr 경고 + `cmd_ship` 위임 | 기존 사용자·스크립트가 즉시 깨지지 않도록 |
| **도그푸딩 동기화** | `sources/` 수정 후 `.harness-kit/`에 동일 반영 | 키트 원본과 적용 결과 동기화 |
| **커밋 메시지** | `archive` → `ship` | 새 명명과 일관성 유지 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd`
- `cmd_archive()` → `cmd_ship()` 함수 리네이밍
- `_check_phase_all_merged()` 내부의 "sdd archive" 참조 → "sdd ship"
- help 텍스트 갱신: `ship [--check]` 메인 항목, `archive` deprecated 표기
- dispatch에 `ship)` 추가, `archive)`는 deprecation 경고 후 `cmd_ship` 호출
- 커밋 메시지: `archive walkthrough ...` → `ship walkthrough ...`
- `compute_next_spec` 주석의 "archive" → "ship"

#### [MODIFY] `.harness-kit/bin/sdd`
- `sources/bin/sdd`와 동일 변경 (도그푸딩 동기화)

### 거버넌스

#### [MODIFY] `sources/governance/constitution.md`
- `sdd archive` 참조를 `sdd ship`으로 변경 (3곳)

#### [MODIFY] `sources/governance/agent.md`
- `sdd archive` 참조를 `sdd ship`으로 변경 (6곳+)

#### [MODIFY] `.harness-kit/agent/constitution.md`
- 도그푸딩 동기화

#### [MODIFY] `.harness-kit/agent/agent.md`
- 도그푸딩 동기화

### 템플릿

#### [MODIFY] `sources/templates/spec.md`
- "archive commit" → "ship commit" (1곳)

#### [MODIFY] `sources/templates/plan.md`
- "archive" 참조 → "ship" (1곳)

#### [MODIFY] `sources/templates/task.md`
- "Archive Commit" → "Ship Commit", 커밋 메시지 변경 (1곳)

#### [MODIFY] `sources/templates/queue.md`
- `sdd archive` → `sdd ship` (사용법 테이블 1곳)

#### [MODIFY] `sources/templates/phase.md`
- "archive 시 자동으로" → "ship 시 자동으로" (해당 시 변경)

#### [MODIFY] `sources/templates/pr_description.md`
- archive 참조 → ship (해당 시 변경)

#### [MODIFY] `.harness-kit/agent/templates/*`
- 위 sources/templates 변경과 동기화

### 슬래시 커맨드

#### [MODIFY] `sources/commands/hk-ship.md`
- `sdd archive --check` → `sdd ship --check`
- `sdd archive` → `sdd ship`
- "Archive Commit" 섹션 제목 → "Ship Commit"
- State 업데이트 섹션의 `sdd archive` 참조 → `sdd ship`

#### [MODIFY] `.claude/commands/hk-ship.md`
- 도그푸딩 동기화

### 테스트

#### [MODIFY] `tests/test-sdd-archive-completion.sh` → `tests/test-sdd-ship-completion.sh`
- 파일 리네이밍
- 내부 `sdd archive` 호출 → `sdd ship`
- deprecated 경로 테스트 추가: `sdd archive` 호출 시 경고 출력 + 정상 동작 확인

### 문서

#### [MODIFY] `docs/REFERENCE.md`
- `### archive` → `### ship`, deprecated 안내 추가

#### [MODIFY] `docs/USAGE.md`
- `sdd archive` 참조 → `sdd ship`

#### [MODIFY] `README.md`
- `sdd archive` 참조 → `sdd ship`

#### [MODIFY] `CHANGELOG.md`
- ship rename 항목 추가

### 백로그

#### [MODIFY] `backlog/queue.md`
- Icebox의 "`sdd archive` 리네이밍 검토" 항목 제거 (본 spec에서 해결)

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-ship-completion.sh
```

### 통합 테스트
```bash
# deprecated 경로 테스트 포함
bash tests/test-sdd-ship-completion.sh
```

### 수동 검증 시나리오
1. `sdd help` 실행 — `ship` 명령 표시, `archive` deprecated 표기 확인
2. `sdd ship --check` 실행 — 기존 `sdd archive --check`와 동일 동작 확인
3. `sdd archive` 실행 — stderr 경고 출력 후 정상 실행 확인

## 🔁 Rollback Plan

- `sdd archive`가 하위 호환으로 유지되므로 롤백 필요성 낮음
- 필요 시 git revert로 전체 변경 되돌림 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship commit
