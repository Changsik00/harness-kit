# Walkthrough: spec-09-05

## 증거 로그

### Task 2: TDD Red — test-update.sh 작성

```
$ bash tests/test-update.sh
▶ 시나리오 A: 기본 update (state 보존)
  ✅ .harness-kit/ 재생성됨
  ✅ .harness-kit/installed.json 존재
  ✅ state 보존: phase=phase-09 spec=spec-09-05-update-rewrite
  ✅ .harness-uninstall-backup-* 정리됨

▶ 시나리오 B: prefix 있는 경우 (prefix 보존)
  ✅ hk-backlog/ 유지됨
  ✅ hk-specs/ 유지됨
  ❌ harness.config.json backlogDir 손실:

 ❌ 1/7 CHECKS FAILED
```

Commit: `7184a7a test(spec-09-05): add failing test for update.sh rewrite`

---

### Task 3: update.sh 재작성

**1차 시도**: prefix 보존만 수정 → state 손실 발생

```
  ❌ state 손실: phase= spec=
  ✅ harness.config.json backlogDir=hk-backlog 유지
```

install.sh가 state를 항상 초기화하므로, install 전후 state save/restore 추가.

**최종 구조**:
```
1. prefix / 버전 읽기 (uninstall 전)
2. uninstall --yes --keep-state
3. state 임시 저장 (install.sh 가 덮어쓰므로)
4. install --yes [--prefix ...]
5. state 복원
6. cleanup (backup dirs)
7. doctor
```

```
$ bash tests/test-update.sh
 ✅ ALL PASS (7/7)
```

코드: 390줄 → 132줄 (66% 감소)

Commit: `4033ffc refactor(spec-09-05): rewrite update.sh as uninstall+install+cleanup`

---

### 전체 테스트 결과 (Ship 직전)

```
tests/test-update.sh       → ✅ ALL PASS (7/7)
tests/test-path-config.sh  → ✅ ALL PASS (10/10)
tests/test-hook-modes.sh   → ✅ ALL 12 CHECKS PASSED
```
