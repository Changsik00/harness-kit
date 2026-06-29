# spec-26-01: settings push 권한 SSOT — mode-toggle ask 잔재 제거

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-26-01` |
| **Phase** | `phase-26` |
| **Branch** | `spec-26-01-settings-push-ssot` (base 모드 — phase 브랜치 위에서 진행, phase-ship PR 로 검토) |
| **Base 브랜치** | `phase-26-auto-safety-residue` |
| **상태** | Planning |
| **타입** | Refactor / Fix |
| **작성일** | 2026-06-29 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`sdd mode` 전환 시 `_settings_mode_patch()` (sources/bin/sdd ~2739) 가 `.claude/settings.json` 의 `permissions.ask` 를 조작한다:
- **turbo / auto** → `ask` 에서 `Bash(git push)`·`Bash(git push:*)` 제거 (자동 허용).
- **governed** → `ask` 에 `Bash(git push)`·`Bash(git push:*)` 추가 (push 시 확인 프롬프트 강제).

한편 install SSOT 인 `sources/claude-fragments/settings.json.fragment` 의 baseline 은:
- `allow` 에 `Bash(git:*)` → git push 는 baseline 에서 이미 자동 허용.
- `deny` 에 `Bash(git push --force:*)`·`-f`·`--force-with-lease` → force push 차단.
- `ask` 에 git push **없음** (= push 게이트 없음).

### 문제점

1. **§5.7 규약 위반**: constitution §5.7 은 "Plan Accept 후 push 는 **완전 자동** (display info block, then push immediately with **NO user response required**)" 이라고 명시한다. 그런데 `_settings_mode_patch` 의 governed 분기는 git push 를 `ask` 로 올려 **프롬프트를 강제**한다 — `git:*` allow 를 더 좁은 `ask` 가 override 하기 때문. 즉 governed 에서 push 가 자동이 아니게 되어 §5.7 과 충돌한다.
2. **SSOT drift (W3)**: fragment baseline 엔 git push 가 `ask` 에 없는데, 토글이 governed 에서 이를 추가하므로 **fresh install → 모드 1회전 후** `.claude/settings.json` 이 fragment 와 영구히 어긋난다. 어느 쪽이 SSOT 인지 테스트로 고정돼 있지 않다.
3. **명시 잔재**: 이 repo 의 `.claude/settings.json` `permissions.allow` 에 `Bash(git push:*)` 가 stray 로 남아있다 (`git:*` 로 이미 커버되어 redundant — 과거 round-trip/수동 추가 잔재). W3 Icebox 가 지목한 항목.

### 해결 방안 (방향2 — 사용자 결정)

push 게이팅을 **모든 모드에서 제거**해 §5.7("push 자동")과 정합시킨다. force push 안전은 이미 `deny` + `check-irreversible.sh` 가 담당하므로 push 게이트는 불필요하다. 구체적으로 `_settings_mode_patch` 를 제거하고, fragment 가 SSOT(push 는 `ask` 에 없음 = 자동) 임을 sync 테스트로 박제한다.

> **반려된 방향1**(fragment `ask` 에 git push 추가 = governed 게이트 부활)은 §5.7 과 충돌하므로 채택하지 않음. (phase-26 결정 기록 참조)

## 요구사항

1. `sdd mode {turbo|auto|governed}` 전환이 `.claude/settings.json` 의 git push `ask` 멤버십을 **변경하지 않는다** (`_settings_mode_patch` 제거).
2. fragment baseline 불변식 박제: `ask` 에 git push 없음(자동) + `deny` 에 force-push 3변형 존재(차단).
3. sdd 소스가 `permissions.ask` 의 git push 를 다시 조작하지 않음을 테스트로 고정 (방향2 회귀 방지).
4. 이 repo 의 `.claude/settings.json` 정리: `ask` 에서 git push 제거(현 상태 유지) + `allow` 의 stray `Bash(git push:*)` 제거(redundant).
5. 전체 테스트 스위트 PASS.

## Out of Scope

- fragment `allow`/`deny` 의 git push 외 항목 재편 — 본 spec 은 push 게이팅만.
- `.claude/settings.json` 의 git push 외 누적 권한 정리 — 별도 (`/fewer-permission-prompts` 영역).
- check-irreversible / deny 의 force-push 차단 로직 변경 — 이미 동작, 본 spec 은 의존만.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [x] push 게이팅 제거 방향(방향2) — 사용자 승인 완료 (2026-06-29).

> [!WARNING]
> - [ ] **동작 변경**: 기존에 governed 모드에서 push 전 확인 프롬프트가 떴다면, 이제 안 뜬다(자동). 단 이는 §5.7 규약이 이미 정한 동작이며, force-push 는 여전히 deny 로 차단된다.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **sources/bin/sdd** | `_settings_mode_patch` 함수 + 3개 호출(turbo/auto/governed) 제거 | drift 원천 제거. push 게이팅이 §5.7 위반 |
| **fragment** | 변경 없음 (이미 §5.7 정합: ask 게이트 없음 + git:* allow + force deny) | baseline 이 이미 올바름 |
| **신규 test-settings-ssot.sh** | fragment 불변식 + sdd 비조작 정적 검증 | SSOT 박제, 방향2 회귀 방지 |
| **.claude/settings.json** | ask 의 git push 제거 유지 + allow stray 제거 | 명시 잔재(W3) 정리 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd`
`_settings_mode_patch()` 함수(~2739–2755) 삭제. `cmd_mode` 의 turbo/auto/governed 분기에서 `_settings_mode_patch "..."` 호출 라인 삭제. 전환 출력의 "settings.json: git push → ..." 줄도 함께 제거.

#### [NEW] `tests/test-settings-ssot.sh`
- T1: fragment `permissions.ask` 에 `Bash(git push)`/`Bash(git push:*)` 없음.
- T2: fragment `permissions.deny` 에 force-push 3변형(`--force:*`·`-f:*`·`--force-with-lease:*`) 존재.
- T3: `sources/bin/sdd` 가 `permissions.ask` 의 git push 를 jq 로 add/remove 하지 않음(`_settings_mode_patch` 부재) — 방향2 회귀 방지.

#### [MODIFY] `.claude/settings.json`
`permissions.ask` 에서 git push 제거 상태 유지(현 dirty 상태). `permissions.allow` 의 stray `Bash(git push:*)` 제거(`git:*` 로 redundant).

## 검증 계획

```bash
bash tests/test-settings-ssot.sh        # 신규 — 불변식
bash tests/test-turbo-mode.sh           # 모드 전환 회귀 (settings 조작 제거 영향)
bash tests/run.sh                        # 전체 회귀
```

수동 검증 시나리오:
1. `sdd mode turbo` → `governed` → `auto` 왕복 후 `jq '.permissions.ask' .claude/settings.json` — git push 가 **추가/제거되지 않음** (멤버십 불변). 기대: 항상 게이트 없음.
2. `git push --force` 시도 → `check-irreversible` + deny 로 여전히 차단.

## 롤백 계획

- `git revert` 로 단순 복원 (settings 조작 로직 + 테스트). state/마이그레이션 부수효과 없음. `.claude/settings.json` 은 텍스트 복원.

## ADR 후보

- [x] ADR 가치 있는 결정 있음 → 후보: `push-always-automatic` (type: convention) — "push 게이팅은 settings ask 가 아니라 §5.7 + deny/hook 으로" 를 명문화할지. **단 §5.7 이 이미 규약화**하고 있어 ADR 중복일 수 있음 → phase-26 결정 기록으로 충분, ADR 보류.
- [ ] 없음

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (신규 test-settings-ssot 포함)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 — 단, base 모드라 **phase-ship PR 에서 일괄 검토**(별도 spec PR 없음). spec walkthrough 는 작성.
- [ ] phase-26 결정 기록에 W3 방향2 + §5.7 발견 반영
