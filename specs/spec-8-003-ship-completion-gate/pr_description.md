# feat(spec-8-003): add completion gate to sdd archive and spec-x done flow

## 📋 Summary

### 배경 및 목적

`sdd archive` 성공 후 phase.md의 spec 상태가 수동 갱신에 의존하여 backlog stale의 근본 원인이 됨. 또한 모든 spec이 완료되어도 phase done을 유도하는 메커니즘이 없었고, spec-x 완료 시 queue.md 갱신이 표준화되어 있지 않았음.

### 주요 변경 사항
- [x] `sdd archive` — archive commit 후 phase.md spec 상태를 자동으로 `Merged`로 갱신
- [x] `sdd archive` — 모든 spec이 Merged이면 `sdd phase done` 유도 메시지 출력
- [x] `sdd specx done <slug>` — 신규 명령: queue.md specx 섹션에서 항목 제거 → done 섹션 이동
- [x] `hk-ship` Step 6 — spec-x 완료 시 `sdd specx done` 호출 명세 추가

### Phase 컨텍스트
- **Phase**: `phase-8`
- **본 SPEC 의 역할**: backlog stale 근본 원인 차단 — archive가 상태 갱신을 자동 수행하여 수동 단계 제거

## 🎯 Key Review Points

1. **phase.md 파싱**: `awk`로 spec ID 기준 정확한 행에서만 `In Progress` → `Merged` 교체. 다른 행 영향 없음.
2. **phase done 유도 판단**: `compute_next_spec()`과 동일한 파싱 패턴으로 Backlog/In Progress 행 유무 확인. 0행이면 유도.
3. **specx_done 마커 기반 교체**: `sdd_marker_append`를 재사용하여 done 섹션에 항목 추가. specx 섹션에서는 awk로 slug 매칭 행만 제거.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-archive-completion.sh
```

**결과 요약**:
- ✅ Check 1: archive → phase.md `In Progress` → `Merged`
- ✅ Check 2: 모든 spec Merged → phase done 유도 메시지
- ✅ Check 3: 잔여 Backlog → 유도 메시지 없음
- ✅ Check 4: `sdd specx done` → queue.md specx→done 이동

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-archive-completion.sh`: 4종 단위 테스트

### 🛠 Modified Files
- `scripts/harness/bin/sdd`: cmd_archive 확장 + _check_phase_all_merged + cmd_specx/specx_done
- `sources/bin/sdd`: 위와 동일 동기화
- `sources/commands/hk-ship.md`: Step 6 spec-x queue 갱신 명세

**Total**: 4 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (4/4)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-8.md`
- Spec: `specs/spec-8-003-ship-completion-gate/spec.md`
- Walkthrough: `specs/spec-8-003-ship-completion-gate/walkthrough.md`
