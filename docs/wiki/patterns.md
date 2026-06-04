---
kind: synthesis
sources:
  - archive/specs/spec-x-planning-economy/walkthrough.md
  - archive/specs/spec-17-04-governance-test-coherence/walkthrough.md
  - docs/decisions/ADR-002-planning-economy.md
  - docs/rca/RCA-001-sdd-ship-spec-add-missing.md
  - specs/spec-19-01-wiki-layer-bootstrap/walkthrough.md
  - specs/spec-19-03-doctor-wiki-slim/walkthrough.md
  - archive/specs/spec-14-03-gitignore-idempotent/walkthrough.md
  - archive/specs/spec-14-04-marker-append-guard/walkthrough.md
  - archive/specs/spec-15-01-upgrade-danger-audit/walkthrough.md
  - archive/specs/spec-17-01-sdd-marker-bugs-fix/walkthrough.md
  - archive/specs/spec-x-archive-clean-commit/walkthrough.md
  - archive/specs/spec-x-hk-update-remote/walkthrough.md
  - archive/specs/spec-x-precommit-chmod-fix/walkthrough.md
  - archive/specs/spec-x-check-secrets-dual-mode/walkthrough.md
  - archive/specs/spec-x-claude-md-nested/walkthrough.md
  - archive/specs/spec-x-claude-md-slim/walkthrough.md
  - archive/specs/spec-x-sdd-search/walkthrough.md
  - archive/specs/spec-x-harness-footguns/walkthrough.md
linked:
  - "[[wiki/decisions]]"
  - "[[ADR-002]]"
  - "[[RCA-001]]"
updated: 2026-06-03
---

# 반복 패턴 증류

> phase-08~18에서 반복 확인된 good pattern과 anti-pattern.
> 각 패턴에 최초 확인 출처 태그.

---

## ✅ Good Patterns

### bundle-before-spec-x
여러 작은 Icebox 항목이 같은 테마로 쌓이면 spec-x 여러 개 대신 하나로 묶어서 처리한다.

- **왜**: phase 응집도 유지 + ceremony 비용 절감
- **출처**: spec-17-04 "잡탕 cleanup", [[ADR-002]] Invariant 3
- **적용**: 3개 이상 소규모 항목이 같은 영역에 있을 때

---

### phase-FF (Phase Fast Flow)
phase 내에서 1-2 commit 규모 변경은 spec 아티팩트 없이 phase 브랜치에 직접 커밋한다.

- **왜**: ceremony(6,000-8,000 토큰)가 작업보다 클 때 ROI 음수
- **출처**: [[ADR-002]] Invariant 1, phase-17 내 소규모 수정들
- **적용**: 단일 파일, 가역적, 명백한 fix일 때 (사용자 명시 승인 필요)

---

### hook-gradual-escalation
새 hook은 반드시 경고 모드(exit 0 + stderr)로 시작하고, 1주 운영 후 차단 모드(exit 2)로 승격한다.

- **왜**: 즉시 차단하면 false positive로 워크플로 막힘. 관찰 기간이 안전망.
- **출처**: CLAUDE.md "Hook 단계론", phase-09, phase-16
- **적용**: 모든 신규 pre-commit / pre-push hook

---

### TDD-red-green-commit
테스트 작성(Red) → 구현(Green) → 커밋 순서를 지킨다. Red 커밋과 Green 커밋을 분리한다.

- **왜**: Red 커밋이 "무엇을 검증하려 했는가"를 코드 히스토리에 남김. 회귀 방지 기준점.
- **출처**: agent.md §6.1 Strict Loop Rule, 모든 phase 공통
- **적용**: 모든 testable behavior

---

### human-curates-llm-maintains
wiki synthesis 페이지는 LLM이 초안을 작성하지만, 포함 여부와 표현은 사람이 최종 결정한다.

- **왜**: LLM은 hallucinate 가능. wiki가 잘못된 결정을 사실인 양 기록하면 누적 오염.
- **출처**: Karpathy LLM Wiki 패턴, spec-19-01 설계
- **적용**: `/hk-wiki-ingest` 실행 시 항상 사용자 검토 후 커밋

---

### dogfooding-as-regression-detector
키트 변경을 본 저장소 자체에 install/update 로 적용(도그푸딩)하면, 다른 사용자 환경에서 일어날 회귀가 본 저장소에서 *자동으로 시연*된다.

- **왜**: 잠재 버그는 "잔재 덕에 우연히 동작"하다가 정상 install 이 잔재를 덮어쓰는 순간 표면화. 도그푸딩이 그 순간을 미리 당겨줌. phase-14 의 phase.md 수동 보정 반복이 곧 marker append 버그의 회귀 케이스 그 자체였음.
- **출처**: spec-14-04 / spec-17-03 / spec-x-install-phase-ship-template walkthrough §발견 사항
- **적용**: sources/ 수정 후 `update.sh --yes` 로 미러 적용. install 결과를 *fixture 디렉토리*에서 검증하는 테스트는 본 저장소 잔재 영향을 받지 않아 잠재 버그 탐지에 특히 효과적.

---

### install-directory-glob
install/uninstall 대상은 하드코딩 명단이 아니라 *디렉토리 통째 glob*(`sources/<area>/*.md`)으로 처리한다.

- **왜**: 명단은 새 파일 추가 시마다 동기화가 필요해 drift 위험(uninstall 의 stale KIT_COMMANDS 사고). glob 은 새 template/command 가 코드 변경 0줄로 자동 install. install.sh 의 5 영역(governance/templates/commands/hooks/bin)이 모두 glob 또는 `cp -rf` 로 수렴.
- **출처**: spec-15-05 / spec-16-01 walkthrough §발견 사항
- **적용**: install 매트릭스가 "schema drift 도구" 가 아닌 "확장 친화 매트릭스" 가 되도록. 단, 명단 기록이 필요한 경우(uninstall 의 사용자 환경 정확 제거)는 `installed.json.installedCommands` 같은 *기록형* 으로 보완.

---

### grep-fixed-string-verification
검증용 grep 은 가능하면 `-F`(고정 문자열)를 쓴다. URL·경로·메타문자가 섞인 패턴은 정규식 해석으로 silent 매치 실패한다.

- **왜**: `<owner>`, `)`, `[` 같은 메타문자가 든 라인을 `grep -E` 로 찾으면 예상과 다르게 동작해 "라인은 존재하나 매치 실패" 가 발생. `grep -qF` 는 정규식 해석을 끄고 약간 더 빠르다.
- **출처**: spec-x-hk-update-remote / spec-14-05 walkthrough §발견 사항
- **적용**: task.md 의 검증 명령, 테스트의 존재 확인 grep. ERE 가 꼭 필요한 경우가 아니면 `-qF` 가 기본.

---

### dual-binary-dogfood-sync
도그푸딩 중에는 `sources/bin/sdd`(키트 원본)와 `.harness-kit/bin/sdd`(install 미러)를 *둘 다* 갱신해야 즉시 효과가 난다.

- **왜**: install 은 sources → .harness-kit 로 복사하지만, 본 저장소는 그 install 결과로 직접 작업하므로 미러가 stale 하면 변경이 반영 안 됨. `test-hook-modes.sh` 가 sources↔미러 정합성을 검사. `.harness-kit/` 이 gitignore 라도 tracked 파일은 `git add -f` 로 스테이징.
- **출처**: spec-13-01 / spec-14-02 / spec-x-output-ux walkthrough §발견 사항
- **적용**: sdd / hook / install asset 수정 시 구현 commit 과 미러 sync commit 을 논리적 단위로 분리(Task N=구현, Task N+1=동기화). 단순 cp 만으로는 부족 — `git add -f` 필수.

---

### test-self-trigger-secret-split
시크릿 가드(check-secrets)가 있는 저장소에서는 테스트·문서의 mock 시크릿을 리터럴로 쓰지 않고 prefix 를 변수로 쪼갠다.

- **왜**: AWS 액세스 키 prefix 나 PEM private-key 헤더 같은 리터럴을 그대로 두면 그 파일 staged 시 가드가 self-trigger 해 자기 테스트를 차단한다 (이 항목 본문도 같은 이유로 리터럴을 피해 서술함).
- **출처**: spec-x-check-secrets-dual-mode / spec-x-harness-footguns walkthrough §발견 사항
- **적용**: `_AKIA_PFX="AKIA"; echo "${_AKIA_PFX}EXAMPLE..."` 처럼 분리. 시크릿 가드가 있는 모든 저장소의 테스트 컨벤션.

---

### nested-claude-md-scoped
하위 디렉토리 CLAUDE.md 는 root 와 중복 없이 디렉토리 특화 내용만, ~25줄 상한으로 둔다.

- **왜**: "해당 디렉토리 파일 편집 시 nested CLAUDE.md 가 자동 로드된다"는 Claude Code 동작을 활용하되, root 중복은 컨텍스트 낭비. 작동 가정이 깨지면 root 에 명시 reference 로 보완.
- **출처**: spec-x-claude-md-nested walkthrough §결정 기록·발견 사항
- **적용**: sources/, specs/ 등 영역별 가이드. root 는 포인터, nested 는 영역 특화.

---

### grep-wrapper-over-index
과거 작업 검색은 사전 색인(sqlite/index 파일)이 아닌 ad-hoc `find -exec grep` 으로 한다.

- **왜**: 108 spec + ADR + RCA 통합 grep 이 0.2~0.5초로 색인 운영(갱신·stale 관리) 부담을 정당화하지 못한다. bash 3.2 호환 위해 `**` globstar 대신 `find`.
- **출처**: spec-x-sdd-search walkthrough §결정 기록·발견 사항
- **적용**: `sdd search`. 1000+ spec 규모에서나 색인 재검토.

---

### bash-data-table-over-nested-closure
동일 패턴 반복 dispatch 는 nested 함수 closure 가 아닌 데이터 표 + for loop 로 짠다.

- **왜**: bash 의 dynamic scoping 때문에 nested closure 는 의존 변수가 드러나지 않고, 호출자 변수와 우연히 충돌하면 조용히 깨진다. `pairs="active|specs ..."` 데이터 표 + for loop 가 의존성을 명시해 더 robust.
- **출처**: spec-x-sdd-search walkthrough §결정 기록·발견 사항
- **적용**: 그룹별 검색 dispatch 등 "같은 동작 × N 입력" 구조.

---

### mediated-design-dialogue
front↔back 도메인 에이전트 설계 협상에 디렉터가 개입하여 아키텍처 일관성과 종료를 보장한다.

- **구조**: front 에이전트 + back 에이전트가 API 계약을 제안/반론. 디렉터가 중재자로 입장 — 결정은 디렉터가 내리고, 에이전트는 구현 옵션만 제시.
- **종료조건**: ① 양측이 동일 계약(스키마·에러코드·인증 방식)에 서명 또는 ② 디렉터가 핑퐁 2회 이상 감지 시 강제 수렴. 무한 핑퐁 방지를 위해 **최대 교환 횟수**(예: 3라운드)를 브리핑에 명시.
- **증류**: 디렉터는 수렴된 계약(최종 스키마·결정 이유)만 흡수 — 교환 과정의 날것 트랜스크립트는 폐기. 이것이 컨텍스트를 보호하는 핵심.
- **왜**: 단일 에이전트가 front·back 양쪽을 동시에 모델링하면 컨텍스트가 폭발. 역할을 분리하되 디렉터가 수렴을 강제하면 폭 × 깊이 동시 확보.
- **출처**: spec-20-04 설계 협의 / agent.md §6.6(director 역할), §6.7(review orchestration)
- **적용**: front↔back API 계약 협상, 마이크로서비스 인터페이스 설계, 다자 에이전트 아키텍처 토론

---

## ❌ Anti-Patterns

### ceremony-over-work
1-2 commit 규모 작업에 full SDD ceremony(spec/plan/task/PR)를 적용한다.

- **왜 위험**: 6,000-8,000 토큰 + 사용자 검토 시간이 실제 변경보다 큼. ROI 음수.
- **출처**: [[ADR-002]] 직접 동기, phase-17 회고
- **대안**: FF(사용자 승인) 또는 spec-x로 demote

---

### silent-inter-spec-drift
다음 spec 시작 전 직전 spec의 실제 변경 영향을 검토하지 않고 원래 phase plan대로 진행한다.

- **왜 위험**: phase plan은 작성 시점의 예상일 뿐. 직전 spec이 이후 spec의 가정을 무너뜨릴 수 있음.
- **출처**: [[ADR-002]] Invariant 2, phase-17에서 spec-17-03→17-05 sweep
- **대안**: 매 spec 시작 시 `sdd spec new` pre-flight 출력 + walkthrough carry-over 점검

---

### bash-pipeline-sigpipe-trap
`set -euo pipefail` 환경에서 `cmd 2>&1 | grep -q "..."` 패턴은 오탐을 유발한다.

- **왜 위험**: `grep -q`는 첫 매치 후 파이프를 닫음 → cmd가 SIGPIPE로 종료 → `pipefail`이 비정상 종료로 처리. 특히 sdd같이 출력이 긴 명령에서 나타남.
- **출처**: spec-19-03 walkthrough §결정 기록 (Check 1 테스트 오탐)
- **대안**: `output=$(cmd 2>&1 || true); echo "$output" | grep -q "..."` 패턴으로 출력 먼저 캡처

---

### frontmatter-range-grep
YAML frontmatter 필드를 검증할 때 `grep "^field:"` 대신 frontmatter 범위로 한정한다.

- **왜 위험**: 문서 본문에 동일 패턴 예시가 있으면 false positive. 특히 스키마·컨벤션을 설명하는 파일(purpose.md 등)에서 발생.
- **출처**: spec-19-01 walkthrough §발견 사항 (purpose.md kind: 파싱 오탐)
- **대안**: `awk 'NR==1 && /---/{in_fm=1} in_fm && /^---/{exit} /^kind:/{print}' file.md`

---

### doc-accumulation-without-wiki
산출물(spec, walkthrough, ADR, RCA)만 계속 쌓고 증류 레이어(wiki)가 없어 지식이 누적되지 않는다.

- **왜 위험**: 세션마다 raw 재탐색. 111개 파일에서 결정 맥락을 찾으려면 대용량 컨텍스트 필요.
- **출처**: phase-19 배경 (이 spec의 존재 이유)
- **대안**: `/hk-wiki-ingest`로 archive할 때마다 wiki 갱신

---

### sdd-marker-append-not-idempotent
`sdd spec new` / `sdd ship` / `sdd phase done` 의 marker 헬퍼가 기존 행을 *업데이트*하지 않고 무조건 *append* 하여 phase.md 의 spec 표가 중복된다.

- **왜 위험**: phase-10~17 거의 모든 spec 시작/ship 마다 phase.md 수동 dedupe 가 필요했던 *예측 가능한 반복 비용*. 중복 행은 NEXT spec 오인까지 유발. 단발 fix 로 안 잡고 방치하면 매번 재발.
- **출처**: spec-10-05 / spec-14-04 / spec-16-02 / spec-16-03 / spec-17-01 walkthrough §발견 사항, [[RCA-001]] 와 같은 "암묵 전제" 계열
- **대안**: 함수 레벨 멱등 가드 — `sdd_marker_append` 가 한 패스 awk(`in_section` 플래그)로 기존 행 존재 시 skip. 호출자 4곳 + 미래 호출자 자동 보호. "있으면 update, 없으면 append" 의도를 `sdd_marker_update_row` 로 코드에 직접 드러냄.

---

### install-overwrite-then-restore
install.sh 가 자산을 항상 OVERWRITE 하고, 사용자 자산(state/hook/fragment)은 update.sh 가 *사후 복원*하는 모델.

- **왜 위험**: 각 OVERWRITE 마다 보호 로직이 따로 필요 → 위험 면적이 누적. 실제로 phase-15 audit 의 다수 버그가 모두 이 패턴에서 비롯. update.sh 를 한 번도 안 돌리면 미러가 *조용히* 어긋남(정기 sync 시점 부재).
- **출처**: spec-15-01 audit "update.sh = uninstall + install 모델의 부담", spec-15-05 / spec-15-06 walkthrough
- **대안**: 보존 정책은 exclusion(blacklist) 으로([[spec-15-05]]) 새 필드 자동 보존. 근본적으로는 in-place upgrade 로 리팩토링하면 위험 면적이 한 자릿수로 축소(거대 변경 — 별도 research spec 필요). install 시점 *초기값 작성*도 누수 경로임에 주의(spec-17-03 가 read/write 만 보고 install 초기값을 놓침).

---

### defensive-git-add-A
"정리 차원에서 일단 `git add -A` 해두자" 식 방어적 코드가 무관한 변경(modified settings.json, untracked 파일)을 의도치 않게 흡수한다.

- **왜 위험**: `git mv` 는 이미 rename 을 stage 하므로 추가 `git add -A` 는 redundant 일 뿐 아니라, 작업 중인 다른 변경을 commit 에 끌어들이는 실사고(`c0010e0`)를 냈음.
- **출처**: spec-x-archive-clean-commit walkthrough §결정 기록
- **대안**: 필요한 path 만 명시 stage. 회귀 테스트는 워킹트리 상태가 아닌 *commit 의 `--name-only` 출력*을 직접 검증해야 사고를 완전히 잡음. 다른 sdd 명령(ship, phase done, specx done)에도 같은 패턴이 있는지 점검.

---

### regex-grep-c-over-awk-exact
fixture/검증에서 sed·ERE 정규식 + `grep -c` 로 줄 수를 세거나 정확 매치를 시도하다 메타문자 escape 누락·이중 출력 함정에 빠진다.

- **왜 위험**: `grep -cE ... || echo 0` 는 매치 0 일 때 grep 의 "0" + echo 의 "0" 이 합쳐져 `set -e` 환경에서 "00" 이 됨(`|| true` 로 회피). `[`,`]`,`(`,`)` escape 가 빠진 sed 패턴은 매치 실패 또는 문법 오류. 모두 *조용한* 오판.
- **출처**: spec-14-03 / spec-14-04 walkthrough §발견 사항 (count_line 함수)
- **대안**: 정확 매치는 awk `$0 == target` 가 정규식보다 견고. 부재 사전 체크는 `grep -qF`(고정 문자열).

---

### install-resets-state
spec 작업 중 대상 프로젝트에 `install.sh .` 를 재실행하면 `.claude/state/current.json`(phase/spec/planAccepted)이 초기화된다.

- **왜 위험**: spec 진행 도중 install 재실행은 비정상 흐름이지만 도그푸딩 중 chmod-fix 등으로 종종 발생. state 가 날아가면 수동 복구(python3/jq)가 필요하고, 복구 누락 시 hook 차단·NEXT 오인.
- **출처**: spec-x-precommit-chmod-fix / spec-x-kit-update-check / spec-x-update-preserve-state walkthrough §발견 사항
- **대안**: state 변경이 필요한 작업은 install 이 아닌 미러 cp + `git add -f` 로 처리. 근본적으로는 update.sh 의 state save/restore 경로를 통해서만 install 을 거치게 함([[spec-15-05]] exclusion 보존).

---

### always-on-context-stale-state
CLAUDE.md 처럼 매 세션 자동 로드되는 컨텍스트에 "현재 단계/Phase" 같이 빠르게 stale 해지는 상태 정보를 둔다.

- **왜 위험**: 매번 수동 갱신을 강제하고, 갱신을 빠뜨리면 자동 로드 컨텍스트가 거짓을 사실인 양 주입한다. 항상-온 채널일수록 오염 비용이 크다.
- **출처**: spec-x-claude-md-slim walkthrough §결정 기록
- **대안**: 상태는 `sdd status` 를 단일 진실원으로 두고 always-on 컨텍스트에서 제거. root 는 포인터, 상세는 별도 문서(예: release-strategy.md)로 분리.
