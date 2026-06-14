# spec-23-01: 외부 확장 우선 사용 거버넌스 + 권장 유도

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-23-01` |
| **Phase** | `phase-23` |
| **Branch** | `spec-23-01-prefer-extensions` |
| **상태** | Planning |
| **타입** | Refactor (거버넌스/도구) |
| **작성일** | 2026-06-14 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`/hk-extend` 는 Serena(LSP 코드 인텔리전스 MCP)를 opt-in(default-off)으로 붙인다. 그러나:
1. **설치돼도 안 씀**: 이번 세션에서 serena 설치본이 있었으나 에이전트는 직접 `grep`/`Read` 만 사용했다. 거버넌스에 "설치 시 우선 사용" 지침이 없어 도구가 사실상 방치된다.
2. **유도 부재**: extend 톤이 "있으면 좋은 것" 수준이라 TS/Python 등 코드 집약 프로젝트에서도 설치가 권장되지 않는다.

### 문제점

확장의 가치는 "설치"가 아니라 "사용"에서 나온다. 동시에 키트는 "컨텍스트 비용 0 우선 (MCP 최후)"(CLAUDE.md #2) 원칙이 있어, 무조건 우선 사용은 원칙과 충돌한다.

### 해결 방안

외부 확장을 **조건부 우선 사용**(설치돼 있고 + 그 도구의 강점 영역일 때)으로 거버넌스에 명문화하고, extend 톤을 권장으로 전환하며, 코드 프로젝트에서 미설치 시 `sdd status` 가 1줄 권장을 출력한다. 트레이드오프는 ADR-008 로 기록한다.

## 요구사항

1. **거버넌스 규칙**: agent.md 에 "외부 확장이 설치돼 있으면 그 강점 영역(예: LSP 심볼 탐색/참조 추적)에서는 raw grep 다단계보다 우선 사용" 규칙 추가. **조건부** — 비-LSP/단순 작업까지 강제하지 않음. 확장 일반으로 작성(serena 는 인스턴스).
2. **ADR-008** (`type: tradeoff`): MCP 상시비용 vs 컨텍스트 절감. 조건부 우선 사용 채택 근거 + 거부된 쪽(무조건/금지)의 비용 명시.
3. **extend 권장 톤**: `hk-extend.md` 를 "권장" 으로 조정하되 opt-in 원칙·상시비용 경고는 유지.
4. **미설치 감지 권장**: `sdd status` drift 가 (코드 파일 존재) AND (확장 미설치) 일 때만 1줄 권장 출력. 비-코드 프로젝트나 이미 설치 시 무출력.
5. **미러 무결성**: `agent.md`↔`sources/governance/agent.md`, `hk-extend.md`↔`sources/commands/`, `sdd`↔`sources/bin/sdd` 모두 byte-identical.
6. **워드 버짓**: 거버넌스 8,000 단어 초과 없음(`sdd doctor`). 규칙 본문은 최소 문장, 상세는 ADR 로.

## Out of Scope

- serena 외 새 확장 추가.
- 설치 자체의 자동화(여전히 사용자 명시 실행 `/hk-extend`).
- `/hk-align` 본문 prompt 추가 — 1차는 `sdd status` drift 한 곳에만 권장을 띄운다(노출 지점 단일화, 잡음 최소화).

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **조건부 우선 사용** 프레이밍 확정(무조건 아님) — 원칙 #2 와의 양립을 ADR-008 로 못박음.
> - [ ] 권장 노출 지점을 `sdd status` drift **한 곳**으로 한정(align 본문 미추가).

> [!WARNING]
> - 거버넌스 동작 변경(에이전트가 확장을 우선 사용하게 됨) — breaking 은 아니나 행동 디폴트 변화.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **agent.md** | §6.5(Static Analysis First) 인접에 "Extension-First (conditional)" 규칙 1블록 추가 | 정적분석 우선 규칙과 같은 결의 "도구 우선순위" 규칙. 영어 |
| **ADR-008** | `type: tradeoff` 로 결정·거부안 비용 기록 | spec-x 부적격 사유였던 아키텍처 결정을 정식 기록 |
| **hk-extend.md** | 도입부를 "opt-in 권장" 으로, 경고/스코프 질문은 유지 | 권장하되 비용 인식은 보존 |
| **sdd drift** | `_drift_extension_recommend()` 신설 — 코드 파일 glob + `installed.json` `.extensions` 검사 | 둘 다 만족 시에만 1줄. 기존 drift 함수 패턴 차용 |

## Proposed Changes

#### [NEW] `docs/decisions/ADR-008-extension-preferential-use.md`
조건부 확장 우선 사용 결정. frontmatter `type: tradeoff`.

#### [MODIFY] `.harness-kit/agent/agent.md` + `sources/governance/agent.md`
"Extension-First (conditional)" 규칙 블록 추가(영어). byte-identical 미러.

#### [MODIFY] `.claude/commands/hk-extend.md` + `sources/commands/hk-extend.md`
도입부 톤을 권장으로 조정. byte-identical 미러.

#### [MODIFY] `.harness-kit/bin/sdd` + `sources/bin/sdd`
`_drift_extension_recommend()` 추가 + `_status_drift` 에 연결. byte-identical 미러.

#### [NEW] `tests/test-drift-extension-recommend.sh`
코드 파일 존재 + 미설치 → 권장 출력 / 미설치인데 코드 없음 → 무출력 / 설치됨 → 무출력 검증.

## 검증 계획

```bash
bash tests/test-drift-extension-recommend.sh
bash tests/run.sh --fast
diff -q .harness-kit/agent/agent.md sources/governance/agent.md
diff -q .harness-kit/bin/sdd sources/bin/sdd
diff -q .claude/commands/hk-extend.md sources/commands/hk-extend.md
bash .harness-kit/bin/sdd doctor
```

수동 검증 시나리오:
1. 본 코드 프로젝트(스크립트 다수)지만 serena 설치됨 → 권장 라인 미출력 기대.
2. `installed.json` 에서 extensions 제거 가정 fixture → 권장 라인 출력 기대.

## ADR 후보

- [x] ADR-008 — 외부 확장 조건부 우선 사용 (type: tradeoff).

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (`tests/test-drift-extension-recommend.sh`, `run.sh --fast`)
- [ ] 3쌍 미러 byte-identical
- [ ] `sdd doctor` 워드 버짓 경고 없음
- [ ] `walkthrough.md` / `pr_description.md` ship commit
- [ ] `spec-23-01-prefer-extensions` 브랜치 push 완료
