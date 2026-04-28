# spec-15-01: upgrade-danger-audit (Research Spec)

> 본 문서는 Research 타입 Spec (constitution §9). 코드 수정 0, 산출물은 본 문서 자체.
> **Plan Accept 시점** 에는 §1~§3 (배경, 질문, DoD) 만 채워져 있고,
> §4~§7 (분석, 비교, 권고, 후속 spec 명세) 는 실행 단계에서 채워집니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-15-01` |
| **Phase** | `phase-15` |
| **Branch** | `spec-15-01-upgrade-danger-audit` |
| **타입** | Research |
| **상태** | Planning |
| **Integration Test Required** | no |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

---

## §1. 배경 (Background)

phase-15.md §배경 참조. 요약: 최근 4건 update-related 버그(state 손실 / install 누락 / phase activate / gitignore dup)가 동일 패턴으로 발생 중이며, 현재 테스트가 "빈 fixture" 만 다루기에 stateful upgrade 시나리오가 사실상 무방비.

본 audit 은 그 위험 영역의 *지도* 를 그리는 것을 목표로 한다. 코드 수정 0, 산출물은 본 `spec.md` 의 §4~§7 + (필요 시) phase-15.md 갱신.

## §2. 연구 질문 (Research Questions)

본 audit 이 답해야 할 질문 — Plan Accept 시점의 검토 포인트.

### Q1. 과거 4건 버그의 공통 패턴은 무엇인가?

- 어떤 layer 에서 깨지는가 (state.json / 파일시스템 / queue marker / 사용자 작성물)?
- 공통 trigger 는 무엇인가 (덮어쓰기 / 부분 백업 / 신규 파일 / 멱등성 위반)?
- 동일 layer 에서 아직 발견되지 않은 잠재 버그가 있는가?

### Q2. install.sh / update.sh 의 덮어쓰기 정책은 무엇인가?

각 파일/디렉토리에 대해 다음 4분류 중 어디에 속하는지 표 작성:
- **OVERWRITE** — 항상 새 키트로 덮어쓰기 (예: `agent/constitution.md`)
- **MERGE** — 기존과 새 것을 머지 (예: `state.json` 의 일부 필드)
- **SKIP-IF-EXISTS** — 이미 있으면 손대지 않음 (예: 사용자 작성 phase.md)
- **APPEND-IDEMPOTENT** — 마커 영역 멱등 추가 (예: `.gitignore` 의 hk 영역)

명시되지 않은 (= "어쩌다 보니 그렇게 동작하는") 파일이 있는가?

### Q3. Stateful upgrade fixture 시스템을 어떤 형태로 만들 것인가?

≥ 2개 옵션 비교:
- **A) 함수 합성** — bash 함수로 `with_in_flight_phase()`, `with_pre_defined_phases()` 등 mixin
- **B) Declarative manifest** — JSON/YAML 로 시나리오 명세 → 파서가 fixture 생성
- **C) 다른 안** — research 중 도출

각 옵션의 trade-off (구현 복잡도 / 가독성 / 시나리오 추가 비용 / bash 3.2 호환성).

### Q4. 본 phase 의 "Go" 조건과 후속 spec 분할은?

- spec-15-02 / 15-03 / 15-04+ 의 명세를 어디까지 구체화할 수 있는가?
- 새로 발견된 잠재 버그를 본 phase 에 흡수할지, 후속 phase / Icebox 로 미룰지의 우선순위 기준 (P0/P1/P2)?
- "Go" = 본 phase 진행 가능 / "No-Go" = 추가 research 또는 phase 재정의 필요.

## §3. Definition of Done (Research)

constitution §9.1 기준:

- [ ] Trade-off Analysis ≥ 2 안 (Q3 의 옵션 A vs B 등)
- [ ] Prototype (해당 시) — 본 audit 은 코드 수정 0 이므로 적용 안 됨, 단 §6 권고에 "초안 의사코드" 포함 가능
- [ ] Go/No-Go 권고 명시
- [ ] §4 ~ §7 모두 채워짐:
  - §4 과거 버그 분석 (Q1)
  - §5 install/update 정책 단면 (Q2)
  - §6 fixture 설계 옵션 비교 + 권고 (Q3)
  - §7 후속 spec 명세 + 우선순위 (Q4)
- [ ] phase-15.md 의 spec 표 / 위험 섹션 갱신
- [ ] walkthrough.md / pr_description.md 작성 + ship + PR 생성

---

## §4. 과거 버그 분석

### §4.1 버그 카탈로그

각 spec 의 spec.md / 머지 commit diff 를 직접 정독한 결과.

| # | Spec / PR | Layer | Trigger | 1줄 fix 요지 |
|:---:|---|---|---|---|
| 1 | `spec-x-update-preserve-state` (#82, c771384) | `state.json` (.claude/state/) | install.sh 가 항상 새 state 템플릿으로 덮어쓰기 + update.sh 백업 화이트리스트가 4개 필드 (`phase, spec, planAccepted, lastTestPass`) 만 → `branch`, `baseBranch` 영구 소실 | jq 객체 백업으로 6개 필드 일괄 백업 + `jq * merge` 복원 |
| 2 | `spec-x-install-phase-ship-template` (#83, 4ea6fac) | 파일시스템 (`.harness-kit/agent/templates/`) | `sources/templates/` 에 `phase-ship.md` 추가했지만 `install.sh:262` 의 하드코딩 리스트 미갱신 → 신규 install 환경에서 템플릿 누락 → `/hk-phase-ship` 동작 불가 | install.sh 리스트에 한 단어 추가 |
| 3 | `spec-x-sdd-phase-activate` (#84, e40b770) | 사용자 작성물 (`backlog/phase-NN.md`) + sdd CLI 의사결정 | `sdd phase new` 가 max+1 알고리즘만 사용. 사용자가 `phase-03~07.md` 를 미리 작성해도 무시하고 `phase-08` 생성 → 사용자 작성 본문 사일런트 무시 | `sdd phase activate` 신설 + `phase new` 가드 |
| 4 | `spec-14-03-gitignore-idempotent` (#78, 2840c2b) | 파일시스템 (`.gitignore` — 사용자/키트 공유 영역) | install.sh 의 `.gitignore` 갱신이 `# harness-kit` 헤더 grep 한 번에만 의존. 헤더 누락 / 사용자 사전 라인 / 라인 일부 누락 시 라인 중복 또는 영구 누락 | 라인별 idempotent ensure 패턴 |

### §4.2 공통 패턴 (3개)

4건 모두 *동일한 형태의 실패* 라기보다는 **"같은 종류의 무방비"** 가 위치만 바꿔 나타난 것. 추출되는 패턴은 다음 셋:

#### Pattern A — Schema Drift (스키마 표류)

**형태**: 진실의 원천 (sources/ 또는 데이터 스키마) 이 자라는데, 그것을 *읽거나 처리하는 로직* 의 화이트리스트가 같이 자라지 않음 → 사일런트 누락.

- 버그 #1: `state.json` 스키마가 `branch`/`baseBranch` 로 자랐는데 update.sh 백업 화이트리스트는 4개에서 멈춤
- 버그 #2: `sources/templates/` 가 8개로 자랐는데 install.sh 복사 리스트는 7개에서 멈춤

**근본**: install/update 로직이 *명시적 화이트리스트* 로 작성되어 있어서 진실의 원천 변경 시 양쪽을 동기화해야 함. 단일-원천 sync 가 아닌 이중-기록 구조.

#### Pattern B — User Content Blindness (사용자 작성물 무시)

**형태**: 키트가 자기 영역과 사용자 영역의 경계를 *암묵적으로* 가정. 사용자가 키트가 관리한다고 여기는 영역에 작성물을 두면 키트가 그것을 인지 못 하고 덮어쓰거나 우회.

- 버그 #3: 사용자가 작성한 `phase-03.md` 가 `sdd phase new` 의 의사결정에 입력으로 들어가지 않음
- 버그 #4: 사용자가 미리 작성한 `.harness-kit/` 라인 또는 헤더 누락 상태가 install.sh 의 의사결정에 입력으로 들어가지 않음

**근본**: 사용자 영역과 키트 영역의 *명시적 경계 정책* 부재. 어떤 파일이 OVERWRITE / MERGE / SKIP-IF-EXISTS / APPEND-IDEMPOTENT 인지 코드 곳곳에 흩어져 있고 문서화되지 않음.

#### Pattern C — Insufficient Idempotency (조건부 멱등성)

**형태**: "재실행 시 동일 결과" 라는 멱등성 명세가 *해피 패스* 에서만 성립. 비정상 입력 (헤더 누락, partial backup 등) 에서는 누적/소실 발생.

- 버그 #1: state.json 의 6개 필드 중 4개만 멱등. 나머지 2개는 update 마다 소실 (음의 멱등성).
- 버그 #4: `.gitignore` 의 4 라인이 헤더 grep 1회로 묶여 처리. 헤더만 누락되면 4 라인 일괄 중복 추가.

**근본**: idempotent 의 단위가 너무 큼 (object 레벨 / 섹션 레벨). 라인/필드 단위로 내려가야 비정상 입력에서도 멱등.

### §4.3 동일 패턴의 잠재 위험 (추론)

각 패턴이 적용될 가능성이 있는 다른 위치 — §5 의 정책 단면 분석에서 검증할 후보.

#### Pattern A 잠재 위험

| 후보 | 의심 |
|---|---|
| `sources/commands/` (슬래시 커맨드) | install.sh 가 `commands/` 디렉토리를 어떻게 복사? 하드코딩 리스트인가, 디렉토리 sync 인가? 새 커맨드 추가 시 누락 가능성 |
| `sources/hooks/` | 동일. 새 hook 추가 시 install 누락 또는 settings.json 등록 누락 |
| `sources/governance/` | constitution / agent / align 외에 새 governance 파일 추가 시 |
| `sources/claude-fragments/` | 신규 fragment 추가 시 install.sh 가 자동 인식? |
| `tests/test-install-layout.sh` | 위 모든 항목이 테스트로 검증되는지 — 검증 자체의 화이트리스트도 표류 가능 |

#### Pattern B 잠재 위험

| 후보 | 의심 |
|---|---|
| `sdd spec new` | active phase 의 max seq+1 로 spec 생성. 사용자가 `spec-15-04-...md` 디렉토리를 미리 만들어 두면 어떻게 동작? `phase new` 와 동일 패턴 가능 |
| `CLAUDE.md` HARNESS-KIT 블록 | install 이 사용자 작성 영역 (블록 외부) 을 보존? 블록 안의 사용자 추가분은? |
| `settings.json` hook 영역 | 사용자가 추가한 hook 이 install 후에도 보존? |
| `queue.md` 마커 외부 (Icebox / 대기 Phase) | sdd 가 마커 외부를 손대지 않는다는 정책이 코드로 강제되는지 |
| `phase-NN.md` 의 사용자 작성 본문 | sdd 가 phase.md 본문을 어디까지 읽고 어디까지 갱신하는지 (이미 spec-x-sdd-phase-activate 에서 부분 확인) |

#### Pattern C 잠재 위험

| 후보 | 의심 |
|---|---|
| `CLAUDE.md` 의 `@.harness-kit/CLAUDE.fragment.md` import 라인 | 라인 단위 멱등인가, 블록 단위인가? 헤더 누락 시 시나리오 동일하게 발생? |
| `settings.json` 의 hook 등록 | jq merge 인가 string append 인가? 동일 hook 등록 시 중복 가능성 |
| `sdd_marker_append` | 한 줄 단위 멱등 — common.sh 에서 확인되었으나 multi-line block 추가는? |
| `state.json` 의 신규 필드 추가 흐름 | install.sh 템플릿 갱신 + update.sh 백업 리스트 갱신 + 스키마 검증의 *3중 sync* 필요 — 어디서 끊어질지 |

## §5. install.sh / update.sh / uninstall.sh 덮어쓰기 정책 단면

### §5.1 정책 분류표

`install.sh` 의 처리 단위를 4분류 (OVERWRITE / MERGE / SKIP-IF-EXISTS / APPEND-IDEMPOTENT) 로 정리.

| 처리 단위 | 정책 | 근거 라인 | Sync 형태 | 위험 패턴 |
|---|---|---|---|---|
| `mkdir -p` 디렉토리 생성 (8개) | IDEMPOTENT | install.sh:243-251 | hardcoded 리스트 | A (낮음 — 대상 디렉토리 추가 시 미생성) |
| `sources/governance/` → `.harness-kit/agent/` | OVERWRITE | install.sh:257-259 | **hardcoded 리스트** (3 파일) | **A (높음)** |
| `sources/templates/` → `.harness-kit/agent/templates/` | OVERWRITE | install.sh:262-264 | **hardcoded 리스트** (8 파일) | **A (높음 — 이미 1회 발현)** |
| `sources/commands/` → `.claude/commands/` | OVERWRITE | install.sh:269-280 | **directory glob** (`*.md`) | A (없음 — 자동 동기화) |
| `sources/hooks/` → `.harness-kit/hooks/` | OVERWRITE + chmod +x | install.sh:285-298 | directory glob (`*.sh`) | A (없음) |
| `sources/bin/` → `.harness-kit/bin/` | OVERWRITE (재귀) | install.sh:303-313 | `cp -rf` 디렉토리 | A (없음) |
| `.claude/settings.json` | MERGE (jq) | install.sh:318-355 | permissions = union, hooks = kit-overwrite | **B (중간 — 사용자 hook 손실)** |
| `CLAUDE.md` HARNESS-KIT 블록 | APPEND-IDEMPOTENT (블록 마커) | install.sh:360-397 | awk 블록 교체 | A/C (낮음 — 블록 단위) |
| `.harness-kit/CLAUDE.fragment.md` | OVERWRITE | install.sh:372 | 단일 파일 cp | (키트 영역, 정상) |
| `.gitignore` | APPEND-IDEMPOTENT (라인) | install.sh:402-442 | 라인별 ensure 헬퍼 | C (없음 — spec-14-03 이후) |
| `.harness-kit/installed.json` | OVERWRITE | install.sh:447-459 | `cat > <<EOF` | (키트 메타, 정상) |
| `.harness-kit/harness.config.json` | OVERWRITE | install.sh:461-474 | `cat > <<EOF` | B (낮음 — 사용자 수정분 손실) |
| `.claude/state/current.json` | **OVERWRITE** | install.sh:476-493 | `cat > <<EOF` (8 필드 템플릿) | **A/C (가장 위험 — 1회 발현)** |

### §5.2 update.sh 의 보존 메커니즘

install.sh 가 모든 것을 OVERWRITE 하므로 update.sh 는 **before/after 스냅샷-복원** 패턴으로 사용자 자산을 보호.

| 보존 대상 | 메커니즘 | 근거 라인 | 위험 |
|---|---|---|---|
| `installed.json.kitVersion` (PREV_VER) | 변수에 jq 로 추출 | update.sh:51 | 정상 |
| `harness.config.json.backlogDir` → prefix | 변수 + 인자 재조립 | update.sh:55-62 | 정상 |
| `harness.config.json.gitignore` 옵션 | 변수 + 인자 재조립 | update.sh:64-69 | 정상 |
| `state.json` 의 6개 필드 | jq 객체 백업 + `* merge` 복원 | update.sh:113-143 | **A (화이트리스트 — 새 필드 추가 시 누락)** |
| `.claude/state/` 디렉토리 자체 | uninstall.sh `--keep-state` | update.sh:111, uninstall.sh:99-103 | 정상 |
| 기타 `.harness-kit/`, `.claude/commands/`, `CLAUDE.md` 블록, `.gitignore` 등 | install.sh 가 멱등/머지로 처리 | (각 install.sh 라인) | install.sh 정책 그대로 |

### §5.3 uninstall.sh 의 청소 정책

update.sh 가 호출하는 `uninstall.sh --keep-state` 는 키트 영역만 제거하고 사용자 영역은 보존해야 한다. 그러나:

| 청소 대상 | 정책 | 근거 라인 | 위험 |
|---|---|---|---|
| `.harness-kit/` 디렉토리 전체 | DELETE | uninstall.sh:68 | 정상 |
| `agent/`, `scripts/harness/` (구 레이아웃) | DELETE | uninstall.sh:75, 79 | 정상 |
| `settings.json` 의 `hooks` 키 | jq `del(.hooks)` | uninstall.sh:87 | 정상 (사용자 추가 hook 도 같이 사라짐 — Pattern B) |
| `.claude/commands/` 의 키트 명령 | **hardcoded 명단으로 rm** | **uninstall.sh:92-95** | **🚨 Pattern A — Critical** |
| `.claude/state/` | DELETE (`--keep-state` 시 skip) | uninstall.sh:99-103 | 정상 |
| `CLAUDE.md` HARNESS-KIT 블록 | awk 로 블록 제거 | uninstall.sh:106-116 | 정상 |
| `.gitignore` HARNESS-KIT 라인 | sed/awk | uninstall.sh:118+ | 정상 |

#### 🚨 §5.3.1 Critical: uninstall.sh 의 KIT_COMMANDS 명단이 stale

**uninstall.sh:92**:
```bash
KIT_COMMANDS="align spec-new plan-accept spec-status handoff phase-new phase-status task-done archive"
```

이 명단은 **구 슬래시 커맨드 이름** 들이다. 현재 `sources/commands/` 에 있는 12개 슬래시 커맨드는 모두 **`hk-` prefix** 를 사용한다 (`hk-align`, `hk-plan-accept`, `hk-archive`, `hk-ship` 등).

**영향**:
- `update.sh` 실행 시 uninstall 단계에서 *어떤 슬래시 커맨드도 제거되지 않음*. 이후 install 단계가 동일 이름의 hk-* 를 다시 복사 → 우연히 정상 동작 (덮어쓰기).
- 그러나 **새 버전에서 슬래시 커맨드를 *이름 변경* 또는 *제거* 하면, 구 커맨드가 사용자 환경에 영구 잔재**. (예: `hk-archive.md` 가 다음 버전에 `hk-cleanup.md` 로 이름 바뀌면 둘 다 존재 → 사용자 혼란 + AI 가 stale 커맨드 사용 가능)
- 또 uninstall 단독으로 사용자가 키트를 완전히 지우려 할 때 **hk-* 슬래시 커맨드들이 모두 잔재**. 이는 사용자 경험 + 거버넌스 신뢰성 모두 손상.

**근본 원인**: install.sh:269-280 은 디렉토리 glob (자동 동기화 ✅) 인데 uninstall.sh:92-95 는 hardcoded 명단. 양방향이 **비대칭**.

**제안 fix**: `.harness-kit/installed.json` 에 install 시점의 슬래시 커맨드 목록을 기록 → uninstall 이 그 목록을 읽어 정확히 그 파일들만 제거. 또는 `.claude/commands/` 의 모든 `hk-*.md` 일괄 제거 (단, 사용자가 본인의 hk- 접두사를 안 쓴다는 가정).

### §5.4 정책 미명시 / 위험 항목 종합

§5.1~§5.3 의 종합 위험 등급:

| 항목 | 위험 등급 | 근거 |
|---|:---:|---|
| `uninstall.sh:92` KIT_COMMANDS stale 명단 | **P0** | 슬래시 커맨드 이름 변경/제거 시 영구 잔재 |
| `install.sh:257-259` governance 하드코딩 (3 파일) | **P1** | 새 governance 파일 추가 시 install 누락 (Pattern A) |
| `install.sh:262-264` templates 하드코딩 (8 파일) | **P1** | 이미 1회 발현 (#83). 추가 시 재발 가능 |
| `update.sh:120` state 백업 화이트리스트 (6 필드) | **P1** | 이미 1회 발현 (#82). 새 state 필드 추가 시 재발 |
| `install.sh:347-348` hooks = kit-overwrite (사용자 hook 손실) | **P2** | 명시된 정책이지만 사용자 영역 보존 누락 (Pattern B) |
| `install.sh:461-474` harness.config.json OVERWRITE | **P2** | 사용자 수정분 손실. 키트 영역이라 영향 적음 |
| `update.sh` uninstall+install 모델 자체 | **P2** | OVERWRITE-then-restore 패턴이 모든 보존 로직의 부담 원천. 별도 phase 후보 (in-place upgrade 리팩토링) |

## §6. Stateful Fixture 설계 옵션 비교

### §6.1 옵션 A — 함수 합성 (Function Composition)

기존 `make_fixture()` 를 base 로 두고, "사용자 환경의 변형" 을 mixin 함수로 적층.

```bash
# tests/lib/fixture.sh (신규 헬퍼 라이브러리)

# Base — 깨끗한 install + git init
make_fixture() {
  local dir; dir=$(mktemp -d)
  bash "$ROOT/install.sh" --yes "$dir" >/dev/null
  git -C "$dir" init -q
  git -C "$dir" config user.email t@l && git -C "$dir" config user.name t
  echo "$dir"
}

# Mixin — in-flight phase/spec 가 진행 중인 사용자
with_in_flight_phase() {
  local dir="$1" phase="${2:-phase-08}" spec="${3:-spec-08-03-something}"
  jq --arg p "$phase" --arg s "$spec" \
     '.phase=$p | .spec=$s | .branch=$s | .baseBranch=null
      | .planAccepted=true | .lastTestPass="2026-04-01T00:00:00Z"' \
     "$dir/.claude/state/current.json" > /tmp/_st && mv /tmp/_st "$dir/.claude/state/current.json"
  cat > "$dir/backlog/${phase}.md" <<EOF
# ${phase}: in-flight phase
<!-- sdd:specs:start -->
| ID | 슬러그 | ... |
<!-- sdd:specs:end -->
EOF
  mkdir -p "$dir/specs/${spec}"
  cat > "$dir/specs/${spec}/spec.md" <<<"# ${spec}: in flight"
}

# Mixin — 사용자가 미리 작성한 phase 들
with_pre_defined_phases() {
  local dir="$1"; shift
  for p in "$@"; do
    cat > "$dir/backlog/${p}.md" <<EOF
# ${p}: 사전 정의 (사용자 작성)
임의의 본문 — update 후 보존되어야 함.
EOF
  done
}

# Mixin — 사용자가 커스터마이즈한 CLAUDE.fragment
with_customized_fragment() {
  local dir="$1"
  printf '\n## 사용자 추가 메모\n임의 텍스트\n' \
    >> "$dir/.harness-kit/CLAUDE.fragment.md"
}

# Mixin — queue.md Icebox 에 사용자 메모
with_dirty_queue_icebox() {
  local dir="$1"
  sed -i.bak 's|^## 🧊 Icebox|## 🧊 Icebox\n- 사용자 메모: 보존되어야 함|' "$dir/backlog/queue.md"
  rm -f "$dir/backlog/queue.md.bak"
}

# Mixin — settings.json 에 사용자 추가 hook (Pattern B 검증용)
with_user_hook() {
  local dir="$1"
  jq '.hooks.UserAddedHook = [{"matcher":"*", "hooks":[{"type":"command", "command":"echo user"}]}]' \
     "$dir/.claude/settings.json" > /tmp/_s && mv /tmp/_s "$dir/.claude/settings.json"
}
```

**시나리오 1 사용 예** (in-flight phase 사용자가 update 실행):

```bash
F=$(make_fixture)
with_in_flight_phase "$F" "phase-08" "spec-08-03-stock-lock"
before=$(jq -c . "$F/.claude/state/current.json")
bash "$ROOT/update.sh" --yes "$F" >/dev/null
after=$(jq -c '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}' \
        "$F/.claude/state/current.json")
[ "$(echo "$before" | jq -c '{phase,spec,branch,baseBranch,planAccepted,lastTestPass}')" = "$after" ] \
  && ok "in-flight 6 fields 보존" || fail "..."
```

### §6.2 옵션 B — Declarative Manifest

각 시나리오를 JSON/YAML 로 명세하고 파서/실행기가 fixture 생성.

```json
// tests/scenarios/in-flight-phase.json
{
  "name": "in-flight phase update",
  "given": {
    "state": {
      "phase": "phase-08",
      "spec": "spec-08-03-stock-lock",
      "branch": "spec-08-03-stock-lock",
      "baseBranch": null,
      "planAccepted": true
    },
    "files": {
      "backlog/phase-08.md": "# phase-08: in-flight\n",
      "specs/spec-08-03-stock-lock/spec.md": "# spec-08-03\n"
    }
  },
  "when": "update.sh --yes",
  "then": {
    "state_preserves": ["phase", "spec", "branch", "baseBranch", "planAccepted", "lastTestPass"],
    "files_preserved": ["backlog/phase-08.md", "specs/spec-08-03-stock-lock/spec.md"]
  }
}
```

```bash
# tests/run-scenario.sh (파서)
SCENARIO="$1"
DIR=$(mktemp -d)
bash install.sh --yes "$DIR" >/dev/null

# given.state 적용
jq -r '.given.state | to_entries[] | "\(.key)=\(.value | @sh)"' "$SCENARIO" \
  | while read kv; do
      key="${kv%%=*}"; val="${kv#*=}"
      jq --arg k "$key" --argjson v "$val" '.[$k]=$v' \
        "$DIR/.claude/state/current.json" > /tmp/_s && mv /tmp/_s "$DIR/.claude/state/current.json"
    done

# given.files 적용
jq -r '.given.files | to_entries[] | "\(.key)\t\(.value)"' "$SCENARIO" \
  | while IFS=$'\t' read -r path content; do
      mkdir -p "$DIR/$(dirname "$path")"
      printf '%s' "$content" > "$DIR/$path"
    done

# when 실행
eval "bash $ROOT/$(jq -r .when "$SCENARIO") $DIR" >/dev/null

# then 검증
jq -r '.then.state_preserves[]' "$SCENARIO" | while read -r field; do
  # before/after 비교 ...
done
```

### §6.3 옵션 C — Scenario-per-file

각 시나리오를 별도 `.sh` 파일로. 함수 헬퍼 없음. 보일러플레이트 복붙.

(코드 생략 — 기존 `tests/test-update.sh` 패턴이 이쪽에 가까움)

### §6.4 Trade-off 비교

| 기준 | A (함수 합성) | B (declarative) | C (file-per-scenario) |
|---|:---:|:---:|:---:|
| 구현 복잡도 | 중 | **상** (파서 구현) | 하 |
| 가독성 (테스트 작성자) | 상 | **상** (선언적) | 중 (반복 보일러) |
| 시나리오 추가 비용 | 함수 호출 1~3 줄 | JSON 파일 1개 | sh 파일 1개 (보일러 포함) |
| 시나리오 변형 (1 mixin 변경) | **변형 함수 1개 만들면 끝** | JSON 분기 추가 | 파일 복사 + 수정 |
| bash 3.2 호환 | ✅ | ✅ (단 jq 의존도 ↑) | ✅ |
| 기존 `make_fixture` 와 통합 | **자연스러움** | 별도 파서 레이어 | 통합 의미 없음 |
| 디버깅 용이성 (실패 추적) | 함수 호출 스택 → 직관 | 파서 → 추가 추상화 한 단 | 직관 |
| 메타-검증 (스키마) | 없음 | **JSON Schema 가능** | 없음 |
| 5개 시나리오 규모 | **적합** | over-engineering | 적합 |
| 50개 시나리오 규모 | OK | **이상적** | 나쁨 (중복 폭발) |

### §6.5 권고: **옵션 A — 함수 합성 (1차) + 시나리오를 함수로 묶기**

**이유**:
1. **현재 규모 (5~10 시나리오)** 에 옵션 B 의 파서 구현 비용은 정당화 안 됨. YAGNI.
2. 본 프로젝트의 기존 fixture 패턴 (`tests/test-sdd-base-branch.sh:20`) 과 자연스럽게 통합. 일관성 ↑.
3. bash 3.2 호환 부담 최소.
4. 디버깅 시 호출 스택이 함수명으로 표현되어 추적 쉬움.
5. 시나리오 50개 이상으로 확장 필요 시점에 옵션 B 로 마이그레이션해도 늦지 않음 (mixin 함수가 그대로 파서의 building block 됨).

**단계적 적용**:
- spec-15-02 에서 `tests/lib/fixture.sh` 생성 + 5개 mixin 구현
- spec-15-03 에서 5개 시나리오를 mixin 조합으로 회귀 테스트 작성
- 시나리오 카운트가 임계점 (>20) 을 넘으면 옵션 B 로 리팩토링 spec 신설 검토

## §7. 후속 Spec 명세 + Go/No-Go

### §7.1 Go/No-Go 결정

**결정: GO** — phase-15 그대로 진행.

**근거**:
- 4건 버그가 명확한 3개 패턴 (Schema Drift / User Content Blindness / Insufficient Idempotency) 으로 압축됨 → fixture 시나리오 ↔ 패턴 1:1 매핑 가능 → 회귀 테스트 설계 명료.
- §5 정책 단면 분석으로 P0 잠재 버그 1건 (uninstall.sh KIT_COMMANDS stale) + P1/P2 다수 식별 → 본 phase 의 spec 분할 정당화됨.
- §6 fixture 옵션 A 가 기존 패턴과 자연스럽게 결합 → 구현 spec (15-02) 의 위험 낮음.
- 추가 research 필요 없음 — 본 audit 으로 phase 의 윤곽 + 우선순위 명확.

**phase-15.md 갱신 사항** (별 commit):
- 성공 기준 #4 ("audit 발견 잠재 버그 모두 spec 등록") 의 *발견* 결과를 §7.4 로 구체화.
- 위험 섹션에 §5.3.1 (uninstall KIT_COMMANDS) P0 명시.
- **Base Branch 모드 전환**: 각 spec → main 직접 머지 정책을 `phase-15-upgrade-safety` base branch 로 변경. 회고(`/hk-phase-review`) + 통합 테스트(`/hk-phase-ship`) 를 phase 단위로 모음.

### §7.2 spec-15-02 명세 초안: stateful-fixture-system

| 항목 | 값 |
|---|---|
| **타입** | Implementation |
| **DoD** | `tests/lib/fixture.sh` 신규 + 5개 mixin 함수 + 셀프 단위 테스트 |
| **요점** | §6.1 의 함수 합성 패턴을 실제 코드로 구현 |

**산출물**:
- `tests/lib/fixture.sh` (신규)
  - `make_fixture()` (기존 패턴 재사용 + install + git init)
  - 5개 mixin: `with_in_flight_phase`, `with_pre_defined_phases`, `with_customized_fragment`, `with_dirty_queue_icebox`, `with_user_hook`
- `tests/test-fixture-lib.sh` (신규) — mixin 자체의 단위 테스트 (state 변형이 의도대로 일어나는지)

**검증**: 각 mixin 호출 후 fixture 의 state/파일 상태가 명세대로 변형되었는지 jq + grep + diff 로 확인.

### §7.3 spec-15-03 명세 초안: historical-regression-tests

| 항목 | 값 |
|---|---|
| **타입** | Tests |
| **DoD** | 4건 버그 + 5개 통합 시나리오 회귀 테스트 |
| **요점** | spec-15-02 의 fixture 위에서 phase-15.md §통합 테스트 시나리오 5개를 회귀 테스트로 |

**산출물**:
- `tests/test-update-stateful.sh` (신규) — 5개 시나리오 (`fixture.sh` mixin 조합):
  1. in-flight phase 보유 → 6 필드 보존
  2. 사전 정의 phase 보유 → 본문 미변경 + activate 정상
  3. 커스터마이즈된 fragment → 사용자 추가분 보존 또는 명시적 conflict
  4. dirty queue → Icebox / 대기 Phase 보존
  5. 신규 산출물 도입 → 누락 없음 + 사용자 수정분 보존

**참고**: 현재 `tests/test-update.sh` 는 시나리오 1 의 부분만 검증. spec-15-03 은 그것을 fixture lib 로 재작성 + 4 시나리오 추가.

### §7.4 spec-15-04+ — Audit 발견 잠재 버그 (P0/P1/P2 분류)

#### P0 — 즉시 픽스 (본 phase 흡수)

| Spec ID 후보 | 이슈 | 위치 | 1줄 fix |
|---|---|---|---|
| **spec-15-04** `uninstall-cmd-list-stale` | uninstall.sh:92 KIT_COMMANDS 가 구 슬래시 커맨드 명단 — hk-* 잔재 위험 | `uninstall.sh:92` | `installed.json` 에 install 시점 hk-* 목록 기록 → uninstall 이 그 목록 사용 |

#### P1 — 본 phase 흡수 또는 후속 phase

| Spec ID 후보 | 이슈 | 위치 | 비고 |
|---|---|---|---|
| **spec-15-05** `dedupe-hardcoded-lists` | install.sh:257-264 + update.sh:120 의 하드코딩 리스트 3개 (governance / templates / state fields) 를 단일 진실 원천으로 통합 | install.sh, update.sh | manifest 파일 (예: `sources/install.manifest`) 또는 헬퍼 함수로 통합. 회귀 테스트 추가. |
| **spec-15-06** `user-hook-preserve` | install.sh:347-348 hooks = kit-overwrite 정책 → 사용자 추가 hook 손실 (Pattern B) | install.sh, settings 머지 | 사용자 hook 영역 분리 (예: `userHooks` 키) 또는 명시 marker 기반 머지. UX 영향 확인 후 결정. |

#### P2 — 후속 phase 또는 Icebox

| Spec ID 후보 | 이슈 | 위치 | 비고 |
|---|---|---|---|
| **spec-15-07** `harness-config-overwrite` | install.sh:461-474 harness.config.json 항상 OVERWRITE | install.sh | 키트 메타라 영향 적음. 사용자 수정분이 있는 경우 jq merge 로 변경 검토. |
| **TBD** `inplace-upgrade-rewrite` | update.sh 의 uninstall+install 모델 자체가 OVERWRITE-then-restore 부담의 원천 | update.sh, install.sh | 별도 Phase 후보 (in-place upgrade 리팩토링). 본 audit 의 거대 가설. 확정 전 별 research spec 필요. |
| **TBD** `report-md-spec-md-cleanup` | constitution §9.2 "report.md replaces spec.md" 가 미운영 규약 (템플릿 부재 + 도구 미지원) | `.harness-kit/agent/constitution.md`, templates | 거버넌스 흠집. spec.md 로 통일 명문화 또는 report.md 템플릿 신설. 본 audit 작성 중 발견. |

### §7.5 권고 액션

1. 본 audit (spec-15-01) 머지.
2. **즉시 spec-15-02 진입** (fixture 시스템) — phase-15 의 골격.
3. spec-15-03 (회귀 테스트) — 02 머지 후.
4. spec-15-04 (P0 — uninstall stale) — 본 phase 안에서. 02/03 와 병렬 가능 (의존성 없음).
5. spec-15-05 / 15-06 (P1) — 본 phase 안에서 시간 여유 있을 때 / 또는 후속 phase-16 으로 분배.
6. P2 항목들은 phase-15 Done 시점에 Icebox 또는 phase-16 으로 분류.

---

## ✅ Definition of Done (체크리스트)

- [ ] §4 과거 버그 분석 작성
- [ ] §5 install/update 정책 단면 작성
- [ ] §6 fixture 옵션 ≥ 2개 비교 + 권고
- [ ] §7 후속 spec 명세 + Go/No-Go
- [ ] phase-15.md 갱신 (필요 시)
- [ ] walkthrough.md / pr_description.md 작성
- [ ] PR 생성
