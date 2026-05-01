# Walkthrough: spec-14-05

> 본 spec 은 phase-14 의 *회고 후속 작업*. 회고에서 발견된 직접 결과물 결함 6건을 한 PR 에 정리.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 회고 잔재 처리 단위 | A: 한 spec 에 통합 / B: 잔재별 spec 분리 | **A** | 모두 phase-14 직접 결과물 결함 + LOC 작음 + phase 마무리 단계 — 단일 PR 의 응집성 |
| `sdd_marker_append` 멱등의 awk 패턴 | A: `in_section` 게이트 + 첫 end 직후 `found` reset / B: 별도 grep 사전 체크 후 awk | **A** | 한 패스 awk — 파일 두 번 읽지 않음. 다른 마커 헬퍼와 일관 |
| 마커 부재 silent → warn 의 종료 코드 | A: rc=1 + stderr / B: die (exit 1, 호출자 abort) / C: 0 + stderr only | **A** | 4 호출자 (queue_mark_done 등) 가 ship/done 단계 — 호출자가 분기 가능. die 는 너무 강함. silent only 회피 |
| m1 정확 토큰 매칭 위치 | A: spec_new 호출 needle 변경 / B: sdd_marker_grep 자체에 정확 매칭 옵션 추가 | **A** | 호출자별 의미 다름. 헬퍼 시그니처 안정 유지. 마커 row 의 ID 가 항상 백틱이라는 사실에 의존 |
| 헤더 주석 갱신 (M3) 의 표현 | A: "bash 3.2+" / B: "bash 3.2+ 호환" / 표시 위치별 다름 | A+B 혼용 | 헤더 단독 주석은 "3.2+" 간결, common.sh 같은 정책 문구는 "3.2+ 호환 (4+ 미사용)" 부연 |

## 💬 사용자 협의

- **주제 1**: phase 회고 결과 처리 방식
  - **사용자 의견**: "해당 phase 에서 발생한건 spec 을 추가해서 해당 phase 에서 처리"
  - **합의**: phase-14 안에 spec-14-05 추가. phase-14 책임 외 잔재 (tests/run.sh, docs/bug-01,02 archive) 는 Icebox.

- **주제 2**: 6 변경 한 PR 통합
  - **사용자 의견**: Plan Accept (1) — 명시적 동의
  - **합의**: 응집성 (모두 phase-14 회고 잔재) 으로 한 PR. task 단위로 분리 commit.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (본 spec 신규 2건)
- **`test-marker-edge-cases.sh`**: ✅ 8/8 PASS
  - A-1, A-2: 다중 마커 쌍 + 동일 라인 / 다른 라인
  - **A-3: 비대칭 영역 (M1 핵심 케이스)** — 첫 영역만 라인 있을 때 둘째 영역에도 추가
  - B-1, B-2, B-3: 마커 부재 → rc=1 + line 미추가 + stderr 메시지 (M2)
  - C-1, C-2: 백틱 포함 needle 의 정확 토큰 매칭 (m1)
- **`test-bash-policy-headers.sh`**: ✅ 4/4 PASS
  - sources/, install.sh, .harness-kit/ 모든 영역에 "bash 4.0+" 0 매치 (M3)

#### 회귀 테스트 (모두 PASS)
- phase-14 4 spec: queued-marker (7/7), doctor-bash (3/3), gitignore-idempotent (22/22), marker-append-guard (5/5)
- sdd 핵심: queue-redesign (5/5), phase-done-accuracy (4/4), spec-completeness (4/4), status-cross-check (7/7)
- **총 10 스위트, 약 80건 검증 모두 PASS**

### 2. 수동 검증

1. **Action**: `grep -rn "bash 4\.0+" sources/ install.sh .harness-kit/` (templates 제외)
   - **Result**: 0 매치 (M3 완료)
2. **Action**: phase-14.md 의 row 양식
   - **Result**: 5 row 모두 `` `spec-14-XX` `` 백틱 포함 양식으로 통일 (m2 완료)

## 🔍 발견 사항

- **TDD Red 단계의 "우연한 PASS" 발견** — A-1/A-2 가 우연히 PASS 였음 (fixture 가 두 영역 모두 비어있어 multi-marker 의 진짜 위험 케이스를 못 잡음). A-3 (비대칭) 추가 후에야 진짜 회귀 케이스 표면화. **TDD Red 가 "fail 이 의도대로 fail 인지" 확인하는 단계라는 점 재확인**.
- **m1 의 정확 매칭이 헬퍼가 아닌 호출자 쪽 변경** — `sdd_marker_grep` 자체는 부분 일치(`index()`) 유지. 호출자 (`spec_new`) 가 needle 에 백틱 포함하여 정확 토큰 매칭 효과 달성. **헬퍼 안정성 vs 호출자 의미** 의 trade-off 에서 호출자 변경 채택 — 헬퍼는 일반성 유지, 의미는 호출자가 책임.
- **회고 메모의 즉시 실천** — 회고에서 식별한 메타 메모 5건이 본 spec 의 행위로 구체화:
  - "정책 변경 시 헤더까지 grep" → M3 처리 (8 파일)
  - "수동 작업 반복 시 별건 처리" → 본 spec 자체가 그 적용
  - "silent no-op → warn" → M2 처리
- **`grep -qF` (fixed string) 채택** — 마커 부재 사전 체크에서 정규식 메타 회피 + 약간 빠름. ERE 가 필요 없는 케이스에 일관 적용 후보.

## 🚧 이월 항목 (Icebox)

- `tests/run.sh phase-N` 인프라 부재 — phase 템플릿 boilerplate 정리 (별 phase 후보)
- `docs/harness-kit-bug-01,02.md` archive 처리
- 다른 grep 영역 미한정 점검 (`sdd:859, 941`)
- 회고 메타 메모 5건의 governance 문서 (constitution / agent.md) 반영

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-25 ~ 2026-04-26 |
| **최종 commit** | `69ad1fd` (chore: normalize phase-14.md spec rows) |
