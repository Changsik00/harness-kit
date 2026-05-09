# feat(spec-x-update-migration): update.sh 버전 인식 마이그레이션 시스템

## 📋 Summary

### 배경 및 목적

`update.sh`가 버전을 확인하지 않고 단순 덮어쓰기만 수행했습니다. 그 결과:
- 폐기된 파일(예: `hk-spec-review.md`)이 업데이트 후에도 잔존
- 신규 훅 5개 추가 등 기능 변경이 있어도 사용자에게 전달되지 않음
- `install.sh` 호출 시 `phase`/`spec`/`planAccepted` state가 초기화되는 버그

이번 변경은 버전 인식 마이그레이션 시스템을 도입하고, 향후 버전 관리의 기반을 마련합니다.
또한 Phase 없이 독립적으로 진행 가능한 Solo Spec(`spec-x-{slug}`) 패턴을 constitution에 공식화합니다.

### 주요 변경 사항

- [x] `update.sh` 전면 재작성 — 버전 비교, 마이그레이션 실행, state 보존/복원, `--shell=` 패스스루
- [x] `sources/migrations/0.4.0.sh` 신설 — 버전별 폐기 파일 목록 + 신규 기능 안내
- [x] `VERSION` 0.3.0 → 0.4.0, `CHANGELOG.md` 신설
- [x] `constitution.md` §4.1, §5.2에 `spec-x-{slug}` Solo Spec 패턴 공식화

### Phase 컨텍스트

- **Phase**: 없음 (Solo Spec — constitution §4.1 예외 조항 최초 적용)
- **본 SPEC의 역할**: 키트 유지보수 인프라 개선 + 거버넌스 확장

## 🎯 Key Review Points

1. **update.sh 마이그레이션 실행 로직**: `_ver_gt` / `_ver_lte` 비교 함수로 버전 구간 내 마이그레이션만 선택 실행. `sources/migrations/*.sh`를 버전 순 정렬(`sort -V`)로 순회
2. **state 보존/복원**: `install.sh` 호출 전 `jq`로 `phase`/`spec`/`planAccepted`/`lastTestPass` 저장 → 호출 후 복원. 기존 버그 수정
3. **constitution spec-x 조항**: `chore`/`fix`/`docs`/소규모 `refactor` 한정 조건 명시. 아키텍처 변경/Feature는 여전히 Phase 필수

## 🧪 Verification

### 자동 테스트
```bash
bash -n update.sh
bash -n sources/migrations/0.4.0.sh
```

**결과 요약**:
- ✅ `update.sh` syntax: 통과
- ✅ `sources/migrations/0.4.0.sh` syntax: 통과

### 수동 검증 시나리오
1. **`./update.sh --help`** → 사용법 정상 출력
2. **구버전(0.3.x) 설치 환경에서 `./update.sh`** → 마이그레이션 안내 + 폐기 파일 제거 흐름 확인 (end-to-end는 이월)

## 📦 Files Changed

### 🆕 New Files
- `CHANGELOG.md`: 0.1.0 ~ 0.4.0 버전 이력
- `sources/migrations/0.4.0.sh`: 0.4.0 마이그레이션 스크립트
- `specs/spec-x-update-migration/`: spec 산출물 (spec/plan/task/walkthrough/pr_description)

### 🛠 Modified Files
- `VERSION` (+1, -1): 0.3.0 → 0.4.0
- `update.sh` (+247, -18): 전면 재작성
- `sources/governance/constitution.md` (+10): spec-x 패턴 추가
- `agent/constitution.md` (+10): 동일 반영 (도그푸딩)

**Total**: 7 files changed

## ✅ Definition of Done

- [x] syntax 검증 통과 (`bash -n`)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-update-migration/walkthrough.md`
- CHANGELOG: `CHANGELOG.md`
