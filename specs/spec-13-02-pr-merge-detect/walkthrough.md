# Walkthrough: spec-13-02

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 폴링 방식 | 포그라운드 루프 vs 백그라운드 데몬 | 포그라운드 루프 | 데몬은 프로세스 관리 복잡도 증가, 종료 보장 어려움 |
| gh 미설치 처리 | exit 1 + 에러 vs exit 0 + 안내 | exit 0 + 안내 | 전체 워크플로우 차단 방지, graceful degradation 원칙 |
| merge 후 동작 | sdd ship 자동 실행 vs 안내만 출력 | 안내만 출력 | 사용자 확인 없이 자동 실행은 부작용 위험 |
| PATH 조작 테스트 | 전체 PATH 교체 vs 빈 bin 앞에 추가 | no_gh_path 재구성 | bash 절대 경로 사용 + 필수 도구 포함 PATH 유지 |

## 💬 사용자 협의

- **주제**: 폴링 간격 30초 / 타임아웃 60분
  - **사용자 의견**: plan.md에서 동의 (Plan Accept)
  - **합의**: 스펙 그대로 구현

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-pr-merge-detect.sh`
- **결과**: ✅ ALL 5 CHECKS PASSED
- **로그 요약**:
```text
═══════════════════════════════════════════
 pr-watch Verification (spec-13-02)
═══════════════════════════════════════════
  ✅ 사용법 안내 출력됨
  ✅ sdd help에 pr-watch 포함
  ✅ gh 없는 환경에서 exit 0
  ✅ gh 미설치 안내 메시지 출력됨
  ✅ 두 파일 동일 (동기화됨)
═══════════════════════════════════════════
 ✅ ALL 5 CHECKS PASSED
═══════════════════════════════════════════
```

#### 전체 테스트 스위트
- **명령**: `for t in tests/test-*.sh; do bash "$t"; done`
- **결과**: FAIL=0 (22개 테스트 파일 전체 통과)

### 2. 수동 검증

- `bash sources/bin/sdd pr-watch` → 사용법 안내 출력, exit 0 확인
- `bash sources/bin/sdd help | grep pr-watch` → 항목 확인
- `PATH=/tmp/empty bash sources/bin/sdd pr-watch 1` → gh 미설치 안내 출력, exit 0 확인

## 📦 변경 파일

| 파일 | 변경 내용 |
|---|---|
| `sources/bin/sdd` | `cmd_pr_watch()` 추가, `case` 분기, help 항목 |
| `.harness-kit/bin/sdd` | sources/bin/sdd 와 동기화 |
| `tests/test-pr-merge-detect.sh` | 신규 — 5가지 시나리오 검증 |
