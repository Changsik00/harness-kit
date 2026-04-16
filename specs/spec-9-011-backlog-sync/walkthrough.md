# Walkthrough: spec-9-011

## 📋 실제 구현된 변경사항

- [x] `cmd_archive` awk 패턴에 `| Active |` 추가 → `| Merged |` 전이 지원
- [x] `cmd_archive` 후 state.json 초기화 (`spec=null`, `planAccepted=false`)
- [x] `cmd_archive` 후 `queue_set_active_progress` 호출로 queue.md active 섹션 갱신
- [x] `cmd_archive` 완료 메시지에 `compute_next_spec` 기반 NEXT 안내 출력
- [x] `queue_set_active_progress` 미사용 변수 (`merged`, `next_spec`) 제거
- [x] queue.md 템플릿에서 NOW/NEXT dead code 마커 섹션 제거
- [x] agent.md §6.3.1 Post-Merge Protocol 추가
- [x] 테스트 파일 경로를 새 레이아웃(`.harness-kit/`)으로 마이그레이션
- [x] Active → Merged, state 초기화, NEXT 안내 테스트 케이스 추가

## 🧪 검증 결과

### 1. 자동화 테스트

#### 통합 테스트
- **명령**: `bash tests/test-sdd-archive-completion.sh`
- **결과**: ✅ Passed (6/6)
- **로그 요약**:
```text
Check 1: sdd archive → phase.md In Progress → Merged  ✅ PASS
Check 2: sdd archive → phase.md Active → Merged  ✅ PASS
Check 3: sdd archive 후 state.json 초기화  ✅ PASS
Check 4: 모든 spec Merged → phase done 유도 메시지  ✅ PASS
Check 5: 잔여 Backlog → NEXT 안내 출력  ✅ PASS
Check 6: sdd specx done → queue.md specx→done 이동  ✅ PASS
```

### 2. 수동 검증

1. **Action**: `grep -r "sdd:now\|sdd:next" sources/templates/ .harness-kit/agent/templates/`
   - **Result**: 0건 — dead code 완전 제거 확인

## 🔍 발견 사항

- `test-sdd-base-branch.sh`, `test-sdd-queue-redesign.sh`도 구 경로(`scripts/harness/bin/sdd`) 참조로 실패 중 (본 spec 범위 외)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + ck |
| **작성 기간** | 2026-04-16 |
| **최종 commit** | `9eaaae8` |
