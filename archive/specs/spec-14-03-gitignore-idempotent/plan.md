# Implementation Plan: spec-14-03

## 📋 Branch Strategy

- 신규 브랜치: `spec-14-03-gitignore-idempotent`
- 시작 지점: `main` (PR #77 머지 직후)
- 첫 task 가 브랜치 생성을 수행
- 첫 commit 에 다음 변경분 포함:
  - `backlog/queue.md` — sdd spec new 결과 active 갱신
  - `backlog/phase-14.md` — sdd:specs 마커에 spec-14-03 행 수동 추가 (sdd 가 sync 못함, 근본 원인은 spec-14-04)
  - `specs/spec-14-03-gitignore-idempotent/` — spec/plan/task

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 라인별 멱등 로직 채택 — `# harness-kit` 헤더 grep 단일 의존을 4 라인 각각 라인별 grep 으로 분해. 동작 변화는 "현재 정상 동작 케이스" 에서 0, "누락/중복 케이스" 에서만 다름.

> [!WARNING]
> - [ ] `install.sh` 는 다양한 사용자 프로젝트에 직접 영향. 회귀 테스트 시나리오를 충분히 다양화 (재install / 헤더 누락 / 라인 일부 누락 / 사용자 사전 라인 / 토글) 필요.

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
[변경 전] _hk_section_exists ? skip 4 lines : append 4 lines
                                    └─ "헤더 누락 + 라인 존재" 시 중복 위험

[변경 후] for line in [header, hk_line, backup_line, state_line]:
              if not exact_match_in_file(line):
                  append(line)
          # 토글: .harness-kit/ ↔ !.harness-kit/ 은 sed 로 변환 후 라인별 ensure
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **헤더 (`# harness-kit`)** | 단독 라인별 grep + ensure | 헤더만 수동 삭제 케이스 보강 |
| **`.harness-kit/` / `!.harness-kit/`** | sed 변환 (토글) + ensure | --gitignore ↔ --no-gitignore 전환 시에도 멱등 |
| **`.harness-backup-*/`, `.claude/state/`** | 라인별 grep + ensure | 사용자가 일부만 지운 케이스 보강 |
| **헬퍼 함수 위치** | `install.sh` 내부 (block-scoped) | 단일 사용처 — sources/install/lib/ 같은 디렉토리 신규 도입은 over-engineering |
| **bash 호환** | `grep -qE`, `echo`, `sed -i.tmp` 만 사용 | 3.2 호환 (spec-14-02 정책) |

## 📂 Proposed Changes

### install.sh 멱등화

#### [MODIFY] `install.sh:402-445`

`# 16. .gitignore 업데이트` 블록을 라인별 멱등 로직으로 재작성:

```bash
# ============================================================
# 16. .gitignore 업데이트 (라인별 멱등)
# ============================================================
log ".gitignore 갱신"
GI="$TARGET/.gitignore"
if [ $DRY_RUN -eq 1 ]; then
  echo "${C_DIM}[dry-run]${C_RST} .gitignore 에 harness-kit 항목 추가 (라인별 멱등)"
else
  touch "$GI"

  # 헬퍼: 정확 매치 grep 후 부재 시 append
  _gi_ensure() {
    local pattern="$1" line="$2"
    if ! grep -qE "$pattern" "$GI" 2>/dev/null; then
      echo "$line" >> "$GI"
    fi
  }

  # gitignore 옵션 토글 — .harness-kit/ ↔ !.harness-kit/
  if [ $HK_GITIGNORE -eq 1 ]; then
    sed -i.tmp 's|^!\.harness-kit/$|.harness-kit/|' "$GI" && rm -f "${GI}.tmp"
    _hk_pat='^\.harness-kit/$';   _hk_line='.harness-kit/'
  else
    sed -i.tmp 's|^\.harness-kit/$|!.harness-kit/|' "$GI" && rm -f "${GI}.tmp"
    _hk_pat='^!\.harness-kit/$';  _hk_line='!.harness-kit/'
  fi

  # 헤더는 다른 라인보다 먼저 — 빈 줄 + 헤더 한 번
  if ! grep -qE '^# harness-kit$' "$GI" 2>/dev/null; then
    [ -s "$GI" ] && echo "" >> "$GI"
    echo "# harness-kit" >> "$GI"
  fi

  # 4 라인 각각 라인별 ensure
  _gi_ensure "$_hk_pat"                "$_hk_line"
  _gi_ensure '^\.harness-backup-\*/$'  '.harness-backup-*/'
  _gi_ensure '^\.claude/state/$'       '.claude/state/'

  ok ".gitignore 갱신"
fi
```

> **불변량**: 본 블록 종료 후 `.gitignore` 에서 4 라인 (헤더 + 3 항목) 각각이 정확히 `grep -c` 로 1 회.

### 회귀 테스트

#### [NEW] `tests/test-gitignore-idempotent.sh`

기존 `test-gitignore-config.sh` 의 D 시나리오 (재설치 멱등) 를 확장하여 다음 케이스 검증:

1. **D-1 ~ D-4**: 첫 install 후 4 라인 (헤더 + .harness-kit/ + .harness-backup-*/ + .claude/state/) 각각 정확히 1 회.
2. **D-5 ~ D-8**: 재install (동일 옵션) 후 4 라인 각각 정확히 1 회 (변화 없음).
3. **E**: 헤더만 수동 삭제 → 재install → 4 라인 각각 정확히 1 회 (헤더 복원, 라인 중복 없음).
4. **F**: 사용자가 미리 `.harness-kit/` 적은 후 첫 install → `.harness-kit/` 정확히 1 회 + 헤더 + 다른 2 라인.
5. **G**: `.harness-backup-*/` 만 지운 후 재install → `.harness-backup-*/` 보강 + 다른 라인 변화 없음.
6. **H**: --gitignore → --no-gitignore 토글 후 → `.harness-kit/` 부재 + `!.harness-kit/` 1 회.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-gitignore-idempotent.sh
```

회귀 점검:
```bash
bash tests/test-gitignore-config.sh   # 기존 시나리오 A~G
bash tests/test-install-layout.sh     # 전체 install 흐름
```

### 통합 테스트

`Integration Test Required = no` — 별도 통합 테스트 없음.

### 수동 검증 시나리오

본 프로젝트 자체에 install 적용 (도그푸딩):
1. 본 프로젝트의 `.gitignore` 백업 → install.sh 재실행 → 4 라인 각각 정확히 1 회 확인.
2. 헤더 라인만 수동 삭제 → install.sh 재실행 → 헤더 복원 + 라인 중복 없음 확인.

## 🔁 Rollback Plan

- `install.sh` 의 한 블록 변경 + 신규 테스트 1 개. `git revert <merge-commit>` 즉시 복원.
- 변경된 install 결과는 "라인별 정확 매치" 라 기존 정상 케이스 (헤더 + 4 라인 모두 있음) 와 동일.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
