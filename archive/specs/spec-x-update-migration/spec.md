# spec-x-update-migration: update.sh 버전 인식 마이그레이션 시스템

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-update-migration` |
| **Phase** | 없음 (Solo Spec) |
| **Branch** | `spec-x-update-migration` |
| **상태** | Planning |
| **타입** | Feature + Governance |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- `update.sh`가 버전을 확인하지 않고 `install.sh --yes`를 단순 실행함
- 설치 버전과 키트 버전 사이의 gap을 인식하지 못해 폐기된 파일이 잔존할 수 있음
- 신규 기능이 추가되어도 업데이트 시 안내가 없어 사용자가 인지하지 못함
- `CHANGELOG.md`가 없어 버전 간 변경 이력을 추적할 수 없음
- constitution의 Spec ID 규칙이 Phase 소속을 강제하여, Phase 단위 작업이 아닌 소규모 독립 변경에도 불필요한 phase 관리 마찰이 발생함

### 문제점

1. 버전 업 시 `.claude/commands/hk-spec-review.md` 같은 폐기 커맨드가 자동 제거되지 않음
2. 5개 신규 훅 추가 등 기능 변경이 있어도 업데이트 시 사용자에게 전달되지 않음
3. `update.sh`가 `install.sh`를 호출하면서 `phase`/`spec`/`planAccepted` state가 초기화됨 (버그)
4. `spec-x-{slug}` 같은 Solo Spec 패턴이 없어, 작은 자족적 변경도 반드시 Phase에 묶어야 함

### 해결 방안 (요약)

`update.sh`를 버전 인식 마이그레이션 시스템으로 재작성하고, 버전 간 변경사항을 `sources/migrations/` 스크립트로 관리한다. 동시에 constitution에 `spec-x-{slug}` Solo Spec 패턴을 추가하여 Phase 없이 자족적 변경을 진행할 수 있는 경로를 공식화한다.

## 🎯 요구사항

### Functional Requirements

1. `update.sh` 실행 시 이전 설치 버전과 새 버전을 비교하여 출력
2. 버전 구간에 해당하는 `sources/migrations/*.sh` 마이그레이션을 순서대로 실행
3. 마이그레이션 실행 시 폐기 파일 목록 확인 후 삭제 (대화형 또는 `--yes` 자동)
4. 마이그레이션 실행 시 신규 기능 안내 텍스트 출력
5. `install.sh` 호출 전후로 `phase`/`spec`/`planAccepted`/`lastTestPass` state 보존
6. `.harness-backup-*` 구버전 백업 디렉토리 정리 안내 및 선택 삭제
7. `--shell=` 옵션 패스스루 지원 (셸 재선택 가능)
8. `CHANGELOG.md` 신설 — 버전별 추가/변경/제거 이력 관리
9. constitution §4.1, §5.2에 `spec-x-{slug}` Solo Spec 패턴 추가

### Non-Functional Requirements

1. 마이그레이션 스크립트는 `sources/migrations/{version}.sh` 형식으로 확장 가능해야 함
2. `--yes` 플래그로 CI/자동화 환경에서 무인 실행 가능
3. 다운그레이드 시 명시적 확인 프롬프트

## 🚫 Out of Scope

- 마이그레이션 롤백 (git revert로 대응)
- `install.sh` 자체 수정 (state 초기화 로직은 update.sh에서 보완)
- Solo Spec의 queue.md 자동 등록 (수동 관리)

## ✅ Definition of Done

- [ ] `update.sh` 재작성 완료 및 syntax 검증 (`bash -n`)
- [ ] `sources/migrations/0.4.0.sh` 작성 완료
- [ ] `VERSION` 0.4.0, `CHANGELOG.md` 작성 완료
- [ ] `constitution.md` (sources + agent 양쪽) spec-x 패턴 추가
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-x-update-migration` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
