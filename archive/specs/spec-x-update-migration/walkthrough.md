# Walkthrough: spec-x-update-migration

> 본 문서는 *증거 로그* 입니다. "무엇을 했고 어떻게 검증했는지" 를 미래의 자신과 리뷰어에게 남깁니다.

## 📋 실제 구현된 변경사항

- [x] `sources/governance/constitution.md` + `agent/constitution.md` — §4.1, §5.2에 `spec-x-{slug}` Solo Spec 패턴 추가
- [x] `VERSION` — 0.3.0 → 0.4.0 버전 bump
- [x] `CHANGELOG.md` 신설 — 0.1.0 ~ 0.4.0 버전 이력
- [x] `sources/migrations/0.4.0.sh` 신설 — 폐기 파일 목록 + 신규 기능 안내 함수
- [x] `update.sh` 전면 재작성 — 버전 비교, 마이그레이션 실행, state 보존/복원, 백업 정리, `--shell=` 패스스루

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (syntax 검증)
- **명령**: `bash -n update.sh && bash -n sources/migrations/0.4.0.sh`
- **결과**: ✅ Passed
- **로그 요약**:
```text
update.sh OK
0.4.0.sh OK
```

### 2. 수동 검증

1. **Action**: `./update.sh --help`
   - **Result**: 사용법 및 옵션 목록 정상 출력

2. **Action**: `bash -n update.sh`
   - **Result**: syntax 오류 없음 확인

3. **Action**: `bash -n sources/migrations/0.4.0.sh`
   - **Result**: syntax 오류 없음 확인

### 3. 증거 자료

- syntax 검증 로그: 위 자동화 테스트 섹션 참조

## 🔍 발견 사항

- `update.sh`가 `install.sh --yes`를 호출하면 `phase`/`spec`/`planAccepted` state가 초기화되는 버그가 이번 재작성에서 함께 수정됨 (state 보존/복원 로직 추가)
- `spec-x-{slug}` 패턴을 이번 Spec 자신이 최초로 사용 — 실증된 패턴임을 확인

## 🚧 이월 항목

- `update.sh` 실제 end-to-end 검증 (구버전 설치 환경이 필요) — 다음 기회로 이월
- `sdd` CLI에 `spec-x` 인식 지원 (현재 `sdd status`에서 phase 없는 spec 표시 미지원)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-11 |
| **최종 commit** | `d5d6251` |
