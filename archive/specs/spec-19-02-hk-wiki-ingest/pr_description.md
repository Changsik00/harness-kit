# feat(spec-19-02): /hk-wiki-ingest 슬래시 커맨드 + sdd archive 힌트

## 개요

`sdd archive` 완료 후 wiki 레이어를 최신 상태로 유지할 수 있도록 `/hk-wiki-ingest` 슬래시 커맨드를 신설합니다.
archive된 spec의 walkthrough에서 결정·패턴을 추출하여 `docs/wiki/` 페이지를 증분 갱신하는 절차를 정의합니다.

## 변경 사항

### 신규 파일

| 파일 | 설명 |
|---|---|
| `sources/commands/hk-wiki-ingest.md` | `/hk-wiki-ingest` 슬래시 커맨드 원본 |
| `.claude/commands/hk-wiki-ingest.md` | 설치된 슬래시 커맨드 (활성 경로) |
| `tests/test-wiki-ingest.sh` | wiki ingest 관련 검증 테스트 (10 checks) |

### 수정 파일

| 파일 | 변경 내용 |
|---|---|
| `sources/bin/sdd` | `cmd_archive()` 완료 후 `/hk-wiki-ingest` 힌트 출력 추가 |
| `.harness-kit/bin/sdd` | 동기화 (동일 변경) |

## 슬래시 커맨드 동작

```
/hk-wiki-ingest [--all]
```

1. `docs/wiki/log.md` 마지막 인제스트 날짜 확인
2. 기본 모드: 마지막 인제스트 이후 archive된 walkthrough 목록 수집
3. 각 walkthrough에서 결정 기록 → `decisions.md`, 발견 사항 → `patterns.md` 추출·추가
4. `log.md`에 인제스트 이벤트 맨 위에 기록 (최신 우선)
5. `index.md` 최근 인제스트 날짜 갱신 (선택)
6. 커밋 여부 확인

## sdd archive 힌트

archive 완료 시 출력:
```
✓ spec-XX-XX-slug → archive/
  → wiki 갱신: /hk-wiki-ingest
```

## 테스트 결과

```
test-wiki-structure.sh: 45/45 PASS
test-wiki-ingest.sh:    10/10 PASS
```

## 체크리스트

- [x] `sources/commands/hk-wiki-ingest.md` 작성
- [x] `.claude/commands/hk-wiki-ingest.md` 설치
- [x] `sdd archive` 힌트 출력 추가 (sources + .harness-kit 동기화)
- [x] `tests/test-wiki-ingest.sh` 작성 및 10/10 PASS 확인
- [x] `tests/test-wiki-structure.sh` 45/45 PASS 유지 확인
