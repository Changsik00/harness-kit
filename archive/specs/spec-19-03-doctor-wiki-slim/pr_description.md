# feat(spec-19-03): sdd doctor wiki layer 점검 + CLAUDE.md 슬림화

## 개요

`sdd doctor` 에 wiki layer 점검 4종을 추가하고, root `CLAUDE.md` 의 저빈도 참조 섹션을 `docs/project-guide.md` 로 분리합니다. `sources/governance/constitution.md` 에 rule prune 권고 기준 섹션을 추가합니다.

## 변경 사항

### 수정 파일

| 파일 | 변경 내용 |
|---|---|
| `sources/bin/sdd` | `cmd_doctor()` — wiki layer 점검 섹션 추가 (W-1~W-4) |
| `.harness-kit/bin/sdd` | 동기화 (동일 변경) |
| `CLAUDE.md` | `## 대상 환경` + `## 디렉토리 의미` 제거 → `docs/project-guide.md` 포인터 |
| `sources/governance/constitution.md` | `§13 Rule Prune Guidance` 섹션 추가 |

### 신규 파일

| 파일 | 설명 |
|---|---|
| `docs/project-guide.md` | 저빈도 참조 섹션 분리 (대상 환경 + 디렉토리 의미) |
| `tests/test-doctor-wiki.sh` | wiki doctor 점검 검증 테스트 (5 checks) |

## sdd doctor — wiki layer 섹션

```
wiki layer
  ✅ docs/wiki/ 존재
  ⚠️  N개 고아 wikilink 감지
  ✅ decisions/rca 문서 최근 참조 OK
  ✅ governance 6462w (< 7000w)
```

점검 항목:
- **W-1**: `docs/wiki/` 부재 시 `⚠ wiki layer 없음 — /hk-wiki-ingest 실행 권장`
- **W-2**: `[[wikilinks]]` 고아 링크 감지 (참조 대상 파일 없음)
- **W-3**: `docs/decisions/` + `docs/rca/` 파일 중 90일+ 미참조 → stale 경고
- **W-4**: governance 파일 단어 수 합계 7,000w 초과 → rule prune 권고

## 테스트 결과

```
test-doctor-wiki.sh:     5/5  PASS
test-wiki-structure.sh: 45/45 PASS
```

## 체크리스트

- [x] sdd doctor W-1~W-4 점검 추가 (sources + .harness-kit 동기화)
- [x] docs/project-guide.md 생성 + CLAUDE.md 포인터 교체
- [x] sources/governance/constitution.md §13 Rule Prune Guidance 추가
- [x] tests/test-doctor-wiki.sh 5/5 PASS 확인
- [x] tests/test-wiki-structure.sh 45/45 PASS 유지 확인
