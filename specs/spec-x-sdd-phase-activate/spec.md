# spec-x-sdd-phase-activate: 사전 정의 phase 활성화 경로 추가

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-sdd-phase-activate` |
| **Phase** | 없음 (Solo Spec) |
| **Branch** | `spec-x-sdd-phase-activate` |
| **상태** | Planning |
| **타입** | Fix (+ 보조 명령 신설) |
| **Integration Test Required** | no |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
- `sdd phase new <slug>`는 `backlog/phase-*.md` + `archive/backlog/phase-*.md` 의 가장 큰 N을 찾아 `N+1`로 새 phase를 생성한다 (`sources/bin/sdd:466-474`).
- 사용자가 phase를 사전 계획해 `backlog/phase-03.md ~ phase-07.md`처럼 미리 작성해 두는 경우, 다음 단계로 넘어갈 때 `phase 03`을 활성화하는 직접 경로가 없다.
- 현재는 `sdd phase new ...`을 실행해도 sdd가 이미 정의된 파일을 인지하지 못하고 `phase-08.md`를 새로 만들어 버린다 → 사전 작성한 phase가 영원히 활성화되지 않는 사일런트 버그.

### 문제점
- **사전 계획 워크플로우 파괴**: `phase-03.md` 본문(배경/목표/시나리오)이 무시되고 새 빈 파일이 추가됨.
- **번호 점프 발생**: 사용자가 phase-03을 의도했으나 sdd는 phase-08을 만들고 활성화 → queue.md의 active/queued 마커가 의도와 어긋남.
- **수동 우회 부담**: 사용자가 `.claude/state/current.json`을 직접 편집하고 `queue.md` 마커를 수동으로 옮겨야 사전 정의된 phase가 활성화됨. 이는 거버넌스 도구가 보호해야 할 영역을 사용자에게 떠넘긴다.
- **재현성**: phase 사전 정의는 `update.sh` 후 state가 초기화되었거나, 여러 phase를 한 번에 계획해 두는 일반적인 시나리오에서 자주 발생.

### 해결 방안 (요약)
1. **`sdd phase activate <id> [--base]`** 신규 서브커맨드 — 기존 phase 파일을 보존한 채 state/queue.md만 활성화.
2. **`sdd phase new` 가드 강화** — `backlog/`에 active도 done도 아닌 phase 파일이 존재하면 die + `phase activate` 경로 안내.
3. 버전 0.6.1 → 0.6.2 bump.

## 🎯 요구사항

### Functional Requirements

1. `sdd phase activate <id>` 호출 시:
   - `<id>`는 `phase-NN` 형식. `backlog/<id>.md`가 존재해야 한다.
   - 이미 done(queue.md done 섹션) 인 phase는 활성화 거부 (die).
   - 이미 다른 active phase가 설정되어 있으면 die — 명시적 전환 안내.
   - `phase.md` 본문은 일체 변경하지 않음 (placeholder 치환도 하지 않음).
   - `state.json`의 `phase`, `spec=null`, `planAccepted=false`, `baseBranch` 갱신.
   - `queue.md`의 `<!-- sdd:active:start -->` 영역을 해당 phase 정보로 교체. queued 마커에서 해당 phase 행이 있으면 제거.
2. `sdd phase activate <id> --base` 호출 시:
   - `baseBranch`를 `<id>-<slug>` 로 설정. slug는 `phase.md` 의 첫 줄 (`# phase-NN: <slug>`) 에서 파싱.
   - 사용자가 `phase.md` 메타 표의 `Base Branch` 필드를 이미 채워둔 경우 해당 값을 우선 사용.
3. `sdd phase new <slug>` 호출 시:
   - `backlog/phase-*.md` 중 active도 done도 아닌 파일이 1개 이상 존재하면 즉시 die. 메시지에 `sdd phase activate <id>` 경로 안내 + 발견된 파일 목록 출력.
   - `--force` 플래그 시 가드 우회하고 기존 동작(N+1 새 생성) 수행.
4. `sdd phase` 도움말에 `activate` 서브커맨드 추가.
5. 버전 bump: `VERSION`, `CHANGELOG.md`, `README.md`, `tests/test-version-bump.sh`, `.harness-kit/installed.json` 모두 0.6.2로 동기화.

### Non-Functional Requirements

1. **Backward compatibility**: 사전 정의 phase가 없는 환경에서 `sdd phase new <slug>` 동작은 변경 없음.
2. **bash 3.2+ 호환**: `declare -A`, `mapfile`, `**` globstar 등 4+ 전용 기능 사용 금지 (CLAUDE.md §3).
3. **Idempotent**: 동일 id 재호출 시 안전 (이미 active면 그대로 종료).

## 🚫 Out of Scope

- `sdd phase new`의 N 계산 로직 변경 (max+1 그대로 유지). 본 spec은 가드만 추가.
- queue.md의 queued/icebox 마커 전체 재설계.
- `phase deactivate` 명령 추가 (필요 시 별도 spec-x).
- phase.md 본문 자동 검증 (메타 필드 누락 등).
- archive에 있는 phase의 재활성화.

## ✅ Definition of Done

- [ ] `sources/bin/sdd` `cmd_phase`에 `activate` 서브커맨드 라우팅 추가
- [ ] `phase_activate()` 함수 구현 (id 검증 + state/queue 갱신 + --base 처리)
- [ ] `phase_new()` 사전 정의 phase 가드 + `--force` 우회 추가
- [ ] `sources/bin/sdd` 도움말 (`cmd_help`) 업데이트
- [ ] `tests/test-sdd-phase-activate.sh` 신규 작성 — activate 정상/실패 시나리오, phase new 가드 시나리오, --force 우회 시나리오
- [ ] `VERSION` → `0.6.2`
- [ ] `CHANGELOG.md` 0.6.2 항목 추가
- [ ] `README.md` 버전 참조 갱신
- [ ] `tests/test-version-bump.sh` TARGET → `0.6.2`
- [ ] `.harness-kit/installed.json` kitVersion → `0.6.2` (도그푸딩)
- [ ] 전체 테스트 스위트 PASS
- [ ] `walkthrough.md` / `pr_description.md` ship + push + PR 생성
