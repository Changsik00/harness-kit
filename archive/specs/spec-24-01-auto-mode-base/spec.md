# spec-24-01: auto 모드 토대 (CLI + 상태 + 훅 인식)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-24-01` |
| **Phase** | `phase-24` |
| **Branch** | `spec-24-01-auto-mode-base` |
| **Base 브랜치** | `main` (phase-24 일반 모드) |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-06-19 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`cmd_mode` 는 `governed` / `turbo` 2-mode 만 안다 (`sources/bin/sdd:2742`). turbo 는 `state.mode="turbo"` + settings 의 git push 허용 + plan-accept 훅 bypass(`check-plan-accept.sh:19`)로 구현돼 있다.

### 문제점

ADR-009 가 정의한 `auto`(자율·unattended) 모드를 *선택할 방법 자체가 없다*. `sdd mode auto` 가 없고, `sdd status` 가 auto 를 표시하지 못하며, 훅들은 turbo 만 비차단으로 인식한다. 후속 spec(24-03 정지규칙, 24-04 논블로킹 결정)이 올라탈 *모드 토대* 가 필요하다.

### 해결 방안

`auto` 를 3번째 모드로 plumbing 한다 — CLI 전환·상태 표시·help·settings patch·훅 인식. 이번 spec 은 *토대* 만: auto 의 행동은 일단 turbo 와 동일(비차단 + push 허용)하게 두고, auto 고유 규약(정지규칙·결정 로그·논블로킹 기본값)은 24-03/24-04 에서 얹는다.

## 요구사항

1. `sdd mode auto` — `state.mode="auto"` 설정 + settings git push 허용(turbo 와 동일) + 전환 메시지.
2. `sdd mode status` 및 `sdd status` 가 `auto` 를 정확히 표시.
3. turbo 를 비차단으로 인식하던 훅(`check-plan-accept.sh` 등)이 `auto` 도 동일하게 인식.
4. `sdd mode` help 에 auto 1줄 추가 (린하게 — 상세는 ADR-009).
5. 잘못된 모드값은 기존대로 거부 (`turbo | governed | auto | status` 외).

## Out of Scope

- 정지규칙 엔진(①②③) — spec-24-03
- 논블로킹 결정(기본값+로그) — spec-24-04
- blast-radius 커밋시점 정렬 — spec-24-02
- agent.md 의 auto 행동 규칙 상세 — spec-24-04 (여기선 모드 표/포인터만)

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] auto 의 settings patch 는 turbo 와 동일(git push allow)하게 — unattended 라 push 프롬프트 불가. (기본 채택)

> [!WARNING]
> - [ ] 토대 단계의 auto 는 turbo 와 행동이 같음 — 정지규칙 없이 auto 를 켜면 turbo 와 구분 안 됨. 24-03/24-04 전까지 "이름만 auto" 임을 명시.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| `cmd_mode` | `auto)` case 추가, turbo 로직 재사용 | 토대 단계 행동 동일 |
| 훅 turbo 게이트 | `turbo` → `turbo|auto` 비차단 인식 | auto 가 plan-accept 등 통과해야 의미 |
| `cmd_status` 모드 행 | turbo/auto = 강조, governed = dim | 자율 모드 가시성 |
| `_settings_mode_patch` | auto = turbo 와 동일 패치 | push 허용 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd` (+ 미러 `.harness-kit/bin/sdd`)
- `cmd_mode`: `auto)` case 추가 — `state_set mode "auto"`, `_settings_mode_patch "auto"`, 전환 메시지(자율·unattended 안내 + 24-03/24-04 전까지 turbo 동급임을 1줄).
- `_settings_mode_patch`: `auto` 를 turbo 와 동일 분기로 처리 (git push allow).
- `cmd_status` 모드 표시: `auto` 도 강조 출력.
- `cmd_help` / `cmd_mode` help: auto 1줄 문서화.

#### [MODIFY] `sources/hooks/check-plan-accept.sh` (+ 미러 `.harness-kit/hooks/`)
- `[ "$mode" = "turbo" ]` 비차단 게이트를 `turbo|auto` 로 확장. (다른 turbo-게이트 훅 있으면 동일 적용 — 구현 시 grep 확인)

#### [MODIFY] `tests/test-mode-auto.sh` (신규 또는 기존 mode 테스트 확장)
- auto 전환/상태/잘못된 값 거부 + 훅이 auto 비차단 인식 검증.

## 검증 계획

```bash
bash tests/test-mode-auto.sh
# 전체 회귀
for t in tests/test-*.sh; do bash "$t" >/dev/null 2>&1 && echo "PASS $t" || echo "FAIL $t"; done
```

수동 검증 시나리오:
1. `sdd mode auto` → `sdd status` 에 Active Mode: auto 표시 — 기대: auto 강조 출력
2. auto 상태에서 `check-plan-accept.sh` 에 production 파일 편집 입력 → 기대: exit 0 (비차단)
3. `sdd mode bogus` → 기대: 거부 + 허용값 안내

## 롤백 계획

- `git revert` — 순수 bash 분기 추가 + 훅 조건 확장. state/마이그레이션 영향 없음(기존 turbo/governed 동작 불변).

## ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — 거버닝 ADR(ADR-009)이 이미 존재. 본 spec 은 그 구현.

## ✅ Definition of Done

- [ ] 모든 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-24-01-auto-mode-base` 브랜치 push 완료
