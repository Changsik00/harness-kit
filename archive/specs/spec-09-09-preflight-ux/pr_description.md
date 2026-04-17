# feat(spec-09-09): preflight UX — 설치/업데이트 전 사전 스캔

## 📋 Summary

### 배경 및 목적

install.sh/update.sh 실행 전 잠재적 충돌/위험을 사전 감지하여 사용자에게 알려주는 preflight 스캔 추가.

### 주요 변경 사항
- [x] install.sh: 이미 설치됨/v0.3 잔재/기존 hooks 감지 → 경고 출력 + 확인
- [x] update.sh: version downgrade/v0.3 잔재 감지 + state 복원 graceful fallback
- [x] critique 반영: inline 방식 (별도 preflight.sh 없음), semver_lt 재사용, hooks 조건 구체화

### Phase 컨텍스트
- **Phase**: `phase-09`
- **본 SPEC의 역할**: 설치/업데이트 UX 개선 — 문제를 사후가 아닌 사전에 감지

## 🎯 Key Review Points

1. **install.sh §3.5 위치**: git repo 확인 후, 설치 계획 출력 전
2. **update.sh state fallback**: jq 파싱 실패 시 경고만 출력하고 기본값 유지

## 🧪 Verification

```bash
bash tests/test-preflight.sh      # 5/5 PASS
bash tests/test-update.sh         # 7/7 PASS
bash tests/test-install-layout.sh # 7/7 PASS
```

## 📦 Files Changed

### 🆕 New Files
- `tests/test-preflight.sh`: preflight 스캔 검증 테스트

### 🛠 Modified Files
- `install.sh`: §3.5 Preflight 스캔 블록 추가
- `update.sh`: preflight 블록 + semver_lt + state fallback

**Total**: 3 files changed

## ✅ Definition of Done

- [x] install.sh preflight 추가
- [x] update.sh preflight + fallback 추가
- [x] 테스트 통과 (신규 + 회귀)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료

## 🔗 관련 자료

- Phase: `backlog/phase-09.md`
- Critique: `specs/spec-09-09-preflight-ux/critique.md`
- Walkthrough: `specs/spec-09-09-preflight-ux/walkthrough.md`
