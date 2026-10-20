# feat(spec-28-02): add source-copy drift check to doctor and status

## 📋 Summary

### 배경 및 목적
키트 원본(`sources/`)과 도그푸딩 사본(`.harness-kit/`, `.claude/commands/`)의 불일치는 일부 테스트가 우연히 잡을 뿐 정식 검사가 없었다 (#231 의 `config models` 수정이 사본에 반영 안 된 채였음). `sdd doctor` / `sdd status` 가 불일치를 알리게 한다.

### 주요 변경 사항
- [x] `_source_sync_report` 헬퍼: bin(+lib)/hooks/governance/templates/commands 의 원본 파일을 사본과 `cmp -s` 비교. 다르거나 사본에 없으면 drift (최대 5개 표시)
- [x] `sdd doctor` 에 `원본↔사본 일치` / drift 경고 항목 추가
- [x] `sdd status` 🔍 진단에 `💡` 한 줄
- [x] 다운스트림(`sources/` 없음)에서는 침묵, 경고만(exit 0)
- [x] 도그푸딩 사본 `.harness-kit/bin/sdd` 동기화

### Phase 컨텍스트
- **Phase**: `phase-28` (docs-freshness)
- **본 SPEC 의 역할**: 성공 기준 2 (drift 검사가 불일치 fixture 감지·일치 fixture 침묵, 본 저장소 0건) 달성

## 🎯 Key Review Points

1. **원본 기준 순회**: 사본에만 있는 파일은 무시 (설치 부산물).
2. **제외 목록 없음**: 매핑 대상은 바이트 동일해야 하는 파일뿐 (`settings.json`·`CLAUDE.md` 등 머지 산출물은 매핑 제외).
3. **활성 조건**: `sources/bin/sdd` 와 사본이 모두 있을 때만 동작.

## 🧪 Verification

```bash
bash tests/test-source-sync-drift.sh
bash tests/run.sh
```

- ✅ `test-source-sync-drift`: 6 케이스 (불일치, 일치 침묵, 사본 누락, 사본 단독 무시, 다운스트림 침묵, status 표시)
- ✅ `tests/run.sh`: PASS 83 / FAIL 0
- 수동: 본 저장소 doctor 일치 확인, 사본 변조 시 경고 확인 후 복구

## 📦 Files Changed

### 🆕 New Files
- `tests/test-source-sync-drift.sh`
- `specs/spec-28-02-source-sync-drift/*`

### 🛠 Modified Files
- `sources/bin/sdd`: `_source_sync_report`, doctor 항목, status 진단
- `.harness-kit/bin/sdd`: 사본 동기화
- `backlog/phase-28.md`, `backlog/queue.md`: spec 표 갱신

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [ ] lint / type check 통과 — shellcheck 미설치로 Shell lint 건너뜀
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-28.md`
- Walkthrough: `specs/spec-28-02-source-sync-drift/walkthrough.md`
- 관련: spec-28-01 (공유 헬퍼 패턴)
