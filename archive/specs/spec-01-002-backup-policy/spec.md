# spec-01-002: .harness-backup 보존 정책

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-01-002` |
| **Phase** | `phase-01` |
| **Branch** | `spec-01-002-backup-policy` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh` 실행 시 `--force` 옵션이 없으면 매번 `.harness-backup-TIMESTAMP/` 디렉토리를 생성한다. 도그푸딩 하루 만에 6개(804KB)가 누적되었고, 보존 정책이 없어 사용자가 직접 삭제해야 한다.

### 문제점

- **무한 누적**: 오래된 백업을 자동 삭제하지 않음
- **실효성 의문**: git history에 이미 모든 이력이 있으므로 백업의 가치가 낮음
- **git-aware 아님**: 워킹 트리가 clean이어도 무조건 백업 생성

### 해결 방안 (요약)

1. 최근 N개(기본 3)만 유지하는 보존 정책 추가
2. git clean 상태일 때 백업 스킵하는 옵션
3. `--no-backup` 옵션 추가

## 🎯 요구사항

### Functional Requirements

1. install.sh 백업 완료 후, `.harness-backup-*` 디렉토리가 `HARNESS_BACKUP_KEEP` (기본 3)개를 초과하면 오래된 것부터 자동 삭제
2. `--no-backup` 옵션 추가: 사용자가 명시적으로 백업을 건너뛸 수 있음
3. git 워킹 트리가 clean이고 harness 관련 파일이 모두 committed 상태이면 백업을 스킵하고 로그 출력

### Non-Functional Requirements

1. 기존 `--force` 옵션과 충돌 없음 (`--force`는 백업 자체를 안 함, `--no-backup`도 동일하지만 의미가 다름)
2. 삭제 대상 백업 목록을 로그로 출력하여 사용자에게 투명성 제공

## 🚫 Out of Scope

- 백업 내용의 diff/merge 기능
- 백업 압축(tar.gz) 전환
- 원격 백업

## ✅ Definition of Done

- [ ] install.sh 5회 반복 실행 후 `.harness-backup-*` 최대 3개
- [ ] `--no-backup` 옵션 동작 확인
- [ ] git clean 상태에서 백업 스킵 확인
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-01-002-backup-policy` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
