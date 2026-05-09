# Walkthrough: spec-x-hook-bypass-fix

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Bash 우회 방어 방식 | (A) Bash 명령 파싱 vs (B) git pre-commit hook | B | Bash 명령 파싱은 패턴이 너무 많아 유지보수 불가. git commit 시점 안전망이 더 단순하고 견고 |
| `Write(~/**)` 수정 방식 | 단순 제거 vs 구체적 경로로 교체 | 구체적 경로로 교체 | 완전 제거 시 홈 디렉토리 보안 의도가 사라짐. `~/.ssh`, `~/.aws` 등 실제 민감 경로만 차단 |
| `git rev-parse --show-toplevel` 사용 | 항상 재계산 vs env 우선 | `${HARNESS_ROOT:-...}` env 우선 | 테스트 중 HARNESS_ROOT를 주입해야 하므로, 기존 env 변수가 있으면 신뢰 |
| `git diff --cached` 호출 방식 | 현재 디렉토리 기준 vs `-C "$HARNESS_ROOT"` | `-C "$HARNESS_ROOT"` 명시 | 현재 작업 디렉토리가 repo 외부일 때도 안전하게 동작 |

## 💬 사용자 협의

- **주제**: Bash 우회 방어 방식
  - **사용자 의견**: Bash 명령 파싱 대신 환경 감지 + 가이드 방식. git pre-commit hook으로 안전망 설치, doctor가 미설치를 감지하고 가이드
  - **합의**: git pre-commit hook 방식으로 결정. install / uninstall / doctor 연동 포함

- **주제**: `Write(~/**)` deny 규칙 발견
  - **사용자 경험**: spec.md 최초 작성 시 Write 툴이 차단됨. 이 규칙이 오히려 Bash 우회를 강제하는 아이러니 상황 발생
  - **합의**: 동일 spec 범위에서 함께 수정. 구체적 경로로 교체

## 🧪 검증 결과

### 1. 자동화 테스트

#### 신규 테스트 — git pre-commit hook
- **명령**: `bash tests/test-git-precommit-hook.sh`
- **결과**: ✅ Passed (10/10)
```text
PASS: 10  FAIL: 0
```

#### 신규 테스트 — settings deny 규칙
- **명령**: `bash tests/test-install-settings-hook.sh`
- **결과**: ✅ Passed (7/7) — Test 6 신규 포함
```text
PASS: 7  FAIL: 0
```

#### 회귀 테스트
- `bash tests/test-staged-lint.sh`: ✅ 6/6 PASS
- `bash tests/test-hk-doctor.sh`: ✅ 6/6 PASS
- `bash tests/test-update.sh`: ✅ 11/11 PASS

### 2. 수동 검증

1. **Action**: `bash doctor.sh .` 실행 (`.git/hooks/pre-commit` 설치 후)
   - **Result**: `✓ .git/hooks/pre-commit 설치됨 (harness 블록 확인)` 출력

2. **Action**: `Write(~/**)` 제거 후 Edit 툴로 파일 수정 시도
   - **Result**: Edit 툴 정상 동작 확인 (이 walkthrough 파일 포함)

## 🔍 발견 사항

- **Test 10 위양성 패턴**: 초기 Test 10이 `.harness-kit/hooks/pre-commit.sh` 파일 존재만으로 통과. `grep -qi "pre-commit"` 단순 검사는 잘못된 이유로 통과 가능 → 이번 spec에서 더 구체적인 패턴으로 수정
- **`Write(~/**)` 부작용**: 이 deny 규칙이 역설적으로 Bash 우회를 강제하는 상황 만들었음. 도그푸딩 환경에서만 발견 가능한 패턴. 향후 harness-kit 설치 시 바로 수정 전파됨
- **`check-scope.sh` 동일 gap 존재**: plan-accept와 동일하게 Bash 우회 가능. 이번 scope 제외 — Icebox 후보

## 🚧 이월 항목

- `check-scope.sh` Bash 우회 문제 → `backlog/queue.md` Icebox 추가 예정

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 |
| **최종 commit** | `b3753f8` |
