# Walkthrough: spec-09-012

## 📋 실제 구현된 변경사항

- [x] 버전 배지 `0.3.0` → `0.5.0`
- [x] 설치 레이아웃 트리를 `.harness-kit/` 구조로 전면 교체
- [x] CLAUDE.md 안내를 `@import` 3줄 방식으로 갱신
- [x] 구 경로 참조 일괄 교체 (`agent/`, `scripts/harness/`, `bin/sdd`)
- [x] queue.md NOW/NEXT 언급 제거, `sdd status` 실시간 계산으로 대체
- [x] 슬래시 커맨드 표에 `/hk-cleanup` 추가
- [x] install.sh 옵션에 `--no-gitignore` 추가
- [x] 명령 요약에 `cleanup.sh` 추가
- [x] sdd archive 설명 갱신 (state 초기화 + NEXT 안내)
- [x] 워크플로 다이어그램에 Post-Merge 흐름 추가

## 🧪 검증 결과

### 수동 검증

1. **Action**: `grep "scripts/harness" README.md`
   - **Result**: 0건 — 구 경로 완전 제거 확인
2. **Action**: `.harness-kit/` prefix 없는 `agent/constitution` grep
   - **Result**: 0건 — 모든 경로 갱신 확인

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + ck |
| **작성 기간** | 2026-04-16 |
| **최종 commit** | `e933e48` |
