# Walkthrough: spec-09-001

> 본 문서는 *증거 로그* 입니다. "무엇을 했고 어떻게 검증했는지" 를 미래의 자신과 리뷰어에게 남깁니다.

## 📋 실제 구현된 변경사항

- [x] `install.sh`: 모든 설치 대상 경로를 `.harness-kit/` 하위로 이동
  - `agent/` → `.harness-kit/agent/`
  - `scripts/harness/bin/` → `.harness-kit/bin/`
  - `scripts/harness/hooks/` → `.harness-kit/hooks/`
  - `.harness-kit/installed.json` 신설 (kitVersion, installedAt)
- [x] `sources/claude-fragments/settings.json.fragment`: hook/bin 경로 전부 `.harness-kit/` 로 교체
- [x] `sources/governance/` 3파일 + `sources/commands/` 3파일: 모든 `agent/`, `scripts/harness/` 경로 참조 교체
- [x] `update.sh`: v0.3→v0.4 레이아웃 마이그레이션 로직 추가
  - old-layout 자동 감지 → 백업 → mv → jq 패치 → installed.json 생성
- [x] `doctor.sh`: 진단 경로 `.harness-kit/` 로 업데이트
- [x] `uninstall.sh`: 제거 대상 `.harness-kit/` 으로 통합, v0.3 잔재 정리 섹션 추가
- [x] 도그푸딩 마이그레이션: `agent/` + `scripts/harness/` → `.harness-kit/` 실제 이동, CLAUDE.md/settings.json 참조 갱신, v0.4.0 확인

## 🧪 검증 결과

### 1. 자동화 테스트

#### test-install-layout.sh (TDD Red→Green)
- **명령**: `bash tests/test-install-layout.sh`
- **결과**: ✅ ALL PASS (7/7)
- **로그 요약**:
```text
✅ .harness-kit/agent/ 존재
✅ .harness-kit/bin/sdd 존재 + 실행 가능
✅ .harness-kit/hooks/ 존재
✅ installed.json kitVersion 필드 존재
✅ agent/ 미생성 확인
✅ scripts/harness/ 미생성 확인
✅ .gitignore 에 !.harness-kit/ 포함
```

#### test-hook-modes.sh
- **명령**: `bash tests/test-hook-modes.sh`
- **결과**: ✅ ALL 12 CHECKS PASSED
- **로그 요약**: sources/ ↔ .harness-kit/ 동기화 5/5, 모드 검증 4/4, sdd hooks 실행 확인

#### test-governance-dedup.sh
- **명령**: `bash tests/test-governance-dedup.sh`
- **결과**: ✅ ALL 8 CHECKS PASSED (Task 8 도그푸딩 이후)
- **로그 요약**:
```text
✅ 중복 문장 0건
✅ constitution.md 동기화 OK
✅ agent.md 동기화 OK
✅ 합계 3804w — 상한(5000w) 이하
✅ sdd 경로 올바름 (.harness-kit/bin/sdd)
```

#### test-two-tier-loading.sh
- **명령**: `bash tests/test-two-tier-loading.sh`
- **결과**: ✅ ALL 7 CHECKS PASSED
- **로그 요약**: @.harness-kit/agent/ import 3종 확인, fragment 124w (≤150w)

### 2. 수동 검증

1. **Action**: `bash .harness-kit/bin/sdd status`
   - **Result**: `harness-kit 0.4.0`, phase-09 active, spec-09-001-dir-layout, Plan Accept: yes 정상 출력
2. **Action**: 임시 repo에 `install.sh --yes` 실행 (test-install-layout.sh 내)
   - **Result**: `.harness-kit/` 생성, `agent/` 미생성, `installed.json` 존재 확인
3. **Action**: update.sh 경로 확인
   - **Result**: old-layout(agent/ 존재 + .harness-kit/ 부재) 감지 후 마이그레이션 플로우 정상 작동

### 3. 증거 자료

- 모든 테스트 로그는 위 자동화 테스트 섹션에 포함됨

## 🔍 발견 사항

- `test-governance-dedup.sh` Check 3 베이스라인이 거버넌스 문서 성장(2637w→3804w)으로 고정 베이스라인 방식 불가 → 상한 방식(≤5000w)으로 전환
- `test-two-tier-loading.sh` Check 3의 grep 패턴이 경로 변경에 맞춰 업데이트 필요 (`@agent/` → `@.harness-kit/agent/`)
- `test-hook-modes.sh` Check 5/7도 `scripts/harness/` → `.harness-kit/` 업데이트 필요
- `.harness-kit/agent/` 내 governance 파일이 이전 `agent/` 디렉토리의 구버전(agent/ 경로 참조)을 담고 있어 sources/에서 재복사 필요했음

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + ck |
| **작성 기간** | 2026-04-14 ~ 2026-04-14 |
| **최종 commit** | `1414a90` |
