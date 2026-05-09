# Walkthrough: spec-x-hk-align-drift-detect

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| drift 감지를 어디 둘지 | (a) `sdd status` 통합 / (b) `sdd doctor` 확장 / (c) 신규 `sdd drift` | (a) status 통합 + `--no-drift` opt-out | hk-align 이 이미 status 만 호출. 단일 명령 원칙 (agent.md §6.4) 유지하면서 자동 보고. CI/오프라인은 escape hatch. |
| `git fetch` 자동 실행 | 자동 vs 수동 | 자동 (best-effort) + `HARNESS_DRIFT_FETCH=0` 으로 끔 | 정확도 우선. 실패해도 silent fallback 으로 status 자체는 계속 동작. 1-2 초 비용은 hk-align 한 번 호출의 가치에 비해 작음. |
| 정합성 검사가 기존 `_status_diagnose` 와 중복 | (a) drift 에서만 / (b) diagnose 에서만 / (c) 둘 다 | (c) 둘 다 — 다른 각도에서 같은 사실 강조 | drift 의 정합성은 *queue.md 기반* (state.json 무관), diagnose 는 *state.json 기반* . 두 신호가 만나는 지점이 신뢰 구간. 사용자 발견율 ↑. |
| 자동 정리 동작 포함 | 포함 vs 미포함 | 미포함 (감지/제안만) | 자동 `git pull` / `git reset` / `rm` 은 사용자가 의도하지 않은 변경을 만들 위험. multi-device 환경은 더더욱. 사용자가 명시 결정 후 직접 실행. |
| T1 fixture 의 install drift | (a) drift 가 발생해도 PASS / (b) fixture 측 정리 | (b) T1 만 add+commit 추가 | make_fixture 는 install 후 git init 만 — 모든 install 파일이 untracked. 이는 *fixture 의 미완성* 이지 본 spec 책임 아님. T1 만 명시적 정리 후 진짜 깔끔 시뮬레이션. |

## 💬 사용자 협의

- **주제**: drift 감지 위치 / fetch 정책 / 자동 정리 여부 (Plan §🛑 사용자 검토 필요 항목 3 가지)
  - **사용자 의견**: "권장대로" — Plan 의 권고 (status 통합 / 자동 fetch + escape hatch / 자동 정리 금지) 모두 수락
  - **합의**: 권고 그대로 진행

- **주제**: 본 spec 의 mode (SDD-x vs phase-16 신설)
  - **사용자 의견**: SDD-x 권장 수락
  - **합의**: spec-x-hk-align-drift-detect 단독 PR. hk-phase-ship 보강은 후속 spec 후보로 분리.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-drift.sh`
- **결과**: ✅ Passed (6 checks across 5 시나리오)
- **로그 요약**:
```text
T1: 깨끗한 상태 → drift 섹션 깔끔            ✅ 동기화 상태 섹션 출력 + ✅ 깔끔 메시지
T2: 원격 behind 1                            ✅ behind 1 보고
T3: specs/ 미커밋                             ✅ spec drift 감지
T4: 모든 spec Merged 인데 phase active        ✅ 정합성 경고
T5: --no-drift                                ✅ 동기화 섹션 미출력
PASS: 6  FAIL: 0
```

#### 회귀 테스트
- `tests/test-sdd-spec-new-seq.sh`: 5/5 PASS
- `tests/test-fixture-lib.sh`: 18/18 PASS
- `tests/test-install-manifest-sync.sh`: 6/6 PASS

### 2. 도그푸딩 결과 (수동 검증)

본 프로젝트에 설치본 sync 후 실제 status 출력:

```text
📊 현재 상태
  Active Phase: 없음
  Active Spec:  spec-x-hk-align-drift-detect
  ...

🔄 동기화 상태
  워킹트리: 6 변경 (1 spec drift / 4 install drift / 1 일반)
  install 부산물: 1 (sources 동일 1 / 정체불명 0)

🔍 진단
  💡 specs/ 에 35개 디렉토리 — sdd archive 로 정리 가능
  ℹ archive/ 에 43개 spec 보관 중
```

**관찰**:
- 워킹트리 6 변경: 본 spec 작업 중이라 정상 (spec dir 1 + install drift 4 = 방금 sync 한 `.harness-kit` / `.claude` 파일들 + 일반 1 = task.md)
- install 부산물 1: `.harness-kit/agent/templates/phase-ship.md` (sources/templates 와 diff empty — keep 안전)
- 원격 섹션 미출력: 신규 브랜치라 아직 upstream 미설정 → drift_remote 가 silent skip (의도된 동작)

## 🔍 발견 사항

- **`_status_diagnose` 와 정합성 메시지 중복 가능**: 기존 진단도 "모든 spec Merged — phase done 가능" 류 메시지를 출력함. drift 의 정합성 검사는 **queue.md 기준**, diagnose 는 **state.json + git 기준** — 둘이 보는 각도가 달라 *결정 기록* 표에 적은 대로 둘 다 유지. 다만 사용자 입장에서 메시지가 비슷해 혼란 가능 → 후속 정리 후보.
- **fixture 의 install 잔재 문제**: `make_fixture` 가 install 후 git init/empty commit 만 하므로 깨끗한 상태가 아니라 모든 설치 파일이 untracked. drift 검사 같은 "git status 기반" 테스트는 fixture 전반 add+commit 필요. 다른 fixture-사용 테스트들은 *변경 추가* 패턴이라 영향 없었음. 후속으로 `make_fixture_clean()` 같은 변형 추가 검토.
- **drift_install 의 매핑 한계**: 현재 매핑은 `agent/templates`, `hooks`, `commands` 3 영역만. `.harness-kit/agent/*.md` (constitution.md 등) 의 untracked 는 "정체불명" 으로만 분류. 영역 추가는 후속 PR 으로.
- **upstream 미설정 시 silent**: 신규 브랜치 (push 전) 는 원격 drift 감지 안 됨. 의도된 동작이지만 사용자에게 "원격 확인 안 됨" 같은 한 줄을 보여주는 것도 검토 가치.

## 🚧 이월 항목

- **`hk-phase-ship` 가 PR 머지 후 `sdd phase done` 자동 호출** → 별도 spec-x 후보. 오늘 (2026-04-30) 발생한 phase-15 후처리 누락 재발 차단.
- **`_status_diagnose` 와 drift 메시지 중복 정리** → 메시지 톤 통합 또는 한쪽으로 통일.
- **`.harness-kit/agent/templates/phase-ship.md` tracked 화** → 본 spec 의 drift 가 "sources 동일 — keep 안전" 으로 분류했지만, 실제로는 *동료 템플릿들이 모두 tracked* 라서 일관성 깨짐. install.sh 가 이 파일을 install 대상에 포함시키는 정리 또는 git add 만 하는 정리 둘 중 하나 필요.
- **drift_install 영역 확장**: `.harness-kit/agent/*.md` 등 추가 매핑.
- **upstream 미설정 시 안내 메시지**: silent skip 대신 한 줄 안내.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-30 ~ 2026-05-01 |
| **최종 commit** | (ship commit 후 갱신) |
