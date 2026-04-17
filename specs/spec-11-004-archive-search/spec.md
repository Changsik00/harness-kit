# spec-11-004: 아카이브 검색 통합

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-11-004` |
| **Phase** | `phase-11` |
| **Branch** | `spec-11-004-archive-search` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-16 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

spec-11-003에서 `sdd archive` 명령이 도입되어 완료 항목을 `archive/` 디렉토리로 이동할 수 있게 되었다. 하지만 아카이브 후 `sdd spec list`, `sdd phase list`, `sdd phase show`, `sdd spec show` 등의 명령이 아카이브된 항목을 찾지 못한다.

### 문제점

1. `sdd spec list` — 아카이브된 spec이 목록에서 사라짐
2. `sdd phase list` — 아카이브된 phase의 spec 수가 0으로 표시
3. `sdd phase show` — 아카이브된 phase의 spec 디렉토리를 찾지 못함
4. `sdd status --verbose` — 아카이브된 spec 누락

### 해결 방안 (요약)

spec/phase 탐색 함수에 `archive/specs/`, `archive/backlog/` fallback 경로 추가. 아카이브된 항목은 `(archived)` 표시로 구분. `compute_next_spec` 등 active 작업 관련 함수는 archive를 탐색하지 않음.

## 🎯 요구사항

### Functional Requirements

1. `sdd spec list` — `archive/specs/` 도 탐색, 아카이브된 항목에 `(archived)` 표시
2. `sdd phase list` — `archive/backlog/` 도 탐색, 아카이브된 phase에 `(archived)` 표시, spec 수에 `archive/specs/` 포함
3. `sdd phase show [N]` — `archive/backlog/phase-NN.md` fallback, `archive/specs/` 에서 spec 디렉토리 탐색
4. `sdd spec show [slug]` — `archive/specs/` fallback
5. `sdd status --verbose` — 아카이브된 spec 수 별도 표시
6. `sdd status` 진단 — 아카이브 항목 수 표시 (예: "archive/ 에 25개 spec 보관 중")

### Non-Functional Requirements

1. `compute_next_spec`, `cmd_ship`, `sdd spec new` 등 active 작업 함수는 archive를 탐색하지 않음
2. 성능: archive가 수백 개여도 기존 명령 속도에 영향 없도록 lazy 탐색

## 🚫 Out of Scope

- 아카이브 복원(unarchive) 자동화
- archive/ 내부 파일 수정 기능
- queue.md에서 아카이브된 phase 제거

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = yes) 아카이브 검색 테스트 PASS
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-11-004-archive-search` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
