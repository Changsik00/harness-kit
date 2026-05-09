# Walkthrough: spec-x-install-fragment-fixes

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| self-host guard 구현 방식 | HK_GITIGNORE=0 강제 vs `_hk_self_host` 플래그 | 플래그 방식 | HK_GITIGNORE=0 으로 바꾸면 `!.harness-kit/` 라인이 추가되는 부작용 발생. 플래그로 해당 라인 전체를 건너뜀이 더 깔끔 |
| self-host 감지 기준 | TARGET==KIT_DIR 비교 vs git ls-files | git ls-files | TARGET 경로 비교는 symlink/절대경로 차이로 오탐 가능. git ls-files는 실제 추적 여부를 정확히 판단 |
| git push ask 제거 후 대안 | allow에 명시 추가 vs 기존 `Bash(git:*)` 위임 | git:* 위임 | allow에 이미 `Bash(git:*)` 가 있어 중복 추가 불필요. check-branch.sh 훅이 main 보호 담당 |

## 💬 사용자 협의

- **주제**: Icebox 항목 유효성 검토
  - **사용자 의견**: "유효한건 진행 하자"
  - **합의**: self-host gitignore 충돌 + git push ask 중복, 2건을 1개 spec-x로 묶어 처리 (옵션 B 선택)

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 — gitignore

- **명령**: `bash tests/test-gitignore-config.sh`
- **결과**: ✅ 12 / 12 PASS

```text
▶ Scenario A: --yes 설치 (기본 gitignore=true)  ✅ ✅ ✅
▶ Scenario B: --no-gitignore 설치              ✅ ✅
▶ Scenario C: --gitignore 명시 설치             ✅
▶ Scenario D: 재설치 멱등성                     ✅
▶ Scenario E: update.sh 후 gitignore=true 보존  ✅ ✅
▶ Scenario F: update.sh 후 gitignore=false 보존 ✅ ✅
▶ Scenario H: self-host guard                  ✅  ← 신규
결과: 12 / 12 PASS ✅ ALL PASS
```

#### 단위 테스트 — settings hook

- **명령**: `bash tests/test-install-settings-hook.sh`
- **결과**: ✅ 5 / 5 PASS

```text
▶ Test 1: PreToolUse 존재           ✅
▶ Test 2: UserAddedHook 보존        ✅
▶ Test 3: UserAddedHook 멱등성      ✅
▶ Test 4: kit hook만 존재           ✅
▶ Test 5: ask 에 git push 없음      ✅  ← 신규
PASS: 5  FAIL: 0
```

### 2. 수동 검증

1. **Action**: TDD Red — test-install-settings-hook.sh Test 5 추가 후 실행
   - **Result**: Test 5 FAIL (ask에 git push 2개 존재) 확인
2. **Action**: fragment ask 섹션에서 git push 2줄 제거
   - **Result**: Test 5 PASS
3. **Action**: TDD Red — test-gitignore-config.sh Scenario H 추가 후 실행
   - **Result**: H-1 FAIL (self-host 감지 실패) 확인
4. **Action**: install.sh 섹션 16에 `_hk_self_host` guard 삽입
   - **Result**: 12/12 PASS

## 🔍 발견 사항

- install.sh 의 gitignore 로직은 `HK_GITIGNORE` 값에 따라 sed 토글 후 `_gi_ensure` 로 라인을 보장하는 구조. guard 삽입 위치는 ensure 직전이 가장 자연스러웠음
- fragment의 git push가 ask에 있었던 이유는 초기 설계 시 "push는 신중하게" 의도였으나, check-branch.sh 훅이 동일 보호를 제공하므로 중복이었음

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + changsik |
| **작성 기간** | 2026-05-06 |
| **최종 commit** | 28817ad |
