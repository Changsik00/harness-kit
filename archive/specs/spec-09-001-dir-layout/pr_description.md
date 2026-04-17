# refactor(spec-09-001): move all harness-kit artifacts to .harness-kit/ hidden directory

## 📋 Summary

### 배경 및 목적

harness-kit을 프로젝트에 설치하면 `agent/`와 `scripts/harness/` 디렉토리가 생성되어 기존 프로젝트 구조와 충돌 위험이 있었음 (`agent/`는 LangChain 등 AI 프레임워크와 충돌, `scripts/`는 기존 스크립트 디렉토리 오염). 모든 harness-kit 산출물을 숨김 디렉토리 `.harness-kit/`으로 통합하여 네임스페이스 충돌을 원천 차단함.

### 주요 변경 사항
- [x] **install.sh**: 설치 경로 전면 교체 (`agent/` → `.harness-kit/agent/`, `scripts/harness/` → `.harness-kit/bin|hooks`) + `.harness-kit/installed.json` 신설
- [x] **sources/governance/ + sources/commands/**: 모든 내부 경로 참조 `.harness-kit/` 로 업데이트
- [x] **settings.json.fragment**: hook command 경로 `.harness-kit/hooks/` 로 업데이트
- [x] **update.sh**: v0.3 old-layout 자동 감지 + `.harness-kit/` 마이그레이션 로직 추가
- [x] **doctor.sh + uninstall.sh**: 진단/제거 경로 `.harness-kit/` 로 업데이트
- [x] **도그푸딩**: 이 프로젝트 자체를 `.harness-kit/` 레이아웃으로 마이그레이션, v0.4.0 확인

### Phase 컨텍스트
- **Phase**: `phase-09` — install-conflict-defense
- **본 SPEC 의 역할**: Phase 9의 첫 스펙으로, 가장 근본적인 충돌 원인인 디렉토리 네임스페이스 오염을 해결. 이후 spec-09-002(CLAUDE.md @import), spec-09-003(config 시스템), spec-09-004(preflight UX)의 기반 레이아웃을 확정함.

## 🎯 Key Review Points

1. **install.sh 경로 전환**: `.harness-kit/`으로 이동 후 설치된 프로젝트의 `installed.json` 생성 여부 — `test-install-layout.sh` 7개 검증 항목 확인
2. **update.sh old-layout 감지 로직**: `agent/` 존재 + `.harness-kit/` 부재를 v0.3으로 판정하고 자동 마이그레이션. 백업(`mv` 전 `cp -rf`) 후 이동하므로 데이터 손실 없음.
3. **settings.json.fragment 경로**: 모든 PreToolUse hook command가 `.harness-kit/hooks/*.sh`를 올바르게 가리키는지

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-install-layout.sh   # 새 레이아웃 설치 검증
bash tests/test-hook-modes.sh       # hook 모드 + sources 동기화
bash tests/test-governance-dedup.sh # governance 경로 + 동기화
bash tests/test-two-tier-loading.sh # align 커맨드 @import 경로
```

**결과 요약**:
- ✅ `test-install-layout.sh`: 7/7 PASS
- ✅ `test-hook-modes.sh`: 12/12 PASS
- ✅ `test-governance-dedup.sh`: 8/8 PASS
- ✅ `test-two-tier-loading.sh`: 7/7 PASS

### 수동 검증 시나리오
1. **sdd 정상 작동**: `bash .harness-kit/bin/sdd status` → `harness-kit 0.4.0`, phase-09 active
2. **신규 설치**: 임시 repo에서 `install.sh --yes` → `.harness-kit/` 생성, `agent/` 미생성

## 📦 Files Changed

### 🆕 New Files
- `.harness-kit/installed.json`: 버전 추적 파일 (kitVersion, installedAt)
- `tests/test-install-layout.sh`: 새 레이아웃 검증 TDD 테스트
- `sources/migrations/0.4.0.sh`: v0.4.0 마이그레이션 안내 스크립트

### 🛠 Modified Files
- `install.sh`: 설치 경로 전면 교체
- `update.sh`: old-layout 마이그레이션 로직 추가
- `doctor.sh`: 진단 경로 업데이트
- `uninstall.sh`: 제거 경로 업데이트, v0.3 잔재 정리
- `sources/governance/constitution.md`, `agent.md`, `align.md`: 경로 참조 업데이트
- `sources/commands/hk-align.md`, `hk-cleanup.md`, `hk-phase-ship.md`: 경로 참조 업데이트
- `sources/claude-fragments/settings.json.fragment`: hook 경로 업데이트
- `.claude/settings.json`: hook 경로 도그푸딩 업데이트
- `CLAUDE.md`: agent/ 경로 참조 → .harness-kit/agent/
- `tests/test-hook-modes.sh`, `test-governance-dedup.sh`, `test-two-tier-loading.sh`: 경로 업데이트

### 🗑 Deleted Files (renamed)
- `agent/` → `.harness-kit/agent/` (11 files renamed)
- `scripts/harness/bin/` → `.harness-kit/bin/` (4 files renamed)
- `scripts/harness/hooks/` → `.harness-kit/hooks/` (9 files renamed)

**Total**: 36 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (34/34 checks)
- [x] `bash .harness-kit/bin/sdd status` → harness-kit 0.4.0 정상 출력
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-09.md`
- Walkthrough: `specs/spec-09-001-dir-layout/walkthrough.md`
