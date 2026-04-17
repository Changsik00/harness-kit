# feat(spec-01-02): .harness-backup 보존 정책

## 📋 Summary

### 배경 및 목적
install.sh 실행마다 `.harness-backup-TIMESTAMP/` 가 무한 누적되는 문제 해결. 하루 도그푸딩에 6개(804KB) 생성. git history에 이미 이력이 있어 실효성 의문.

### 주요 변경 사항
- [x] `--no-backup` 옵션 추가 — 백업 생성을 명시적으로 건너뜀
- [x] git 워킹 트리 clean 감지 시 백업 자동 스킵 (git history가 보호)
- [x] 보존 정책: 최근 `HARNESS_BACKUP_KEEP`(기본 3)개만 유지, 나머지 자동 삭제

### Phase 컨텍스트
- **Phase**: `phase-01` (설치/운영 마찰 해소)
- **본 SPEC 의 역할**: 불필요한 백업 누적을 방지하여 디스크 낭비 및 사용자 혼란 제거

## 🎯 Key Review Points

1. **git-clean 감지**: `git status --porcelain`이 비어있으면 백업 스킵. uncommitted 변경이 있으면 무조건 백업.
2. **보존 정책**: `ls -dt`로 시간순 정렬 후 `tail -n +4`로 오래된 것 선택, `rm -rf`로 삭제.
3. **HARNESS_BACKUP_KEEP 환경변수**: 기본값 3, 사용자가 변경 가능.

## 🧪 Verification

### 수동 검증 시나리오
1. 기존 6개 백업 상태에서 install.sh 2회 실행 → 3개만 유지 ✅
2. 삭제 로그에 대상 디렉토리 이름 출력 ✅
3. install plan에 "최근 3개 유지" 표시 ✅

## 📦 Files Changed

### 🛠 Modified Files
- `install.sh` (+18, -2): --no-backup 옵션, git-clean 스킵, 보존 정책

**Total**: 1 file changed

## ✅ Definition of Done

- [x] install.sh 5회 반복 실행 후 .harness-backup-* 최대 3개
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-01.md`
- Walkthrough: `specs/spec-01-02-backup-policy/walkthrough.md`
