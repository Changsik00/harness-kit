# feat(spec-27-02): docs integrity check (`sdd doctor` 확장)

> 첫 줄은 commit subject 와 정확히 일치해야 합니다 (`type(spec-...): description`).

## 📋 Summary

### 배경 및 목적
`sdd doctor` 는 도구/설치 파일/훅 권한/wiki layer 는 점검하지만 ADR·backlog 문서 규약은 점검하지 않는다(GitHub #168). ADR 번호 중복, frontmatter 누락, 인덱스 drift(spec-27-01), 완료 phase 의 backlog 잔존을 한 번에 점검하는 "docs 무결성" 섹션을 `sdd doctor` 에 추가한다.

### 주요 변경 사항
- [x] `sdd doctor` 에 "docs 무결성" 섹션 추가 — ADR id 중복(FAIL) / frontmatter 누락(FAIL) / 인덱스 drift(WARN) / backlog 완료 phase 잔존(WARN)
- [x] `_backlog_completed_residue` 공유 헬퍼 분리 — spec-27-03(`sdd archive`)이 재사용 예정
- [x] 실 데이터 검증: 본 저장소의 phase-23~26 미아카이브 잔존을 정확히 검출

### Phase 컨텍스트
- **Phase**: `phase-27` (docs-integrity)
- **본 SPEC 의 역할**: GitHub #168 세 제안 중 두 번째. spec-27-01(`adr-index --check`)을 재사용하고, spec-27-03 이 재사용할 잔존 탐지 헬퍼를 제공.

## 🎯 Key Review Points

1. **서브셸 exit 격리**: `cmd_adr_index --check` 는 실패 시 `exit 1` 하는 top-level 커맨드 함수라, doctor 안에서 직접 호출하면 doctor 전체가 죽는다. `( cmd_adr_index --check )` 서브셸로 감싸 격리했다.
2. **잔존 탐지 헬퍼 분리**: `_backlog_completed_residue` 를 doctor 의 fail/warn 클로저 밖, top-level 함수로 뒀다 — spec-27-03 이 `cmd_archive` 에서 그대로 재사용할 수 있게.
3. **doctor 의 진단 전용 성격 유지**: 이번 4항목도 다른 기존 검사처럼 exit code 를 바꾸지 않는다 — 순수 정보 출력.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-doctor-docs-integrity.sh
bash tests/run.sh
```

**결과 요약**:
- ✅ `tests/test-doctor-docs-integrity.sh`: 5/5 통과 (clean/dup-id/no-frontmatter/index-drift/backlog-residue)
- ✅ `tests/run.sh`: 80/80 통과, FAIL 0

### 수동 검증 시나리오
1. **시나리오 1**: `sdd doctor` 실 저장소 실행 → ADR 관련 3항목 PASS, backlog 잔존 4개(phase-23~26) WARN — 실제 미아카이브 상태 정확히 반영.

## 📦 Files Changed

### 🆕 New Files
- `tests/test-doctor-docs-integrity.sh`: 신규 검사 4항목 회귀 테스트
- `specs/spec-27-02-docs-integrity-check/spec.md`, `task.md`, `walkthrough.md`, `pr_description.md`: spec 산출물

### 🛠 Modified Files
- `sources/bin/sdd` (+87): `cmd_doctor()` 확장 + `_backlog_completed_residue` 공유 헬퍼 (키트 원본, SoT)
- `.harness-kit/bin/sdd` (+87): 동일 변경 미러 (본 저장소 도그푸딩 설치본)

**Total**: 5 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check 통과 (shellcheck 미설치로 skip — 환경 제약)
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-27.md`
- Walkthrough: `specs/spec-27-02-docs-integrity-check/walkthrough.md`
- 관련 이슈: GitHub #168 (제안 2)
- 관련 spec: spec-27-01 (adr-index --check 재사용), spec-27-03 (잔존 헬퍼 재사용 예정)
- 관련 ADR: 없음
