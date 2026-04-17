# spec-11-001: sdd archive → sdd ship 리네이밍

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-11-001` |
| **Phase** | `phase-11` |
| **Branch** | `spec-11-001-ship-rename` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-16 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd archive` 명령은 spec 완료 시 walkthrough/pr_description 검증 → commit → phase.md 상태 전이(→ Merged) → state.json 초기화를 수행한다. 이름은 "archive"이지만 실제 동작은 "ship/finalize"에 가깝다.

### 문제점

1. phase-11에서 "완료 항목을 archive/ 디렉토리로 이동"하는 진짜 아카이브 기능을 도입해야 하는데, `sdd archive`가 이미 점유 중
2. `sdd archive`라는 이름이 실제 동작(상태 전이 + 커밋 + 초기화)과 괴리가 있어 직관적이지 않음
3. Icebox에 이미 리네이밍 필요성이 기록되어 있음 (queue.md 28행)

### 해결 방안 (요약)

`sdd archive` → `sdd ship`으로 리네이밍. 하위 호환을 위해 `sdd archive` 호출 시 deprecation 경고 + `sdd ship` 사용 안내 출력 후 정상 실행. 관련 거버넌스·템플릿·커맨드·테스트·문서를 일괄 갱신한다.

## 🎯 요구사항

### Functional Requirements

1. `sdd ship [--check]` — 기존 `sdd archive`와 완전 동일한 기능 수행
2. `sdd archive` 호출 시: stderr에 deprecation 경고 출력 후 `cmd_ship`으로 위임 (기능 차단하지 않음)
3. help 텍스트에서 `archive` → `ship` 변경, `archive`는 "(deprecated → ship)" 표기
4. 거버넌스 문서(`constitution.md`, `agent.md`)에서 `sdd archive` 참조를 `sdd ship`으로 변경
5. 템플릿(`spec.md`, `plan.md`, `task.md`, `queue.md`, `phase.md`, `pr_description.md`)에서 참조 변경
6. 슬래시 커맨드(`hk-ship.md`)에서 `sdd archive` 호출을 `sdd ship`으로 변경
7. 기존 테스트 파일 갱신 및 deprecation 경로 테스트 추가

### Non-Functional Requirements

1. 하위 호환: 기존 `sdd archive` 호출이 정상 동작 (경고만 추가)
2. 커밋 메시지 형식: `docs(spec-N-NNN): archive ...` → `docs(spec-N-NNN): ship ...`으로 변경

## 🚫 Out of Scope

- `archive` 이름의 재사용 (spec-11-003에서 처리)
- 식별자 패딩 변경 (spec-11-002에서 처리)
- 디렉토리 이동 기능 (spec-11-003에서 처리)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = yes) 기존 archive 테스트가 ship으로 전환되어 PASS
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-11-001-ship-rename` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
