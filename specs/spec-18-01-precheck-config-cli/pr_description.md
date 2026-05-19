# feat(spec-18-01): sdd config precheck list/add/remove 구현

## 📋 Summary

### 배경 및 목적

harness-kit을 사용하는 프로젝트에서 PR 전 lint/type-check 등 precheck를 빠뜨려 CI에서 에러가 발견되는 패턴이 반복됨. `installed.json`에 precheck 명령을 등록하고 CLI로 관리할 수 있는 기반 인프라가 필요.

### 주요 변경 사항
- [x] `sdd config precheck list` — 등록된 precheck 명령 목록 번호 포함 출력
- [x] `sdd config precheck add <command>` — precheck 배열 추가. 중복 시 warn + skip. 활성 spec `task.md` 마커 자동 동기화
- [x] `sdd config precheck remove <index>` — 1-기반 인덱스로 제거. 범위 초과 시 오류. 마커 자동 동기화
- [x] `_sync_precheck_task_marker()` 헬퍼 — 활성 spec의 `task.md` `<!-- sdd:precheck:start/end -->` 마커 구간을 현재 설정으로 교체

### Phase 컨텍스트
- **Phase**: `phase-18` — Precheck Gate
- **본 SPEC 의 역할**: precheck 설정 관리 CLI. 이후 spec-18-02(task.md 템플릿 마커), spec-18-03(hk-ship 실행)의 기반

## 🎯 Key Review Points

1. **`_sync_precheck_task_marker`의 마커 사전 확인**: `sdd_marker_replace`는 마커 없을 때 silent no-op이므로, `grep -qF`로 마커 존재를 먼저 확인하고 없으면 `warn` 출력 후 계속. 명령 성공은 보장.
2. **jq `any(. == $cmd)` 중복 감지**: bash 3.2+ 환경에서 배열 중복 검사를 jq에 위임하는 패턴. `any()` 함수가 올바른 boolean을 반환하는지 주의.
3. **1-기반 인덱스 → 0-기반 jq del**: `remove <N>` 입력을 `jq del(.precheck[$((N-1))])` 로 변환. 범위 검사는 bash에서 `jq length`로 선행 처리.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-precheck-config.sh
```

**결과 요약**:
- ✅ T1 — precheck add: installed.json 배열 추가
- ✅ T2 — 중복 add: warn + skip
- ✅ T3 — list: 번호 포함 출력 / 빈 상태 안내
- ✅ T4 — remove 1: 첫 항목 제거, 나머지 유지
- ✅ T5 — 범위 초과: 오류 출력
- ✅ T6 — 마커 있는 task.md: 마커 구간 갱신
- ✅ T7 — 마커 없는 task.md: warn + 명령 성공
- **PASS=8 / FAIL=0**

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-precheck-config.sh`: T1~T7 단위 테스트 (213 lines)

### 🛠 Modified Files
- `sources/bin/sdd` (+114, -2): `cmd_config` precheck 케이스 추가 + 신규 함수 5개 + help 블록 업데이트

**Total**: 2 files changed, 327 insertions(+), 2 deletions(-)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (8/8)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-18.md`
- Walkthrough: `specs/spec-18-01-precheck-config-cli/walkthrough.md`
