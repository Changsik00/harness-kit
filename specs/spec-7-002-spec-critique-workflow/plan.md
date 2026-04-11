# Implementation Plan: spec-7-002

## 📋 Branch Strategy

- 신규 브랜치: `spec-7-002-spec-critique-workflow`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 서브에이전트 모델: Opus 사용 동의 (비용 발생)
> - [ ] WebSearch 도구 접근 허용 여부 확인

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **서브에이전트 타입** | `general-purpose` (model: opus) | WebSearch + 파일 읽기 모두 필요 |
| **결과 저장** | `specs/<dir>/critique.md` | spec 산출물과 동일 위치, 리뷰 흔적 보존 |
| **단계 위치** | spec.md 작성 후 / Plan Accept 전 (선택) | Plan 개선에 반영 가능한 시점 |
| **템플릿 섹션** | 선택 작성 (`<!-- optional -->`) | 강제하지 않아 워크플로우 마찰 최소화 |

## 📂 Proposed Changes

### [신규 커맨드]

#### [NEW] `sources/commands/hk-spec-critique.md`

```
1. 현재 spec 확인 (sdd status --json)
2. spec.md 읽기
3. Opus 서브에이전트 호출:
   - 유사 기법 웹 검색
   - 요구사항 누락/모순/과잉 비판
   - 대안 2~3개 + 트레이드오프 + 권장안
4. critique.md 저장
5. 사용자 보고
```

### [agent.md]

#### [MODIFY] `sources/governance/agent.md` + `agent/agent.md`

§4.4 Hard Stop for Review 직후에 추가:

```
### 4.5 Critique Step (Optional)
spec.md 작성 후, Plan Accept 전에 /hk-spec-critique 호출 가능.
결과(critique.md)를 검토하여 spec.md 또는 plan.md 개선에 활용.
```

### [spec 템플릿]

#### [MODIFY] `sources/templates/spec.md` + `agent/templates/spec.md`

Definition of Done 앞에 추가:

```markdown
## 🔍 Critique 결과 (선택)
<!-- /hk-spec-critique 실행 후 핵심 발견사항 요약. 미실행 시 생략 가능. -->
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트
```bash
echo "커맨드 파일 존재 확인"
ls sources/commands/hk-spec-critique.md
```

### 수동 검증 시나리오
1. `/hk-spec-critique` 호출 → spec 없을 때 오류 메시지 확인
2. 활성 spec 있을 때 호출 → critique.md 생성 확인
3. critique.md 내용에 유사 기법 / 비판 / 대안 3섹션 포함 확인

## 🔁 Rollback Plan

- `git revert`로 대응. 커맨드 파일 삭제만으로도 기능 비활성화 가능.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
