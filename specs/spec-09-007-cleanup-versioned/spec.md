# spec-09-007: 버전별 정리 스크립트 (cleanup.sh)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-09-007` |
| **Phase** | `phase-09` |
| **Branch** | `spec-09-007-cleanup-versioned` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-15 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sources/migrations/0.4.0.sh` 파일이 존재하며 `migration_cleanup()`(삭제할 파일 목록)과 `migration_new_features()`(변경사항 안내 메시지) 함수가 정의되어 있다. 그러나 이 파일을 실제로 호출하는 코드가 없다.

`update.sh`는 현재 uninstall → install → 백업 디렉토리 정리 → doctor 순서로 동작하며, 버전별 마이그레이션 로직이 빠져 있다. 구 커맨드 파일(`.claude/commands/align.md`, `spec-new.md` 등 9개)은 `0.4.0.sh`에 삭제 대상으로 선언되어 있지만 실제로 삭제되지 않는다.

### 문제점

- **migration 인프라 미연동**: `sources/migrations/` 디렉토리와 migration 파일이 존재하지만 어디에서도 호출되지 않는 dead code
- **구 파일 잔재**: v0.3 → v0.4 업데이트 시 구 커맨드 파일이 남아 사용자 혼란 유발
- **버전별 정리 진입점 부재**: 개별 migration을 실행하거나 특정 버전 구간의 정리를 수행할 standalone 스크립트가 없음

### 해결 방안 (요약)

`cleanup.sh`를 신설하여 `sources/migrations/` 의 migration 파일들을 버전 순으로 실행하고, `update.sh`에서 install 후 `cleanup.sh`를 호출하도록 연동한다.

## 🎯 요구사항

### Functional Requirements

1. **`cleanup.sh` 신설**
   - 인자: `--from <ver> --to <ver> [--yes] [TARGET]`
   - `sources/migrations/` 에서 `--from` < ver <= `--to` 범위의 migration 파일을 semver 순으로 실행
   - 각 migration 파일의 `migration_cleanup()` 함수를 source 하여 삭제 대상 파일 목록 획득 → 존재하는 파일만 삭제
   - 각 migration 파일의 `migration_new_features()` 함수를 source 하여 변경사항 메시지 출력
   - `--yes` 없으면 삭제 전 확인 프롬프트

2. **`update.sh` 연동**
   - install 완료 후, state 복원 후, 백업 정리 전에 `cleanup.sh --from $PREV_VER --to $NEW_VER --yes "$TARGET"` 호출
   - cleanup.sh 실패 시 경고만 출력하고 계속 진행 (non-fatal)

3. **migration 파일 규약**
   - 파일명: `{semver}.sh` (예: `0.4.0.sh`)
   - 필수 함수: `migration_cleanup()` — 삭제할 파일 목록 (TARGET 기준 상대경로, 줄 단위)
   - 선택 함수: `migration_new_features()` — 사용자에게 보여줄 변경사항 메시지
   - 파일은 source 되므로 직접 실행 불가 (shebang은 있되 `# 직접 실행하지 마세요` 주석)

4. **기존 `0.4.0.sh` 검증**
   - cleanup.sh에 의해 정상적으로 source 및 실행되는지 확인
   - 나열된 9개 구 커맨드 파일이 존재할 경우 삭제되는지 테스트

### Non-Functional Requirements

1. cleanup.sh 단독 실행 가능 (update.sh 없이도 사용 가능)
2. migration 파일이 0개인 경우 (범위 내 해당 없음) 정상 종료
3. semver 비교는 `sort -V` 활용 (macOS/Linux 호환)

## 🚫 Out of Scope

- 새로운 migration 파일 추가 (기존 `0.4.0.sh`만 검증)
- rollback 기능 (migration은 단방향)
- `install.sh` 변경 (cleanup은 update 전용)

## ✅ Definition of Done

- [ ] `cleanup.sh` 신설 및 단독 실행 가능
- [ ] `update.sh`에서 cleanup.sh 호출 연동
- [ ] `sources/migrations/0.4.0.sh`가 정상 실행되어 구 파일 삭제
- [ ] 테스트: 범위 내 migration 실행, 범위 외 skip, 빈 범위 정상 종료
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-09-007-cleanup-versioned` 브랜치 push 완료
