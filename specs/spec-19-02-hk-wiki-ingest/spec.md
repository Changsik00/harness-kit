# spec-19-02: hk-wiki-ingest 슬래시 커맨드 구현

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-19-02` |
| **Phase** | `phase-19` |
| **Branch** | `spec-19-02-hk-wiki-ingest` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-05-27 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`docs/wiki/` 레이어가 spec-19-01에서 부트스트랩되었다. `decisions.md`, `patterns.md` 등 증류 페이지가 존재하지만, 새로운 spec이 archive된 후 wiki를 갱신하는 **표준 워크플로가 없다**. 사용자가 매번 수동으로 wiki 파일을 열고 편집해야 하며, 이 마찰이 wiki 유지를 포기하게 만든다.

### 문제점

- `sdd archive` 실행 후 wiki 갱신이 이루어지지 않으면 wiki↔raw drift가 누적됨
- "archive 후 wiki 갱신"이라는 워크플로가 명시되어 있지 않아 사용자가 잊기 쉬움
- `/hk-wiki-ingest` 커맨드가 없어 Claude가 wiki를 갱신하는 절차가 정의되지 않음

### 해결 방안 (요약)

`/hk-wiki-ingest` 슬래시 커맨드를 신설해 Claude가 최근 archived spec의 walkthrough.md를 읽고 `docs/wiki/decisions.md`, `docs/wiki/patterns.md`를 갱신하며 `docs/wiki/log.md`에 인제스트 이벤트를 기록하는 표준 워크플로를 확립한다. `sdd archive` 실행 시 후처리 힌트를 출력해 사용자가 자연스럽게 `/hk-wiki-ingest`로 이어가도록 안내한다.

## 🎯 요구사항

### Functional Requirements

1. `/hk-wiki-ingest` 실행 시 Claude가 최근 archived spec들의 walkthrough.md를 읽고 wiki 페이지를 갱신한다
2. `docs/wiki/log.md`에 인제스트 이벤트(타임스탬프 + 대상 spec 목록)를 기록한다
3. `docs/wiki/decisions.md`, `docs/wiki/patterns.md`를 신규 발견사항으로 갱신한다
4. `sdd archive` 완료 시 `→ /hk-wiki-ingest 로 wiki 갱신 권장` 힌트를 출력한다
5. 인제스트 범위를 지정할 수 있다 (기본: 마지막 인제스트 이후 신규 archived spec, `--all`: 전체)

### Non-Functional Requirements

1. 커맨드는 `sources/commands/` 에 위치하고 `.harness-kit/commands/` 에 동기화된다
2. 슬래시 커맨드 형식은 기존 `hk-archive.md` 패턴을 따른다 (절차 + 출력 형식 명세)
3. `sdd archive` 힌트는 bash 3.2+ 호환 방식으로 추가된다

## 🚫 Out of Scope

- 자동 wiki 갱신 (CI/훅 자동화) — 사용자 명시 호출만
- 전체 wiki 재구축 — 증분 갱신만
- 템플릿 "관련 문서" 섹션 추가 — spec-19-01 이슈 수정에서 이미 완료

## 📑 ADR 후보

- [ ] 없음

## 🔗 관련 문서 (Related)

- 관련 wiki: [[wiki/purpose]], [[wiki/log]]
- 관련 ADR: [[ADR-003]]
- 관련 RCA: 없음

## ✅ Definition of Done

- [ ] `sources/commands/hk-wiki-ingest.md` 존재 + `.harness-kit/commands/hk-wiki-ingest.md` 동기화
- [ ] `sdd archive` 완료 시 `/hk-wiki-ingest` 힌트 출력 확인
- [ ] `docs/wiki/log.md` 갱신 시나리오 수동 검증 PASS
- [ ] `tests/test-wiki-structure.sh` 45/45 PASS (회귀 없음)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-19-02-hk-wiki-ingest` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
