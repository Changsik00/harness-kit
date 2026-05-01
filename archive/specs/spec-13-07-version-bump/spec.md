# spec-13-07: 버전 bump (0.5.0 → 0.6.0)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-13-07` |
| **Phase** | `phase-13` |
| **Branch** | `spec-13-07-version-bump` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-23 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
phase-13에서 hk-doctor, pr-watch, run-test 3가지 DX 개선을 완료했다. `kitVersion`은 여전히 `0.5.0`이다.

### 문제점
완료된 기능이 버전 번호에 반영되지 않아 변경 이력 추적이 어렵고, 다른 프로젝트에 설치 시 이전 버전과 구분이 안 됨.

### 해결 방안 (요약)
`VERSION` 파일, `.harness-kit/installed.json`의 `kitVersion`을 `0.6.0`으로 갱신하고 `CHANGELOG.md`에 phase-13 변경사항을 기록한다.

## 🎯 요구사항

### Functional Requirements
1. `VERSION` 파일: `0.5.0` → `0.6.0`
2. `.harness-kit/installed.json`: `kitVersion` → `0.6.0`
3. `CHANGELOG.md` 작성/갱신: phase-13 변경사항 (hk-doctor, pr-watch, run-test) 기록
4. `sdd version` → `0.6.0` 출력 확인

### Non-Functional Requirements
1. 전체 테스트 스위트 FAIL=0 유지

## 🚫 Out of Scope

- `install.sh`의 로직 변경 (버전 상수는 `VERSION` 파일에서 읽으므로 불필요)
- semver 자동화 스크립트

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `sdd version` → `0.6.0` 확인
- [ ] `CHANGELOG.md` 작성 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-13-07-version-bump` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
