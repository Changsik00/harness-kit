# spec-x-claude-md-nested: 디렉토리별 CLAUDE.md 도입 (sources/, specs/)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-claude-md-nested` |
| **Phase** | 없음 (spec-x — phase 비소속) |
| **Branch** | `spec-x-claude-md-nested` |
| **상태** | Planning |
| **타입** | docs (Add) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-18 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
- Claude Code 의 CLAUDE.md auto-load 기능은 *디렉토리별* 로 동작 — working dir 의 상위 경로에 있는 모든 `CLAUDE.md` 가 자동 로드됨.
- 본 저장소는 현재 root `CLAUDE.md` 하나만 사용 중. 그 안에 *두 시점* 의 가이드가 공존:
  1. **키트 원본 시점** — `sources/`, `install.sh` 수정 시 적용되는 규약 (bash 3.2+ 호환, 도그푸딩, install 메커니즘 등)
  2. **도그푸딩 결과 시점** — `specs/`, `backlog/`, `.harness-kit/` 등 SDD 작업 시점의 규약 (한국어 산출물, 템플릿, archive 정책 등)
- root CLAUDE.md 끝부분에 "두 시점이 한 파일에 공존함에 주의" 섹션을 두어 *명시적으로 경고* 하는 상태.

### 문제점
1. **시점 혼동 비용** — 작업 중에 "지금 어느 시점인가" 를 매번 의식해야 함. 새 세션 / 어시스턴트 입장에서 매번 결정 비용 발생.
2. **컨텍스트 미스매치** — `sources/templates/` 만 다루는 작업에 SDD 산출물 규약 (한국어, immutable, archive) 이 자동 로드되어 노이즈. 반대로 spec 작업 중에 bash 3.2+ 호환 룰 등 키트 원본 규약이 노이즈.
3. **Claude Code 의 디렉토리별 auto-load 미활용** — 기사 (news.hada.io/topic?id=29556) 가 권장하는 "context-scoped CLAUDE.md" 원칙 미적용 (인사이트 #3).

### 해결 방안 (요약)
디렉토리 특화 컨텍스트를 별 파일로 분리:
- 신규 `sources/CLAUDE.md` — 키트 원본 작업 시 필요한 규약·주의사항만
- 신규 `specs/CLAUDE.md` — SDD 작업 로그 시 필요한 규약·주의사항만

root 는 *변경 없음* (별 spec 분리 — 본 spec 은 *디렉토리 특화 컨텍스트 추가* 만 집중). Claude Code 가 sources/ 또는 specs/ 의 파일을 편집할 때 해당 nested CLAUDE.md 가 자동 로드되어 *작업-시점-적합* 한 컨텍스트만 활성화.

## 🎯 요구사항

### Functional Requirements
1. **`sources/CLAUDE.md` 신규** — 다음 내용 포함:
   - 이 디렉토리는 *키트 원본* 임 (다른 프로젝트에 install 되어 복사됨)
   - 수정해도 *이미 install 된 프로젝트* 는 자동 갱신되지 않음 — `update.sh` 가 갱신 역할
   - bash 3.2+ 호환 필수 (bash 4+ 전용 기능 금지 목록은 root CLAUDE.md 의 작업 원칙 §3 참조)
   - `sources/templates/`, `sources/governance/`, `sources/commands/`, `sources/hooks/`, `sources/bin/`, `sources/claude-fragments/` 각 디렉토리의 install 대상 경로
2. **`specs/CLAUDE.md` 신규** — 다음 내용 포함:
   - 이 디렉토리는 *작업 로그* 임 (진행/완료된 spec 의 산출물 보관)
   - 한국어 산출물 원칙
   - `.harness-kit/agent/templates/` 에서 템플릿 읽고 따를 것
   - immutable 정책 — 머지된 spec 의 산출물은 사후 수정하지 않음 (archive 이동 후 특히)
   - archive 와의 관계 — `archive/specs/` 는 보관소 (immutable)
3. **root `CLAUDE.md` 무변경** — 본 spec scope 외. 두 시점 공존 메타 가이드 유지 (별 spec 에서 재검토).

### Non-Functional Requirements
1. **간결성** — 각 nested CLAUDE.md 는 *디렉토리 특화* 정보만. root 와 중복 금지. 각 15-25줄 목표.
2. **install.sh 영향 없음** — install.sh 는 root CLAUDE.md 의 `HARNESS-KIT:BEGIN/END` 만 다룸. nested 추가는 무관.
3. **테스트 회귀 없음** — 기존 CLAUDE.md 관련 테스트 (`test-install-claude-import.sh`) 가 root 만 검사하므로 영향 없을 것. 검증은 task 에서.

## 🚫 Out of Scope

- root `CLAUDE.md` 슬림화 — 별 spec-x. 본 spec 은 *추가만*, 이동 없음.
- 다른 디렉토리 CLAUDE.md (`docs/CLAUDE.md`, `backlog/CLAUDE.md` 등) — 본 spec 은 두 핵심 디렉토리만.
- `sources/governance/` 내부에 nested CLAUDE.md 추가 — sources/CLAUDE.md 한 단계로 충분 (Claude Code 가 상위 경로의 CLAUDE.md 도 함께 로드).
- 키트 적용 결과 (install 된 프로젝트) 에서 `.harness-kit/CLAUDE.md` 또는 유사 nested 도입 — 본 저장소 도그푸딩 시점만 다룸.

## 📑 ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — 단순 docs 추가, 거버넌스/구조 변경 없음.

## ✅ Definition of Done

- [ ] `sources/CLAUDE.md` 신규 생성 (≤ 25줄)
- [ ] `specs/CLAUDE.md` 신규 생성 (≤ 25줄)
- [ ] 기존 테스트 (`test-install-claude-import.sh` 등) 회귀 없음
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-claude-md-nested` 브랜치 push 완료
- [ ] PR 생성 및 사용자 검토 요청
