# docs(spec-x-hk-update-remote): /hk-update 안내를 원격 실행 1차로 전환

## 📋 Summary

### 배경 및 목적
다른 프로젝트에서 `/hk-update` 를 따라 실행하면 "파일을 찾을 수 없음" 오류가 자주 발생했다. 안내가 *로컬에 클론된 kit 디렉토리* 를 전제로 `bash <kit-dir>/update.sh .` 형태를 권장하기 때문이다. 사용자가 kit 을 클론한 적이 없거나, 다른 머신/계정의 경로를 기억하면 바로 막힌다.

`get.sh` 는 이미 `--update` 분기를 갖고 있어, **원격에서 직접 갱신**하는 경로가 기술적으로 존재한다 (`get.sh:95-97`). 안내 메시지만 정렬하면 새 코드 없이 사용자 경험을 정상화할 수 있다.

### 주요 변경 사항
- [x] `/hk-update` §5 "업데이트 실행" 안내를 **원격 curl 1차 + 로컬 fallback 2차** 구조로 교체
- [x] `sdd status` 의 kit 업데이트 알림 문구를 `/hk-update` 하나로 단순화
- [x] `README.md` 키트 진입점 표에 원격 갱신 명령 행 추가

### Phase 컨텍스트
- **Phase**: 없음 (Solo Spec — `spec-x-{slug}`)
- **본 SPEC 의 역할**: install/update 진입점의 비대칭(install 은 원격 1줄, update 는 로컬 클론 필요)을 해소.

## 🎯 Key Review Points

1. **`sources/commands/hk-update.md` §5**: 원격 1차 / 로컬 2차 / 비-GitHub graceful skip / 안전 문구 4단 구성이 흐름상 자연스러운지. `<owner>/<repo>` 가 `kitOrigin` 도출 로직(§2)과 일치하는지.
2. **에이전트 자동 실행 금지 문구 유지**: `update` 는 uninstall → install 재실행이라는 파괴적 동작이므로, 슬래시 커맨드에서 자동 실행하지 않는다는 안전 문구를 유지했다.
3. **하위 호환**: `update.sh` 와 `get.sh` 의 인터페이스는 변경하지 않음. 기존 로컬 클론 사용자는 동일하게 동작한다.

## 🧪 Verification

### 자동 테스트
본 spec 은 문서 변경만 포함 → 자동 테스트 대신 정적 grep 점검:

```bash
grep -qF 'get.sh) --update' sources/commands/hk-update.md
grep -qF 'bash <kit-dir>/update.sh' sources/commands/hk-update.md
grep -n  '/hk-update'         sources/bin/sdd
grep -qF 'curl ... get.sh) --update' README.md
```

**결과 요약**:
- ✅ 원격 명령 라인 추가됨
- ✅ 로컬 fallback 라인 보존됨 (하위 호환)
- ✅ `sdd status` 알림 문구 단순화 (`/hk-update` 단일 진입점)
- ✅ README 표에 원격 갱신 행 추가

### 수동 검증 시나리오
1. **시나리오 1**: `/hk-update` 본문 통독 → 원격 1차 → 로컬 fallback → 비-GitHub graceful skip → 안전 문구 순서로 흐름 자연.
2. **시나리오 2**: `get.sh --update` 가 내부적으로 `update.sh` 를 호출하는 분기(`get.sh:95-97`) 재확인 → 코드 변경 없으므로 회귀 위험 0.

## 📦 Files Changed

### 🛠 Modified Files
- `sources/commands/hk-update.md` (+18, -8): §5 본문 교체.
- `sources/bin/sdd` (+1, -1): kit 알림 문구 단순화.
- `README.md` (+2, -1): 키트 진입점 표에 원격 갱신 명령 행 추가.

### 🆕 New Files
- `specs/spec-x-hk-update-remote/spec.md`
- `specs/spec-x-hk-update-remote/plan.md`
- `specs/spec-x-hk-update-remote/task.md`
- `specs/spec-x-hk-update-remote/walkthrough.md`
- `specs/spec-x-hk-update-remote/pr_description.md`

**Total**: 3 production files modified + 5 spec artifacts.

## ✅ Definition of Done

- [x] (해당 없음) 자동 단위 테스트 — 문서 변경
- [x] 정적 grep 점검 4종 PASS
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] (해당 없음) lint / type check — 문서 변경
- [x] 사용자 검토 요청 알림 완료
