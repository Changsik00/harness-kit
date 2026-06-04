# feat(spec-20-01): add director-mode switch (/hk-director + sdd config + 노출)

## 📋 Summary

### 배경 및 목적

ADR-005(context orchestration)의 디렉터 모드를 사용자가 명시적으로 켜고 끌 수 있는 스위치가 없었다. 본 spec 은 phase-20(디렉터 모드)의 첫 조각으로, 모드 토글 + persistent 플래그 + 상태 노출을 추가한다. (프로토콜 행동·모델 config·review 패널은 후속 spec.)

### 주요 변경 사항
- [x] `/hk-director on|off|toggle` 슬래시 커맨드 (sources + 도그푸딩 미러)
- [x] `sdd config director-mode [on|off|toggle]` — `installed.json` `directorMode` boolean (uxMode 대칭)
- [x] `sdd status` 조건부 노출(on 일 때만) + `doctor` 정보성 점검(off 도 pass — WARN 아님)

### Phase 컨텍스트
- **Phase**: `phase-20` (디렉터 모드)
- **본 SPEC 의 역할**: 모드의 *진입점*. 후속 spec(프로토콜/모델 config/review 패널)이 의존할 스위치·플래그·노출 훅 제공.

## 🎯 Key Review Points

1. **`_config_director_mode` (sdd)**: `uxMode` 패턴 대칭. boolean 저장에 `--argjson` 사용(문자열용 `--arg` 아님) — 주의 지점.
2. **doctor off = `_doc_pass`**: off 는 의도적 기본값이라 WARN 카운트 오염 방지(디렉터 결정).
3. **이중 미러**: self-host 도그푸딩 — `sources/bin/sdd` ↔ `.harness-kit/bin/sdd`, `sources/commands` ↔ `.claude/commands` 동기.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-director-mode.sh
```
**결과 요약**: ✅ 10/10 PASS (명령 존재·frontmatter·미러 parity·config on/off/toggle·status 조건부·doctor 노출)

### 수동 검증 시나리오
1. `sdd config director-mode on` → `sdd status` 에 `Director Mode: on` 출력
2. `sdd config director-mode off` → status 행 미출력, doctor WARN 증가 없음

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/hk-director.md` / `.claude/commands/hk-director.md`: 토글 커맨드 + 미러
- `tests/test-director-mode.sh`: 단위 테스트 10 케이스

### 🛠 Modified Files
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: config director-mode 라우팅·함수, status·doctor 노출
- `backlog/phase-20.md`: spec-20-01 표 등록

**Total**: 5 new + 3 modified

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (10/10)
- [x] (통합 테스트 불필요 — Integration Test Required = no)
- [x] `walkthrough.md` ship commit
- [x] `pr_description.md` ship commit
- [x] Shell 프로젝트 — lint/type check 불필요
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-20.md`
- Walkthrough: `specs/spec-20-01-director-switch/walkthrough.md`
- 관련 ADR: `docs/decisions/ADR-005-context-orchestration.md`, `docs/decisions/ADR-006-director-mode.md`
