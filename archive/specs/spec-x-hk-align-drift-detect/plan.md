# Implementation Plan: spec-x-hk-align-drift-detect

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-hk-align-drift-detect`
- 시작 지점: `main` (origin/main 동기화 완료 — f79a8b4)
- 첫 task 가 브랜치 생성을 수행함
- spec-x 는 main 에서 분기 (memory: spec-x는 main에서 브랜치)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **drift 감지 위치 결정**: `sdd status` 에 통합 (이 plan 의 채택안) vs. 신규 `sdd doctor` 확장 vs. 신규 `sdd drift` 명령. → **`sdd status` 에 통합** 을 권고. 이유: hk-align 이 이미 status 를 호출하므로 단일 명령 원칙 유지 + 자동 보고. `--no-drift` 로 opt-out 가능.
> - [ ] **`git fetch` 자동 실행 여부**: 자동 (정확도 ↑, 1-2 초 비용) vs. 수동만. → **자동 + 실패 시 silent fallback** 권고. 오프라인일 때 fetch 실패해도 status 는 정상 반환.
> - [ ] **자동 정리 동작 포함 여부**: 본 spec 은 감지·제안만. `git pull`, `sdd phase done`, `rm` 같은 정리 동작은 자동 실행 안 함. → 사용자가 직접 호출.

> [!WARNING]
> - [ ] **`git fetch` 의 네트워크 호출**: 이전 status 는 *완전 로컬* 이었으나 본 변경으로 매 status 호출에 네트워크 1 회 발생. CI 등에서 부담될 수 있음 — `--no-drift` 또는 `HARNESS_DRIFT_FETCH=0` 환경변수로 끌 수 있도록 escape hatch 제공.
> - [ ] **Backward compat**: 기존 status 출력 포맷에 새 섹션이 *추가* 되는 것 — 기존 정보 형식은 보존. status 결과를 파싱하는 외부 스크립트 (있다면) 깨지지 않도록.

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
sdd status (cmd_status @ sources/bin/sdd:269)
   │
   ├─ 기존: 로컬 파일 읽기 (queue/phase/specs/state.json)
   │
   └─ 신규: drift_check() 호출 (--no-drift 가 아니면)
          ├─ remote_drift()       — git fetch + behind/ahead
          ├─ worktree_drift()     — git status --porcelain 분류
          ├─ repo_consistency()   — queue.md active vs phase-N.md
          └─ install_residue()    — sources vs .harness-kit 비교
        ↓
       🔄 동기화 상태 섹션 출력
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **drift 위치** | `sdd status` 에 통합 + `--no-drift` opt-out | hk-align 단일 명령 원칙 유지 + 자동 보고 |
| **fetch 정책** | 자동 fetch (`git fetch origin --quiet 2>/dev/null \|\| true`) + escape hatch | 정확도 우선, 오프라인 시 fail-soft |
| **검사 범위** | 4 카테고리 (remote / worktree / consistency / install) | 지난 꼬임 4 가지에 1:1 대응 |
| **자동 정리** | **금지** | 사용자 결정 사항 — 위험 높음. 감지·제안만. |
| **bash 호환** | 3.2 호환 함수만 | CLAUDE.md §3 기존 정책 준수 |

## 📂 Proposed Changes

### [sdd CLI]

#### [MODIFY] `sources/bin/sdd`

**위치 1: `cmd_status()` (line ~269)** — `--no-drift` 인자 파싱 + drift_check 호출 추가.

```bash
# 의사코드
cmd_status() {
  local show_drift=1
  for arg; do
    case "$arg" in
      --no-drift) show_drift=0 ;;
      --brief)    show_drift=0 ;;
      ...
    esac
  done

  # 기존 로컬 상태 출력 (변경 없음)
  print_local_status

  # 신규 drift 섹션
  if [ "$show_drift" -eq 1 ]; then
    drift_check
  fi
}
```

**위치 2: 신규 함수 4 개 추가** (cmd_status 직전 또는 별도 lib).

```bash
drift_check() {
  echo ""
  echo "🔄 동기화 상태"

  local has_drift=0
  drift_remote   && has_drift=1
  drift_worktree && has_drift=1
  drift_consistency && has_drift=1
  drift_install  && has_drift=1

  if [ "$has_drift" -eq 0 ]; then
    echo "  깔끔"
  fi
}

drift_remote() {
  # git fetch origin --quiet 2>/dev/null || return 0  # silent fail
  # git rev-list --left-right --count HEAD...@{u} 같은 식
  # 출력: "  원격: behind N / ahead M  (origin/main)"
}

drift_worktree() {
  # git status --porcelain 결과 파싱
  # specs/ 안 미커밋 → spec drift
  # .harness-kit/ / .claude/ 안 untracked → install drift
  # 그 외 → 일반 미커밋
  # 출력: "  워킹트리: K 변경 (X spec / Y install / Z 일반)"
}

drift_consistency() {
  # queue.md 의 active phase 추출
  # 해당 phase-N.md 읽기 → spec 표의 모든 row 가 Merged 면 의심
  # 출력: "  정합성: phase-15 의 모든 spec Merged 인데 active — sdd phase done 미실행 의심"
}

drift_install() {
  # .harness-kit/agent/templates, .harness-kit/hooks, .claude/commands 안의 untracked 열거
  # 각 파일을 sources/ 의 대응 파일과 diff
  # 출력: "  install 부산물: K (sources 와 동일 — keep 안전 / 정체불명)"
}
```

#### [MODIFY] `sources/bin/sdd` cmd_help

`status` 항목의 옵션 설명에 `--no-drift` 추가.

### [Slash command]

#### [MODIFY] `sources/commands/hk-align.md`

§5 (상태 요약 보고) 의 출력 예시에 `🔄 동기화 상태` 섹션 추가. 다른 부분은 변경 최소.

### [Governance]

#### [MODIFY] `sources/governance/align.md`

§2 (컨텍스트 점검) 에 "drift 감지가 자동 포함됨" 한 줄 추가. §5 (상태 요약 보고) 의 출력 형식에 동기화 섹션 추가.

### [도그푸딩]

#### [MODIFY] `.harness-kit/bin/sdd` 등 설치본
- `install.sh` / `update.sh` 가 `sources/` → `.harness-kit/` 로 복사하는 흐름. 본 spec 의 변경은 sources 만 손대고, 도그푸딩은 별도 검증 (수동 install 또는 후속 commit).

### [테스트]

#### [NEW] `tests/test-sdd-drift.sh`

bash 3.2 호환 단위 테스트. fixture 디렉토리 (tests/lib/fixture.sh 의 헬퍼 사용) 로:

- T1: 깨끗한 상태 → "🔄 동기화 상태: 깔끔"
- T2: behind=1 시뮬레이션 (로컬 reset 후) → "원격: behind 1 / ahead 0"
- T3: specs/ 에 untracked 디렉토리 → "워킹트리: 1 변경 (1 spec drift / ...)"
- T4: queue active phase 의 spec 모두 Merged → "정합성: phase-N — sdd phase done 미실행 의심"
- T5: `--no-drift` → 동기화 섹션 출력 안 됨

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-drift.sh
bash tests/test-sdd-spec-new-seq.sh   # 회귀
bash tests/test-fixture-lib.sh        # 회귀
bash tests/test-install-manifest-sync.sh   # 회귀
```

### 수동 검증 시나리오

1. **현 환경에서 깔끔 시나리오**: main 브랜치 깨끗 → `bash sources/bin/sdd status` 실행 → "🔄 동기화 상태: 깔끔" 확인 (단, `.harness-kit/agent/templates/phase-ship.md` 는 install drift 로 잡힐 수 있음 — 의도된 발견)
2. **behind 시나리오**: 로컬 main 을 1 commit 뒤로 reset → `sdd status` → "원격: behind 1 / ahead 0" 확인
3. **워킹트리 spec drift 시나리오**: `mkdir -p specs/spec-x-fake` + `touch specs/spec-x-fake/spec.md` → `sdd status` → "워킹트리: 1 변경 (1 spec drift / ...)" 확인
4. **정합성 시나리오**: 과거 phase-15 가 active 였던 시점 재현 (git stash 로) → "phase-15 의 모든 spec Merged 인데 active" 표시 확인
5. **--no-drift**: `sdd status --no-drift` → 동기화 섹션 미출력

## 🔁 Rollback Plan

- drift 검사가 잘못 동작하거나 false positive 다수 발생 시 → `git revert` 로 본 PR 단일 롤백.
- 부분 롤백이 필요하면 `--no-drift` 를 default 로 변경하는 작은 follow-up commit 으로 임시 대처.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
