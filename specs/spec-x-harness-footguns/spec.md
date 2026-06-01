# spec-x-harness-footguns: 하네스 운영 footgun 3종 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-harness-footguns` |
| **Phase** | 없음 (spec-x, 독립) |
| **Branch** | `spec-x-harness-footguns` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-30 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

도그푸딩 대상 프로젝트에서 harness-kit 를 운영하던 중 한 세션에서 세 가지 마찰(friction)이 현장 제보로 올라왔다. 세 건 모두 키트 원본(`sources/`, `update.sh`)의 실제 결함으로 소스 확인을 마쳤다.

### 문제점

**① `/hk-update` 미커밋 산물이 spec 브랜치를 오염**
- `update.sh` 는 `.harness-kit/*`·`.claude/*` 를 덮어쓰고 **커밋 없이 종료** (`update.sh:191`).
- `sources/commands/hk-update.md` 도 업데이트 후 커밋 안내가 **없음** (`:93-105`).
- `sdd status` 의 install drift 감지는 동작하나 **보고만 하고 차단/유도하지 않음**.
- `sdd spec new` / `specx new` 는 활성 spec 만 검사하고 미커밋 파일은 무시 → 사용자가 `git checkout -b spec-...` 하면 untracked 업데이트 산물이 새 브랜치로 따라붙어 PR scope 를 오염시킨다.

**② 시크릿 가드 오탐 (false positive)**
- `check-secrets.sh:58` 의 정규식 값 부분 `[^[:space:]]+` 가 너무 관대해 `${POSTGRES_PASSWORD:-default}` 같은 env 변수 보간을 시크릿 값으로 오탐 → 합법 코드에 3회 warn.
- env 보간·placeholder 예외 로직이 전무하여 `${VAR}` 뿐 아니라 `changeme`/`placeholder`/주석 속 예시/URL 쿼리 등 다수 합법 패턴을 동일하게 오탐한다 (systemic).

**③ `phase activate --base` 진입 마찰**
- `phase activate --base` 는 phase.md 의 `Base Branch` 메타가 `phase-NN-slug` 형식으로 **미리 채워져 있지 않으면 die** 한다 (`sdd:965-967`). 채워주는 로직이 없어 "미정" 상태에선 명령 자체가 막힌다 — `phase new --base` 는 phase.md 를 자동 갱신(`sdd:892`)하는데 `activate` 만 비대칭으로 누락.
- 또한 이미 active 인 같은 phase 를 base 모드로 재활성화하려 해도 활성 spec 가드(`sdd:944`)에 막히고, `--force` 를 쓰면 active spec 컨텍스트가 silent reset 된다.
- 결국 사용자는 `state.json` 을 surgery 로 직접 편집할 수밖에 없었고 phase.md `Base Branch` 는 "미정" 으로 남았다.

### 해결 방안 (요약)

세 footgun 을 하나의 spec-x 로 묶어 각각 최소 수정한다: (①) update 후 미커밋 산물 커밋 유도 + spec/specx new 시 install drift 경고, (②) 시크릿 정규식에 env 보간·placeholder 예외 추가, (③) `phase activate --base` 가 phase.md 메타를 자동 기입하고 같은 phase 재활성화 시 active spec 을 보존하도록 수정.

## 🎯 요구사항

### Functional Requirements

1. **update 미커밋 가드** — `update.sh` 종료 시 `.harness-kit/*`·`.claude/*` 에 미커밋 변경이 있으면 명시적 커밋 안내(정확한 `git add`/`git commit` 명령 포함)를 출력한다. `hk-update.md` 에도 동일 안내를 반영한다.
2. **branch 오염 경고** — `sdd spec new` / `sdd specx new` 실행 시 미커밋 install drift(`.harness-kit/*`·`.claude/*`)가 감지되면 비차단(warn) 경고를 출력해 브랜치 생성 전 커밋을 유도한다.
3. **시크릿 오탐 제거** — `check-secrets.sh` 의 일반 시크릿 패턴이 값이 shell 변수 보간(`${...}`/`$(...)`/`$NAME`)이거나 알려진 placeholder(`changeme`/`placeholder`/`example`/`your_*`/`xxx`/`<...>`/`...`)인 경우 시크릿으로 간주하지 않는다. 실제 하드코딩 시크릿(`password=hardcoded123` 등)은 계속 차단한다.
4. **base 메타 자동 기입** — `phase activate --base` 가 base 브랜치를 결정하면(`--base=<branch>` 인자 또는 phase.md 메타) phase.md 의 `Base Branch` 필드를 그 값으로 자동 갱신한다.
5. **active spec 보존** — `cur_phase == id` (이미 active 인 같은 phase 를 base 모드로 재활성화)일 때는 활성 spec/planAccepted 를 리셋하지 않고 baseBranch 설정 + phase.md 메타 갱신만 수행한다.

### Non-Functional Requirements

1. bash 3.2+ 호환 (BSD grep/sed 포함) — bash 4 전용 기능 금지.
2. 기존 동작 backward compatibility: 진짜 시크릿 차단, 정상 update 흐름, 기존 `phase new --base` 동작은 그대로 유지.
3. 경고는 warn 모드(exit 0 + stderr/stdout) — 차단(exit≠0) 으로 승격하지 않는다 (Hook 단계론).

## 🚫 Out of Scope

- `update.sh` 가 산물을 **자동 커밋**하는 것 (dirty repo 위험 → 안내까지만).
- 시크릿 가드의 차단 모드 승격 또는 entropy 기반 탐지 도입.
- `sdd phase base` 같은 신규 서브커맨드 추가 (기존 `phase activate --base` 수정으로 해결).
- install drift 자동 정리.

## 📑 ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 (3건 모두 국소 fix, 장기 아키텍처 결정 없음)

## 🔗 관련 문서 (Related)

- 관련 spec: [[spec-x-check-secrets-dual-mode]] (시크릿 가드 듀얼모드, #149)
- 관련 spec: [[spec-x-hk-align-drift-detect]] (install drift 감지 도입)
- 관련 wiki: `docs/wiki/patterns.md`

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`check-secrets`, `phase-activate`/`base-branch`, `update`, 신규 spec-new 경고 테스트)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-harness-footguns` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
