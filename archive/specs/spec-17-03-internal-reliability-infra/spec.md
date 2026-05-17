# spec-17-03: Internal Reliability Infrastructure

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-17-03` |
| **Phase** | `phase-17` (운영 성숙도) |
| **Branch** | `spec-17-03-internal-reliability-infra` |
| **상태** | Planning |
| **타입** | Refactor + Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

phase-16 회고에서 식별된 *내부 운영 인프라 부채* 3-4 건:

**C3 — `installed.json` 캐시 필드가 tracked 파일**:
- `installed.json` 안에 `lastVersionCheck`, `latestKnownVersion` 두 필드 — `check-kit-version.sh` hook 이 매 SessionStart 마다 갱신.
- tracked 파일이라 매번 워킹트리 dirty 1 건 발생. phase-ship cleanliness 가정 위배. 사용자가 매 세션마다 `git checkout --` 수동.

**W2 — Phase-level integration test 자동화 부재**:
- phase-16 시나리오 3 개 (type closure / stale 탐지 / slogan grep) 의 PASS 검증을 매번 수동 grep.
- phase-ship 절차에 자동화 진입점 없음 — phase 회고 / 회귀 점검의 정량 입력 부재.

**W6 — `doctor.sh` 신규 산출물 점검 누락**:
- spec-16-01 (rca.md 템플릿) / spec-16-02 (adr.md 템플릿) / docs/rca/ / docs/decisions/ 가 doctor checklist 에 미포함.
- install 미러 무결성 검사가 신규 자산을 모름 — drift 검출 못함.

**(선택) `sdd_marker_grep` helper 일반화**:
- spec-17-01 의 `cmd_spec_new` fix 가 *호출 측 분기* (backtick OR plain) 로 우회. helper 자체는 backtick 만 매칭.
- 다른 사용 지점도 동일 회피 패턴 필요할 수 있음 — 근본 해결은 helper 일반화.

### 문제점

- 매 SessionStart 마다 `installed.json` drift 발생 → phase-ship 시 cleanliness 가정 위배 → 회고에서 매번 지적 (RCA-001 같은 invariant 위반은 아니지만 chronic).
- phase 시나리오 검증이 매번 수동 → phase-ship 자동화 회로의 빈 칸. 다음 phase 도 동일 비용.
- doctor 가 phase-16 산출물을 모름 → install 미러 drift / 누락 시 silent.

### 해결 방안 (요약)

1. **Cache 분리**: 캐시 필드를 `.harness-kit/cache.json` 으로 이관 + `.gitignore`. sdd `_drift_kit_version` 와 hook `check-kit-version.sh` 가 cache.json read/write. 기존 installed.json 의 캐시 필드 있으면 첫 hook 실행 시 migration.
2. **Phase integration script**: `tests/test-phase16-integration.sh` 신규 작성 — phase-16.md 시나리오 1/2/3 한 명령 실행. `phase-NN-integration.sh` 명명 규약 신설 — 후속 phase 도 동일 패턴.
3. **Doctor 확장**: `doctor.sh` 의 templates list 에 `rca.md` / `adr.md` 추가. dir list 에 `docs/rca` / `docs/decisions` 추가 (optional — 부재 시 skip, 존재 시 검증).
4. **(선택) helper 일반화**: `sdd_marker_grep` 가 backtick / plain 두 패턴 모두 매칭하도록 일반화 + 호출 측의 우회 분기 제거. 시간 남으면.

## 🎯 요구사항

### Functional Requirements

1. **`installed.json` 캐시 필드 제거 + `cache.json` 신설**:
   - install.sh / update.sh 가 새 installed.json 작성 시 `lastVersionCheck` / `latestKnownVersion` 미포함.
   - `.harness-kit/cache.json` 첫 사용 시 자동 생성 — `{ "lastVersionCheck": "...", "latestKnownVersion": "..." }` 구조.
   - `.gitignore` 에 `.harness-kit/cache.json` 추가.
2. **Hook + sdd 의 read/write 경로 전환**:
   - `sources/hooks/check-kit-version.sh` — `INSTALLED_JSON` 대신 `CACHE_JSON` 사용. 단, kitVersion / kitOrigin 읽기는 여전히 installed.json (그 필드는 그대로).
   - `sources/bin/sdd` `_drift_kit_version` — 동일하게 cache.json 사용.
3. **Migration**: hook 첫 실행 시 — installed.json 에 두 캐시 필드 있으면 cache.json 으로 옮기고 installed.json 에서 제거 (silent, 1 회만).
4. **Phase integration script**:
   - `tests/test-phase16-integration.sh` 작성 — phase-16.md 의 시나리오 1 (Knowledge Type closure), 시나리오 2 (stale ADR fixture), 시나리오 3 (reliability layer 3 곳 grep) 3 개 모두 자동 PASS 검증.
   - fixture (ADR-999) 격리 — trap cleanup.
   - 명명 규약: `tests/test-phase{N}-integration.sh` (후속 phase 도 동일).
5. **Doctor 확장**:
   - `doctor.sh` 의 templates checklist (line 81) 에 `rca.md` / `adr.md` 추가 — 7 → 9 항목.
   - `doctor.sh` 의 dir checklist (line 67) 에 `docs/rca` / `docs/decisions` 추가 — optional (부재 시 skip with `check_warn` 또는 silent skip).
   - 기존 사용자 (phase-16 산출물 install 안 받음) 환경에서 false negative 폭증 안 함.
6. **install 미러 동기화**: 모든 sources 변경을 `.harness-kit/bin/sdd` / `.harness-kit/hooks/check-kit-version.sh` 등에 동기화.
7. **(선택) helper 일반화** — `sdd_marker_grep` 가 backtick + plain 두 패턴 매칭. 호출 측 (cmd_spec_new) 의 분기 단순화.

### Non-Functional Requirements

1. **Backward compatibility** — 기존 installed.json 형식 (캐시 필드 포함) 자연스럽게 마이그레이션. 사용자 액션 0.
2. **bash 3.2+ 호환** — 모든 변경 bash 3.2 동작 확인.
3. **silent on absent** — cache.json 부재 시 hook / sdd 가 first-run 으로 정상 진행 (이미 잘 처리됨).
4. **Test isolation** — phase16-integration.sh 의 fixture (ADR-999) 가 spec-16-03 의 test-drift-stale-adr.sh fixture 와 충돌 안 함 (다른 slug 사용).

## 🚫 Out of Scope

- **`sdd status --json` 출력 확장** (NEXT, artifacts 필드 추가) — spec-17-02 walkthrough 의 이월 항목, 별 spec-x.
- **`get.sh` 의 `--dry-run` pass-through** — spec-17-02 walkthrough 의 이월 항목, 별 spec-x.
- **`installed.json` 의 다른 필드 (uxMode, installedCommands) 분리** — 본 spec 은 *캐시* 필드만. uxMode 는 *프로젝트 메타* 라 installed.json 유지.
- **phase-NN-integration.sh 의 phase-17 / phase-15 등 backfill** — 본 spec 은 phase-16 만. 후속 phase 가 자기 시점에 작성.
- **doctor.sh 의 *전체* 리팩토링** — 본 spec 은 4 항목 추가만. 다른 checklist 변경 없음.

## ✅ Definition of Done

- [ ] `installed.json` 의 두 캐시 필드 install 시 미포함 (install.sh / update.sh 변경)
- [ ] `.harness-kit/cache.json` 자동 생성 (hook 또는 sdd 첫 호출 시)
- [ ] `.gitignore` 에 `.harness-kit/cache.json` 추가
- [ ] `sources/hooks/check-kit-version.sh` cache.json 사용 + migration 로직
- [ ] `sources/bin/sdd` `_drift_kit_version` cache.json 사용
- [ ] install 미러 (`.harness-kit/hooks/check-kit-version.sh`, `.harness-kit/bin/sdd`) 동기화
- [ ] `tests/test-phase16-integration.sh` 신규 작성 + 3 시나리오 PASS
- [ ] `doctor.sh` templates checklist 에 rca.md / adr.md 추가
- [ ] `doctor.sh` dir checklist 에 docs/rca / docs/decisions optional 추가
- [ ] (선택) `sdd_marker_grep` helper 일반화 + 호출 측 단순화
- [ ] 회귀: `test-sdd-marker-idempotent.sh` 3/3 + `test-drift-stale-adr.sh` 3/3 PASS 유지
- [ ] 워킹트리 cleanliness 검증 — SessionStart hook 실행 후 `git status --porcelain` 빈 출력
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] PR 생성 (target: `phase-17-coherence-fix`)
