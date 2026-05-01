# Walkthrough: spec-15-02 (stateful-fixture-system)

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| lib 위치 | A) `tests/lib/fixture.sh` / B) `tests/helpers/` / C) `tests/_fixture.sh` | **A** | 향후 헬퍼 추가 가능성 — `lib/` 디렉토리가 자연스러움. 일반 bash 컨벤션 |
| 함수 prefix 정책 | A) 모두 prefix / B) public 은 없음, internal 만 `_fx_` | **B** | 가독성 — 테스트 작성자가 `with_in_flight_phase` 같은 표현으로 작성. internal 만 보호 |
| trap 정리 책임 | A) lib 가 글로벌 trap 설치 / B) 각 테스트가 trap 작성 | **B** | 단일 lib 가 글로벌 trap 설치하면 다른 테스트의 cleanup 과 충돌. 명시적 책임 분담 |
| `make_fixture` 의 queue.md 처리 | A) install.sh 가 만들 때까지 대기 / B) 템플릿 복사로 보강 | **B (TDD 중 발견)** | install.sh 는 `backlog/` 디렉토리만 만들고 queue.md 는 sdd 첫 호출 시 생성. fixture 는 "사용 중인 사용자" 모사 — sdd 사용 후 상태가 자연스러움 |

## 💬 사용자 협의

- **주제**: phase-15 base branch 모드 전환 (회고 위해)
  - **사용자 의견**: "이게 왜 main 으로 머지 되지? 내가 주문을 잘못햇나봐.. phase 로 가야지 그래야 phase 회고도 하자"
  - **합의**: phase-15-upgrade-safety base 브랜치 신설, spec-15-01 PR retarget. spec-15-02 부터는 phase 브랜치를 base 로.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (`tests/test-fixture-lib.sh`)
- **결과**: ✅ Passed (18 / 18)
- **그룹별**:
  - Group 1 — `make_fixture` (3): 디렉토리 / .harness-kit/ / state.json
  - Group 2 — `with_in_flight_phase` (4): state.phase / state.spec / phase.md / specs/ 디렉토리
  - Group 3 — `with_pre_defined_phases` (3): 다중 파일 / 마커 / 단일 인자 가변
  - Group 4 — `with_customized_fragment` (2): TEST_USER_FRAGMENT 마커 / 라인 수 증가
  - Group 5 — `with_dirty_queue_icebox` (2): TEST_USER_ICEBOX_NOTE / sdd 마커 영역 손상 없음
  - Group 6 — `with_user_hook` (2): UserAddedHook / 기존 hooks 보존
  - Group 7 — **조합** (2): in_flight + dirty_queue + user_hook 동시 적용 정상 + in_flight 산출물 보존

#### 회귀 — `tests/test-version-bump.sh`
- **결과**: ✅ Passed (6 / 6 + 전체 스위트 FAIL=0)

### 2. 수동 검증
1. **Action**: `source tests/lib/fixture.sh; F=$(make_fixture); ls "$F"`
   - **Result**: ✅ `.harness-kit/`, `backlog/queue.md`, `.claude/state/current.json`, `specs/` 모두 존재
2. **Action**: `with_in_flight_phase "$F" phase-08 spec-08-03-test; jq . "$F/.claude/state/current.json"`
   - **Result**: ✅ 6 필드 모두 채워짐, phase-08.md / specs/spec-08-03-test/ 생성

## 🔍 발견 사항

### `make_fixture` 의 queue.md 누락 (TDD Red 단계 발견)

처음 mixin 을 작성한 직후 Group 5 (dirty_queue_icebox) 와 Group 7 (조합) 이 fail. 원인은 **install.sh 가 backlog/ 디렉토리만 만들고 queue.md 를 복사하지 않음**. 실제 사용자 환경에서는 sdd 첫 호출 (`ensure_queue_file` in `sources/bin/sdd:631`) 이 queue.md 를 자동 생성.

`make_fixture` 가 *"사용 중인 사용자"* 를 모사하므로 sdd 호출 결과인 queue.md 도 base fixture 에 포함되어야 자연스러움. 템플릿 복사 한 줄 추가로 해결.

→ **이는 install.sh 정책의 한 단면**: queue.md 는 "사용자가 sdd 를 한 번이라도 쓴 흔적" 이라 install 시점에는 부재. 다른 spec/phase 도 같은 패턴 (state.json 은 install 이 생성, queue.md / phase.md 는 sdd 가 생성). spec-15-01 §5 의 정책 분류표를 보강할 후보.

### bash trap 의 한계

조합 테스트 (Group 7) 작성 시 trap 으로 N 개 fixture 정리하는 패턴 — `FIXTURES_TO_CLEAN+=($F)` 배열 + cleanup 함수. bash 3.2 호환을 위해 `${FIXTURES_TO_CLEAN[@]:-}` (default 처리) 가 필요. 이는 spec-15-03 (회귀 테스트) 작성 시 동일 패턴 재사용 예정.

## 🚧 이월 항목

- 기존 `tests/test-sdd-base-branch.sh:20-52` 의 inline `make_fixture()` 를 본 lib 로 마이그레이션 → spec-15-03 (회귀 테스트) 작성 중 자연스럽게 흡수 가능. 본 spec 범위 밖.
- `make_fixture` 가 install.sh 의 "queue.md 미생성" 을 우회한 것은 fixture 입장에서는 적절하지만, install.sh 자체에 queue.md 도 만들게 할지는 별 spec 후보 — spec-15-01 §5.4 의 P1/P2 spec 들과 함께 검토.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-28 |
| **최종 commit** | `c03c472` (ship 직전 기준) |
