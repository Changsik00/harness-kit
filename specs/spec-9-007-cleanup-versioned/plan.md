# Implementation Plan: spec-9-007

## 📋 Branch Strategy

- 신규 브랜치: `spec-9-007-cleanup-versioned`
- 시작 지점: `phase-9-install-conflict-defense`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] cleanup.sh의 `--from`/`--to` semver 비교에 `sort -V` 사용 — macOS `sort`에서 `-V` 지원 확인 필요 (GNU coreutils 설치 시 `gsort -V`, 미설치 시 fallback 필요)

> [!WARNING]
> - [ ] `update.sh` 변경: cleanup.sh 호출 위치가 state 복원 후 / 백업 정리 전

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **semver 비교** | `sort -V` + macOS fallback (`/usr/bin/sort`는 `-V` 미지원 시 숫자 분할 비교) | Homebrew coreutils 없는 환경도 지원 |
| **migration 실행** | source 후 함수 호출 (현재 0.4.0.sh 규약 유지) | 이미 정의된 인터페이스 활용 |
| **에러 처리** | cleanup.sh 자체는 `set -euo pipefail`, update.sh에서는 `|| true`로 non-fatal | 정리 실패가 전체 업데이트를 막지 않도록 |

## 📂 Proposed Changes

### cleanup.sh (신규)

#### [NEW] `cleanup.sh`

버전 구간 기반 migration 실행 스크립트.

```text
인자: --from <ver> --to <ver> [--yes] [TARGET]

동작:
1. sources/migrations/ 에서 *.sh 파일 목록 수집
2. semver 비교로 from < ver <= to 범위 필터링
3. 범위 내 파일을 버전 순으로 순회:
   a. source 하여 migration_cleanup() 함수 획득
   b. 삭제 대상 파일 목록 출력
   c. --yes 없으면 확인 프롬프트
   d. 존재하는 파일만 삭제
   e. migration_new_features() 있으면 메시지 출력
4. 삭제 결과 요약 출력
```

### update.sh (수정)

#### [MODIFY] `update.sh`

state 복원(L107-119) 후, 백업 정리(L121-129) 전에 cleanup.sh 호출 추가.

```text
# ── 4.5 cleanup (버전별 정리) ─────────────────────────
if [ -f "$KIT_DIR/cleanup.sh" ]; then
  log "버전별 정리 실행 중..."
  "$KIT_DIR/cleanup.sh" --from "$PREV_VER" --to "$NEW_VER" --yes "$TARGET" || warn "cleanup 일부 실패 (계속 진행)"
fi
```

### 테스트

#### [NEW] `tests/test-cleanup.sh`

cleanup.sh 단위 테스트:
- 범위 내 migration 실행 확인
- 범위 외 migration skip 확인
- 빈 범위 (동일 버전) 정상 종료
- 존재하지 않는 파일 skip (에러 없음)
- 존재하는 파일 삭제 확인

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-cleanup.sh
```

### 수동 검증 시나리오
1. 임시 디렉토리에 구 커맨드 파일 9개 생성 → `cleanup.sh --from 0.3.0 --to 0.4.0 --yes` → 9개 삭제 확인
2. `cleanup.sh --from 0.4.0 --to 0.4.0` → 아무것도 실행 안 됨 (동일 버전)
3. `update.sh --yes` 실행 → cleanup 단계 로그 출력 확인

## 🔁 Rollback Plan

- cleanup.sh는 파일 삭제만 수행하므로 git 기록에서 복원 가능
- update.sh 연동은 `|| true`이므로 제거해도 기존 동작에 영향 없음

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
