# spec-24-03: 정지규칙 엔진 + 결정 로그

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-24-03` |
| **Phase** | `phase-24` |
| **Branch** | `spec-24-03-stop-rules` |
| **Base 브랜치** | `main` (phase-24 는 base 브랜치 없음 — 각 spec → main) |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-06-21 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`auto` 모드(spec-24-01)는 plumbing 만 있고, blast-radius 가드는 커밋 시점으로 정렬됐다(spec-24-02). 하지만 auto 의 *유일한 사전 안전판* 인 **정지규칙(ADR-009 auto 규약 3)** 과 사람 검토의 근거가 될 **결정 로그(규약 2·4)** 가 아직 없다.

### 문제점

ADR-009 가 규정한 auto 안전 모델이 미구현이다:
- **정지규칙 ②(비가역/파괴 행동)**: force push·대량 삭제·외부 발행 등은 사후 검증으로도 못 되돌린다 — 실행 *전* 에 멈춰야 한다. 현재 감지 장치 없음.
- **정지규칙 ③(반복 테스트 실패)**: `post-commit-verify.sh` 는 실패 시 auto-revert 만 한다 — 같은 실패가 무한 반복돼도 사람을 부르지 않는다.
- **결정 로그**: auto 는 결정을 기본값으로 논블로킹 처리(규약 2)하는데, 그 결정·근거를 누적해 `phase-ship`(규약 4)에서 사람이 일괄 검토할 *기록 장치* 가 없다.

### 해결 방안

정지규칙의 *기계적 엔진* 2종과 결정 로그 *기록 장치* 를 만든다: (1) 비가역 명령을 실행 전 감지하는 PreToolUse `Bash` 훅 `check-irreversible.sh`, (2) `post-commit-verify.sh` 에 연속 실패 카운터 + N회 후 hard-stop, (3) 결정·근거를 active spec walkthrough 에 누적하는 `sdd decision` 명령. 훅 단계론에 따라 ②는 **경고 모드** 로 시작(1주 운영 후 차단 승격 — phase 위험완화 결정).

## 요구사항

1. **②비가역 행동 감지 훅** (`check-irreversible.sh`, PreToolUse `Bash` 매처): 보수적으로 좁게 정의한 비가역/파괴 명령을 감지해 경고. 감지 경계는 테스트로 고정.
   - 감지 대상(초기, narrow): force push(`git push --force`/`-f`/forced refspec `+`), history rewrite(`git filter-branch`/`filter-repo`), 광범위 삭제(`rm -rf` 의 `/`·`~`·bare `*` 타깃, `git clean -fdx`/`-fd`), 외부 발행(`npm|yarn|pnpm publish`, `gh release create`).
   - 모드 해석: `hook_resolve_mode "STOP_RULES" "warn"` — 경고 모드 시작, `HARNESS_HOOK_MODE_STOP_RULES=block` 으로 차단 승격 가능.
2. **③반복 실패 정지** (`post-commit-verify.sh` 확장): auto 모드에서 검증 실패 시 `state.autoFailCount` 증가, **N(기본 3)회 연속 실패** 시 auto-revert 대신 hard-stop 신호(사람 호출). 통과 시 카운터 0 리셋. 기존 turbo 동작은 불변.
3. **결정 로그** (`sdd decision`): `sdd decision add "<이슈>" "<선택>" "<근거>"` → active spec `walkthrough.md` 의 결정 로그 표에 행 append(섹션·헤더 없으면 생성). `sdd decision list` → 누적 행 출력. phase-ship(24-05)에서 수집할 토대.
4. 도그푸딩 미러(`.harness-kit/`) 동시 반영 + 신규 훅 settings 등록(`settings.json.fragment` + `.claude/settings.json`).
5. 신규 테스트 PASS + 전체 스위트 회귀 없음.

## Out of Scope

- **①방향 모호함 정지** + auto 의 *행동 규칙* (agent.md §8.4 auto 서술) → spec-24-04(논블로킹 결정)에서. 본 spec 은 *기계적 엔진* 만.
- **결정 로그의 phase-ship 일괄 노출** → spec-24-05.
- ②경고 → 차단(exit 2) 승격 → 1주 운영 후 별건(phase-FF).
- 감지 목록 확장(borderline 명령: `git reset --hard`, `--force-with-lease`, `docker push` 등) → 운영 데이터 후 별건. 초기엔 false-positive 최소화 위해 narrow.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] ②감지는 **narrow + 경고 모드** 로 시작 — 좁게 잡아 false-positive 를 줄이고, 테스트로 경계 고정 후 1주 뒤 차단 승격(phase 위험완화 결정 준수).
> - [ ] ③hard-stop 임계 N **기본 3회** (env `HARNESS_AUTO_FAIL_MAX` 로 조정).

> [!WARNING]
> - [ ] `state.json` 에 `autoFailCount` 필드 추가 — 기존 state 호환(누락 시 0 취급). schema 검증 테스트 있으면 동반 갱신.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **②`check-irreversible.sh`** | `check-diff-size.sh` 패턴 — `hook_tool_input command` grep + `hook_violation` | 기존 Bash 매처 훅과 일관. 경고 모드·mode 해석 재사용 |
| **③`post-commit-verify.sh`** | 연속 실패 카운터를 state 에 누적, N회 후 revert→hard-stop 전환 | 기존 auto-revert 흐름 보존하며 무한 반복만 차단(ADR-009 ③) |
| **결정 로그 `sdd decision`** | walkthrough 표에 append(멱등 헤더 생성) | "결정·근거를 walkthrough 에 누적"(규약 2) — 별도 저장소 없이 기존 산출물 활용 |

**②감지 경계(narrow, 테스트 고정)**: force push / history rewrite / 광범위 rm-rf·git clean / 외부 publish·release. `git reset --hard`·`--force-with-lease` 등 borderline 은 *제외*(FP 최소화). 경계는 `test-stop-rules.sh` 가 고정.

## Proposed Changes

#### [NEW] `sources/hooks/check-irreversible.sh`
②정지규칙 훅. PreToolUse `Bash` 매처. `command` 추출 → narrow 비가역 패턴 grep → `hook_violation`(경고 모드). `_lib.sh` 의 `hook_resolve_mode "STOP_RULES" "warn"` 사용.

#### [MODIFY] `sources/hooks/post-commit-verify.sh`
③연속 실패 카운터. auto 모드 검증 실패 시 `state.autoFailCount` 증가 → N(기본 3, `HARNESS_AUTO_FAIL_MAX`)회 시 auto-revert 대신 hard-stop 메시지(사람 호출). 통과 시 0 리셋. turbo 경로·기존 revert 동작 보존.

#### [MODIFY] `sources/bin/sdd`
`sdd decision add "<이슈>" "<선택>" "<근거>"` / `sdd decision list` 서브커맨드. active spec walkthrough.md 의 결정 로그 표에 행 append(섹션·헤더 멱등 생성). state 부재·active spec 부재 시 graceful.

#### [MODIFY] `sources/claude-fragments/settings.json.fragment` · [MODIFY] `.claude/settings.json`
PreToolUse `Bash` 매처 hooks 배열에 `.harness-kit/hooks/check-irreversible.sh` 등록.

#### [NEW] `tests/test-stop-rules.sh`
②감지(각 패턴 경고 / 정상 명령 무경고 / 경계 false-positive 없음 / block 모드 exit 2) + ③카운터(실패 누적 / N회 hard-stop / 통과 리셋).

#### [NEW] `tests/test-decision-log.sh`
`sdd decision add` 행 append / 헤더 멱등 / `list` 출력 / active spec 부재 graceful.

#### [NEW] `.harness-kit/hooks/check-irreversible.sh` · [MODIFY] `.harness-kit/hooks/post-commit-verify.sh` · [MODIFY] `.harness-kit/bin/sdd`
도그푸딩 미러 (각 구현 task 에서 두 트리 동시 반영).

## 검증 계획

```bash
bash tests/test-stop-rules.sh        # 신규
bash tests/test-decision-log.sh      # 신규
bash tests/test-turbo-hooks.sh       # post-commit-verify 회귀
bash tests/test-mode-auto.sh         # auto 모드 회귀
for t in tests/test-*.sh; do bash "$t" >/dev/null 2>&1 && echo "PASS $t" || echo "FAIL $t"; done
```

수동 검증 시나리오:
1. auto 모드에서 `git push --force` 시도 → 기대: stderr 비가역 경고(경고 모드 — 실행은 통과).
2. `sdd decision add "기본값 선택" "A" "흐름 우선"` → active spec walkthrough 결정 로그에 행 추가, `sdd decision list` 로 확인.
3. auto 검증 3회 연속 실패 → 3회째 hard-stop 메시지 + 카운터 동작.

## 롤백 계획

- `git revert` 로 전체 되돌림. `state.autoFailCount` 는 누락 시 0 취급이라 잔존해도 무해.
- 신규 훅 등록 revert 시 settings.json 에서 해당 줄 제거(미러 indirection — 재설치 불필요).

## ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — ADR-009 가 정지규칙 ①②③·결정 로그를 이미 거버닝. 본 spec 은 그 구현.

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (신규 + 회귀)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-24-03-stop-rules` 브랜치 push 완료
