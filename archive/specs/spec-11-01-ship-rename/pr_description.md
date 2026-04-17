# refactor(spec-11-01): sdd archive → sdd ship 리네이밍

## 📋 Summary

### 배경 및 목적
`sdd archive` 명령은 실제로 "spec 완료 처리 + 상태 전이 + 커밋"을 수행하지만 이름이 동작과 괴리가 있었다. phase-11에서 디렉토리 아카이브 기능을 도입하기 위해 `archive` 이름을 해방할 필요가 있었다.

### 주요 변경 사항
- [x] `sdd archive` → `sdd ship` 리네이밍 (함수, dispatch, help)
- [x] `sdd archive` 호출 시 deprecation 경고 + 정상 동작 (하위 호환)
- [x] 거버넌스·템플릿·슬래시 커맨드·문서 전면 갱신 (25개 파일)
- [x] 테스트 리네이밍 + deprecated 경로 테스트 추가 (8/8 PASS)

### Phase 컨텍스트
- **Phase**: `phase-11` — 식별자 체계 개선 및 디렉토리 아카이브
- **본 SPEC의 역할**: 네이밍 충돌을 선제 해소하여 spec-11-03(디렉토리 아카이브)에서 `archive` 이름을 자유롭게 사용 가능하게 함

## 🎯 Key Review Points

1. **deprecated 경로**: `sdd archive` 호출이 stderr 경고 후 정상 실행되는지 — `tests/test-sdd-ship-completion.sh` Check 7
2. **전수 참조 갱신**: 25개 파일에 걸친 rename이 누락 없이 되었는지 — `grep -r "sdd archive"` 결과에 deprecated 안내만 남아야 함

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-ship-completion.sh     # 8/8 PASS
bash tests/test-sdd-phase-done-accuracy.sh # 4/4 PASS
```

### 수동 검증 시나리오
1. `sdd help` → `ship` 명령 표시, `archive` deprecated 표기 확인
2. `sdd ship --check` → 기존 동작과 동일
3. `sdd archive` → stderr에 deprecation 경고 출력 후 정상 실행

## 📦 Files Changed

### 🛠 Modified Files
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: cmd_archive → cmd_ship, dispatch, help, 커밋 메시지
- `sources/governance/`: constitution.md, agent.md — `sdd archive` → `sdd ship`
- `sources/templates/`: 6개 파일 — archive → ship 참조
- `sources/commands/hk-ship.md` / `.claude/commands/hk-ship.md`: sdd archive → sdd ship
- `docs/REFERENCE.md`, `docs/USAGE.md`, `README.md`, `CHANGELOG.md`
- `backlog/queue.md`: Icebox 리네이밍 항목 제거 + 사용법 테이블 갱신
- `.harness-kit/agent/`: 거버넌스·템플릿 도그푸딩 동기화
- `tests/test-sdd-archive-completion.sh` → `tests/test-sdd-ship-completion.sh`

**Total**: 25 files changed (+146, -101)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (8/8)
- [x] 통합 테스트 통과 (4/4)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-11.md`
- Walkthrough: `specs/spec-11-01-ship-rename/walkthrough.md`
