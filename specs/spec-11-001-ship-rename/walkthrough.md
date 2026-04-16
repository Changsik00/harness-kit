# Walkthrough: spec-11-001

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 새 명령 이름 | `ship` / `finalize` / `complete` | `ship` | Icebox에서 이미 "ship/finalize"로 논의됨. "ship"이 가장 짧고 직관적 |
| deprecated 경로 동작 | 경고만 / 경고+실행 / 차단 | 경고+실행 | 기존 스크립트·습관이 즉시 깨지지 않도록 전환기간 확보 |
| 커밋 메시지 변경 | `archive walkthrough` → `ship walkthrough` | 변경 | 새 명명과 일관성 유지, 기존 히스토리는 그대로 보존 |

## 💬 사용자 협의

- **주제**: `sdd archive` 리네이밍 방향
  - **사용자 의견**: Icebox에 기록된 대로 리네이밍 필요. spec-11-003에서 `archive` 이름을 디렉토리 아카이브 기능으로 재사용할 것
  - **합의**: `sdd ship`으로 변경, deprecated 경로 유지

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (ship 완료 흐름)
- **명령**: `bash tests/test-sdd-ship-completion.sh`
- **결과**: 8/8 PASS
- **로그 요약**:
```text
Check 1: sdd ship → In Progress → Merged ✅
Check 2: sdd ship → Active → Merged ✅
Check 2b: sdd ship → Done → Merged ✅
Check 3: state.json 초기화 ✅
Check 4: phase done 유도 메시지 ✅
Check 5: NEXT spec 안내 ✅
Check 6: specx done 이동 ✅
Check 7: deprecated 경고 + 정상 동작 ✅
```

#### 통합 테스트 (phase-done-accuracy)
- **명령**: `bash tests/test-sdd-phase-done-accuracy.sh`
- **결과**: 4/4 PASS

## 🔍 발견 사항

- `sdd archive` 참조가 거버넌스·템플릿·커맨드·테스트·문서에 걸쳐 ~31곳에 분포 — 향후 명령 리네이밍은 영향 범위를 먼저 grep으로 전수 파악하는 것이 필수
- `tests/test-sdd-phase-done-accuracy.sh`는 내부에서 `sdd archive`를 호출하는데, deprecated 경로 덕에 변경 없이 통과함 — 차후 해당 테스트도 `sdd ship`으로 갱신하면 좋음

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-16 |
| **최종 commit** | `52ca80d` |
