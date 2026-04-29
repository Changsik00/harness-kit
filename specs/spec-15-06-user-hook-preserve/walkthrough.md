# Walkthrough: spec-15-06

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| hook 머지 범위 | (A) 모든 hook key 보존 vs (B) kit-unknown key만 보존 | B | kit 관리 key(PreToolUse, SessionStart)는 항상 최신 fragment로 갱신해야 안전. 사용자가 kit event type 내부 항목을 추가하는 경우는 범위 외로 명시 |
| update.sh vs uninstall.sh 수정 | (A) uninstall.sh에서 kit hook만 제거 vs (B) update.sh에서 save/restore | B | uninstall.sh는 독립 실행 시나리오를 고려해 현재 범위를 유지. update.sh는 이미 state save/restore 패턴이 있어 일관성 있는 위치 |
| sdd spec_new() 수정 범위 | (A) 이번 spec 외 별도 spec-x로 분리 vs (B) 동일 scope에 포함 | B | phase 버그와 완전 동일 패턴. 발견 즉시 수정이 합리적이며 코드량도 한 줄 수정 |

## 💬 사용자 협의

- **주제**: spec-15-07(sdd가 할당)이 아닌 spec-15-06 사용
  - **사용자 의견**: sdd가 spec-15-07을 할당한 것은 archive scan 미구현 버그의 파생 문제이므로 sdd 수정도 이번 spec에 포함
  - **합의**: sdd `spec_new()` archive 스캔 수정 + spec-15-06 복원 + hook 보존 수정을 한 PR로 처리

- **주제**: hook 머지 정책 (PreToolUse 내부 항목 병합 여부)
  - **사용자 의견**: 명시적 Out of Scope로 처리
  - **합의**: event type key 단위 보존으로 범위 확정. PreToolUse 내부 병합은 후속 spec 후보

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 — sdd seq 검증
- **명령**: `bash tests/test-sdd-spec-new-seq.sh`
- **결과**: ✅ Passed (3/3)
- **로그 요약**:
```text
▶ Test 1: specs/ 에 01-03 있을 때 → 04 할당
  ✅ PASS: Test 1: 04 할당 (expected)
▶ Test 2: archive/specs/ 에 01-05, specs/ 비어있을 때 → 06 할당
  ✅ PASS: Test 2: 06 할당 (archive 포함 스캔)
▶ Test 3: specs/에 01-03, archive/에 04-06 → 07 할당
  ✅ PASS: Test 3: 07 할당 (specs + archive 합산)
 PASS: 3  FAIL: 0
```

#### 단위 테스트 — hook 보존 검증
- **명령**: `bash tests/test-install-settings-hook.sh`
- **결과**: ✅ Passed (4/4)
- **로그 요약**:
```text
▶ Test 1: install 후 PreToolUse 가 fragment 버전으로 갱신됨
  ✅ PASS: Test 1: PreToolUse 존재 (2 개 matcher)
▶ Test 2: 사용자 UserAddedHook → install 후 보존
  ✅ PASS: Test 2: UserAddedHook 보존됨
▶ Test 3: 재설치 후 UserAddedHook 중복 없음 (멱등성)
  ✅ PASS: Test 3: UserAddedHook 중복 없음 (count=1)
▶ Test 4: 사용자 hook 없을 때 kit hook 정상 존재
  ✅ PASS: Test 4: kit hook만 존재 (PreToolUse=2, SessionStart=1, 사용자 hook 없음)
 PASS: 4  FAIL: 0
```

#### 통합 테스트 — stateful update 시나리오
- **명령**: `bash tests/test-update-stateful.sh`
- **결과**: ✅ Passed (17/17)
- **로그 요약**:
```text
▶ Scenario 3: 사용자 추가 hook event type → update 후 보존 (Pattern B)
  ✅ PASS: S3: 사용자 UserAddedHook 보존됨
 결과: PASS=17  FAIL=0
```

### 2. 수동 검증

1. **Action**: `sdd spec new user-hook-preserve` 실행 후 spec-15-07이 할당됨
   - **Result**: archive scan 미구현으로 specs/에 spec-15-06이 있으면 07을 할당하는 버그 재현 확인
2. **Action**: `sources/bin/sdd`와 `.harness-kit/bin/sdd`에 archive scan 추가 후 test-sdd-spec-new-seq 실행
   - **Result**: 3개 케이스 모두 올바른 seq 할당
3. **Action**: 사용자가 settings.json에 `UserAddedHook` 추가 후 install.sh 재실행
   - **Result**: 수정 전 손실, 수정 후 보존 확인
4. **Action**: update.sh 흐름 — uninstall → install 순서에서 user hook 유실 확인
   - **Result**: update.sh에 save/restore 추가 후 S3 통합 테스트 PASS

## 🔍 발견 사항

- `uninstall.sh:87`의 `jq 'del(.hooks)'`는 여전히 kit hook과 user hook을 구분 없이 제거. `uninstall.sh` 단독 실행 시 user hook이 소실되는 한계는 존재 (update.sh 경유 시에는 복원됨)
- PreToolUse 내부에 사용자가 직접 커스텀 hook entry를 추가하는 경우는 여전히 보존 안 됨 — 후속 spec 후보로 icebox 적합

## 🚧 이월 항목

- PreToolUse / SessionStart 내부 항목 레벨 병합 → Icebox
- `uninstall.sh` 단독 실행 시 user hook 보존 → Icebox

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-28 |
| **최종 commit** | `60e10c7` |
