---
kind: synthesis
sources:
  - docs/decisions/ADR-001-knowledge-types.md
  - docs/decisions/ADR-002-planning-economy.md
  - docs/decisions/ADR-003-wiki-frontmatter-schema.md
  - docs/rca/RCA-001-sdd-ship-spec-add-missing.md
  - specs/spec-19-01-wiki-layer-bootstrap/walkthrough.md
  - archive/specs/spec-08-02-phase-base-branch/walkthrough.md
  - archive/specs/spec-13-02-pr-merge-detect/walkthrough.md
  - archive/specs/spec-15-05-dedupe-hardcoded-lists/walkthrough.md
  - archive/specs/spec-x-sdd-version-source-fix/walkthrough.md
  - archive/specs/spec-x-update-preserve-state/walkthrough.md
linked:
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
  - "[[ADR-002]]"
  - "[[ADR-003]]"
  - "[[RCA-001]]"
updated: 2026-05-28
---

# 핵심 결정 증류

> raw ADR/RCA에서 추출한 의사결정 요약. 세부 근거는 원본 참조.

---

## [[ADR-001]] — Knowledge Type Vocabulary (2026-05-16)

**결정**: ADR/RCA frontmatter의 `type:` 슬롯에 5어휘 closure 도입.

| type | 의미 |
|---|---|
| `decision` | 비자명한 설계 선택 |
| `invariant` | 시스템이 보존해야 할 속성 |
| `failure-pattern` | 재발하는 실패 (재현+예방) |
| `convention` | 일관성을 위한 명명/구조 규칙 |
| `tradeoff` | 기각된 안에 명시적 비용이 있는 선택 |

**왜**: 결정과 실패가 grep 가능한 자산으로 누적되지 않던 문제. `grep -rh "^type:" docs/rca docs/decisions`로 type별 추출 가능.

**주의**: closure 변경 자체가 ADR 대상. vocabulary 밖 값은 거버넌스 위반.

---

## [[ADR-002]] — Planning Economy & Inter-Spec Re-Validation (2026-05-17)

**결정**: SDD ceremony 비용을 인식하고 3개 invariant 박음.

**Invariant 1 — ceremony 비용 의식**:
- 1-2 task + 단일 파일 + 가역적 → **FF** (사용자 명시 승인 필요)
- 3-5 task + 단일 영역 → **spec-x** 또는 **bundle/phase FF**
- 6+ task / cross-file / 통합 테스트 → **spec**

**Invariant 2 — phase plan은 draft, 매 spec 시작 시 재검증**:
직전 merged spec의 walkthrough(이월/발견) + `git diff --stat` 점검 후 잔여 spec 재평가.

**Invariant 3 — phase 내에서는 bundle/phase FF 우선 (spec-x demote 보다)**:
spec-x demote는 phase가 끝난 후 잔재일 때만.

**왜**: phase-17에서 spec-17-03이 install.sh 누수를 미발견 → spec-17-05 sweep으로 뒤늦게 처리. pre-spec 재검증으로 사전 차단 가능했음.

---

## [[RCA-001]] — sdd ship이 spec/plan/task를 git add 안 함 (2026-05-15)

**증상**: `sdd ship` 후 spec.md/plan.md/task.md가 untracked으로 남아 수동 add 필요. 2회 연속 발생.

**근인**: sdd ship의 git add 매트릭스가 walkthrough/pr_description만 포함. spec-x 운영에서 pre-flight commit이 없는 것이 일반적이라는 전제 누락.

**교훈**: "암묵적 전제"가 가장 위험한 버그 경로. sdd ship의 add 매트릭스는 spec 디렉토리 전체를 포함해야 함.

**Invariant**: `sdd ship` 후 해당 spec 디렉토리 내 신규 산출물 untracked이 남으면 안 됨.

---

## [[ADR-003]] — Wiki Frontmatter `kind:` vs ADR `type:` 네임스페이스 분리 (2026-05-27)

**결정**: wiki 페이지는 `kind:` 슬롯, ADR/RCA는 `type:` 슬롯을 사용한다. 두 네임스페이스는 공존하되 겹치지 않는다.

| 슬롯 | 사용 파일 | 허용 값 |
|---|---|---|
| `type:` | ADR/RCA (`docs/decisions/`, `docs/rca/`) | 5어휘 closure (ADR-001) |
| `kind:` | wiki 페이지 (`docs/wiki/`) | `catalog`, `synthesis`, `reference` |

**왜**: ADR-001의 `type:` 5어휘 closure는 ADR/RCA 전용. wiki 페이지에 `type: decision`을 붙이면 `grep -rh "^type:"` 쿼리가 오염되어 wiki 파일이 ADR/RCA로 오인됨.

**주의**: `type:`과 `kind:` 값 모두 closure 밖 값은 거버넌스 위반. vocabulary 변경은 ADR 대상.

출처: spec-19-01 walkthrough §결정 기록, [[ADR-003-wiki-frontmatter-schema]]

---

## [[spec-15-05]] — state.json 보존은 exclusion(blacklist), inclusion 아님 (2026)

**결정**: `update.sh` 가 install 후 state.json 을 복원할 때, 보존할 키를 whitelist(inclusion) 하지 않고 install-managed 키(`kitVersion`, `installedAt`)만 `del` 로 제외(exclusion)한다.

**왜**: inclusion 은 새 state 필드가 생길 때마다 update.sh 동기화를 강제 — 실제로 누락이 발생했었음(#82). exclusion 은 install template 이 바뀔 때만 영향받고, 사용자가 직접 추가한 필드까지 자동 보존된다.

**Trade-off**: 사용자가 stale 키를 남길 위험은 있으나, 본 프로젝트 컨벤션상 사용자가 state.json 을 직접 편집하지 않으므로 수용. install 자산은 항상 OVERWRITE → state 만 사후 복원하는 모델의 부담을 줄이는 방향.

출처: spec-15-05 walkthrough §결정 기록, spec-x-update-preserve-state walkthrough §발견 사항

---

## [[spec-x-sdd-version-source-fix]] — kitVersion SSOT 는 installed.json(git-tracked) (2026)

**결정**: `sdd version` / `sdd status` 가 읽는 kitVersion 소스를 gitignored `current.json` 에서 git-tracked `installed.json` 으로 변경한다.

**왜**: `current.json` 은 gitignore 대상이라 `update.sh` 를 우회하거나 멀티 디바이스 환경에서 쉽게 stale 해진다. `installed.json` 이 install 이 항상 새로 쓰는 SSOT. 실제로 본 저장소에서 `installed.json`=0.6.0 인데 `current.json.kitVersion`=0.5.0 으로 어긋난 사례가 발생.

**교훈**: 버전/메타 같은 install-managed 값의 SSOT 는 *git-tracked + install 이 항상 갱신하는* 파일이어야 한다. gitignored 파일을 SSOT 로 두면 "사용자가 update 를 안 돌린" 운영 누락이 곧 데이터 불일치로 드러난다.

출처: spec-x-sdd-version-source-fix walkthrough §결정 기록, spec-x-update-preserve-state walkthrough §발견 사항 1

---

## [[spec-13-02]] — 선택 도구 미설치는 차단(exit 1) 아닌 graceful degradation(exit 0 + 안내) (2026)

**결정**: `gh` 같은 선택 도구가 없을 때 워크플로 전체를 차단(exit 1)하지 않고 exit 0 + 안내를 출력한다. doctor 의 `gh` 체크도 FAIL 이 아닌 WARN. PR merge 감지는 자동 ship 이 아닌 안내만.

**왜**: 차단은 온보딩 마찰을 키우고, 부작용(자동 실행)은 사용자 확인 없는 위험을 만든다. 필수가 아닌 도구는 *없어도 핵심 경로가 살아있게* 하는 것이 reliability layer 의 일관 원칙.

**적용 범위**: 폴링은 데몬이 아닌 포그라운드 루프(종료 보장), merge 후 동작은 안내만, bash 절대경로 사용 + 필수 도구 PATH 유지.

출처: spec-13-02 walkthrough §결정 기록

---

## [[spec-08-02]] — 테스트 fixture 의 lib 심링크는 `bin/lib/` 에 (2026)

**결정**: `sdd` fixture 테스트 시 lib 심링크를 `scripts/harness/lib/` 가 아닌 `scripts/harness/bin/lib/` 에 만들고, 이를 `make_fixture()` 헬퍼로 표준화한다.

**왜**: `sdd` 는 `${BASH_SOURCE[0]}` 기준으로 `lib/` 을 탐색하므로 바이너리 *옆* 의 lib 만 인식한다. fixture 가 "사용 중인 사용자" 를 모사하려면 install 산출물(state.json 은 install 생성, queue.md 는 sdd 첫 호출 시 생성)을 그대로 갖춰야 한다.

**교훈**: fixture 는 "install 직후 빈 상태" 가 아니라 "sdd 를 한 번 쓴 흔적까지 포함한 상태" 가 자연스럽다. `.harness-kit/installed.json` + `.claude/state/current.json` 두 파일이 모든 sdd 스모크 테스트의 최소 셋업.

출처: spec-08-02 / spec-14-01 / spec-15-02 walkthrough §발견 사항
