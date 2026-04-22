# spec-13-06: 업데이트 레지스트리 (update-registry)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-13-06` |
| **Phase** | `phase-13` |
| **Branch** | `spec-13-06-update-registry` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-23 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
harness-kit을 여러 프로젝트에 설치한 경우, 각 프로젝트가 어느 버전을 쓰는지 한눈에 알 방법이 없다. 각 프로젝트의 `.harness-kit/installed.json`을 개별적으로 확인해야 한다.

### 문제점
- 0.6.0 릴리스 후 어느 프로젝트를 업데이트해야 하는지 파악 어려움
- 구버전 harness-kit을 쓰는 프로젝트에서 새 기능 미사용

### 해결 방안 (요약)
`install.sh` 실행 시 `~/.harness-kit-registry.json`에 프로젝트 경로와 버전을 기록한다. `sdd update-check`로 레지스트리를 읽어 현재 kitVersion과 비교 출력한다.

## 🎯 요구사항

### Functional Requirements
1. `install.sh` 실행 시 `~/.harness-kit-registry.json` 에 `{path, version, installedAt}` append/upsert
2. `sdd update-check` 실행 시:
   - 레지스트리 파일 없으면 "레지스트리 없음" 안내 + exit 0
   - 있으면 각 프로젝트의 버전과 현재 kitVersion 비교 출력
   - 구버전 프로젝트에 ⚠ 표시
3. `sdd help`에 `update-check` 항목 추가

### Non-Functional Requirements
1. 레지스트리 쓰기 실패 시 경고만 출력, `install.sh` 성공 처리
2. `jq` 없는 환경에서 graceful skip
3. 경로가 더 이상 존재하지 않는 항목은 `(삭제됨)` 표시

## 🚫 Out of Scope

- 자동 업데이트 (`sdd upgrade` 등)
- 원격 버전 비교 (GitHub API 연동)
- 레지스트리 항목 수동 삭제 명령

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-update-registry.sh`)
- [ ] `install.sh` 실행 시 레지스트리 갱신 확인
- [ ] `sdd update-check` 출력 형식 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-13-06-update-registry` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
