# feat(spec-27-01): ADR 인덱스 자동 생성 (`sdd adr-index`)

> 첫 줄은 commit subject 와 정확히 일치해야 합니다 (`type(spec-...): description`).

## 📋 Summary

### 배경 및 목적
`docs/decisions/` 의 ADR 은 frontmatter(`id`/`type`/`date`/`status`)를 갖지만 이를 한눈에 보는 인덱스가 없어 수기 관리 시 drift 가 발생한다(GitHub #168). frontmatter 를 SoT 로 삼아 `docs/decisions/README.md` 를 (재)생성/검증하는 `sdd adr-index` 를 추가한다.

### 주요 변경 사항
- [x] `sdd adr-index` — ADR frontmatter + 제목행을 스캔해 `docs/decisions/README.md` 마커 구간(`<!-- adr-index:start -->`~`end`) 테이블을 번호순으로 재생성
- [x] `sdd adr-index --check` — drift 시 exit 1 (CI/doctor 게이트용, 파일 변경 없음)
- [x] macOS awk `-v` 멀티라인 실패를 회피하는 bash 라인 루프 기반 마커 치환 (GitHub #168 이 지적한 함정 실측 확인)
- [x] 기존 9개 ADR 로 `docs/decisions/README.md` 최초 생성

### Phase 컨텍스트
- **Phase**: `phase-27` (docs-integrity)
- **본 SPEC 의 역할**: GitHub #168 세 제안 중 첫 번째(ADR 인덱스 자동 생성). spec-27-02(docs-integrity-check) 가 `adr-index --check` 를 게이트로 재사용할 예정.

## 🎯 Key Review Points

1. **`--check` 의 마커 탐지 방식**: 처음엔 정규식 substring 매치를 썼다가, README 안내 문구가 마커 문법을 그대로 인용해서 자기 자신을 마커로 오인하는 버그를 겪음 — 정확한 라인 일치(`$0 == "..."`)로 수정. 마커 기반 파서를 리뷰할 때 유사 패턴 주의.
2. **bash 라인 루프 기반 마커 치환**: 기존 `sdd_marker_replace`(awk `-v content`)를 재사용하지 않고 신규 헬퍼를 작성한 이유 — macOS BWK awk 가 `-v` 값의 개행에서 즉시 실패함을 실측 확인(GitHub #168).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-adr-index.sh
bash tests/run.sh
```

**결과 요약**:
- ✅ `tests/test-adr-index.sh`: 6/6 통과 (missing/generate/idempotent/check-ok/drift-detect/regenerate)
- ✅ `tests/run.sh`: 79/79 통과, FAIL 0

### 수동 검증 시나리오
1. **시나리오 1**: `sdd adr-index` 최초 실행 → `docs/decisions/README.md` 생성, ADR-001~009 전부 번호순 등장.
2. **시나리오 2**: 재실행 → 파일 변화 없음(idempotent). `--check` → exit 0.

## 📦 Files Changed

### 🆕 New Files
- `tests/test-adr-index.sh`: `sdd adr-index` 회귀 테스트 6건
- `docs/decisions/README.md`: 최초 생성된 ADR 인덱스
- `specs/spec-27-01-adr-index-gen/spec.md`, `task.md`, `walkthrough.md`, `pr_description.md`: spec 산출물

### 🛠 Modified Files
- `sources/bin/sdd` (+113): `cmd_adr_index()` + 디스패치 등록 + 헬프 문구 (키트 원본, SoT)
- `.harness-kit/bin/sdd` (+113): 동일 변경 미러 (본 저장소 도그푸딩 설치본)
- `backlog/phase-27.md` (+1): spec 표에 spec-27-01 자동 등록 (sdd 마커 갱신)
- `backlog/queue.md` (+1/-1): active phase 요약 갱신 (sdd 마커 갱신)

**Total**: 8 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check 통과 (shellcheck 미설치로 skip — 환경 제약, staged-lint 훅 경고만)
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-27.md`
- Walkthrough: `specs/spec-27-01-adr-index-gen/walkthrough.md`
- 관련 이슈: GitHub #168 (제안 1)
- 관련 ADR: 없음
