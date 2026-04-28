# feat(spec-15-02): stateful upgrade fixture 시스템 — `tests/lib/fixture.sh` + 5 mixin

## 📋 Summary

### 배경 및 목적

spec-15-01 audit §6.5 권고 (옵션 A — 함수 합성) 의 실제 구현. "사용 중인 사용자" 환경 — in-flight phase / 사전 정의 phase / customized fragment / dirty queue / user hook — 를 합성할 수 있는 fixture 헬퍼 라이브러리.

**목표**: spec-15-03 (회귀 테스트) 가 phase-15.md §통합 테스트 시나리오 5개를 작성할 때 사용할 빌딩 블록 제공. 본 spec 자체는 헬퍼 + 헬퍼 단위 테스트만.

### 주요 변경 사항

- [x] `tests/lib/fixture.sh` 신규 — `make_fixture()` (base) + 5 mixin (`with_*`)
- [x] `tests/test-fixture-lib.sh` 신규 — 7 그룹 × 검증 = **18 checks**
- [x] **TDD Red → Green** — Red 단계에서 install.sh 의 queue.md 미생성 문제 발견, base fixture 가 템플릿 복사로 보강
- [x] bash 3.2+ 호환 / 0 부수효과 (source 만으로 디렉토리 생성 안 됨) / public prefix 없음 (가독성)

### Phase 컨텍스트

- **Phase**: `phase-15` (upgrade-safety, base branch: `phase-15-upgrade-safety`)
- **본 SPEC 의 역할**: phase 의 골격 — spec-15-03 (회귀 테스트) 의 의존성. spec-15-04 (P0 fix) 와 병렬 가능.

## 🎯 Key Review Points

1. **`make_fixture()` 의 queue.md 보강** (`tests/lib/fixture.sh:28-32`) — install.sh 가 만들지 않는 queue.md 를 템플릿 복사로 채움. "사용 중인 사용자" 모사. 발견 경위는 walkthrough §발견 사항.
2. **mixin 시그니처 일관성** — 첫 인자 항상 fixture dir. 가변 인자 가능 (`with_pre_defined_phases`).
3. **사용자 추가분 식별 마커** — `TEST_USER_*` (FRAGMENT / ICEBOX_NOTE / HOOK). spec-15-03 회귀 테스트가 update 후 보존 검증 시 이 마커들로 grep.
4. **0 부수효과 + 명시적 정리 책임** — lib 가 글로벌 trap 설치 안 함. 각 테스트가 trap 작성. 다른 테스트와 충돌 회피.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-fixture-lib.sh
bash tests/test-version-bump.sh
```

**결과**:
- ✅ `test-fixture-lib.sh`: 18 / 18 (7 그룹)
- ✅ `test-version-bump.sh`: 6 / 6 + 전체 스위트 FAIL=0

### 수동 검증 시나리오
1. **make_fixture 단독**: `F=$(make_fixture)` → `.harness-kit/`, `backlog/queue.md`, `.claude/state/current.json` 모두 존재.
2. **mixin 조합**: `with_in_flight_phase + with_dirty_queue_icebox + with_user_hook` 동시 적용 시 모든 산출물 정상.

## 📦 Files Changed

### 🆕 New Files
- `tests/lib/fixture.sh`: stateful fixture 헬퍼 라이브러리 (139줄)
- `tests/test-fixture-lib.sh`: 헬퍼 단위 테스트 (18 checks)
- `specs/spec-15-02-stateful-fixture-system/{spec,plan,task,walkthrough,pr_description}.md`

### 🛠 Modified Files
- `backlog/queue.md`: sdd 자동 갱신 (active spec 표시)
- `backlog/phase-15.md`: sdd 자동 갱신 (spec 표 — spec-15-02 추가)

### 코드 변경
- `tests/lib/fixture.sh` 신규만. 기존 테스트 / 코드 수정 없음.

## ✅ Definition of Done

- [x] `tests/lib/fixture.sh` 신규 — `make_fixture` + 5 mixin
- [x] `tests/test-fixture-lib.sh` 18 checks PASS
- [x] 회귀 스위트 PASS
- [x] bash 3.2+ 호환
- [x] walkthrough.md / pr_description.md 작성

## 🔗 관련 자료

- Phase: `backlog/phase-15.md`
- spec-15-01 audit (의존): `specs/spec-15-01-upgrade-danger-audit/spec.md` §6.5
- 다음 spec: spec-15-03 (회귀 테스트 — 본 lib 사용) / spec-15-04 (P0 fix — 병렬 가능)
