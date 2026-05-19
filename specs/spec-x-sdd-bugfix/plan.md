# Implementation Plan: spec-x-sdd-bugfix

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-sdd-bugfix`
- 시작 지점: `main`

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [x] sed 선행 치환 패턴 추가 — 기존 `sdd spec new` (일반 phase spec) 영향 없음 확인

## 🎯 핵심 전략

### 주요 결정

| 버그 | 수정 위치 | 방법 |
|:---:|:---|:---|
| Branch 중복 | `specx_new()` sed 패턴 | `{seq}-{slug}` → `{slug}` 선행 치환 추가 |
| 테스트 glob | `test-uninstall-cmd-list.sh` | `hk-*.md` → `*.md` |

### Bug 1 상세

현재 sed:
```bash
sed "s/{phaseN}/x/g; s/{seq}/${slug}/g; s/{slug}/${slug}/g"
```

템플릿 `spec-{phaseN}-{seq}-{slug}` 처리 순서:
1. `{phaseN}` → `x`: `spec-x-{seq}-{slug}`
2. `{seq}` → `foo`: `spec-x-foo-{slug}`
3. `{slug}` → `foo`: `spec-x-foo-foo` ❌

수정 후:
```bash
sed "s/{phaseN}/x/g; s/{seq}-{slug}/${slug}/g; s/{seq}/${slug}/g; s/{slug}/${slug}/g"
```

새 처리 순서:
1. `{phaseN}` → `x`: `spec-x-{seq}-{slug}`
2. `{seq}-{slug}` → `foo`: `spec-x-foo` ✅
3. `{seq}` → `foo` (나머지 단독 occurrence)
4. `{slug}` → `foo` (나머지 단독 occurrence)

### Bug 2 상세

```bash
# 현재 (FAIL)
expected=$(find "$ROOT/sources/commands" -maxdepth 1 -name 'hk-*.md' | wc -l)

# 수정 (PASS)
expected=$(find "$ROOT/sources/commands" -maxdepth 1 -name '*.md' | wc -l)
```

## 📂 Proposed Changes

#### [MODIFY] `sources/bin/sdd`
`specx_new()` 함수 sed 패턴에 `{seq}-{slug}` 선행 치환 추가.

#### [MODIFY] `.harness-kit/bin/sdd`
dogfooding 동기화.

#### [MODIFY] `tests/test-uninstall-cmd-list.sh`
Scenario 1 기대값 glob `hk-*.md` → `*.md`.

## 🧪 검증 계획

### 단위 테스트
```bash
bash tests/test-uninstall-cmd-list.sh
bash tests/test-install-claude-import.sh
bash tests/test-marker-append-guard.sh
bash tests/test-marker-edge-cases.sh
```

### 수동 검증
1. `bash .harness-kit/bin/sdd specx new test-slug` → spec.md Branch 필드 = `spec-x-test-slug` 확인 후 디렉토리 삭제

## 🔁 Rollback Plan

- `git revert` — 순수 bash 변수 치환 수정, state 영향 없음

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] 모든 task 완료
- [ ] walkthrough.md / pr_description.md ship
