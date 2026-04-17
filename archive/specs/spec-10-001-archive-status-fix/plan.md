# Implementation Plan: spec-10-001

## 📋 Branch Strategy

- 신규 브랜치: `spec-10-001-archive-status-fix`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] awk 패턴에 `| Done |` 추가 — 기존 `Active`/`In Progress` 매칭에 영향 없음 확인

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **awk 패턴** | 조건에 `\| Done \|` 추가 | 최소 변경으로 버그 수정, 기존 로직 보존 |
| **양쪽 sdd** | sources/bin/sdd + .harness-kit/bin/sdd 동시 수정 | 도그푸딩 환경에서 둘 다 사용되므로 동기화 필수 |
| **상태 전이 주석** | awk 블록 상단에 전이 모델 주석 추가 | 향후 상태 추가 시 누락 방지 |

## 📂 Proposed Changes

### sdd archive 함수

#### [MODIFY] `sources/bin/sdd` — `cmd_archive()` awk 블록 (~line 687)

현재:
```awk
index($0, sid) && (/\| In Progress \|/ || /\| Active \|/) {
  sub(/\| In Progress \|/, "| Merged |")
  sub(/\| Active \|/, "| Merged |")
}
```

변경 후:
```awk
# 상태 전이 모델: Backlog → Active → In Progress → Done → Merged
# archive는 Active/In Progress/Done 어느 상태에서든 Merged로 전환
index($0, sid) && (/\| In Progress \|/ || /\| Active \|/ || /\| Done \|/) {
  sub(/\| In Progress \|/, "| Merged |")
  sub(/\| Active \|/, "| Merged |")
  sub(/\| Done \|/, "| Merged |")
}
```

#### [MODIFY] `.harness-kit/bin/sdd` — 동일 변경 적용

sources/bin/sdd와 동일한 수정을 .harness-kit/bin/sdd에도 적용.

#### [MODIFY] `tests/test-sdd-archive-completion.sh` — Done → Merged 테스트 추가

기존 archive 테스트에 Done 상태 spec의 Merged 전환 시나리오 추가.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-archive-completion.sh
```

### 전체 테스트
```bash
bash tests/run-all.sh
```

### 수동 검증 시나리오
1. phase.md에 `| Done |` 상태 spec이 있는 상태에서 `sdd archive` 실행 → `| Merged |`로 전환 확인
2. `| Active |` 상태 spec에서 `sdd archive` 실행 → 기존대로 `| Merged |` 전환 확인 (회귀 없음)

## 🔁 Rollback Plan

- awk 패턴 1줄 원복으로 즉시 롤백 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
