# fix(spec-x-archive-clean-commit): sdd archive 커밋이 무관한 워킹트리 변경을 흡수하지 않도록 수정

## 📋 Summary

### 배경 및 목적
직전 머지 (#102) 직후 도그푸딩 검증 중 `c0010e0 chore: archive 0 spec dirs + 0 backlog files + 1 spec-x dirs` 커밋이 의도한 archive rename 외에 워킹트리에 떠 있던 install drift 2건 (`.claude/settings.json` deny 규칙, `.harness-kit/installed.json` 메타) 을 함께 흡수한 것을 발견. 원인은 `cmd_archive` 의 `git -C "$SDD_ROOT" add -A`.

### 주요 변경 사항
- [x] `cmd_archive` 의 `git add -A` 라인 1줄 제거 — `git mv` 가 이미 rename 을 stage 하므로 추가 add 는 redundant
- [x] 회귀 테스트 신규 1건 추가 (`tests/test-sdd-dir-archive.sh` Check 9, 4 assertion):
  1. archive commit 에 untracked `unrelated.md` 미포함
  2. archive commit 에 modified `README.md` 미포함
  3. 워킹트리에 untracked 보존
  4. 워킹트리에 modified 보존
- [x] dogfood sync (`.harness-kit/bin/sdd`)

## 🎯 Key Review Points

1. **`git mv` 의 자동 staging 의존성**: `git mv` 는 source 삭제 + destination 추가를 한 번에 stage 한다. `mkdir -p archive/...` 가 만든 빈 디렉토리도 첫 mv 와 함께 자연스럽게 stage 됨 → 추가 add 불필요.
2. **회귀 테스트의 범위**: untracked + modified 두 가지 무관 변경 시나리오 모두 검증. `git show --name-only HEAD` 출력을 직접 파싱하여 archive commit 내용을 검증.
3. **백워드 호환**: 기존 archive 동작 (대상 식별, --keep, --dry-run, 커밋 메시지 형식) 변경 없음.

## 🧪 Verification

```bash
bash tests/test-sdd-dir-archive.sh         # 18/18 PASS (Check 9 신규)
bash tests/test-sdd-archive-search.sh      # 11/11 PASS (회귀)
bash tests/test-sdd-status-cross-check.sh  # 7/7   PASS (회귀)
```

### 수동 검증 시나리오
1. 워킹트리에 install drift 가 있는 상태에서 `sdd archive` 실행 → archive commit 은 rename 만 포함, drift 는 워킹트리에 보존
2. 워킹트리가 깔끔한 상태에서 `sdd archive` 실행 → 기존과 동일하게 동작

## 📦 Files Changed

### 🛠 Modified Files
- `sources/bin/sdd` (-1, +1): `git add -A` 라인 제거 + 주석 갱신
- `.harness-kit/bin/sdd` (-1, +1): dogfood sync
- `tests/test-sdd-dir-archive.sh` (+72): Check 9 추가

### 🆕 New Files
- `specs/spec-x-archive-clean-commit/{spec,plan,task,walkthrough,pr_description}.md`

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (36/36 across 3 files)
- [x] 통합 테스트 — 해당 없음
- [x] walkthrough.md ship commit 완료
- [x] pr_description.md ship commit 완료
- [x] bash syntax 통과 (`bash -n sources/bin/sdd`)
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- 직전 사고 커밋: `c0010e0 chore: archive 0 spec dirs + 0 backlog files + 1 spec-x dirs`
- 직전 PR: #102 (sdd archive 가 spec-x 도 처리하도록 확장)
