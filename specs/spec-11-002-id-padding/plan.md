# Implementation Plan: spec-11-002

## 📋 Branch Strategy

- 신규 브랜치: `spec-11-002-id-padding`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 9개 backlog 파일 + 33개 spec 디렉토리 일괄 리네이밍 — git blame/log 추적에 영향
> - [ ] phase.md 내부 spec 참조 텍스트도 변경됨 — 기존 링크 깨질 수 있음

> [!WARNING]
> - [ ] 대량 `git mv` 후 GitHub에서 rename detection이 제대로 동작하는지 PR에서 확인 필요

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **sdd 코드** | `phase_new`의 ID 생성에 `printf '%02d'` 추가 (1곳) | 유일한 코드 변경점. 나머지 파싱은 `[0-9]*`로 이미 호환 |
| **마이그레이션** | bash 스크립트로 `git mv` + `sed` 일괄 실행 | 수작업 불가능한 규모(42개 대상), 재현 가능해야 함 |
| **커밋 전략** | sdd 코드 변경 1커밋 + 마이그레이션 1커밋 + 문서 1커밋 | 코드 변경과 데이터 이동 분리 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd` (line 444)
`phase_new` 함수에서 phase ID 생성 시 2자리 패딩 적용:
```bash
# Before
local id="phase-${next}"
# After
local id="phase-$(printf '%02d' "$next")"
```

#### [MODIFY] `.harness-kit/bin/sdd`
도그푸딩 동기화

### 마이그레이션 (단일 커밋)

#### backlog 파일 리네이밍 (9개)
`backlog/phase-{1..9}.md` → `backlog/phase-{01..09}.md`

#### backlog 파일 내부 참조 갱신
- 각 `phase-N.md` 파일의 헤딩 `# phase-N:` → `# phase-0N:`
- spec 표 내부의 `spec-N-` 참조 → `spec-0N-`
- 디렉토리 참조 `specs/spec-N-` → `specs/spec-0N-`

#### spec 디렉토리 리네이밍 (33개)
`specs/spec-{1..9}-*` → `specs/spec-{01..09}-*`

#### spec 디렉토리 내부 파일 참조 갱신
- 각 spec.md, plan.md, task.md 등의 내부 `spec-N-` → `spec-0N-` 참조
- `phase-N` → `phase-0N` 참조

#### queue.md 참조 갱신
- 완료 섹션의 phase 참조 패딩

#### state.json
- 현재 active phase/spec이 단일 자릿수면 패딩

### 거버넌스·문서

#### [MODIFY] `sources/governance/constitution.md`
- §6.1 예시: `phase-1` → `phase-01`, `phase-8-work-model` → `phase-08-work-model`
- §6.2 예시: `spec-1-001` → `spec-01-001`
- §6.4 예시: `spec-1-001-stock-row-locking` → `spec-01-001-stock-row-locking`
- §10.2 커밋 예시 갱신

#### [MODIFY] `sources/governance/agent.md`
- §4.1 레이아웃 예시 패딩

#### [MODIFY] `sources/claude-fragments/CLAUDE.fragment.md`
- 핵심 규칙 요약의 예시 패딩

#### [MODIFY] `.harness-kit/agent/` 도그푸딩 동기화

#### [MODIFY] `backlog/queue.md`
- Icebox의 "식별자 2자리 패딩" 항목 제거

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-ship-completion.sh
bash tests/test-sdd-phase-done-accuracy.sh
bash tests/test-sdd-status-cross-check.sh
```

### 수동 검증 시나리오
1. `ls specs/` — phase 순서대로 정렬되는지 확인
2. `ls backlog/phase-*.md` — 정렬 확인
3. `sdd status` — 정상 동작 확인
4. `sdd phase list` — 모든 phase 인식 확인

## 🔁 Rollback Plan

- `git revert` 3개 커밋으로 전체 롤백 가능
- 마이그레이션 커밋이 단일이므로 revert도 단일

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship commit
