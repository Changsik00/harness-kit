# spec-x-sdd-bugfix: sdd specx Branch 중복 버그 + 테스트 glob 불일치 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-sdd-bugfix` |
| **Phase** | `phase-x` |
| **Branch** | `spec-x-sdd-bugfix` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | yes |
| **작성일** | 2026-05-19 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd specx new <slug>` 로 spec-x 를 생성하면 `spec.md` 의 Branch 필드가 정상 생성된다. 테스트 `tests/test-uninstall-cmd-list.sh` 는 설치된 커맨드 수를 검증한다.

### 문제점

1. **Branch 중복**: `sdd specx new foo` 실행 시 `spec.md` 의 Branch 필드가 `spec-x-foo-foo` 로 생성됨. 템플릿의 `spec-{phaseN}-{seq}-{slug}` 에서 spec-x 전용 sed 치환이 `{seq}` 와 `{slug}` 를 모두 같은 slug 값으로 교체해 중복 발생.
2. **테스트 glob 불일치**: `test-uninstall-cmd-list.sh` 가 `find sources/commands -name 'hk-*.md'` (14개) 로 기대값을 계산하지만, `install.sh` 는 `*.md` (15개, `hk.md` 포함) 로 설치 — 매 실행마다 `개수 불일치` FAIL.

### 해결 방안

Bug 1: `specx_new()` sed 패턴에 `{seq}-{slug}` → `{slug}` 치환을 선행 추가해 중복 방지. Bug 2: 테스트의 `hk-*.md` 글롭을 `*.md` 로 통일.

## 🎯 요구사항

### Functional Requirements

1. `sdd specx new foo` 실행 후 `spec.md` Branch 필드 = `spec-x-foo` (중복 없음)
2. `tests/test-uninstall-cmd-list.sh` Scenario 1 개수 비교 PASS

### Non-Functional Requirements

1. 기존 일반 spec (`sdd spec new`) Branch 필드 생성에 영향 없음
2. bash 3.2+ 호환 유지

## 🚫 Out of Scope

- 템플릿 구조 변경 (spec.md 템플릿 자체 수정)
- `hk.md` 파일 명칭 변경

## 📑 ADR 후보

- [x] 없음

## ✅ Definition of Done

- [ ] `sdd specx new test-slug` 실행 후 Branch = `spec-x-test-slug` 확인
- [ ] `bash tests/test-uninstall-cmd-list.sh` PASS
- [ ] 기존 회귀 테스트 PASS
- [ ] `walkthrough.md` + `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-sdd-bugfix` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
