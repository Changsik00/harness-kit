# spec-21-03: Intent 블록 커맨드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-21-03` |
| **Phase** | `phase-21` |
| **Branch** | `spec-21-03-intent-block` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-06-13 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

spec-21-02 에서 `post-commit-verify.sh` 가 `installed.json` 의 `.precheck[]` 배열을 실행한다.
그러나 precheck 는 **프로젝트 전역 설정**이어서, 지금 이 작업만을 위한 빠른 검증 커맨드를 임시로 지정할 수 없다.

### 문제점

세션-로컬한 의도(`goal`)와 검증 커맨드(`test`)를 선언할 방법이 없다.
Turbo 모드에서 "지금 무엇을 하려는가"를 기록하면, 사람과 Claude 모두 컨텍스트를 공유할 수 있다.

### 해결 방안 (요약)

`sdd intent` 서브커맨드로 `.claude/state/intent.yaml` 을 생성/조회/삭제한다.
`post-commit-verify.sh` 가 intent.yaml 의 `test` 필드를 precheck 보다 우선 실행한다.
intent 없으면 기존 precheck fallback — 하위 호환 유지.

## 🎯 요구사항

### Functional Requirements

1. `sdd intent "<목표>"` — intent.yaml 에 goal 만 기록 (test/files 생략 가능)
2. `sdd intent "<목표>" --test "<커맨드>"` — goal + test 기록
3. `sdd intent "<목표>" --files "<a,b,c>"` — goal + files 기록 (쉼표 구분)
4. `sdd intent show` — 현재 intent.yaml 내용 출력 (없으면 안내)
5. `sdd intent clear` — intent.yaml 삭제
6. `post-commit-verify.sh`: intent.yaml 에 `test` 필드가 있으면 precheck 대신 intent.test 실행
7. `sdd status` 에 Active Intent goal 한 줄 표시
8. `sources/bin/sdd` + `sources/hooks/post-commit-verify.sh` 동일 변경 미러링

### Non-Functional Requirements

1. bash 3.2+ 호환 — yq 미설치 환경에서도 동작 (grep/sed 로 파싱)
2. intent.yaml 없으면 기존 precheck 동작 완전 보존 — 하위 호환
3. intent.yaml 은 `.claude/state/intent.yaml` 에 위치 (gitignore 고려)

## 🚫 Out of Scope

- `check-scope.sh` 에서 intent.files 를 scope 검증에 사용
- intent.yaml 의 JSON Schema / 복잡한 유효성 검사
- `/hk-intent` 슬래시 커맨드 — spec-21-04

## 📑 ADR 후보

- [ ] 없음

## 🔗 관련 문서

- 관련 spec: `specs/spec-21-01-mode-schema/`, `specs/spec-21-02-turbo-hooks/`
- 관련 phase: `backlog/phase-21.md`

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-intent-block.sh`)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-21-03-intent-block` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
