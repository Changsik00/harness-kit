# feat(spec-x-sdd-search): 마크다운 자산 통합 검색 `sdd search`

## 📋 Summary

### 배경 및 목적

기존 `sdd archive` 는 `git mv` 로 디렉토리를 옮기는 수준 — 실제로는 *stash* 에 가깝고, archive 본연의 "지식 보존" 역할이 빈약했다. archive 누적 108 spec, ADR/RCA, walkthrough 의 결정/실패 패턴이 `grep -rn` 수동 호출 외엔 접근 불가.

[1st1/lat.md](https://github.com/1st1/lat.md) (Agent Lattice — active code 의 markdown 지식 그래프) 를 참고했으나, 우리 도메인은 *과거 작업* 의 검색에 가까워 별도 색인 시스템 없이 **bash-native grep wrapper** 로 충분하다고 판단. 본 PR 은 그 wrapper 를 추가한다.

### 주요 변경 사항

- [x] CLI: `sdd search <keyword> [--scope=<s>] [--ignore-case]` 신설
- [x] scope: `all`(기본) / `active` / `archive` / `decisions` / `rca` / `backlog`
- [x] 출력: 카테고리별 그룹 헤더 + `<rel path>:<line>: <text>`
- [x] `sources/bin/sdd` 도움말에 한 줄 추가, dispatcher 분기 추가
- [x] 도그푸딩 동기화 (`.harness-kit/bin/sdd`)
- [x] `tests/test-sdd-search.sh` 신설 — 7 시나리오 fixture 기반 단위 테스트

### Phase 컨텍스트

- **Phase**: 없음 (spec-x — Solo Spec)
- **본 SPEC 의 역할**: archive 의 knowledge retention 1차 회복. lat.md 의 3 단계 점진안 (1: decisions-index 자동 추출 / 2: search wrapper / 3: wiki link + drift) 중 **2 단계만** 본 spec 으로 처리. 사용자 선택.

## 🎯 Key Review Points

1. **무색인 설계**: 사전 인덱스 / sqlite 없이 호출 시점 `find + grep`. 108 spec 규모에서 latency 0.2~0.5s 라 색인 운영 부담 정당화 어려움. 1000+ 누적 시 재검토.
2. **bash 3.2 호환**: `**` globstar 미사용 (`find ... -name '*.md'`). `declare -A` / `mapfile` 미사용. CLAUDE.md 작업 원칙 §3 준수.
3. **scope dispatch 패턴**: 5 그룹을 `pairs="active|specs archive|archive/specs|archive/backlog ..."` 데이터 표 + for 루프로 처리. 처음 시도한 nested function closure 는 dynamic scoping 이 brittle 해서 폐기.
4. **슬래시 커맨드 미생성**: `/hk-search` 추가 안 함 — `/hk-*` 자동완성 noise + 검색은 expert workflow 라 CLI 가 더 자연스러움. 필요 시 후속 spec.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-sdd-search.sh
```

**결과 요약**:
- ✅ T1 전체 scope 매치 + 그룹 헤더
- ✅ T2 매치 없음 → exit 1 + 메시지
- ✅ T3 `--scope=decisions` 만
- ✅ T4 `--ignore-case`
- ✅ T5 regex `foo|bar`
- ✅ T6 인자 없음 → die
- ✅ T7 invalid scope → die

**Total**: 7 PASS / 0 FAIL

### 회귀 테스트

| 테스트 | 결과 |
|---|---|
| `test-sdd-config.sh` | 7/7 PASS |
| `test-sdd-archive-search.sh` | 11/11 PASS |
| `test-governance-dedup.sh` Check 2 (cp 정합) | PASS |

> Check 3 (word count) 의 pre-existing FAIL 은 [기존 Icebox 등록 항목](../../backlog/queue.md) — 본 PR 무관.

### 수동 검증 시나리오

1. **실 archive 검색**: `sdd search uxMode --ignore-case` → active 1 + archive 50 + 다수 그룹 매치
2. **빈 결과**: `sdd search nonexistent_xyz` → `검색 결과 없음` + exit 1
3. **scope 제한**: `sdd search 'lat.md' --scope=active` → active 그룹만, 다른 헤더 없음

## 📦 Files Changed

### 🆕 New Files

- `tests/test-sdd-search.sh`: fixture 기반 7 시나리오 단위 테스트
- `specs/spec-x-sdd-search/{spec,plan,task,walkthrough,pr_description}.md`: SDD 산출물

### 🛠 Modified Files

- `sources/bin/sdd` (+80, -0): 도움말 라인 + dispatcher 분기 + `cmd_search` / `_search_dispatch` / `_search_in` 함수
- `.harness-kit/bin/sdd` (+80, -0): 도그푸딩 동기화

**Total**: 8 files changed

## ✅ Definition of Done

- [x] `tests/test-sdd-search.sh` 7/7 PASS
- [x] 회귀 테스트 (sdd-config, sdd-archive-search, governance-dedup cp) PASS
- [x] sources↔installed 정합성 (cp 검사)
- [x] `walkthrough.md` / `pr_description.md` 작성
- [ ] PR 생성 + URL 보고

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-sdd-search/walkthrough.md`
- 참고: [1st1/lat.md](https://github.com/1st1/lat.md) — Agent Lattice (active code knowledge graph)
- 후속 후보: decisions-index 자동 추출 (1 단계), wiki link + drift check (3 단계)
