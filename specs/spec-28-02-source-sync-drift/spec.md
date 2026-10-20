# spec-28-02: 원본↔사본 drift 검사

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-28-02` |
| **Phase** | `phase-28` |
| **Branch** | `spec-28-02-source-sync-drift` |
| **Base 브랜치** | `phase-28-docs-freshness` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-10-20 |
| **소유자** | changsik |

## 배경 및 문제 정의

### 현재 상황
키트 원본(`sources/`)은 `install.sh`/`update.sh` 로 도그푸딩 사본(`.harness-kit/`, `.claude/commands/`)에 복사된다. 일치 여부는 `tests/test-hook-modes.sh`, `tests/test-install-manifest-sync.sh` 가 *일부 파일*(hooks, `bin/sdd`, constitution, spec 템플릿)만 우연히 잡는다. 정식 검사는 없다.

### 문제점
- 2026-10-19 spec-28-01 사본 동기화 중, 사본 `.harness-kit/bin/sdd` 가 원본보다 뒤처져 #231 의 `config models` 수정이 반영되지 않은 상태였음이 확인됐다. 테스트 목록에 없는 파일(commands, agent.md, align.md, 나머지 템플릿, `bin/lib`)은 같은 일이 생겨도 알 방법이 없다.
- 사본이 낡으면 hook·거버넌스가 원본과 다르게 동작해 "고쳤는데 안 고쳐진" 상태가 된다.

### 해결 방안
원본→사본 매핑 표를 정의하고, 원본 파일이 사본과 다르거나 사본에 없으면 `sdd doctor` 가 경고, `sdd status` 진단에 한 줄을 띄운다. 키트 원본 저장소(`sources/bin/sdd` 존재)에서만 동작하고 다운스트림에서는 침묵한다.

## 요구사항

1. **매핑** (원본 → 사본):
   - `sources/bin/*` (+ `bin/lib/*`) → `.harness-kit/bin/`
   - `sources/hooks/*` → `.harness-kit/hooks/`
   - `sources/governance/*.md` → `.harness-kit/agent/`
   - `sources/templates/*` → `.harness-kit/agent/templates/`
   - `sources/commands/*.md` → `.claude/commands/`
2. **판정**: 원본 파일마다 사본과 바이트 단위로 비교(`cmp -s`). 다르거나 사본에 없으면 drift. 사본에만 있는 파일은 무시한다(설치 부산물·캐시).
3. 공유 헬퍼 `_source_sync_report` 하나를 `cmd_doctor` 와 `_status_diagnose` 가 함께 쓴다. drift 가 있을 때만 한 줄 출력(`원본↔사본 drift N개: a, b, c(최대 5) — update.sh 또는 cp 로 동기화`), 없으면 침묵.
4. **자동 비활성**: `$SDD_ROOT/sources/bin/sdd` 또는 `$SDD_ROOT/.harness-kit/bin/sdd` 가 없으면 침묵(다운스트림). 
5. 경고만(exit 0). 휴리스틱이 아니라 결정론적이지만, 의도된 차이가 생길 수 있어 차단하지 않는다(CLAUDE.md #5).
6. 본 저장소에서 실행 시 0건이어야 한다(의도된 제외 항목 없음 — 현재 전부 일치 확인됨).
7. bash 3.2+ 호환, `set -euo pipefail` 하에서 비정상 종료하지 않는다.

## Out of Scope

- 자동 동기화(`cp`/`update.sh` 실행) — 안내까지만
- `.claude/settings.json`, `CLAUDE.md` 등 머지·렌더되는 파일 (원본과 바이트 비교 불가)
- 기존 sync 테스트(test-hook-modes 등) 제거 — 역할이 달라(테스트=CI 고정, 본 검사=운영 중 조기 경보) 유지
- `harness.config.json` 등 설정 SSOT (spec 외 #231 에서 처리)

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 매핑 범위(bin/hooks/governance/templates/commands)가 적절한가 — `.claude/settings.json`·`CLAUDE.md` 는 머지 산출물이라 제외
> - [ ] 경고 전용(exit 0)으로 시작

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| 비교 | 원본 기준 순회 + `cmp -s` | 단순·결정적. diff 출력 불필요, 파일명만 필요 |
| 활성 조건 | `sources/bin/sdd` + 사본 `bin/sdd` 둘 다 존재 | 키트 저장소 판별. 다운스트림 자동 침묵 |
| 통합 | 공유 헬퍼 (spec-28-01 `_wiki_freshness_report` 패턴) | doctor/status 중복 방지 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd`
- `_source_sync_report` 헬퍼 추가 (`_wiki_freshness_report` 근처).
- `cmd_doctor` 에 점검 항목 추가: 출력 있으면 `_doc_warn`, 없으면 `_doc_pass`(키트 저장소일 때만).
- `_status_diagnose` 에 `💡` 한 줄 추가.

#### [NEW] `tests/test-source-sync-drift.sh`
- 임시 fixture(가짜 `sources/` + 사본)로 격리.

#### [MODIFY] `.harness-kit/bin/sdd`
- 도그푸딩 사본 동기화.

## 검증 계획

```bash
bash tests/test-source-sync-drift.sh
bash tests/test-wiki-freshness.sh
bash tests/test-hook-modes.sh
bash tests/run.sh
```

수동: 본 저장소 `sdd doctor` 에서 drift 0 확인 → `.harness-kit/hooks/_lib.sh` 를 임시 변조 후 경고 확인 → 복구.

## 롤백 계획
- `git revert` (state·마이그레이션 없음).
