# Implementation Plan: spec-x-install-fragment-fixes

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-install-fragment-fixes`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **버그 B**: `ask`에서 git push 제거 시, 사용자의 기존 settings.json에 git push가 ask에 있어도 update 후에는 사라진다. 의도된 동작인지 확인.

> [!WARNING]
> - [ ] fragment 변경은 신규 설치 프로젝트에만 즉시 반영됨. 이미 설치된 프로젝트는 `update.sh` 실행 후 반영.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **install.sh self-host guard** | `git ls-files .harness-kit/` 출력 유무로 감지 | 추가 상태 파일 없이 git 정보만으로 판단 가능 |
| **git push ask 제거** | fragment ask 섹션에서 항목 삭제 | allow의 `Bash(git:*)`로 이미 커버, 훅으로 main 보호 |

## 📂 Proposed Changes

### [버그 A] install.sh self-host guard

#### [MODIFY] `install.sh`

섹션 16 (`.gitignore 업데이트`) 의 gitignore 토글/ensure 로직 직전에 self-host guard 삽입:

```bash
# self-host guard: .harness-kit/ 가 git-tracked 이면 ignore 추가 건너뜀
if [ "$HK_GITIGNORE" -eq 1 ] && git -C "$TARGET" ls-files ".harness-kit/" 2>/dev/null | grep -q .; then
  warn ".harness-kit/ 가 git 추적 중 (self-host 모드) — .gitignore 에 .harness-kit/ 추가 건너뜀"
  HK_GITIGNORE=0
fi
```

`HK_GITIGNORE=0`으로 변경하면 이후 로직이 `!.harness-kit/`를 추가하려 하므로, `_hk_skip` 플래그로 아예 `.harness-kit/` 관련 라인을 건너뛰는 방식으로 구현:

```bash
_hk_self_host=0
if [ "$HK_GITIGNORE" -eq 1 ] && git -C "$TARGET" ls-files ".harness-kit/" 2>/dev/null | grep -q .; then
  warn ".harness-kit/ 가 git 추적 중 (self-host 모드) — .gitignore 에 .harness-kit/ 추가 건너뜀"
  _hk_self_host=1
fi

if [ "$_hk_self_host" -eq 0 ]; then
  _gi_ensure "$_hk_pat" "$_hk_line"
fi
_gi_ensure '^\.harness-backup-\*/$'  '.harness-backup-*/'
_gi_ensure '^\.claude/state/$'       '.claude/state/'
```

### [버그 A] 테스트 추가

#### [MODIFY] `tests/test-gitignore-config.sh`

Scenario H 추가 — self-host 감지:

```
git-tracked .harness-kit/ 파일이 있는 fixture에 --yes 설치 시
→ .gitignore에 '.harness-kit/' 가 추가되지 않아야 함
```

### [버그 B] fragment git push ask 제거

#### [MODIFY] `sources/claude-fragments/settings.json.fragment`

`ask` 섹션에서 2줄 제거:
```json
// 제거
"Bash(git push)",
"Bash(git push:*)",
```

### [버그 B] 테스트 추가

#### [MODIFY] `tests/test-install-settings-hook.sh` (또는 신규 파일)

신규 설치 후 `settings.json`의 ask 섹션에 `git push` 계열 항목이 없음을 검증.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-gitignore-config.sh
bash tests/test-install-settings-hook.sh
```

### 수동 검증 시나리오

1. `./install.sh --yes .` 실행 → `.gitignore`에 `.harness-kit/` 추가되지 않음을 확인
2. 신규 fixture에 install → `settings.json` ask 섹션에 git push 없음 확인

## 🔁 Rollback Plan

- fragment 변경은 `git revert`로 즉시 되돌림
- install.sh 변경도 `git revert`로 즉시 되돌림
- 이미 설치된 프로젝트는 rollback 불필요 (update.sh 미실행 상태이면 영향 없음)

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
