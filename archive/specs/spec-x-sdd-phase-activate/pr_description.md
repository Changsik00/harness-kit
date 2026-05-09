# fix(spec-x-sdd-phase-activate): 사전 정의 phase 활성화 경로 + phase new 가드 + 0.6.2

## 📋 Summary

### 배경 및 목적

사용자가 phase 를 사전 계획해 `backlog/phase-03.md ~ phase-07.md` 처럼 미리 작성해둔 상태에서 `sdd phase new <slug>` 를 실행하면, sdd 는 사전 정의 파일을 인지하지 못하고 max+1 번호로 새 phase 를 만들어 버린다. 사용자가 작성한 본문은 무시되고, queue.md active 마커도 의도와 어긋난다. 결국 사용자는 `state.json` + `queue.md` 를 직접 편집해 우회해야 한다.

본 PR 은 이를 해결한다:

1. **`sdd phase activate <phase-NN>` 신규 명령** — 본문 미수정으로 state/queue active 마커만 갱신.
2. **`sdd phase new` 가드 강화** — 사전 정의 phase 가 있으면 die + 명확한 안내. `--force` 로 우회 가능.
3. **0.6.1 → 0.6.2 bump**.

### 주요 변경 사항

- [x] `sdd phase activate <phase-NN> [--base]` 신규 — 사용자 작성 본문 보존 + state/queue 활성화
- [x] `sdd phase new <slug>` 가드 — 사전 정의 phase 감지 시 die + `phase activate` 안내. `--force` 로 우회
- [x] `--base` 옵션은 phase.md 메타 표의 `Base Branch` 필드(`phase-NN-<slug>` 형식)를 읽음 — 비어있으면 die (자동 조립 안 함)
- [x] `cmd_help` 도움말 갱신
- [x] 신규 테스트 `tests/test-sdd-phase-activate.sh` (13 checks)
- [x] 버전 0.6.2 동기화 (VERSION, installed.json, CHANGELOG, README, test-version-bump)

### Phase 컨텍스트

- **Phase**: 없음 (Solo Spec)
- **본 SPEC 의 역할**: 사전 계획 워크플로우의 핵심 누락 동작 보강. 거버넌스 도구가 사용자 작성 본문을 우선시하도록 정책 명문화.

## 🎯 Key Review Points

1. **`phase_activate()` 의 본문 무수정 정책** (`sources/bin/sdd`) — 사용자가 작성한 phase.md 본문을 일체 변경하지 않음 (placeholder 치환도 하지 않음). Artifact Integrity (constitution §5.4) 와 일관.
2. **`phase_new()` 가드 로직** — `queue_phase_is_done()` 으로 done 섹션을 검사하고, `state.phase` 와 비교해 미활성 phase 를 식별. `--force` 우회 경로는 명시적 의도일 때만 사용.
3. **`--base` + meta 추출** — `phase.md` 메타 표의 `Base Branch` 행에서 `phase-NN-<slug>` 형식만 받아들임. 사용자가 메타를 미리 채우지 않으면 die — 자동 조립 안 함 (한국어 제목과의 충돌 방지).
4. **bash 3.2+ 호환성** — `declare -A`, `mapfile` 등 4+ 전용 기능 미사용. 미정의 변수 + `set -u` 케이스도 회피 (TDD Red 단계 발견사항 walkthrough §발견 사항 참조).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-phase-activate.sh
bash tests/test-version-bump.sh
```

**결과 요약**:
- ✅ `test-sdd-phase-activate.sh`: 13 / 13 (activate 정상/실패, idempotent, --base 메타, phase new 가드, --force 우회, 회귀)
- ✅ `test-version-bump.sh`: 6 / 6 + 전체 스위트 FAIL=0

### 수동 검증 시나리오

1. **사전 정의 phase 활성화**: `backlog/phase-03.md` 작성 → `sdd phase activate phase-03` → `state.phase=phase-03`, phase-03.md 본문 보존, queue.md active 마커 갱신.
2. **`phase new` 가드**: 동일 환경에서 `sdd phase new another` → die. 메시지에 `sdd phase activate phase-03` 안내 포함. phase-04.md 생성 안 됨.
3. **`--force` 우회**: `sdd phase new another --force` → phase-04.md 정상 생성.
4. **회귀**: 사전 정의 phase 없는 상태에서 `sdd phase new fresh` → phase-01.md 생성 (기존 동작 동일).

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-phase-activate.sh`: phase activate / phase new 가드 단위 테스트 (13 checks)

### 🛠 Modified Files
- `sources/bin/sdd`: `phase_activate()` 신규 + `phase_new()` 가드/`--force` + `queue_phase_is_done()` 헬퍼 + `cmd_phase` 라우팅 + `cmd_help` 갱신
- `.harness-kit/bin/sdd`: 도그푸딩 동기화 (sources/bin/sdd 와 동일)
- `VERSION`: `0.6.1` → `0.6.2`
- `.harness-kit/installed.json`: `kitVersion` `0.6.1` → `0.6.2`
- `CHANGELOG.md`: `[0.6.2] — 2026-04-28` 항목 추가
- `README.md`: 버전 배지 `0.6.1` → `0.6.2`
- `tests/test-version-bump.sh`: `TARGET="0.6.2"`
- `backlog/queue.md`: spec-x 등록 (sdd 자동)

### Spec 산출물
- `specs/spec-x-sdd-phase-activate/` (spec.md, plan.md, task.md, walkthrough.md, pr_description.md)

## ✅ Definition of Done

- [x] `sdd phase activate` 신규 명령
- [x] `sdd phase new` 가드 + `--force`
- [x] 도움말 갱신
- [x] 단위 테스트 13/13 PASS + 회귀 PASS
- [x] 0.6.2 버전 동기화 (5 위치)
- [x] CHANGELOG / README 반영
- [x] 도그푸딩: `.harness-kit/bin/sdd` 동기화
- [x] walkthrough.md / pr_description.md 작성

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-sdd-phase-activate/walkthrough.md`
- Spec: `specs/spec-x-sdd-phase-activate/spec.md`
- Plan: `specs/spec-x-sdd-phase-activate/plan.md`
