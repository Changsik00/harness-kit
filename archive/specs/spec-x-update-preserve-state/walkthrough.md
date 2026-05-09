# Walkthrough: spec-x-update-preserve-state

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| state 백업 방식 | (A) bash 변수 6개 / (B) jq 객체 한 덩어리 + `* merge` | **B** | bash 변수가 4개 → 6개로 늘어나는 것보다 jq 객체가 응집도 ↑. 이후 새 필드 추가 시 키 하나만 jq projection 에 추가하면 됨. bash 3.2 호환 (`declare -A` 미사용). |
| `kitVersion` 동기화 전략 | (A) update.sh 가 명시 갱신 / (B) install.sh 가 새로 쓰는 값을 그대로 둠 | **B** | install.sh 가 항상 새 템플릿을 작성하므로, 백업 객체에서 `kitVersion` 을 빼면 자동 동기화. 별도 로직 불필요. |
| 도그푸딩 시 install 부수 변경 처리 | (A) 모두 커밋 / (B) 의미 있는 것만 커밋 + 노이즈 revert + 별 이슈는 Icebox | **B** | `.gitignore` 중복 추가, `settings.json` 재정렬 등은 본 spec 의 의도와 무관. 별 이슈로 Icebox 에 올려 추후 별도 spec 으로 분리. |

## 💬 사용자 협의

- **주제**: 작업 모드 결정
  - **사용자 의견**: update.sh 버그 수정 + 본 프로젝트 update + 0.6.1 버전 bump
  - **합의**: SDD-x (Solo Spec) — 단일 PR 범위, fix 타입, 새 아키텍처 결정 없음. 사전 정리로 stale `spec-x-phase-14-finalize` state 정리 후 진입.
- **주제**: 작업 범위
  - **사용자 의견**: "그대로 진행" (slug=`update-preserve-state`, 6개 항목 범위 그대로)
  - **합의**: tests 회귀 + install.sh 템플릿 + update.sh 보존 + VERSION/CHANGELOG/README + 도그푸딩까지 한 spec 에 묶음.

## 🧪 검증 결과

### 1. 자동화 테스트

#### `tests/test-update.sh` (핵심 회귀)

```text
▶ 시나리오 A: 기본 update (state 보존)
  ✅ .harness-kit/ 재생성됨
  ✅ .harness-kit/installed.json 존재
  ✅ state 보존: phase=phase-9 spec=spec-9-005-update-rewrite
  ✅ branch/baseBranch 보존: branch=spec-9-005-update-rewrite baseBranch=phase-9-rewrite
  ✅ planAccepted/lastTestPass 보존: pa=true lt=2026-04-27T00:00:00Z
  ✅ kitVersion 동기화: state=0.6.0 installed=0.6.0 VERSION=0.6.0
  ✅ .harness-uninstall-backup-* 정리됨
▶ 시나리오 B: prefix 있는 경우 (prefix 보존)
  ✅ hk-backlog/ 유지됨
  ✅ hk-specs/ 유지됨
  ✅ harness.config.json backlogDir=hk-backlog 유지
▶ 시나리오 C: install.sh 가 baseBranch 필드 포함 state.json 작성
  ✅ 신규 install state.json 에 baseBranch 필드 존재
✅ ALL PASS (11/11)
```

#### `tests/test-version-bump.sh`

```text
✅ PASS: VERSION 파일에 0.6.1 포함
✅ PASS: sdd version → 0.6.1
✅ PASS: CHANGELOG.md 존재 + 0.6.1 포함
✅ PASS: README.md에 0.6.1 포함
✅ PASS: installed.json kitVersion = 0.6.1
✅ PASS: 전체 테스트 스위트 FAIL=0
=== 결과: PASS=6 FAIL=0 ===
```

#### 전체 sweep

```bash
for t in tests/test-*.sh; do bash "$t" || echo "FAIL: $t"; done
# → Total fails: 0 (29 test files)
```

### 2. 수동 검증 (도그푸딩)

| # | Action | Result |
|---|---|---|
| 1 | `bash update.sh --yes .` | `0.6.0 → 0.6.1` 로그, doctor `PASS=40 WARN=1 FAIL=0` |
| 2 | `cat .claude/state/current.json` | `kitVersion=0.6.1`, `baseBranch` 필드 존재, `spec/planAccepted/lastTestPass` 보존 ✓ |
| 3 | `bash .harness-kit/bin/sdd status` | 헤더 `harness-kit 0.6.1` ✓ (이전: 0.5.0) |

## 🔍 발견 사항

### 1. `state.json.kitVersion` 이 0.5.0 으로 박혀 있던 진짜 이유

본 프로젝트는 `installed.json` = 0.6.0 인데 `state.json.kitVersion` = 0.5.0 이었음. 처음엔 update.sh 의 4-필드 화이트리스트 누락이 직접 원인일 거라 의심했으나, 코드 분석 결과:

- update.sh 가 install.sh 호출 후 jq merge 로 *백업한 4개 필드만* 덮어쓰므로, install.sh 가 새로 쓴 `kitVersion` 은 그대로 살아 있어야 함 (0.6.0 으로).
- 그런데 실제론 0.5.0 이었음 → **사용자가 `update.sh` 를 한 번도 돌리지 않은 것**. VERSION 파일을 직접 0.5.0 → 0.6.0 으로 bump 한 spec-13 작업 이후 "도그푸딩 sync" 없이 다음 phase 들이 진행됨.

→ 결론: `update.sh` 의 *직접* 버그는 `branch`/`baseBranch` 손실. `kitVersion` 동기화 부재는 운영 누락(미실행)이었음. 본 spec 의 회귀 테스트가 동기화도 검증하므로, 향후 같은 누락이 반복되어도 테스트가 잡아냄.

### 2. 도그푸딩으로 드러난 부수 이슈 3건 (Icebox 등록)

본 spec 의 도그푸딩 step 에서 새로 발견. 모두 별 spec-x 에서 처리 권장:

1. **install.sh 의 self-host gitignore 충돌**: install.sh 가 항상 `.harness-kit/` 를 .gitignore 에 추가하지만, 본 프로젝트는 도그푸딩 결과물 `.harness-kit/` 를 git 추적함 → 도그푸딩마다 `.gitignore` 에 중복 라인 추가됨. self-host 감지 또는 `--no-gitignore-harness-kit` 옵션 검토.
2. **`phase-ship.md` 템플릿 누락**: `sources/templates/phase-ship.md` 는 존재하지만 install.sh 의 템플릿 복사 루프 (install.sh:262) 에 7개 파일 하드코딩 — `phase-ship.md` 빠짐. `/hk-phase-ship` 슬래시 커맨드가 이 템플릿을 참조한다면 신규 설치 환경에서 동작하지 않을 가능성.
3. **`settings.json` ask 리스트에 `git push` 자동 추가**: 도그푸딩 시 install 이 `Bash(git push)` / `Bash(git push:*)` 를 ask 섹션에 추가. allow 에 이미 있어도 ask 가 우선이라면 매번 권한 프롬프트 발생. 의도 확인 필요.

### 3. `test-version-bump.sh` 의 "버전 앵커 sweep" 효과

이 테스트는 5곳 (VERSION, sdd version 출력, CHANGELOG, README, installed.json) 에 새 버전이 모두 반영됐는지 확인하는 단일 진실 원천 역할. 0.6.0 → 0.6.1 bump 시 `TARGET="0.6.1"` 한 줄만 고치면 5곳을 모두 검증해줌. 향후 버전 bump 누락 방지 효과 큼.

## 🚧 이월 항목

- 부수 이슈 3건 (위 §2) → `backlog/queue.md` Icebox 등록 완료.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Opus) + dennis |
| **작성 기간** | 2026-04-27 (단일 세션) |
| **최종 commit** | `f7c0cae` (dogfood) |
| **총 commits** | 5 (test → install fix → update fix → version bump → dogfood) |
