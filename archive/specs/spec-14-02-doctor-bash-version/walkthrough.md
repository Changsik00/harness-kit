# Walkthrough: spec-14-02

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| doctor 의 bash 요구사항 완화 방식 | A: min "3.2" / B: min 비움 / C: optional + WARN | **A** | 코드는 정확히 "3.2 이상" 호환. 정책-코드 일치가 가장 명확. C 의 WARN 다운그레이드는 "4+ 권장" 의 모호한 메시지를 남김 |
| `CLAUDE.md` 의 "bash 4.0+ 전용" 정책 처리 | A: 그대로 (정책 유지, doctor 만 완화) / B: 정책도 갱신 (3.2+) | **B** | 정책-구현 모순을 바로잡는 게 본 spec 의 목적. A 는 doctor 가 통과해도 정책상 모호함 잔존 |
| phase-14.md sdd:specs 마커가 빈 헤더로 비어있는 별건 이슈 | A: 본 spec 에서 근본 수정 / B: 수동 보정만 + 근본 진단은 spec-14-04 로 이관 | **B** | 본 spec scope 를 doctor + 정책으로 한정. 근본 원인은 sdd 의 marker_append 동작과 관련 — spec-14-04 의 marker append guard 작업과 자연스럽게 묶임 |

## 💬 사용자 협의

- **주제**: 정책 변경 동의 — `CLAUDE.md` 의 "bash 4.0+ 전용" → "bash 3.2+"
  - **사용자 의견**: Plan Accept (1) 으로 채택 → 명시적 동의로 해석
  - **합의**: 향후 정말 4+ 가 필요해지면 별도 spec 으로 정책 재변경 + shebang/설치 가이드 동반 갱신.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (본 spec 신규)
- **명령**: `bash tests/test-doctor-bash-version.sh`
- **결과**: ✅ Passed (3/3)
- **로그 요약**:
```text
▶ Check 1: sources/bin/sdd 에 bash 4.0 required 부재
  ✅ sdd 에 bash 4.x required 미사용
▶ Check 2: doctor 출력에 ❌ bash 부재
  ✅ doctor 출력에 ❌ bash 없음
▶ Check 3: doctor 의 bash 라인이 PASS/WARN
  ✅ bash 라인 = PASS (✅ bash 3.2.57)
ALL 3 CHECKS PASSED
```

#### 회귀 테스트
- `test-hk-doctor.sh` ✅ 6/6 (doctor 구조 검증)
- `test-sdd-queued-marker-removed.sh` ✅ 7/7 (spec-14-01 회귀)

### 2. 수동 검증

1. **Action**: `bash .harness-kit/bin/sdd doctor` (변경 후)
   - **Result**: 첫 화면에 `✅ bash 3.2.57` — false positive 사라짐.
2. **Action**: `grep -E "bash 4\.0\+? 전용" CLAUDE.md`
   - **Result**: 0 매치 — 정책 표현 갱신 완료.

## 🔍 발견 사항

- **`_check_tool` 의 버전 비교는 major 정수 비교**: `sdd:1387` 의 `[ "$major" -lt "$required_major" ]` — 즉 `min_ver "3.2"` 는 사실상 `major >= 3` 만 강제. macOS 기본 bash (3.2.57) 의 major 는 3 이므로 PASS. 4+ 환경도 PASS. 의도대로 동작하지만, "3.2.0 이상 vs 3.0.0" 같은 minor 차이는 잡지 못함 — 본 spec 에는 문제 없음.
- **phase-14.md 의 sdd:specs 마커 빈 헤더 이슈**: 본 spec 첫 commit 에서 spec-14-01 (Merged) + spec-14-02 (In Progress) 행을 수동 보정. `sdd ship` 이 호출됐을 때 spec 행을 Merged 로 업데이트해야 했지만 실제로는 마커 영역이 비어있었음. 근본 원인은 spec-14-04 (`sdd_marker_append` 가드) 와 함께 진단/수정.
- **`.harness-kit/bin/sdd` 도그푸딩 동기화 패턴**: install.sh 가 sources → .harness-kit 로 복사하지만, 본 프로젝트는 도그푸딩 중이라 *둘 다* 동시에 갱신해야 즉시 효과 발생. 향후 spec 마다 같은 패턴 반복 — spec-14-03 (`install.sh` 수정), spec-14-04 (`common.sh` 수정) 모두 도그푸딩 동기화 task 필요.

## 🚧 이월 항목

- 없음. spec-14-03, 04 는 phase-14 의 다음 spec 으로 진행.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-25 |
| **최종 commit** | `6d6f323` (fix: relax doctor bash requirement) |
