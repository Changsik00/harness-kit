# Walkthrough: spec-x-archive-include-specx

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| spec-x archive 자격 판정 기준 | (A) queue.md `done` 섹션 등록 / (B) PR 머지 여부 (gh CLI) / (C) 전체 일괄 인자 | (A) | 기존 phase 흐름과 동일 게이트, 외부 도구 의존 없음, `sdd specx done` 호출이 자연스러운 자격 부여 시점 |
| `--keep=N` 의 spec-x 적용 여부 | spec-x 도 keep 적용 / spec-x 는 keep 영향 없음 | spec-x 영향 없음 | spec-x 에는 phase 같은 시간/순서 개념이 없어 `--keep=N` 의미가 모호. all-or-nothing 이 단순 |
| Check 7 fixture: queue.md 에 phase 행 없는 상태에서 spec-x 만 등록 | queue.md 에 dummy phase 추가 / phase 없이 spec-x 만 | phase 없이 spec-x 만 | 실제 사용 패턴 (phase 일시적 비어있음) 을 반영, 코드의 조기 return 에지 케이스 함께 검증 |
| Task 4 에서 발견된 .gitignore install drift | 이번 spec 에 포함 / 별도 spec-x 분리 / -f 우회 | 이번 spec 에 포함 | N3 (sync 일관성) 충족 위해 필수, 단일 commit 에 명시적으로 묶음 |

## 💬 사용자 협의

- **주제**: archive 자격 판정 기준 결정
  - **사용자 의견**: 별도 명시 없음 — Recommendation 옵션 (A) 수용
  - **합의**: queue.md done 섹션 기반. `sdd specx done <slug>` 호출이 archive 자격 게이트.

- **주제**: .gitignore install drift 처리
  - **사용자 의견**: "Task 4 범위 확장 (Recommended)" 선택
  - **합의**: 잡음을 이 PR 의 sync commit 에 함께 revert. 별도 spec-x 로 분리하지 않음.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-dir-archive.sh`
- **결과**: ✅ Passed — PASS=14 / FAIL=0
- **로그 요약**:
```text
Check 4: done 섹션 미등록 spec-x 디렉토리는 보존됨  → PASS (의미 변경, 본문 그대로)
Check 7: done 섹션 등록 spec-x 는 archive 됨        → PASS (신규)
Check 8: done 섹션 등록 + --dry-run 시 이동 안 됨    → PASS (신규)
결과: PASS=14  FAIL=0
```

#### 회귀 테스트 (영향 가능 영역)
- `bash tests/test-sdd-archive-search.sh` → ✅ PASS=11 / FAIL=0
- `bash tests/test-sdd-status-cross-check.sh` → ✅ PASS=7 / FAIL=0

### 2. 수동 검증

1. **Action**: `bash -n sources/bin/sdd`
   - **Result**: syntax OK
2. **Action**: TDD Red — 테스트 먼저 추가하여 PASS=11 / FAIL=3 확인 (Check 7 의 2개 + Check 8 의 1개 fail)
   - **Result**: 예상대로 fail. 발견: queue.md 에 phase 행이 없을 때 cmd_archive 가 조기 return 함 (`완료된 phase 가 없습니다.`) — 구현 시 spec-x 도 검사하도록 조건 갱신 필요.
3. **Action**: TDD Green — `cmd_archive` 에 `done_specx` 추출 + 별도 수집 루프 추가
   - **Result**: 14/14 PASS. 조기 return 조건은 `phases && specx 모두 비어있을 때만` 으로 확장.
4. **Action**: `cp sources/bin/sdd .harness-kit/bin/sdd` (도그푸딩 sync)
   - **Result**: `git add` 가 `.gitignore` 의 `.harness-kit/` 라인에 의해 차단됨 → 사용자 결정 후 .gitignore revert + 추가 untracked 산출물 (`.harness-kit/hooks/pre-commit.sh`) 함께 수습.

## 🔍 발견 사항

- **`.gitignore` install drift 가 dogfood sync 를 조용히 망가뜨리고 있었음**: `.harness-kit/` 무시 라인이 PR #96 산출물인 `.harness-kit/hooks/pre-commit.sh` 를 untracked 상태로 가두고 있었다. 본 PR 에서 revert 하면서 동시에 hooks 도 tracked 로 전환. 향후 동일 drift 가 재발하지 않도록 install.sh 의 .gitignore 처리 로직 점검이 필요할 수 있음 → 별도 작업 후보.
- **cmd_archive 의 조기 return 조건이 spec-x 도입 시 까다로움**: `done_phases` 만 비어있어도 즉시 종료하던 구조였음. `done_specx` 가 비어있을 때만 종료하도록 조합 조건으로 확장. 향후 archive 종류가 더 늘어나면 (예: phase-x 같은 가상 묶음) 통합 카운터 패턴으로 리팩토링 검토.
- **`sdd status` 진단 메시지의 정확도**: 이전엔 spec-x 만 있는 specs/ 에 "sdd archive 로 정리 가능" 안내가 거짓이었음. 본 PR 머지 후엔 사용자가 `sdd specx done <slug>` 한 항목에 한해 진실이 됨. 완전한 정확도 (`done 등록된 N개만 archive 가능`) 는 별개 polish.

## 🚧 이월 항목

- `.claude/settings.json` 의 deny 규칙 추가 (`~/.aws`, `~/.config/gcloud`, `~/.gnupg`, `~/.ssh`) — 보안 강화 가치 있음, 별도 검토.
- `.harness-kit/installed.json` 의 메타 갱신 (kitVersion 0.6.2→0.7.0 등) — `update.sh` / `/hk-update` 자동 결과, 별도 commit.
- install.sh 가 `.gitignore` 에 잡음을 추가하지 않는지 점검 — 본 PR 에서 revert 한 잡음의 출처 확인 필요.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 |
| **최종 commit** | (Ship commit 후 갱신) |
