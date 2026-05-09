# spec-x-archive-clean-commit: sdd archive 커밋이 무관한 워킹트리 변경을 흡수하지 않도록 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-archive-clean-commit` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-archive-clean-commit` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-09 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
`cmd_archive` (`sources/bin/sdd:1714~1716` 부근) 는 spec / backlog 이동 후 다음 두 줄로 마무리한다:

```bash
git -C "$SDD_ROOT" add -A
git -C "$SDD_ROOT" commit -m "$commit_msg"
```

`git add -A` 는 워킹트리의 *모든* 변경 (modified, deleted, untracked) 을 staging 에 추가한다.

### 문제점
직전 세션 `c0010e0 chore: archive 0 spec dirs + 0 backlog files + 1 spec-x dirs` 커밋이 실증한다 — 의도한 archive 이동(rename) 외에 **워킹트리에 떠 있던 install drift 2건** (`.claude/settings.json` deny 규칙, `.harness-kit/installed.json` 메타) 이 함께 흡수되어 archive 커밋에 들어갔다.

이는 유해하다:
1. **커밋 의미 혼탁**: chore archive 커밋이 비-archive 변경을 포함 → git history / `git blame` 추적 곤란.
2. **사용자 의도와 불일치**: 사용자가 archive *만* 원했는데 다른 in-progress 변경이 동의 없이 커밋됨.
3. **무관 변경이 사라지는 위험**: 별개 PR 로 다루려던 변경이 chore 커밋에 묻혀 검토 누락 가능.

### 해결 방안 (요약)
`git mv` 는 이미 rename 을 staging 에 자동 등록한다. archive 명령에서 추가 `git add -A` 는 중복이며 유해 → **삭제**한다. 결과적으로 archive 커밋은 staged rename 만 포함.

## 🎯 요구사항

### Functional Requirements
1. **F1**: `sdd archive` 실행 후 생성되는 commit 은 archive rename 만 포함한다 (워킹트리의 다른 modified / untracked 파일 미포함).
2. **F2**: 워킹트리에 무관한 변경이 있어도 archive 동작은 정상 진행되며, 그 변경은 워킹트리에 unstaged 상태로 그대로 남는다.

### Non-Functional Requirements
1. **N1**: 기존 archive 동작 (대상 식별, --keep, --dry-run) 은 변경 없음.
2. **N2**: 도그푸딩 sync — `sources/bin/sdd` 와 `.harness-kit/bin/sdd` 일관성.

## 🚫 Out of Scope
- archive 도중의 더 정교한 트랜잭션성 보장 (rollback 등) — 현재 단순한 `git mv` + commit 흐름 유지.
- 다른 sdd 명령 (`ship`, `phase done` 등) 의 git add 패턴 점검 — 별개 spec-x 후보.
- archive 커밋 메시지의 형식 변경 — 기존 그대로.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS — 신규 회귀 테스트 + 기존 테스트 무손상
- [ ] `walkthrough.md` / `pr_description.md` ship commit
- [ ] `spec-x-archive-clean-commit` push + PR 생성
