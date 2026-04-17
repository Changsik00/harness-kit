# Implementation Plan: spec-10-004

## 📋 Branch Strategy

- 신규 브랜치: `spec-10-004-phase-done-accuracy`
- 시작 지점: `phase-10-status-reliability`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `_check_phase_all_merged` Done 카운트 추가로 phase-ship 유도 타이밍 변경
> - [ ] `compute_next_spec`에서 Done spec 우선 반환 — NEXT 안내가 달라짐

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **`_check_phase_all_merged`** | `$5` 필드로 `Merged` 아닌 모든 상태 카운트 | `-F'\|'` 환경에서 `$0` 패턴 매칭이 불안정. `$5` 직접 비교가 확실 |
| **`compute_next_spec`** | Done 우선, Backlog 다음 | Done은 archive만 하면 되므로 가장 빨리 처리 가능 |
| **git 기반 판별** | `_check_phase_all_merged`에서 git log 교차 확인 | phase.md가 부정확해도 실제 머지 여부로 판단 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd` — `_check_phase_all_merged()` (라인 883~905)

기존 awk를 `$5` 필드 비교로 전환. `Done` 포함:
```text
in_t {
  id = $2; gsub(/[[:space:]]/, "", id); gsub(/`/, "", id)
  st = $5; gsub(/[[:space:]]/, "", st)
  if (id != "" && id !~ /^-+$/ && id !~ /^ID$/ && st != "Merged" && st != "") count++
}
```

+ git 기반 교차 확인: phase.md에 non-Merged가 남아있지만 git log에 모두 머지됨 → 추가 안내.

#### [MODIFY] `sources/bin/sdd` — `compute_next_spec()` (라인 190~204)

Done 우선 검색 추가:
```text
# 1차: Done 상태 (archive 필요) 우선
# 2차: Backlog 상태 (새 작업)
```

### 동기화

#### [MODIFY] `.harness-kit/bin/sdd`
도그푸딩 동기화.

### 테스트

#### [NEW] `tests/test-sdd-phase-done-accuracy.sh`

- 시나리오 1: Done 잔류 시 "모든 Merged" 미출력
- 시나리오 2: 모든 spec Merged → "모든 Merged" 출력
- 시나리오 3: Done spec + Backlog spec → NEXT가 Done spec (archive 우선)
- 시나리오 4: git에 모든 spec 머지됨 + phase.md에 Done 잔류 → git 기반 안내

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-phase-done-accuracy.sh
```

### 전체 회귀 테스트
```bash
for t in tests/test-*.sh; do bash "$t"; done
```

## 🔁 Rollback Plan

- `sources/bin/sdd`의 두 함수 변경만 revert. 읽기 전용 함수이므로 부작용 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
