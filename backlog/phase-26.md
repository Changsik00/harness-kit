# phase-26: auto-safety-residue (auto 안전망 잔여)

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-26-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-26` |
| **상태** | In Progress |
| **시작일** | 2026-06-28 |
| **목표 종료일** | TBD |
| **소유자** | dennis |
| **Base Branch** | `phase-26-auto-safety-residue` |

## 🎯 배경 및 목표

### 현재 상황

phase-25(auto-reliability)가 auto 의 *논블로킹 백스톱·정지규칙 2층 모델·사후 검증 1차*를 완성했다. 그러나 phase-25 회고에서 **안전망의 잔여 구멍 3건**(W1/W2/W3)이 남았다 — 모두 "auto 를 실제로 fire-and-forget 했을 때 새는 경계"다.

- **W1 (경계 미가시)**: `check-irreversible.sh` 의 감지는 *narrow*(false-positive 최소화)라, `git -C /x reset --hard`(reset 앞 `-C /x` 로 regex 미스)·`git rebase -i`·`rm -rf ./dir`(non-root/glob 타깃) 등은 *의도적으로* 미감지다. 그러나 이 경계가 테스트로 고정돼 있지 않아, 후속 변경이 경계를 *소리 없이* 옮겨도 회귀가 안 잡힌다.
- **W2 (fail-safe 방향 역전)**: `_sr_default="warn"` 후 `[ "$(hook_state mode)" = "auto" ] && _sr_default="block"`. state 파일/jq 부재로 `hook_state mode` 가 **빈 문자열**이면 — auto 세션이어도 — warn 으로 떨어져 비가역 명령이 통과한다. 즉 *모드 불명* 시 fail-dangerous(정지망 off). 비가역 가드는 불명 시 block(fail-safe)이어야 한다 (CLAUDE.md #5 의 "auto 에선 block 이 fail-safe" 원칙의 미적용 구멍).
- **W3 (settings SSOT 미고정)**: `.claude/settings.json` 의 `Bash(git push:*)` 가 install SSOT 인 `sources/claude-fragments/settings.json.fragment` 엔 없다. 이는 mode-toggle(`sdd:2747-2753`)이 런타임에 `permissions.ask` 에서 git push 를 넣고 빼는 round-trip 의 잔재다. *단순 drift 가 아니라* — mode-managed 항목을 제외한 **baseline 정합성**이 테스트로 고정돼 있지 않은 것이 문제.

### 목표 (Goal)

auto 안전망의 세 잔여 구멍을 닫는다 — 비가역 가드의 *경계를 테스트로 가시화*(W1)하고, *모드 불명 시 fail-safe(block)로 통일*(W2)하며, *settings baseline SSOT 를 sync 테스트로 고정*(W3)한다. phase 종료 시 "auto 가드가 새는 세 경로"가 모두 회귀 테스트로 박제된다.

### 성공 기준 (Success Criteria) — 정량 우선
1. W1: `git -C /x reset --hard`·`git rebase -i`·`rm -rf ./dir` 가 **의도적 미감지**임을 명시하는 assert_quiet 테스트가 `test-stop-rules.sh` 에 존재(경계 박제).
2. W2: state 파일 부재(모드 불명) + 비가역 명령 → **block(exit 2)** 으로 동작하는 테스트 존재. governed 명시 state → warn(회귀 유지).
3. W3 (방향2): `_settings_mode_patch` 제거로 모드 전환이 git push `ask` 를 조작하지 않음(§5.7 정합) + fragment 불변식(ask 무 git push / deny force 변형) 을 박제하는 sync 테스트 존재 + PASS.
4. 전체 테스트 스위트 PASS(신규 포함), 거버넌스 단어 예산(≤8000) 불변(이 phase 는 governance 문서 거의 미변경).

## 🧩 작업 단위 (SPEC + phase-FF)

> 본 절은 phase 의 *작업 지도* 입니다. W1/W2/FF4 는 작고 가역적이라 **phase-FF**, W3 은 조사 중 §5.7 모순·sdd 동작 변경이 드러나 **spec-26-01 로 승격**(§11.3 재검증).
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-26-01` | settings-push-ssot | P? | Merged | `specs/spec-26-01-settings-push-ssot/` |
<!-- sdd:specs:end -->

> SPEC: `spec-26-01-settings-push-ssot` (W3). 나머지는 phase-FF.

### SPEC

`spec-26-01` — W3 (settings push 권한 SSOT). 조사 중 발견: mode-toggle `_settings_mode_patch` 가 governed 에서 git push 를 `ask` 로 올려 **§5.7("push 자동")과 충돌** + fresh-install drift. → 방향2(토글 제거, push 게이팅을 §5.7+deny/hook 에 일임)로 spec 승격. 상세: `specs/spec-26-01-settings-push-ssot/spec.md`.

### phase-FF 항목 (완료)

| # | 항목 | 요점 | 연관 모듈 | 커밋 |
|---|---|---|---|:---:|
| FF1 (W1) | 비가역 가드 경계 박제 | `git -C /x reset --hard`·`rebase -i`·`rm -rf ./dir` 등 narrow 밖 변형이 **의도적 미감지**임을 assert_quiet 로 고정 | `tests/test-stop-rules.sh` | `052c6ea` |
| FF2 (W2) | 모드 불명 fail-safe 통일 | state/jq 부재로 mode 불명 시 `_sr_default` 를 block(fail-safe)으로. governed 명시 state 는 warn 회귀 유지 | `sources/hooks/check-irreversible.sh` | `64ce1f6` |
| FF4 | queue.md phase-24 중복 줄 정리 | `sdd phase done 24` 가 만든 중복 완료 줄 1건 제거(cosmetic) | `backlog/queue.md` | `49c48d7` |

> FF2 의 fail-safe 방향(불명→block)은 CLAUDE.md #5 에서 이미 결정됨 → phase-FF 적합.
> W3 만 §5.7 모순·sdd 동작 변경이라 spec 승격(§11.3).

## 📌 결정 기록 (Review)

> Phase PR review 중 발생한 결정·합의·발견을 누적합니다. Phase 레벨 living decision log (→ agent.md §6.3.2).

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| C(W1/W2/W3) 작업 단위 | A: 2~3 spec / B: 전부 phase-FF(spec 없음) / C: 단일 spec-x 번들 | **B (phase-FF)** | W1/W2/W3 각각 1–2 commit 의 작고 가역적 항목 → §11.4 가 phase-FF(spec 산출물 없이 phase 브랜치 직접 커밋, phase-ship 일괄 검토) 를 명시. spec 3종세트는 과한 ceremony(§11.1). 최초 spec-26-01 생성했다가 phase-FF 로 정정 |
| W2 모드 불명 시 기본값 | warn(현행, fail-dangerous) / block(fail-safe) | **block** | 비가역 가드는 모드 확인 불가 시 "멈추고 사람 대기"가 fail-safe. CLAUDE.md #5 정합. env override·rare-empty-state 로 attended 비용 낮음 |
| auto 모드로 본 phase 진행 | governed / auto | **auto** | 사용자 명시 지시("C 를 auto 모드로"). auto 의 phase-level fire-and-forget 도그푸딩 겸함. W2 결정이 선결돼 새 아키텍처 결정 없음 → auto 적합(§2.4) |
| W3 settings push 게이팅 방향 | 방향1(fragment ask 에 push 추가=governed 게이트) / 방향2(toggle 제거=push 항상 자동) | **방향2** (사용자 승인 2026-06-29) | 조사 중 발견: mode-toggle governed 분기가 git push 를 `ask` 로 올려 **constitution §5.7("push 자동, NO user response")과 충돌**. 방향1 은 §5.7 위반 지속. 방향2 는 drift 원천 제거 + §5.7 정합, force-push 는 deny+hook 이 이미 차단. W3 을 spec-26-01 로 승격 |
| W3 작업 단위 (phase-FF vs spec) | phase-FF / spec 승격 | **spec-26-01** | §5.7 규약·sdd 동작 변경이라 설계 근거를 spec.md 로 남길 가치(§11.3). 방향 결정 후에도 구현 회귀(모드 전환 테스트 영향) 점검 필요 |

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 의 Done 조건 중 하나. 이 프로젝트의 통합 테스트는 `tests/` bash 스위트.

### 시나리오 1: 비가역 가드 경계·fail-safe 회귀
- **Given**: `check-irreversible.sh` (W1 경계 + W2 fail-safe 반영)
- **When**: `bash tests/test-stop-rules.sh` 실행
- **Then**: 미감지 변형(W1)은 무경고, state 불명+비가역(W2)은 block(exit 2), 기존 T1~T22 전부 PASS
- **연관 항목**: FF1, FF2

### 시나리오 2: settings baseline SSOT
- **Given**: 신규 settings sync 테스트
- **When**: 해당 테스트 실행
- **Then**: `.claude/settings.json` baseline(mode-managed 제외) == fragment, PASS
- **연관 항목**: FF3

### 통합 테스트 실행
```bash
# 본 phase 관련 테스트
bash tests/test-stop-rules.sh
bash tests/run-all.sh   # 전체 회귀
```

## 🔗 의존성

- **선행 phase**: phase-25 (auto-reliability) — 본 phase 는 그 회고 잔여
- **외부 시스템**: 없음 (bash + jq)
- **연관 ADR**: `docs/decisions/ADR-009-*.md` (정지규칙·모드 차등)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| W2 block 통일이 attended(broken-state) UX 저해 | 낮음 | env override(`HARNESS_HOOK_MODE_STOP_RULES`) 존재, empty-state 는 rare. governed 명시 state 는 warn 회귀 유지 |
| W3 sync 테스트가 런타임 mutation 을 drift 로 오판 | 중간 | mode-managed 키를 양쪽에서 정규화·제외 후 비교 (런타임 ↔ baseline 분리) |
| auto 모드 자율 실행 중 테스트 red | 낮음 | post-commit-verify 가 auto-revert + 카운터. phase-ship PR 에서 사람 최종 검토 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (base branch 모드: `phase-26-auto-safety-residue` → main)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
