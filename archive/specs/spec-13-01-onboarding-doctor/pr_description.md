# feat(spec-13-01): add sdd doctor subcommand and hk-doctor slash command

## 📋 Summary

### 배경 및 목적
harness-kit 설치 후 환경이 올바르게 구성됐는지 확인하는 방법이 없었다. 필수 도구 미설치나 파일 누락 시 cryptic error가 발생해 온보딩 마찰이 높았다. `sdd doctor` 명령과 `/hk-doctor` 슬래시 커맨드로 설치 환경을 즉시 진단할 수 있게 한다.

### 주요 변경 사항
- [x] `sdd doctor` 서브커맨드 추가 — bash/jq/git/gh 도구 체크 + 설치 파일 + 훅 권한 + .claude/settings.json 체크리스트
- [x] `/hk-doctor` 슬래시 커맨드 추가 (`sources/commands/hk-doctor.md`) — `sdd doctor` 호출 wrapper
- [x] `sdd help` 에 `doctor` 항목 추가
- [x] `tests/test-hk-doctor.sh` 추가 — 6개 항목 검증

### Phase 컨텍스트
- **Phase**: `phase-13` — 개발자 경험(DX) 향상 — 자동화 & 온보딩
- **본 SPEC의 역할**: 온보딩 첫 단계 — 설치 직후 환경 검증 자동화로 진입 마찰 제거

## 🎯 Key Review Points

1. **gh 처리 (WARN)**: gh 미설치 시 FAIL이 아닌 WARN 처리. spec-13-02에서 gh 필수성이 높아지지만 현재는 선택 도구로 분류. exit 0 보장.
2. **exit 0 보장**: FAIL 항목이 있어도 항상 exit 0. doctor는 진단 도구이므로 프로세스를 차단하지 않아야 함.
3. **sdd 동기화**: `sources/bin/sdd` 수정 시 `.harness-kit/bin/sdd`도 함께 복사 필요 (test-hook-modes.sh Check 5가 검증).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-hk-doctor.sh
```

**결과 요약**:
- ✅ sdd doctor 명령 인식됨
- ✅ exit code 0
- ✅ hk-doctor.md 존재 + frontmatter
- ✅ sdd help에 doctor 포함
- ✅ bash/jq/git 항목 모두 포함

### 수동 검증 시나리오
1. **`bash sources/bin/sdd doctor`** → 체크리스트 형식 출력, 종합 판정 출력
2. **`bash sources/bin/sdd help | grep doctor`** → `doctor` 항목 포함 확인

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/hk-doctor.md`: hk-doctor 슬래시 커맨드
- `tests/test-hk-doctor.sh`: doctor 기능 단위 테스트 (6 checks)

### 🛠 Modified Files
- `sources/bin/sdd` (+95): `cmd_doctor()` 함수 + case 분기 + help 항목 추가
- `.harness-kit/bin/sdd`: sources/bin/sdd 동기화

**Total**: 4 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (6/6 PASS)
- [x] 전체 테스트 스위트 FAIL=0
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-13.md`
- Walkthrough: `specs/spec-13-01-onboarding-doctor/walkthrough.md`
