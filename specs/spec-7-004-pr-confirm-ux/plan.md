# Implementation Plan: spec-7-004

## 📋 Branch Strategy

- 신규 브랜치: `spec-7-004-pr-confirm-ux`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 확인 블록 항목 확인 — 브랜치, 제목, 커밋 수, 파일 변경 수 (4가지)

## 🎯 핵심 전략 (Core Strategy)

### PR 확인 블록 고정 형식

```
🔍 PR 생성 확인
- 브랜치:    <head> → <base>
- 제목:      <PR title>
- 커밋 수:   <N>개
- 파일 변경: <M>개

생성할까요? [Y/n]
```

- **[Y/n]**: 대문자 Y = 기본값. 엔터 포함 거부 표현 외 모든 응답 → 진행
- **거부 표현**: `n`, `no`, `아니`, `취소`, `cancel` → 중단
- **`--no-confirm`**: 확인 블록 자체를 생략하고 바로 실행

### Push 확인 블록 고정 형식 (hk-handoff)

```
🔍 Push 확인
- 브랜치: <current-branch> → origin
- 커밋 수: <N>개 (push 예정)

push 할까요? [Y/n]
```

동일한 긍정/거부 규칙 적용.

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **확인 블록** | 커맨드 §4 바로 앞에 삽입 | PR 생성 직전 마지막 확인 지점 |
| **--no-confirm** | 커맨드 호출 시 옵션으로 전달 | 기본은 항상 확인, 자동화에서만 스킵 |
| **적용 범위** | hk-gh-pr + hk-handoff + hk-bb-pr | 3개 PR 관련 커맨드 통일 |

## 📂 Proposed Changes

### [MODIFY] `sources/commands/hk-gh-pr.md` + `.claude/commands/hk-gh-pr.md`

§4 PR 생성 앞에 확인 블록 절차 추가:

```text
### 4. PR 확인 (사용자 승인)

`--no-confirm` 옵션이 없는 경우, 다음 블록을 표시하고 응답 대기:

🔍 PR 생성 확인
- 브랜치:    <head> → <base>
- 제목:      <PR title>
- 커밋 수:   <N>개
- 파일 변경: <M>개

생성할까요? [Y/n]

거부(n/no/아니/취소/cancel) 시 중단. 그 외 모든 응답(엔터, Y, ok, go, ㅇㅇ, 해, . 등) → PR 생성 진행.
```

### [MODIFY] `sources/commands/hk-handoff.md` + `.claude/commands/hk-handoff.md`

§4 Push 확인 절차를 고정 블록으로 교체:

```text
### 4. Push 확인 (사용자 승인)

`git log --oneline origin/<branch>..HEAD` 로 커밋 수 확인 후:

🔍 Push 확인
- 브랜치: <current-branch> → origin
- 커밋 수: <N>개 (push 예정)

push 할까요? [Y/n]

거부(n/no/아니/취소/cancel) 시 중단. 그 외 모든 응답 → push 진행.
```

### [MODIFY] `sources/commands/hk-bb-pr.md` + `.claude/commands/hk-bb-pr.md`

동일한 확인 블록 형식 적용.

### [MODIFY] `sources/commands/hk-spec-critique.md` + `.claude/commands/hk-spec-critique.md`

반영 항목 선택 프롬프트에 긍정/거부 규칙 명시:

```text
→ 반영할 항목 번호를 입력하거나 "all" / "none"을 선택하세요.
  거부(n/no/아니/취소/cancel/none) 외 모든 응답 → 긍정으로 처리
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트

```bash
# 거버넌스/커맨드 문서 변경만 — 자동화 테스트 없음
echo "수동 검증으로 대체"
```

### 수동 검증 시나리오

1. `hk-gh-pr.md` §4 확인 블록 존재 여부 + `--no-confirm` 옵션 명시 확인
2. `hk-handoff.md` §4 Push 확인 블록 형식 일치 확인
3. `hk-bb-pr.md` 동일 형식 확인
4. `sources/`와 `.claude/commands/` 양쪽 반영 여부 확인

## 🔁 Rollback Plan

- 문서 변경만이므로 git revert로 즉시 복구 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
