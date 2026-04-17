# spec-10-005: 산출물 생성 시점 수정 + walkthrough 템플릿 개선

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-10-005` |
| **Phase** | `phase-10` |
| **Branch** | `spec-10-005-artifact-timing-fix` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd spec new`가 5개 산출물(spec, plan, task, walkthrough, pr_description)을 모두 템플릿에서 복사하여 생성한다. walkthrough 템플릿은 검증 결과 위주이고, 작업 중 결정/협의 기록 용도가 부족하다.

### 문제점

1. **walkthrough/pr_description 조기 생성**: spec 생성 시점에 이미 파일이 존재하여, Artifacts 체크에서 `Ship-ready`로 오판. 실제로는 내용이 템플릿 placeholder 상태.
2. **walkthrough 용도 부족**: 현재 "무엇을 했고 어떻게 검증했는지"에만 집중. 작업 중 이슈 발생 → 결정 기록, 사용자와 협의한 내용 기록이 누락됨.

### 해결 방안 (요약)

`sdd spec new`에서 walkthrough/pr_description 생성을 제외하고, walkthrough 템플릿에 결정 기록 + 사용자 협의 섹션을 추가한다.

## 🎯 요구사항

### Functional Requirements

1. **`sdd spec new` 수정**: walkthrough.md, pr_description.md를 생성하지 않음. spec, plan, task만 생성.
2. **walkthrough 템플릿 개선**:
   - `📌 결정 기록` 섹션 추가 — 작업 중 이슈 발생 시 결정 사항과 이유 기록
   - `💬 사용자 협의` 섹션 추가 — 사용자와 논의한 내용 및 합의 사항 기록
   - 기존 `🔍 발견 사항`을 Optional에서 일반 섹션으로 승격
3. **Artifacts 체크 정상화**: walkthrough/pr_description이 Ship 시점에만 생성되므로, Executing 단계에서 `✗`로 정확히 표시.

### Non-Functional Requirements

1. 기존에 이미 생성된 spec 디렉토리에는 영향 없음 (신규 spec부터 적용)
2. `sdd archive`의 기존 검증 로직 변경 없음

## 🚫 Out of Scope

- pr_description 템플릿 내용 변경 (현재 내용으로 충분)
- `sdd archive` 리네이밍 (Icebox)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-10-005-artifact-timing-fix` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
