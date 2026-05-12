# feat(spec-x-governance-ask-user-guideline): AskUserQuestion 가이드라인 + uxMode 설정 + sdd config 커맨드

## 📋 Summary

### 배경 및 목적

거버넌스 문서가 `AskUserQuestion` 툴을 인지하지 않고 텍스트 포맷(1/2, [Y/n])만 명시하여,
Agent가 중요한 결정 포인트에서도 텍스트 목록을 출력하게 됐다.
결과적으로 UX가 텍스트/[Y/n]/화살표선택 세 가지 형태로 혼재됐다.

`agent.md §8.4`를 신설해 주요 결정 포인트에서 `AskUserQuestion` 툴을 SHOULD 사용하도록
가이드라인을 추가한다. 기존 텍스트 포맷은 fallback으로 유지하고, `uxMode` 설정 필드와
`sdd config ux-mode` 커맨드로 사용자가 동작 방식을 제어할 수 있게 한다.

### 주요 변경 사항

- [x] `agent.md §8.4` 신설: `AskUserQuestion` 툴 사용 권장 + uxMode 필드 참조
- [x] `install.sh`: `installed.json` 기본값에 `"uxMode": "interactive"` 추가
- [x] `sources/bin/sdd` + `.harness-kit/bin/sdd`: `sdd config ux-mode [interactive|text]` 커맨드 추가
- [x] `tests/test-sdd-config.sh`: T1~T4 자동화 테스트 추가 (TDD)
- [x] `sources/governance/agent.md` + `.harness-kit/agent/agent.md` 동시 수정 (도그푸딩 동기화)

### Phase 컨텍스트

- **Phase**: `spec-x` (Solo)
- **역할**: 거버넌스 UX 일관성 가이드라인 수립 + 설정 인프라

## 🎯 Key Review Points

1. **§8.4 내용** (`sources/governance/agent.md`): 권장 포인트 표, fallback 조건, uxMode 필드 참조, `sdd config` 변경 명령 포함 여부.
2. **`sdd config ux-mode`**: 인자 없음(현재값 출력) / `text` / `interactive` / 잘못된 값(오류) 네 케이스 처리.
3. **기존 §5.2·§5.7 무변경**: constitution의 텍스트 포맷 규칙은 그대로 — 이 PR은 가이드라인 추가만 한다.
4. **기존 설치본 호환**: `uxMode` 필드 없는 기존 `installed.json`은 `"interactive"` fallback — breaking change 없음.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-config.sh      # PASS=4
bash tests/test-governance-dedup.sh # ALL 8 CHECKS PASSED
```

**결과 요약**:
- ✅ sdd config ux-mode text/interactive/읽기/오류 4가지 시나리오 통과
- ✅ 중복 문장 0건
- ✅ sources ↔ .harness-kit 동기화 OK
- ✅ 섹션 번호 중복 없음

## 📦 Files Changed

### 🛠 Modified Files
- `sources/governance/agent.md`: §8.4 신설 + uxMode 참조
- `.harness-kit/agent/agent.md`: 도그푸딩 동기화
- `install.sh`: installed.json 템플릿에 `"uxMode": "interactive"` 추가
- `sources/bin/sdd`: `cmd_config()`, `_config_ux_mode()` 추가 + 디스패처 + help 텍스트
- `.harness-kit/bin/sdd`: 도그푸딩 동기화

### ✨ New Files
- `tests/test-sdd-config.sh`: sdd config ux-mode TDD 테스트

**Total**: 5 modified, 1 new

## ✅ Definition of Done

- [x] `bash tests/test-sdd-config.sh` PASS
- [x] `bash tests/test-governance-dedup.sh` ALL PASS
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-governance-ask-user-guideline/walkthrough.md`
