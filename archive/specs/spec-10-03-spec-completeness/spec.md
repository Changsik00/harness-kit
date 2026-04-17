# spec-10-03: active spec 산출물 완성도 검증

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-10-03` |
| **Phase** | `phase-10` |
| **Branch** | `spec-10-03-spec-completeness` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd status`는 active spec이 있을 때 task 진행률만 표시한다. 필수 산출물(spec.md, plan.md, task.md, walkthrough.md, pr_description.md)의 존재 여부를 확인하지 않아, archive 시점에야 누락을 발견한다.

### 문제점

1. **산출물 누락을 늦게 발견**: walkthrough.md나 pr_description.md가 없는 채로 `sdd archive`를 실행하면 그때서야 거부됨. 미리 알았으면 작업 흐름이 끊기지 않음.
2. **현재 작업 단계가 불명확**: spec+plan만 있는지, task까지 있는지, ship-ready인지를 한눈에 알 수 없음.

### 해결 방안 (요약)

`cmd_status`에서 active spec이 있을 때 산출물 체크리스트와 완성도 단계를 표시한다.

## 🎯 요구사항

### Functional Requirements

1. **산출물 체크리스트**: active spec 디렉토리의 필수 파일 존재 여부를 표시:
   `산출물: ✓ spec ✓ plan ✓ task ✗ walkthrough ✗ pr_description`
2. **완성도 단계 표시**: 산출물 조합에 따른 단계 레이블:
   - `Planning` — spec.md + plan.md 존재
   - `Executing` — + task.md 존재
   - `Ship-ready` — + walkthrough.md + pr_description.md 존재
3. `cmd_status`의 Tasks 라인 다음에 산출물 라인 출력.

### Non-Functional Requirements

1. `--brief`, `--json` 모드에서는 산출물 표시 생략.
2. active spec이 없으면 산출물 라인 미출력.

## 🚫 Out of Scope

- 산출물 내용 품질 검증 (placeholder 감지 등 — archive에서 이미 수행)
- `cmd_archive`의 기존 검증 로직 변경

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-10-03-spec-completeness` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
