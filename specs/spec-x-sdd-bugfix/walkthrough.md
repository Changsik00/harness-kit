# Walkthrough: spec-x-sdd-bugfix

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Bug 1 수정 위치 | (A) 템플릿 변경 / (B) specx_new() sed 패턴 수정 | **(B)** | 템플릿은 일반 spec/phase에서도 공용. sed에서 `{seq}-{slug}` 복합 패턴을 선행 치환하면 템플릿 건드릴 필요 없음 |
| Bug 2 수정 위치 | (A) 테스트 glob 수정 / (B) install.sh glob 수정 | **(A)** | install.sh의 `*.md` 가 정답 (hk.md 포함이 의도된 동작). 테스트가 잘못된 기대값을 갖고 있었음 |

### ADR 승격 가이드

- [x] 없음

## 💬 사용자 협의

없음 (버그픽스 2개 번들, 사용자 결정 불필요)

## 🧪 검증 결과

### 자동화 테스트

| 테스트 | 결과 |
|---|---|
| `tests/test-uninstall-cmd-list.sh` | ✅ PASS=9 FAIL=0 |
| `tests/test-install-claude-import.sh` | ✅ ALL PASS (6/6) |
| `tests/test-marker-append-guard.sh` | ✅ ALL 5 CHECKS PASSED |
| `tests/test-marker-edge-cases.sh` | ✅ ALL 8 CHECKS PASSED |

`sdd test passed` → `2026-05-19T02:06:15Z`

### 수동 검증

1. **Action**: `sdd specx new test-slug` → `spec.md` Branch 필드 확인
   - **Result**: `| **Branch** | \`spec-x-test-slug\` |` ✅ (이전: `spec-x-test-slug-test-slug`)

## 🔍 발견 사항

- **테스트 중 state 오염**: `sdd specx new test-slug` 검증 시 active spec이 `spec-x-test-slug`로 변경되어 plan accept 훅이 차단됨. python3으로 직접 state.json 복원. `specx new` 가 state를 갱신하는 부작용 — 향후 검증 목적의 `--no-state` 옵션 icebox 후보.

## 🚧 이월 항목

- `sdd specx new --no-state` 옵션 — 검증/테스트 목적 생성 시 state 오염 방지

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-19 |
| **최종 commit** | (push 후 갱신) |
