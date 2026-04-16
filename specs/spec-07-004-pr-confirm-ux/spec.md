# spec-07-004: PR 확인 UX 일관성

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-07-004` |
| **Phase** | `phase-07` |
| **Branch** | `spec-07-004-pr-confirm-ux` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`hk-gh-pr.md`와 `hk-handoff.md`에서 PR 생성 전 에이전트가 사용자에게 보여주는 정보와 확인 방식이 매번 다르다:

- 어떤 때는 브랜치/제목/타깃을 보여주고, 어떤 때는 생략
- 확인 방식이 "사용자에게 확인을 받습니다" 텍스트만 있고 구체적 형식 없음
- `--no-confirm` 같은 스킵 옵션 없음 — 자동화 시나리오에서 매번 입력 필요

### 문제점

- 사용자가 "내가 뭘 승인하는지" 불명확한 상태에서 PR이 생성될 수 있음
- 실수로 잘못된 base 브랜치에 PR이 생성될 가능성
- 반복 작업(연속 spec 처리)에서 매번 확인 입력이 마찰이 됨

### 해결 방안 (요약)

`hk-gh-pr.md`와 `hk-handoff.md`에 고정 형식의 "PR 확인 블록"을 정의하고, Y/n 프롬프트를 표준화한다. `--no-confirm` 옵션으로 CI/자동화 시나리오에서 스킵 가능하게 한다.

## 🎯 요구사항

### Functional Requirements

1. `hk-gh-pr.md` §4 PR 생성 직전에 고정 형식 "PR 확인 블록" 표시 (항상):
   ```
   🔍 PR 생성 확인
   - 브랜치:    <head> → <base>
   - 제목:      <PR title>
   - 커밋 수:   <N>개
   - 파일 변경: <M>개

   생성할까요? [Y/n]
   ```
2. **긍정 응답**: 거부 표현(`n`, `no`, `아니`, `취소`, `cancel`) 외 모든 응답 → PR 생성 (엔터, `Y`, `y`, `ok`, `go`, `ㅇㅇ`, `해`, `.` 등 포함)
3. **거부 응답**: `n`, `no`, `아니`, `취소`, `cancel` → 중단
4. `--no-confirm` 플래그 지원 — 확인 블록 없이 바로 PR 생성 (자동화/반복 사용 시)
4. `hk-handoff.md` §4 Push 확인 블록도 동일 형식으로 표준화
5. `hk-bb-pr.md`에도 동일한 확인 블록 형식 적용
6. `hk-spec-critique.md` 반영 항목 선택 프롬프트도 동일 긍정/거부 규칙 적용

### Non-Functional Requirements

1. 기본 동작은 항상 확인 — `--no-confirm`은 명시적으로 지정해야만 동작
2. 문서 변경만으로 구현 — 코드/스크립트 변경 없음

## 🚫 Out of Scope

- 실제 `--no-confirm` 파싱 스크립트 구현 (문서 레벨 정의만)
- PR 생성 후 자동 머지
- 리뷰어/라벨 자동 설정

## ✅ Definition of Done

- [ ] `hk-gh-pr.md` §4에 PR 확인 블록 고정 형식 + Y/n + `--no-confirm` 정의 완료
- [ ] `hk-handoff.md` §4에 동일 형식 Push 확인 블록 적용 완료
- [ ] `hk-bb-pr.md`에도 동일 확인 블록 형식 적용 완료
- [ ] `hk-spec-critique.md` 반영 항목 선택 프롬프트 긍정/거부 규칙 적용 완료
- [ ] `sources/`와 `.claude/commands/` 양쪽 반영 완료
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-07-004-pr-confirm-ux` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
