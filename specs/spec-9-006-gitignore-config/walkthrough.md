# Walkthrough: spec-9-006

> 증거 로그 — 무엇을 했고 어떻게 검증했는지.

## 📋 실제 구현된 변경사항

- [x] `install.sh` Section 1: `--gitignore` / `--no-gitignore` 플래그 추가, `HK_GITIGNORE=-1` 초기값
- [x] `install.sh` Section 5b 신설: gitignore UX 질문 (`ASSUME_YES=1`이면 기본 Y 자동 처리)
- [x] `install.sh` Section 16: 조건부 `.gitignore` 처리 (기본 → `.harness-kit/`, `--no-gitignore` → `!.harness-kit/`)
- [x] `install.sh` Section 17: `harness.config.json`에 `"gitignore": true|false` 필드 포함
- [x] `update.sh`: uninstall 전 `gitignore` 필드 읽어 `--gitignore`/`--no-gitignore` 로 install에 전달
- [x] `tests/test-gitignore-config.sh` 신설 (11 checks)
- [x] `tests/test-install-layout.sh` Check 7 업데이트 (구: `!.harness-kit/` → 신: `.harness-kit/`)

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-gitignore-config.sh`
- **결과**: ✅ 11 / 11 PASS

```text
▶ Scenario A: --yes 설치 (기본 gitignore=true)
  ✅ A-1: .gitignore에 '.harness-kit/' 포함
  ✅ A-2: harness.config.json gitignore=true
  ✅ A-3: .gitignore에 '!.harness-kit/' 미포함 (un-ignore 없음)

▶ Scenario B: --no-gitignore 설치
  ✅ B-1: .gitignore에 '!.harness-kit/' 포함 (un-ignore)
  ✅ B-2: harness.config.json gitignore=false

▶ Scenario C: --gitignore 명시 설치
  ✅ C-1: --gitignore 플래그 → '.harness-kit/' in .gitignore

▶ Scenario D: 재설치 멱등성
  ✅ D-1: 재설치 후 '.harness-kit/' 항목 1개 (중복 없음)

▶ Scenario E: update.sh 후 gitignore=true 보존
  ✅ E-1: update 후 '.harness-kit/' 유지
  ✅ E-2: update 후 harness.config.json gitignore=true 유지

▶ Scenario F: update.sh 후 gitignore=false 보존
  ✅ F-1: update 후 '!.harness-kit/' 유지
  ✅ F-2: update 후 harness.config.json gitignore=false 유지
```

- **관련 테스트 전체**:
  - `test-install-layout.sh`: ✅ 7/7 PASS
  - `test-path-config.sh`: ✅ 10/10 PASS
  - `test-update.sh`: ✅ 7/7 PASS
  - `test-install-claude-import.sh`: ✅ 6/6 PASS
  - `test-hook-modes.sh`: ✅ 12/12 PASS

## 🔍 발견 사항

- jq의 `//` 대체 연산자는 `false`를 falsy로 처리하여 "MISSING"을 반환함. `has("gitignore")`로 존재 여부를 먼저 확인해야 함. 테스트 및 update.sh에 반영.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + ck |
| **작성 기간** | 2026-04-15 |
| **최종 commit** | `9e051f7` |
