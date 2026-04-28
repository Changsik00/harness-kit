# Implementation Plan: spec-15-04

## 📋 Branch Strategy

- 신규 브랜치: `spec-15-04-historical-regression-tests`
- **시작 지점**: `phase-15-upgrade-safety`
- PR target: `phase-15-upgrade-safety`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **시나리오 fail 발견 시 처리** — 본 spec 은 검증만. 회귀 발견 시 별도 spec-x 로 즉시 fix 또는 phase-15 안의 spec 추가.
> - [ ] **시나리오 3 (customized fragment) 의 기대 동작** — 사용자 추가분이 *보존되거나* *명시적 conflict 표시*. 현재 구현이 어느 쪽인지 본 spec 으로 확인. fail 시 spec-15-06 (user-hook-preserve) 와 함께 처리.
> - [ ] **시나리오 5 (gitignore dup)** — spec-14-03 에서 라인별 멱등으로 fix 됨. 본 spec 은 *재발 방지 회귀* 테스트. fail 시 spec-14-03 fix 회귀.

> [!WARNING]
> - [ ] 5 시나리오 중 일부는 update.sh 가 *느린 동작* (uninstall + install) 이라 테스트 시간이 누적될 수 있음. 시나리오 1 ~ 5 직렬 실행 ≈ 10~20 초 예상.

## 🎯 핵심 전략 (Core Strategy)

### 테스트 파일 구조

```
tests/test-update-stateful.sh
├── source tests/lib/fixture.sh
├── 헬퍼: ok / fail / cleanup trap
├── Scenario 1 — in-flight phase (#82)
├── Scenario 2 — pre-defined phases (#84)
├── Scenario 3 — customized fragment (Pattern B)
├── Scenario 4 — dirty queue (Pattern B)
├── Scenario 5 — multi-install + .gitignore (#78, #83)
└── 결과 요약 + exit
```

### 시나리오별 검증 패턴

#### Scenario 1: in-flight phase (state 손실 #82)
```bash
F=$(make_fixture)
with_in_flight_phase "$F" "phase-08" "spec-08-03-test"
before=$(jq -c '{phase,spec,branch,baseBranch,planAccepted,lastTestPass}' "$F/.claude/state/current.json")
bash "$ROOT/update.sh" --yes "$F" >/dev/null 2>&1
after=$(jq -c '{phase,spec,branch,baseBranch,planAccepted,lastTestPass}' "$F/.claude/state/current.json")
[ "$before" = "$after" ] && ok "6 필드 보존" || fail "..."
new_ver=$(jq -r '.kitVersion' "$F/.claude/state/current.json")
[ "$new_ver" = "$(cat "$ROOT/VERSION")" ] && ok "kitVersion 갱신" || fail "..."
[ -f "$F/backlog/phase-08.md" ] && ok "phase 본문 보존" || fail "..."
[ -d "$F/specs/spec-08-03-test" ] && ok "spec 디렉토리 보존" || fail "..."
```

#### Scenario 2: pre-defined phases (#84)
```bash
F=$(make_fixture)
with_pre_defined_phases "$F" "phase-09" "phase-10" "phase-11"
before9=$(md5 -q "$F/backlog/phase-09.md" 2>/dev/null || md5sum "$F/backlog/phase-09.md")
bash "$ROOT/update.sh" --yes "$F" >/dev/null 2>&1
after9=$(md5 -q "$F/backlog/phase-09.md" 2>/dev/null || md5sum "$F/backlog/phase-09.md")
[ "$before9" = "$after9" ] && ok "phase-09 본문 미변경" || fail "..."
# sdd phase activate 시도
(cd "$F" && bash .harness-kit/bin/sdd phase activate phase-09 2>&1 >/dev/null)
[ "$(jq -r '.phase' "$F/.claude/state/current.json")" = "phase-09" ] \
  && ok "activate 정상" || fail "..."
```

#### Scenario 3: customized fragment (Pattern B)
```bash
F=$(make_fixture)
with_customized_fragment "$F"
bash "$ROOT/update.sh" --yes "$F" >/dev/null 2>&1
if grep -q "TEST_USER_FRAGMENT" "$F/.harness-kit/CLAUDE.fragment.md"; then
  ok "사용자 추가분 보존"
else
  # XFAIL — 현재는 OVERWRITE 정책. spec-15-06 후보.
  fail "TEST_USER_FRAGMENT 손실 (예상 — spec-15-06 으로 처리)"
fi
```

> 시나리오 3 은 **현재 install.sh 정책상 fail 예상** (CLAUDE.fragment.md 가 OVERWRITE). 본 spec 에서는 *결과 기록* 의 의미. fail 한 결과를 spec-15-06 의 입력으로 사용. test 자체는 expected fail (XFAIL) 처리하지 않고 그냥 fail 로 두면 회귀 스위트가 빨간 신호. 현실적 선택 두 가지:
>   - A) 시나리오 3 을 *건너뛰고* spec-15-06 에서 추가
>   - B) 시나리오 3 을 expected-fail (XFAIL) 으로 marking — bash 에서는 보통 `if check; then ok; else warn; fi` 류로 회피 가능
>   - C) 시나리오 3 자체를 spec-15-06 에서 같이 작성

> 본 plan 의 결정: **A (건너뛰고 spec-15-06 에서 추가)** — 본 spec 의 회귀 스위트가 깨끗하게 PASS 해야 다른 spec 의 회귀 검증으로 사용 가능. 시나리오 3 은 phase-15.md §통합 테스트 시나리오 3 의 "보존 또는 명시적 conflict" 정책을 결정해야 본격 검증 가능. spec-15-06 의 산출물.

#### Scenario 4: dirty queue (Pattern B)
```bash
F=$(make_fixture)
with_dirty_queue_icebox "$F"
bash "$ROOT/update.sh" --yes "$F" >/dev/null 2>&1
grep -q "TEST_USER_ICEBOX_NOTE" "$F/backlog/queue.md" && ok "사용자 메모 보존" || fail "..."
grep -q "sdd:active:start" "$F/backlog/queue.md" && grep -q "sdd:active:end" "$F/backlog/queue.md" \
  && ok "sdd 마커 손상 없음" || fail "..."
```

> 시나리오 4 는 update.sh 가 backlog/queue.md 를 *건드리지 않음* (사용자 영역) 이라 정상 PASS 예상. Pattern B 검증.

#### Scenario 5: multi-install (#78 gitignore + #83 phase-ship)
```bash
F=$(make_fixture)
# install 2 회 (멱등성 검증)
bash "$ROOT/install.sh" --yes "$F" >/dev/null 2>&1
bash "$ROOT/install.sh" --yes "$F" >/dev/null 2>&1
# 8 템플릿 모두 존재
all_templates_ok=1
for t in queue phase phase-ship spec plan task walkthrough pr_description; do
  [ -f "$F/.harness-kit/agent/templates/$t.md" ] || all_templates_ok=0
done
[ $all_templates_ok -eq 1 ] && ok "8 템플릿 존재" || fail "..."
# .gitignore 의 hk 라인 정확 1 회씩
for line in '.harness-kit/' '.harness-backup-\*/' '.claude/state/' '# harness-kit'; do
  cnt=$(grep -cE "^${line}\$" "$F/.gitignore" 2>/dev/null || echo 0)
  [ "$cnt" -eq 1 ] && ok ".gitignore '$line' 정확 1 회" || fail "..."
done
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **시나리오 3 처리** | 건너뛰기 (echo "Scenario 3 — spec-15-06 에서 처리") | 현재 fail 예상. spec-15-06 의 명시적 정책 결정 필요 |
| **md5 명령** | macOS `md5 -q` / Linux `md5sum` 자동 분기 | 본 프로젝트 macOS 1차 + Linux best-effort 정책 |
| **`set -e` 회피** | `set -uo pipefail` 만 사용 | 한 시나리오 fail 이 다른 시나리오 차단 안 하도록 |
| **fixture 정리** | 각 시나리오마다 `CLEANUP+=("$F")` + `trap cleanup EXIT` | spec-15-02 의 단위 테스트 패턴 그대로 |

## 📂 Proposed Changes

### [NEW] `tests/test-update-stateful.sh`

위 plan §시나리오별 검증 패턴 의사코드를 실제 구현. 5 시나리오 (시나리오 3 은 placeholder + skip 메시지) + 헬퍼 + cleanup trap.

### [MODIFY 없음]

기존 코드 / 테스트 파일 수정 없음. *추가* 만.

## 🧪 검증 계획

### 단위 테스트
```bash
bash tests/test-update-stateful.sh
```

### 회귀
```bash
bash tests/test-version-bump.sh   # 전체 스위트 자동 실행
```

### 예상 결과
- 시나리오 1, 2, 4, 5 모두 PASS — 이미 fix 된 버그들의 stateful 회귀 잠금
- 시나리오 3 SKIP 메시지 (spec-15-06 후보)
- 총 ≥ 10 checks PASS (시나리오 3 의 2 checks 제외)

## 🔁 Rollback Plan

- 본 spec 은 *추가만*. PR revert 시 `tests/test-update-stateful.sh` 제거. 다른 영향 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] `tests/test-update-stateful.sh` 5 시나리오 (시나리오 3 placeholder)
- [ ] 모든 검증 PASS
- [ ] 회귀 PASS
- [ ] walkthrough.md / pr_description.md ship + PR
