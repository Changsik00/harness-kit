# feat(spec-x-tool-guidance): doctor.sh에 프로젝트 품질 도구 점검 추가

## 📋 Summary

### 배경 및 목적

stack adapter 제거 후 프로젝트의 lint/test/typecheck 설정 유무를 확인하는 단계가 없었다. `doctor.sh`에 품질 도구 점검 섹션을 추가하여, 설정이 누락된 경우 설치 방법과 함께 안내한다.

### 주요 변경 사항
- [x] `doctor.sh`에 `[7/7] 프로젝트 품질 도구` 섹션 추가
- [x] Node.js/Python/Go 프로젝트 타입 자동 감지
- [x] 타입별 lint, test, typecheck 설정 점검 + 설치 안내 (warn 수준)

### Phase 컨텍스트
- **Phase**: 없음 (Solo Spec)
- **본 SPEC 의 역할**: stack adapter 제거 후 품질 도구 안내 공백 해소

## 🎯 Key Review Points

1. **warn만 사용**: 품질 도구 누락 시 fail이 아닌 warn — 프로젝트 초기에는 아직 설정이 없을 수 있으므로
2. **감지 로직**: package.json / pyproject.toml / go.mod 존재 여부로만 판단 — 단순하고 신뢰성 높음

## 🧪 Verification

### 수동 검증 시나리오
1. `bash -n doctor.sh` → 구문 오류 없음 ✅
2. harness-kit 자체에서 실행 → "프로젝트 타입 감지 불가" warn ✅
3. 기존 섹션 1~6 정상 동작 확인 ✅

## 📦 Files Changed

### 🛠 Modified Files
- `doctor.sh` (+99, -6): 섹션 번호 조정 + `[7/7] 프로젝트 품질 도구` 섹션 추가

**Total**: 1 file changed

## ✅ Definition of Done

- [-] 모든 단위 테스트 통과 — 테스트 대상 아님 (스크립트 수정)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-tool-guidance/walkthrough.md`
- 선행 작업: spec-x-remove-stack-adapter (#28)
