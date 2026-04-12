# spec-x-tool-guidance: 프로젝트 품질 도구 점검 및 설치 안내

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-tool-guidance` |
| **Phase** | 없음 (Solo Spec) |
| **Branch** | `spec-x-tool-guidance` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-12 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

harness-kit은 SDD 프로세스에서 ship 전 lint/test 실행을 요구한다(`hk-ship.md` 품질 게이트). 그러나 대상 프로젝트에 lint나 test가 설정되어 있는지 검증하는 단계가 없다.

### 문제점

- **누락 가능성**: 프로젝트에 eslint, prettier, jest 등이 설정되지 않은 채로 harness-kit을 설치하면, ship 시 품질 게이트가 무의미해짐
- **안내 부재**: `doctor.sh`가 harness-kit 설치 상태만 점검하고, 프로젝트 자체의 개발 도구 설정은 확인하지 않음
- **stack adapter 제거 후 공백**: 이전에는 stack adapter가 lint/test 명령을 제공했지만, 제거 후 이 영역이 비어 있음

### 해결 방안 (요약)

`doctor.sh`에 프로젝트 품질 도구 점검 섹션을 추가한다. lint, test, typecheck 설정이 없으면 warn으로 안내한다. 차단(fail)이 아닌 안내(warn) — 프로젝트 초기 단계에서는 아직 설정이 없을 수 있으므로.

## 🎯 요구사항

### Functional Requirements

1. **`doctor.sh`에 품질 도구 점검 섹션 추가**
   - Node.js 프로젝트(`package.json` 존재): `scripts.test`, `scripts.lint` 유무 확인
   - Python 프로젝트(`pyproject.toml` 또는 `setup.py` 존재): pytest/ruff/mypy 등 설정 유무 확인
   - Go 프로젝트(`go.mod` 존재): `go test` 가능 여부 (기본 내장이므로 pass)
   - 기타/감지 불가: "프로젝트 타입을 감지할 수 없습니다. lint/test 설정을 확인하세요" warn

2. **점검 항목 (warn 수준)**
   - Linter 설정 여부 (eslint, prettier, ruff, golangci-lint 등 설정 파일)
   - Test 스크립트/프레임워크 설정 여부
   - Type checker 설정 여부 (tsconfig.json, mypy, 등)

3. **안내 메시지에 설치 가이드 포함**
   - warn 시 "설치 방법" 한 줄 힌트 제공 (예: `npm install --save-dev eslint`)

### Non-Functional Requirements

1. warn으로만 안내 — fail로 차단하지 않음
2. 프로젝트 타입 감지는 파일 존재 여부로만 판단 (package.json, go.mod 등)
3. 기존 doctor.sh 섹션 번호 체계 유지 (새 섹션 추가 시 총 섹션 수 조정)

## 🚫 Out of Scope

- 자동 설치 (사용자가 직접 설치해야 함)
- 특정 lint/test 도구 강제 (프로젝트 선택에 맡김)
- CI/CD 파이프라인 점검

## ✅ Definition of Done

- [ ] `doctor.sh`에 품질 도구 점검 섹션 추가
- [ ] Node.js, Python, Go 프로젝트 타입별 점검 동작 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-x-tool-guidance` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
