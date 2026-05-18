# Walkthrough: spec-x-kit-update-notify

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 버전 알림 전달 방법 | (A) check-kit-version.sh 단독 / (B) sdd --brief 에 suffix 포함 | **(B)** | Claude Code compact format 은 첫 번째 훅 출력만 포함. (A)는 두 번째 훅이라 에이전트 컨텍스트에 도달하지 못함 |
| hk-update 실행 주체 | (A) 사용자가 직접 복사-붙여넣기 / (B) 에이전트가 Bash 직접 실행 / (C) 임시 동의 후 직접 실행 | **(C)** | (A)는 기존 방식이고 "잘 안돼"의 원인. (B)는 확인 없는 destructive 작업. (C)는 step 4에서 이미 Y/n 확인을 받으므로 추가 마찰 없음 |
| check-kit-version.sh 유지 여부 | 제거 / 유지 | **유지** | cache.json 갱신 역할(24h TTL) 담당. 제거하면 brief의 suffix도 캐시 없어 동작 안 함 |

### ADR 승격 가이드

- [x] 없음 — 특정 slash command 실행 정책 변경, 이 프로젝트 한정

## 💬 사용자 협의

- **주제**: hk-update 시 에이전트가 직접 실행할 수 있는지 / 어떤 방식이 낫는지
  - **사용자 의견**: 처음엔 규칙 제거 고려 → 특별 항목으로 임시 동의 방식 선택
  - **합의**: step 4 Y/n 확인 후 에이전트 Bash 직접 실행 (임시 동의 기반)

## 🧪 검증 결과

### 자동화 테스트

| 테스트 | 결과 |
|---|---|
| `tests/test-install-claude-import.sh` | ✅ ALL PASS (6/6) |
| `tests/test-marker-append-guard.sh` | ✅ ALL 5 CHECKS PASSED |
| `tests/test-marker-edge-cases.sh` | ✅ ALL 8 CHECKS PASSED |

`sdd test passed` → `lastTestPass: 2026-05-18T07:59:18Z`

### 수동 검증

1. **Action**: `cache.json`에 `latestKnownVersion: "0.99.0"` 임시 기록 후 `sdd status --brief`
   - **Result**: `harness-kit 0.12.0 →UPDATE:0.99.0 | ...` ✅
2. **Action**: `cache.json` 없는 상태에서 `sdd status --brief`
   - **Result**: `harness-kit 0.12.0 | ...` (기존 포맷 그대로) ✅

## 🔍 발견 사항

- **compact 포맷의 단일 훅 제약 확인**: 이번 작업에서 Claude Code `compact hook success` 포맷이 첫 번째 훅 출력만 포함한다는 것을 실증적으로 확인. `check-kit-version.sh`가 두 번째 훅이라 에이전트가 그 출력을 볼 수 없었던 것. brief suffix 방식이 이를 우회하는 올바른 해결책.
- **`sources/claude-fragments/` 업데이트 불필요 확인**: `settings.json` IMPORTANT 에코는 `install.sh`가 직접 삽입하는 하드코딩 구문이 아니라 현재 `.claude/settings.json`에만 존재. `sources/` 에는 해당 fragment 없어서 dogfooding 동기화로 충분.
- **get.sh "git pull" 가이드 미확인**: 사용자가 구버전에서 봤다고 보고했으나 현재 `get.sh`에는 해당 문구 없음. 현재 코드 기준 이슈 없음.

## 🚧 이월 항목

- `sources/` 에 `settings.json` IMPORTANT 에코 fragment 추가 — 현재 install.sh가 에코 메시지를 hard-code로 삽입하는지, fragment로 관리하는지 검토 필요. 후속 spec 후보.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-18 |
| **최종 commit** | (push 후 갱신) |
