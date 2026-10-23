# docs(spec-30-01): wiki 3층 구조와 인제스트·조회 규약 개정

## 📋 Summary

### 배경 및 목적
wiki 는 출처 단위 append-only 로그라 "지금 입장 · 번복 · 미결" 에 답하지 못했다. 시범(방향·hooks 페이지)에서 3층 구조의 효용을 확인했으므로, 그 구조와 갱신 규약을 schema·인제스트 커맨드·조회 규칙에 반영한다.

### 주요 변경 사항
- [x] `schema.md` 재작성: 3층(방향 / 구현 / 이슈 스레드), 제자리 갱신 + 변경 이력 보존(append-only 폐지), 충돌 시 사용자 확인, 출처 필수, `verify` 마커, 크기 상한(200/150/300줄)
- [x] 컴포넌트 페이지 템플릿 `wiki-component.md` 추가 (`covers:` frontmatter 로 spec 경로 ↔ 컴포넌트 기계 매핑)
- [x] `/hk-wiki-ingest` 를 "영향 컴포넌트만 제자리 갱신" 흐름으로 개정 (`decisions.md`/`patterns.md` 직접 편집 단계 제거)
- [x] `CLAUDE.fragment.md` 조회 순서: direction/components → threads → 출처별 로그
- [x] `decisions.md`/`patterns.md` 를 출처별 로그로 격하(배너만, 내용 불변), `index.md` 3층 안내
- [x] 계약 테스트 `tests/test-wiki-schema-v2.sh` (7 Case)

### Phase 컨텍스트
- **Phase**: `phase-30`
- **본 SPEC 의 역할**: 구조·규약을 확정해 spec-30-02(사실 검증 lint)가 검증 대상(`verify` 마커)을 찾고 spec-30-03 이 컴포넌트 페이지를 채울 수 있는 토대를 만든다.

## 🎯 Key Review Points

1. **append-only 폐지** (`schema.md` §페이지 작성 규약 1·2): 지우지 않는 대상이 "현재 서술"에서 "이력"으로 바뀐다. 충돌은 사용자 확인 의무 — 인제스트가 완전 자동이 아니게 됨.
2. **`covers:` 매핑** (`hk-wiki-ingest.md` 3단계): 매핑 불가 항목은 LLM 이 임의 분류하지 않고 사용자에게 묻는다.
3. **검증 한계**: 계약 테스트는 문구·섹션·마커·크기만 고정한다. 인제스트 *행동* 검증은 phase 종료 시 실사용으로 이월했다.
4. **계획 외 1줄**: `doctor.sh` 필수 템플릿 목록에 `wiki-component.md` 추가 (`test-doctor-templates` 가 일치를 강제).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-wiki-schema-v2.sh
bash tests/run.sh
```

**결과 요약**:
- ✅ `test-wiki-schema-v2`: 7 Case 통과
- ✅ 전체: PASS 88 / FAIL 0

### 수동 검증 시나리오
1. **`sdd doctor`** → 고아 wikilink 없음, wiki 최신 (기존 WARN 3건은 본 spec 무관)
2. **인제스트 실사용** → 이월 (phase 종료 시점, walkthrough 에 사유 기록)

## 📦 Files Changed

### 🆕 New Files
- `sources/templates/wiki-component.md` (+ `.harness-kit/agent/templates/` 사본): 컴포넌트 페이지 양식
- `tests/test-wiki-schema-v2.sh`: 계약 테스트

### 🛠 Modified Files
- `docs/wiki/schema.md`: 3층·갱신 규약 재작성
- `sources/commands/hk-wiki-ingest.md` (+ `.claude/commands/` 사본): 컴포넌트 단위 인제스트
- `sources/claude-fragments/CLAUDE.fragment.md` (+ `.harness-kit/CLAUDE.fragment.md`): 조회 순서
- `docs/wiki/{decisions,patterns,index}.md`, `docs/wiki/components/hooks.md`: 배너·안내·verify 마커
- `doctor.sh`: 필수 템플릿 목록 +1
- `tests/test-wiki-structure.sh`: Check 7 단언을 새 조회 규칙에 맞춤

**Total**: 18 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [ ] lint (shellcheck 미설치로 skip)
- [x] 사용자 검토 요청

## 🔗 관련 자료

- Phase: `backlog/phase-30.md`
- Walkthrough: `specs/spec-30-01-wiki-three-layer-schema/walkthrough.md`
- 관련 ADR: ADR-003 (wiki frontmatter), ADR 후보 `wiki-update-in-place-with-history` (결정 대기)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
