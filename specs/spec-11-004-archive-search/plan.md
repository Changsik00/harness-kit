# Implementation Plan: spec-11-004

## 📋 Branch Strategy

- 신규 브랜치: `spec-11-004-archive-search`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] archive fallback이 적용되는 함수와 적용되지 않는 함수의 구분이 명확한지

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **탐색 방식** | 각 함수에서 `$SDD_ROOT/archive/specs` / `archive/backlog` 를 추가 glob | 중앙 변수보다 함수별 명시가 안전 |
| **표시 방식** | `(archived)` 텍스트 마커 | 색상만으로는 불충분, grep 가능해야 함 |
| **제외 범위** | `compute_next_spec`, `cmd_ship`, `spec_new`, `cmd_archive` | active 작업 흐름에 archive가 개입하면 안 됨 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd`

1. **`spec_list`**: `archive/specs/` glob 추가, archived 항목에 `(archived)` 표시
2. **`phase_list`**: `archive/backlog/phase-*.md` 추가 탐색, archived phase에 `(archived)` 표시, spec count에 archive 포함
3. **`phase_show`**: phase.md를 `archive/backlog/`에서도 찾기, spec dirs를 `archive/specs/`에서도 찾기
4. **`spec_show`**: spec dir를 `archive/specs/`에서도 찾기
5. **`status --verbose`**: archive된 spec 수 별도 표시
6. **`_status_diagnose`**: archive 항목 수 진단 표시

#### [MODIFY] `.harness-kit/bin/sdd`
도그푸딩 동기화

### 테스트

#### [NEW] `tests/test-sdd-archive-search.sh`
- Check 1: `sdd spec list` — archive된 spec이 `(archived)` 표시로 목록에 포함
- Check 2: `sdd phase list` — archive된 phase가 `(archived)` 표시로 포함
- Check 3: `sdd phase show N` — archive된 phase 상세 표시 가능
- Check 4: `sdd status` — archive 항목 수 진단 포함

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-archive-search.sh
bash tests/test-sdd-dir-archive.sh
bash tests/test-sdd-ship-completion.sh
```

## 🔁 Rollback Plan

- `git revert` 단일 커밋으로 롤백 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship commit
