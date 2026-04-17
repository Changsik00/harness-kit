# Walkthrough: spec-01-02

## 📋 실제 구현된 변경사항

- [x] `--no-backup` 옵션 추가 (인자 파싱 + 백업 섹션 분기)
- [x] git 워킹 트리 clean 감지 시 백업 자동 스킵
- [x] 보존 정책: 백업 후 최근 `HARNESS_BACKUP_KEEP`(기본 3)개만 유지, 나머지 자동 삭제
- [x] install plan 출력에 백업 모드 표시 개선
- [x] `local` 키워드 버그 수정 (함수 밖에서 사용 불가)

## 🧪 검증 결과

### 1. 수동 검증

1. **Action**: install.sh를 2회 반복 실행 (기존 6개 백업 상태에서)
   - **Result**: 오래된 5개 삭제, 최근 3개만 유지 확인. 삭제 로그 정상 출력.

2. **Action**: `ls -dt .harness-backup-*` 로 최종 확인
   - **Result**: 3개만 존재 (.harness-backup-20260410-141202, -141151, -130103)

3. **Action**: install plan 출력 확인
   - **Result**: "백업: 있음 (.harness-backup-TIMESTAMP/, 최근 3개 유지)" 정상 표시

## 🔍 발견 사항

- install.sh가 함수가 아닌 스크립트 본문에서 `local` 키워드를 사용하면 bash 에러 발생. 도그푸딩으로 즉시 발견하여 수정.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-10 |
| **최종 commit** | `1601bd3` |
