# Walkthrough: spec-19-01

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| wiki frontmatter `type:` vs `kind:` | ADR-001 `type:` 어휘 재사용 vs 별도 `kind:` 네임스페이스 | `kind:` 별도 도입 | ADR-001의 5어휘 closure는 ADR/RCA 전용. wiki 페이지에 `type: decision`을 붙이면 grep 쿼리가 오염됨 |
| 테스트의 `kind:` 파싱 오류 | 본문의 스키마 예시 줄(`kind: catalog \| synthesis`)이 grep에 걸림 | frontmatter 영역만 awk로 추출 | `grep "^kind:"` 대신 `awk 'NR==1 && /---/{in_fm=1} in_fm && /---/{exit} /^kind:/{print}'` — purpose.md 같이 본문에 스키마 예시가 있는 파일에서 false match 방지 |
| wiki 초기 부트스트랩 범위 | 111개 spec 전체 링크 vs 핵심 ADR/RCA만 증류 | 핵심 ADR/RCA만 (3개) | 색인이 아닌 증류가 목표. 111개를 링크해도 탐색 가치는 동일 — 오히려 노이즈. `/hk-wiki-ingest`로 archive마다 점진 누적. |

### ADR 승격 가이드

- [x] ADR 승격 대상 있음 → `docs/decisions/ADR-003-wiki-frontmatter-schema.md` (type: convention)
  - wiki `kind:` vs ADR `type:` 공존 규칙은 cross-spec + 6개월 이상 유효할 convention

## 💬 사용자 협의

- **주제**: wiki 연결 범위
  - **사용자 의견**: "파일 구조는 알겠는데 이걸로 어떤 것을 엮으려고? 문서 전체?"
  - **합의**: 전체 INDEX가 아닌 증류(distillation). raw 111개를 링크하지 않고, 의미 있는 결정·패턴만 wiki 페이지에 합성. `/hk-wiki-ingest`로 archive 시 점진 누적.

- **주제**: lat.md + LLM Wiki 참조 추가
  - **사용자 의견**: LLM Wiki (Karpathy), llm_wiki (nashsu) 레퍼런스 제시
  - **합의**: lat.md 개념 차용 + Karpathy LLM Wiki 패턴 적용. "human curates, LLM maintains" 원칙 채택.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (통합 테스트)
- **명령**: `bash tests/test-wiki-structure.sh`
- **결과**: ✅ 32/32 PASS
- **로그 요약**:
```text
 wiki structure (spec-19-01)
 결과: 32/32 PASS
 ✓ ALL PASS
```

### 2. 수동 검증

1. **Action**: `bash tests/test-wiki-structure.sh` (TDD Red → 0/12 FAIL)
   - **Result**: docs/wiki/ 없음, ADR/RCA sources: 필드 없음 — 예상대로 전부 실패
2. **Action**: wiki 파일 5개 생성 + frontmatter 적용
   - **Result**: Check 1~3 통과
3. **Action**: `kind:` 파싱 테스트 실행 → 1/32 FAIL (purpose.md 본문 스키마 줄 false match)
   - **Result**: awk frontmatter 범위 추출로 테스트 수정 → 32/32 통과
4. **Action**: ADR-001/002, RCA-001 frontmatter에 `sources:`, `linked:`, `updated:` 추가
   - **Result**: Check 5 전부 통과

## 🔍 발견 사항

- **테스트 파싱 함정**: `grep "^field:"` 방식은 본문에 동일 패턴 예시가 있을 때 false positive 발생. 특히 purpose.md처럼 스키마를 설명하는 문서에서 자주 나타남. frontmatter 파싱은 항상 `---` 마커 사이로 범위 한정 필요.
- **ADR-003 후보**: `wiki/kind:` vs `ADR/type:` 공존 규칙은 spec-19-02에서 템플릿 적용 시 충돌 가능성이 있어 ADR-003으로 명문화 권장.

## 🚧 이월 항목

- **ADR-003 작성** (`wiki-frontmatter-schema`, type: convention) → 이번 spec 내 작성하거나 spec-19-02에서 처리
- **Obsidian 수동 검증** (docs/ vault 열어 wikilink 탐색) → 사용자 환경에서 직접 확인 권장

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-27 |
| **최종 commit** | `4149b9e` |
