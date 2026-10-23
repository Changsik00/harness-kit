# feat(spec-30-02): wiki 지식 lint — 사실 검증과 의미 lint

## 📋 Summary

### 배경 및 목적
wiki 가 코드와 어긋나면 에이전트에게 거짓 맥락을 준다(phase-30 최대 위험). 기존 lint 는 구조와 "인제스트했는가" 만 봤다. 코드와 대조할 수 있는 주장은 결정론적으로, 판단이 필요한 것은 LLM 보고서로 점검한다.

### 주요 변경 사항
- [x] `sdd doctor` W-5 / `sdd status` 진단에 **wiki 사실 검증** 추가 (경고, exit 0, 문제 없으면 침묵)
  - `<!-- verify: hooks-defaults -->` 표 ↔ `.harness-kit/hooks/*.sh` 의 `hook_resolve_mode` 선언 대조 (불일치 / 표에 없는 hook / 코드에 없는 hook)
  - frontmatter `sources:`/`covers:` 경로 존재 확인, 페이지 크기 상한(200/150/300줄)
  - 알 수 없는 verify 키·표 없는 마커는 별도 보고 (조용히 통과하지 않음)
- [x] **신선도 신호 A 교정**: spec-30-01 로 인제스트가 `decisions.md`/`patterns.md` 를 편집하지 않게 되어 영구 오탐이 되므로, 운영 파일 외 wiki 전체에서 ADR 언급을 찾도록. 문구는 "wiki 낡음(보조)"
- [x] `/hk-wiki-lint` 신설 — 모순·대체됐는데 현재형·장기 보류·출처 없음·verify 마커 누락을 점검하는 **보고서 전용** 명령
- [x] `schema.md` Lint 절: 사실 검증(주) / 신선도(보조) / 의미 lint 역할 분담
- [x] 첫 실측에서 나온 wiki 낡음 정정 (`sources:` 경로 3건, `direction.md` 수치)

### Phase 컨텍스트
- **Phase**: `phase-30`
- **본 SPEC 의 역할**: wiki 를 "정리 색인"이 아니라 "맞는 지식"으로 유지하기 위한 감시 장치. spec-30-03 이 컴포넌트 페이지를 채울 때 기계 검증 가능한 주장에 마커를 달면 바로 보호된다.

## 🎯 Key Review Points

1. **사실의 출처는 코드** (`_wiki_verify_hooks_defaults`): 불일치는 wiki 가 틀린 것으로 보고한다.
2. **휴리스틱 한계**: 표의 자연어 칸에서 `block`/`warn` 단어를 찾는다. 헤더에 `기본` 열이 없으면 대조하지 못하고 침묵한다(이월 항목에 개선 후보 기록). 그래서 경고로 시작.
3. **신호 A 의미 변경**: "ADR 이 decisions/patterns 에 있나" → "wiki 어디든 언급됐나". index/log/schema 는 제외.
4. **hook 선언 위치**: spec 초안의 `sources/hooks/` 우선 대신 `.harness-kit/hooks/`(= `sdd hooks` 와 동일) 사용.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-wiki-verify.sh
bash tests/test-wiki-freshness.sh
bash tests/run.sh
```

**결과 요약**:
- ✅ `test-wiki-verify` Case 1~10 (일치 침묵 / 기본값 변경 / 표에 없는 hook / 표 없음 / 알 수 없는 키 / 경로 / 크기 / 침묵 / 본 저장소 0건 + status / 커맨드 계약)
- ✅ `test-wiki-freshness` Case 7·8 (components 언급 인정, index 제외, "(보조)" 라벨)
- ✅ 전체: PASS 89 / FAIL 0

### 수동 검증 시나리오
1. 본 저장소 hooks.md 의 `check-branch` 기본을 임시로 `warn` 으로 변경 → `sdd doctor` 가 불일치 보고, 원복 후 OK
2. `/hk-wiki-lint` 절차를 시범 2페이지에 수동 수행 → 지적 3종 (1건 즉시 수정). 독립 세션 실행은 이월

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/hk-wiki-lint.md` (+ `.claude/commands/` 사본): 의미 lint 명령
- `tests/test-wiki-verify.sh`: 사실 검증·커맨드 계약 테스트

### 🛠 Modified Files
- `sources/bin/sdd` (+ `.harness-kit/bin/sdd`, +130): `_wiki_verify_*`, doctor W-5, status 진단, 신선도 신호 A
- `docs/wiki/schema.md`: Lint 절 역할 분담
- `docs/wiki/{decisions,patterns,direction}.md`: 낡은 경로·수치 정정
- `tests/test-wiki-freshness.sh`: 신호 A 새 정의 케이스

**Total**: 14 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] 본 저장소 `sdd doctor` 사실 검증 불일치 0건
- [x] `walkthrough.md` / `pr_description.md` ship commit 완료
- [ ] lint (shellcheck 미설치로 skip)
- [x] 사용자 검토 요청

## 🔗 관련 자료

- Phase: `backlog/phase-30.md`
- Walkthrough: `specs/spec-30-02-wiki-knowledge-lint/walkthrough.md`
- 선행: spec-30-01 (#239)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
