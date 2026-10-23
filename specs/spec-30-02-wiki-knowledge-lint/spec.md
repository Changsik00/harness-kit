# spec-30-02: 지식 lint (사실 검증 + 의미 lint)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-30-02` |
| **Phase** | `phase-30` |
| **Branch** | `spec-30-02-wiki-knowledge-lint` |
| **Base 브랜치** | `phase-30-wiki-as-knowledge` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-10-23 |
| **소유자** | changsik |

## 배경 및 문제 정의

### 현재 상황
- `sdd doctor` 의 wiki layer 검사는 구조만 본다: 고아 wikilink, stale ADR/RCA, 신선도(`_wiki_freshness_report`: 미반영 ADR + 인제스트 이후 archive 누적).
- spec-30-01 이 3층 구조, `verify` 마커 문법(`<!-- verify: <키> -->` 를 표 바로 위 줄), 크기 상한(components 200 / direction 150 / threads 300줄), `covers:`/`sources:` frontmatter 를 정했다. 그러나 이를 검사하는 도구가 없다.
- 시범에서 LLM 이 사실을 두 번 틀렸다(commit-msg 오탐, phase-03~06 실행 기록). 사람 검토 없이는 잡히지 않았다.

### 문제점
- wiki 페이지가 코드와 어긋나도(예: hook 기본 모드 변경) 아무 경고가 없다. 거짓 wiki 는 에이전트에게 거짓 맥락을 준다 — phase-30 최대 위험.
- 신선도 신호 A("ADR-NNN 이 `decisions.md`/`patterns.md` 에 없음")는 30-01 이후 **구조적으로 오탐**이 된다. 인제스트가 두 로그를 더 이상 편집하지 않으므로, 새 ADR 이 생길 때마다 영구 경고가 뜬다.
- 모순·"대체됐는데 현재형인 주장"·장기 보류 같은 의미 수준 문제는 결정론으로 못 잡는다.

### 해결 방안
(a) 결정론적 **사실 검증** `_wiki_verify_report` 를 `sdd doctor` 에 추가 (경고, exit 0). 마커 키별 검증기를 case 로 등록하는 확장 가능한 구조로 하고, 이번에는 `hooks-defaults` 와 범용 `path-exists`(frontmatter 의 `sources:`/`covers:` 경로 존재) 두 가지를 구현한다. 크기 상한 초과도 같은 보고에 포함. (b) LLM 기반 **의미 lint** 커맨드 `/hk-wiki-lint` 신설. (c) 신선도 신호 A 를 새 구조에 맞게 교정하고 doctor 문구에서 "보조 신호"로 격하.

## 요구사항

1. **사실 검증 진입점**: `_wiki_verify_report` — 문제가 있을 때만 줄을 출력, 없거나 전제(`docs/wiki/` 없음, 마커·components 없음)가 없으면 침묵 (`_source_sync_report` 와 같은 침묵 규약). 다운스트림에서 wiki 가 없으면 침묵.
2. **마커 파서**: 페이지에서 `<!-- verify: <키> -->` 를 찾고 바로 아래 연속된 표(`|` 로 시작하는 줄)를 대상으로 한다. 마커 바로 아래가 표가 아니면 "마커 아래에 표 없음" 보고. 알 수 없는 키는 "알 수 없는 verify 키: X" 보고(오타 방지).
3. **`hooks-defaults` 검증기**: `sources/hooks/*.sh`(없으면 `.claude/scripts/harness/hooks/`, 다운스트림 대비)의 `hook_resolve_mode "NAME" "default"` 선언에서 파일명→기본값을 뽑아 표와 대조한다.
   - 표 행의 첫 칸(여러 hook 이 ` / ` 로 묶일 수 있음)에서 hook 파일명을 찾아, 그 행의 **기본 칸**에 선언 기본값(`block`/`warn`/`off`)이 단어로 들어 있는지 확인. 선언 기본값이 변수(`$...`)인 hook(`check-irreversible`)은 "모드별" 이므로 기본 칸에 `auto=`/`attended=` 중 하나가 있으면 통과.
   - 코드에는 선언이 있는데 표에 행이 없는 hook → "표에 없는 hook". 표에는 있는데 hook 파일이 없는 이름(선언 없는 hook 은 제외: pre-commit.sh, post-commit-verify 등 모드 선언이 없는 것은 대조 대상이 아님)은 무시하되, `check-*.sh` 이름인데 파일이 없으면 "코드에 없는 hook" 보고.
4. **`path-exists`**: 모든 wiki 페이지(`docs/wiki/**/*.md`, catalog 제외)의 frontmatter `sources:`/`covers:` 항목이 저장소에 존재하는지 확인(`covers:` 는 접두 디렉토리/파일). 없으면 "존재하지 않는 경로 N개: ..." 보고(상위 5개).
5. **크기 상한**: components 200 / direction 150 / threads 300줄 초과 페이지를 "크기 상한 초과: <페이지> N줄" 로 보고.
6. **doctor 연결**: wiki layer 섹션에 W-5 "wiki 사실 검증" 으로 추가(경고만). `sdd status` 진단에도 한 줄 노출(낡음 신호와 같은 방식).
7. **신선도 교정**: 신호 A 의 "ADR 이 wiki 에 있나" 검사 대상을 `decisions.md`·`patterns.md` 에서 **`docs/wiki/` 전체(index.md 제외)** 로 넓힌다. doctor 문구는 "wiki 낡음(보조 신호)" 로 바꾸고, 사실 검증 결과가 주 신호임을 schema.md Lint 절에 반영.
8. **`/hk-wiki-lint`** (`sources/commands/hk-wiki-lint.md`, 사본 `.claude/commands/`): LLM 의미 lint. 먼저 `sdd doctor` 의 사실 검증 결과를 확인한 뒤 페이지를 읽고 다음을 점검해 **보고서만 출력**(파일 수정 금지, 사용자 승인 후 별도 갱신): ① 같은 주제에 서로 모순되는 주장 ② 변경 이력에 "→ 현재" 로 대체됐는데 현재 설계에 이전 입장이 그대로 남은 곳 ③ `반복·미결`/`열린 질문` 항목이 N개월 이상 같은 상태(날짜 근거 필수) ④ 출처 없는 사실 주장 ⑤ 코드에서 기계 검증 가능한데 `verify` 마커가 없는 표. 각 지적에는 페이지·줄·근거를 붙이고, 확신 없는 항목은 `(추정)` 표시.
9. **hook 단계론**: 모든 검사는 경고(exit 0)로 시작. 차단 승격은 본 spec 범위 밖.

## Out of Scope

- `verify` 키 추가(sdd 서브커맨드 목록, 상태 파일 스키마 등) — spec-30-03 에서 컴포넌트 페이지를 쓰면서 필요한 키를 등록
- 의미 lint 의 자동 실행·자동 수정 (보고서 출력만)
- ADR `supersedes` 필드, `threads.md` 작성
- 경고의 차단 승격

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **신선도 신호 A 의 의미 변경** (요구사항 7): 30-01 로 인제스트가 로그를 편집하지 않게 되어 기존 정의가 영구 오탐이 된다. 교정 방향(wiki 전체에서 ADR 언급 검색)에 동의 여부.
> - [ ] **`hooks-defaults` 의 판정 방식**: 표의 자연어 칸에서 `block`/`warn` 단어를 찾는 휴리스틱이다. 표 서식이 크게 바뀌면 오탐 가능 → 경고로 시작하는 이유.

> [!WARNING]
> - [ ] 본 repo 에서 불일치 0건이어야 한다. 첫 실행에서 시범 `hooks.md` 표의 실제 불일치가 나오면 코드가 아니라 **문서를 먼저 고친다**(코드 기본값이 사실의 출처).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **검증기 구조** | `case "$key"` 레지스트리 + 키별 함수 `_wiki_verify_<key>` | 30-03 이 키를 추가할 때 기존 코드를 안 건드림 |
| **사실의 출처** | 코드(hook 선언)가 진실, wiki 가 틀린 것으로 보고 | CLAUDE.md "원본이 우선" 규약과 schema.md Query 절과 일치 |
| **침묵 규약** | 문제 있을 때만 출력 | `_source_sync_report` 와 동일, 신호 대 잡음 유지 |
| **의미 lint** | LLM 보고서 전용, 수정은 별도 승인 | 의미 판단은 오탐 가능 — 사람이 보고 결정 (hook 단계론) |
| **휴리스틱 한계 명시** | 표 파싱 실패는 "검증 불가" 로 별도 보고, 침묵하지 않음 | 조용한 통과가 가장 위험 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd` (+ 사본 `.harness-kit/bin/sdd`)
`_wiki_verify_report`(마커 파서, `hooks-defaults`, `path-exists`, 크기 상한), 신선도 신호 A 교정, doctor W-5, `_status_diagnose` 연결.

#### [NEW] `sources/commands/hk-wiki-lint.md` (+ 사본 `.claude/commands/hk-wiki-lint.md`)
의미 lint 절차 (요구사항 8).

#### [MODIFY] `docs/wiki/schema.md`
Lint 절: 사실 검증(주) / 신선도(보조) / 의미 lint 역할 분담.

#### [NEW] `tests/test-wiki-verify.sh`
fixture 기반 테스트 (검증 계획 참조).

#### [MODIFY] `tests/test-wiki-freshness.sh`
신호 A 의 새 정의(wiki 전체 검색)에 맞게 케이스 조정.

#### [MODIFY] `docs/wiki/components/hooks.md` (필요 시)
첫 실행에서 불일치가 나오면 표를 코드에 맞게 정정.

## 검증 계획

```bash
bash tests/test-wiki-verify.sh
bash tests/test-wiki-freshness.sh
bash tests/test-doctor-wiki.sh
bash tests/run.sh
```

`test-wiki-verify.sh` 케이스 (임시 repo fixture):
1. 일치 fixture → 침묵
2. hook 기본값을 바꾼 fixture (표는 그대로) → 불일치 보고 (성공 기준 2)
3. 코드에 hook 추가했는데 표에 없음 → "표에 없는 hook"
4. 마커 아래에 표 없음 → 보고
5. 알 수 없는 verify 키 → 보고
6. `sources:` 에 존재하지 않는 경로 → `path-exists` 보고
7. 페이지 크기 상한 초과 → 보고
8. wiki 없음/마커 없음 → 침묵 (다운스트림)
9. 본 저장소 실측 → 불일치 0건 (성공 기준 2)
10. 신선도 신호 A: 새 ADR 이 components 페이지에만 언급돼도 미반영으로 보지 않음

수동 검증 시나리오:
1. `.harness-kit` 가 아닌 임시 복사본에서 `hook_resolve_mode "BRANCH" "block"` 을 `"warn"` 으로 바꾸고 `sdd doctor` → W-5 경고 확인.
2. `/hk-wiki-lint` 를 본 저장소에 실행해 보고서 확인(오탐률 기록 — 단, 결과는 walkthrough 기록용이며 자동 수정 없음).

## 롤백 계획

- `git revert`. 새 검사는 경고 전용이라 롤백 시 동작 의존이 없다. state·마이그레이션 영향 없음.

## ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 (검증기 구조는 spec 수준 결정; "코드가 사실의 출처" 는 기존 schema.md 규약의 구현)

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (`test-wiki-verify.sh` 포함, 전체 회귀 0)
- [ ] 본 저장소 `sdd doctor` 사실 검증 불일치 0건
- [ ] `/hk-wiki-lint` 수동 실행 결과 walkthrough 기록
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-30-02-wiki-knowledge-lint` 브랜치 push 완료
