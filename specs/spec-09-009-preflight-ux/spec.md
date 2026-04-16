# spec-09-009: preflight UX — 설치/업데이트 전 사전 스캔 요약

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-09-009` |
| **Phase** | `phase-09` |
| **Branch** | `spec-09-009-preflight-ux` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-15 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`는 설치 계획(디렉토리, 파일 목록)을 보여주고 확인을 받지만, 기존 환경에 대한 **충돌/위험 스캔**은 하지 않는다. `update.sh`는 버전 전환만 표시하고 바로 진행한다. 문제가 있으면 설치/업데이트 도중이나 사후에야 발견된다.

### 문제점

- 설치 전 기존 디렉토리/파일 충돌 여부를 사용자가 사전에 알 수 없음
- update 시 version downgrade를 감지하지 않음
- 문제 발생 시 롤백이 어렵거나 수동 개입 필요

### 해결 방안 (요약)

`install.sh`와 `update.sh`의 기존 사전 점검 섹션을 확장하여 preflight 스캔을 inline으로 추가한다. 별도 `preflight.sh` 파일 없이 각 스크립트 내부에 직접 작성한다.

## 🔍 Critique 결과

> `/hk-spec-critique` 실행 결과 5건 반영 (전체: `specs/spec-09-009-preflight-ux/critique.md`)

- **구조 변경**: `sources/bin/lib/preflight.sh` 별도 파일 → inline (공통 로직이 1개뿐, 과잉 추상화)
- **semver 비교**: `cleanup.sh`의 `semver_lt()` 패턴 재사용
- **hooks 충돌 조건**: `.claude/settings.json` 존재 → `hooks` 키 존재로 구체화
- **state 검증 제거**: update preflight에서 state 파일 검증 대신 복원 로직의 graceful fallback으로 대체
- **v0.3 오탐 방지**: `agent/constitution.md` 또는 `scripts/harness/bin/sdd` 등 harness-kit 고유 파일로 감지

## 🎯 요구사항

### Functional Requirements

1. **install.sh preflight 스캔** (기존 사전 점검 섹션 확장)
   - 기존 harness-kit 설치 감지 (`.harness-kit/installed.json` 존재 → ⚠ "이미 설치됨, update.sh 사용 권장")
   - v0.3 구 레이아웃 감지 (`agent/constitution.md` 또는 `scripts/harness/bin/sdd` 존재 → ⚠ "v0.3 잔재 발견, update.sh로 마이그레이션 권장")
   - `.claude/settings.json`에 `hooks` 키가 있는 경우 ℹ "기존 hooks 설정 있음 (키트가 덮어씀)"
   - 스캔 결과를 요약 블록으로 출력
   - 경고(⚠) 항목이 있으면 추가 확인 프롬프트 (`--yes`/`--force`/`--dry-run` 시 자동 진행)

2. **update.sh preflight 스캔** (버전 표시 후, 확인 전)
   - version downgrade 감지: `semver_lt()` 함수로 NEW_VER < PREV_VER 비교 → ⚠ 경고
   - v0.3 구 레이아웃 잔재 감지 (install과 동일 조건 → cleanup 대상 안내)
   - 스캔 결과를 동일한 요약 블록 형식으로 출력

3. **update.sh state 복원 graceful fallback**
   - state 복원 시 `jq` 파싱 실패하면 경고 출력 후 기본값으로 초기화 (기존: 실패 시 에러)

### Non-Functional Requirements

1. `--yes` 플래그 시 preflight 경고가 있어도 자동 진행 (경고는 출력)
2. `--dry-run` 시에도 preflight 스캔 실행
3. 별도 파일 추출 없음 — 각 스크립트 내부에 inline

## 🚫 Out of Scope

- `sources/bin/lib/preflight.sh` 공통 라이브러리 (critique에서 YAGNI 판정)
- ERROR 레벨 차단 (경고만, 차단 안 함)
- CI용 기계 판독 출력
- doctor.sh 통합

## ✅ Definition of Done

- [ ] `install.sh`에 preflight 스캔 단계 추가
- [ ] `update.sh`에 preflight 스캔 단계 + state 복원 fallback 추가
- [ ] 테스트: preflight 경고 출력 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-09-009-preflight-ux` 브랜치 push 완료
