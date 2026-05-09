# Implementation Plan: spec-x-archive-clean-commit

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-archive-clean-commit`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **`git add -A` 라인 1줄 삭제 만으로 충분한가?**: `git mv` 는 이미 rename 을 stage 한다. 추가 add 가 필요한 경우는 archive 디렉토리가 신규 생성될 때 빈 디렉토리 가시성을 위해서일 수 있으나, git 은 빈 디렉토리를 추적하지 않으며 `git mv` 가 파일을 옮기면서 자연스럽게 신규 디렉토리도 stage 됨 → 안전.

> [!WARNING]
> - [ ] **부수 효과 검증**: `git add -A` 가 archive rename 외에 무엇을 추가했는지 확인 — 분석 결과 (1) drift 흡수 외에 (2) 의도된 staged 변경이 있을 수 있다는 시나리오는 발견되지 않음. 그래도 회귀 테스트로 보호.

## 🎯 핵심 전략

### 변경 핵심

```diff
-  # Commit
-  git -C "$SDD_ROOT" add -A
-  git -C "$SDD_ROOT" commit -m "$commit_msg"
+  # Commit (git mv 가 이미 rename 을 stage 했음 — 추가 add 불필요)
+  git -C "$SDD_ROOT" commit -m "$commit_msg"
```

### 회귀 테스트 시나리오

`tests/test-sdd-dir-archive.sh` 에 신규 Check 9 추가:

1. fixture: phase-01 done + spec-01-001 디렉토리 + 워킹트리에 무관한 변경 (예: `unrelated.md` 신규 untracked + 기존 README.md modified)
2. `sdd archive` 실행
3. assert:
   - archive commit 의 변경 파일 수 = 2 (rename 1쌍 + backlog 이동)
   - archive commit 에 `unrelated.md` 미포함
   - archive commit 에 README.md 변경 미포함
   - 워킹트리에 `unrelated.md` 가 untracked 로 그대로 남음
   - 워킹트리에 README.md 가 modified 로 그대로 남음

## 📂 Proposed Changes

### [MODIFY] `sources/bin/sdd`
- `cmd_archive` 함수의 `git add -A` 라인 1줄 삭제 (line ~1715)

### [MODIFY] `.harness-kit/bin/sdd`
- 도그푸딩 sync — sources 와 동일하게 갱신

### [MODIFY] `tests/test-sdd-dir-archive.sh`
- 신규 Check 9 추가: "archive commit 은 무관한 워킹트리 변경을 흡수하지 않음"

## 🧪 검증 계획

```bash
bash tests/test-sdd-dir-archive.sh         # 신규 Check 9 포함 PASS
bash tests/test-sdd-archive-search.sh      # 회귀
bash tests/test-sdd-status-cross-check.sh  # 회귀
```

### 수동 검증
- 본 PR 머지 후, 다음 archive 실행 시 워킹트리 install drift 가 흡수되지 않는지 확인.

## 🔁 Rollback Plan
- 단일 PR git revert 로 롤백 가능. 데이터 영향 없음.

## 📦 Deliverables 체크
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
