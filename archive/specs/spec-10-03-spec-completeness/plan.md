# Implementation Plan: spec-10-03

## 📋 Branch Strategy

- 신규 브랜치: `spec-10-03-spec-completeness`
- 시작 지점: `phase-10-status-reliability`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 산출물 체크리스트가 `cmd_status` 기본 출력에 추가됨 — 기존 출력 형식 소폭 변경

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **산출물 검사** | `[ -f "$spec_dir/file.md" ]` 단순 존재 검사 | 내용 품질은 archive에서 검증. status는 빠르게 유무만 확인 |
| **단계 레이블** | Planning → Executing → Ship-ready | SDD 워크플로우의 자연스러운 단계와 일치 |
| **출력 위치** | Tasks 라인 다음 | 산출물 상태는 task 진행률과 함께 봐야 의미 있음 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd` — `cmd_status()` (Tasks 라인 이후)

산출물 체크리스트 + 완성도 단계 출력 블록 추가:

```text
  Artifacts:    ✓ spec ✓ plan ✓ task ✗ walkthrough ✗ pr_description (Executing)
```

로직:
```text
if active spec exists:
  for each artifact in [spec.md, plan.md, task.md, walkthrough.md, pr_description.md]:
    check = file exists ? "✓" : "✗"
  stage = determine from artifact combination
  print formatted line
```

### 동기화

#### [MODIFY] `.harness-kit/bin/sdd`

`sources/bin/sdd` 변경 사항을 도그푸딩용으로 복사.

### 테스트

#### [NEW] `tests/test-sdd-spec-completeness.sh`

- 시나리오 1: active spec에 spec.md+plan.md만 → `Planning` 단계, walkthrough/pr_description에 `✗`
- 시나리오 2: +task.md → `Executing` 단계
- 시나리오 3: +walkthrough.md+pr_description.md → `Ship-ready` 단계
- 시나리오 4: active spec 없음 → 산출물 라인 미출력

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-spec-completeness.sh
```

### 전체 회귀 테스트
```bash
# 15개 테스트 파일 전체 실행
for t in tests/test-*.sh; do bash "$t"; done
```

## 🔁 Rollback Plan

- `sources/bin/sdd`의 변경만 revert. 읽기 전용 기능이므로 부작용 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
