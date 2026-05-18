# specs/ — 작업 로그 시점

이 디렉토리는 진행 중 / 완료된 **spec 의 산출물 보관소** 입니다. archive 와의 차이: 머지 후 정리 전까지는 `specs/`, 정리 후 `archive/specs/` 로 이동합니다.

## 핵심 주의

- **한국어 산출물**: spec.md / plan.md / task.md / walkthrough.md / pr_description.md / critique.md 모두 한국어로 작성. 코드·파일 경로·표준 기술 용어만 영어 허용.
- **템플릿 강제**: 신규 산출물 작성 시 `.harness-kit/agent/templates/` 의 해당 템플릿을 먼저 *읽고* 따를 것 (constitution §5.4). 템플릿 없이 생성은 CRITICAL VIOLATION.
- **머지 후 immutable**: PR 머지된 spec 의 산출물은 사후 수정하지 않습니다. 새 정보·결정이 있으면 *새 spec* 으로 작성.
- **archive 정책**: `archive/specs/*` 는 grep / 정합성 검사에서 false positive 의 원천. 외부 참조 검색 시 archive 는 건너뛰는 것이 기본 (immutable 보존소).
- **One Task = One Commit**: task.md 의 각 task 는 하나의 commit 에 대응합니다. 일괄 commit 은 CRITICAL VIOLATION.

## 산출물 구조

| 파일 | 역할 |
|---|---|
| `spec.md` | 배경 / 요구사항 / 범위 / DoD |
| `plan.md` | 실행 계약 — 브랜치 전략 / 변경 목록 / 검증 |
| `task.md` | 체크박스 단위 실행 목록 (One Task = One Commit) |
| `walkthrough.md` | 작업 기록 — 결정·협의·검증·발견 (ship 시 작성) |
| `pr_description.md` | PR 본문 (ship 시 작성) |
| `critique.md` | (선택) `/hk-spec-critique` 결과 |
