# spec-14-05: phase-14 회고 잔재 정리

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-14-05` |
| **Phase** | `phase-14` |
| **Branch** | `spec-14-05-phase-review-followup` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-25 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

phase-14 의 4 spec 모두 Merged. 정량 성공 기준 5/5 PASS. 그러나 phase 회고 (Opus sub-agent 비판 검증) 에서 다음 잔재 발견 — *모두 phase-14 자체 변경의 직접 결과물 결함*:

| ID | 출처 spec | 위치 | 심각도 |
|---|---|---|---|
| **M1** | spec-14-04 | `common.sh` `sdd_marker_append` awk 가 단일 마커 쌍 가정에 강결합 | Major |
| **M2** | spec-14-04 | `sdd_marker_append` 마커 부재 파일에서 silent no-op | Major |
| **M3** | spec-14-02 (잔여) | 8 개 파일에 "bash 4.0+" 헤더 주석 잔존 | Major |
| **M4** | spec-14-03 | `install.sh` `sed -i.tmp ... && rm -f ...` 가 `set -e` 와 결합 시 sed 실패 silent 통과 | Major |
| **m1** | spec-14-04 | `sdd_marker_grep` 의 `index()` 부분 일치 — `spec-14-01` 검색이 `spec-14-011` 매치 가능 | Minor |
| **m2** | spec-14-02/03/04 chore | `backlog/phase-14.md` 의 수동 보정 row 4건이 sdd auto-gen 양식과 불일치 (백틱 부재) | Minor |

phase-14 책임 외 잔재 (`tests/run.sh phase-N` 인프라, `docs/harness-kit-bug-01,02` archive 처리) 는 **본 spec 범위 아님** — Icebox 등록.

### 문제점

- **M1**: 같은 이름 마커 쌍이 한 파일에 2개 이상 있을 때 멱등성 깨짐. 현재 사용 패턴에선 발생 안 하지만 향후 위험. awk 의 `found` 가 첫 end 마커 후 reset 안 되고 `in_section` 게이트 부재.
- **M2**: 마커가 전혀 없는 파일에 호출 시 line 미추가 + rc=0 → 호출자가 성공으로 인식. queue.md 가 사용자에 의해 마커 통째 삭제된 경우 디버깅 단서 0.
- **M3**: spec-14-02 가 CLAUDE.md / doctor 만 갱신했고 코드 헤더 주석은 그대로. `grep -rn "bash 4\.0+" sources/ install.sh .harness-kit/` → 8건. 정책-코드 mismatch 부분 미해결.
- **M4**: bash 의 `cmd1 && cmd2` 는 compound command 라 cmd1 실패 시 `set -e` abort 안 함. sed 실패 시 `.gitignore.tmp` 잔재 + 토글 안 된 상태로 install 계속.
- **m1**: 현재 zero-padding 정책 (`spec-NN-NN`) 하에선 false positive 불가, 향후 위험. spec_new 처럼 *분기 결정* 호출자에선 부분 일치가 곧 silent 데이터 실수.
- **m2**: spec-14-02/03/04 시작 시 phase-14.md 수동 보정으로 추가된 row 4건이 sdd auto-gen 양식 (`` `spec-14-NN` ``) 과 다름 (백틱 부재). 한 표 안에 두 양식 공존.

### 해결 방안 (요약)

phase-14 회고에서 식별한 *직접 결과물 결함* 6건을 한 PR 에서 정리:

1. **M1**: `sdd_marker_append` awk 보강 — `in_section` 게이트 + 첫 end 마커에서 reset
2. **M2**: `sdd_marker_append` 가 마커 부재 시 stderr warn + non-zero exit
3. **M3**: 8 개 파일의 "bash 4.0+" 헤더 주석을 "bash 3.2+" 로 일괄 갱신
4. **M4**: `install.sh` 의 `sed && rm` 조합에 `|| die` 추가
5. **m1**: `spec_new` 의 `sdd_marker_grep` 호출 needle 을 정확 토큰 매칭으로 — 마커 row 가 백틱+파이프 패턴이므로 `\`${short_id}\`` 매칭으로 호출 사이트 변경
6. **m2**: `backlog/phase-14.md` 수동 보정 row 4건을 sdd auto-gen 양식으로 정규화

회고의 메타 메모 5건은 walkthrough.md 에 기록되며, 본 spec 의 *행위* 가 그 메모에 부합:
- "정책 변경 시 헤더까지 grep" → M3 처리가 직접 실천
- "수동 작업 반복 시 별건 처리" → 본 spec 자체가 그 적용 (회고 후 즉시 spec 추가)
- "silent no-op → warn" → M2 처리가 직접 실천

## 🎯 요구사항

### Functional Requirements

1. **M1 fix**: `sdd_marker_append` awk 패턴이 다중 마커 쌍 (같은 이름 2 쌍) 환경에서 동일 라인 호출 시 정확히 1줄. 단위 테스트로 검증.
2. **M2 fix**: 마커 부재 파일 호출 시 stderr 에 명확한 메시지 + rc 1. 호출자가 실패 신호를 받도록.
3. **M3 fix**: `grep -rn "bash 4\.0+" sources/ install.sh .harness-kit/` → 0 매치. 8 개 파일 (sources/ + .harness-kit/) 의 헤더 주석에서 "bash 4.0+" 표현 제거 또는 "bash 3.2+" 로 정확화.
4. **M4 fix**: `install.sh:419, 422` 의 `sed -i.tmp ... && rm -f ...` 패턴에 `|| die` 또는 동등한 실패 처리 추가.
5. **m1 fix**: `spec_new` 의 `sdd_marker_grep` 호출이 정확 토큰 매칭 — 회귀 테스트에서 phase 본문 텍스트가 `spec-14-01` 매치, 마커 안엔 `spec-14-011` 만 있을 때 `spec-14-01` 검색이 false 반환.
6. **m2 fix**: `backlog/phase-14.md` 의 sdd:specs 마커 안 row 4건 (spec-14-01 ~ 04) 을 sdd auto-gen 양식 (`| \`spec-14-XX\` | ... |`) 으로 정규화.
7. **회귀 테스트 추가** — `tests/test-marker-edge-cases.sh`:
   - A: 다중 마커 쌍에서 sdd_marker_append 멱등 (M1)
   - B: 마커 부재 파일 호출 시 stderr + rc=1 (M2)
   - C: sdd_marker_grep 정확 매치 — `spec-14-01` 이 `spec-14-011` 에 false positive 안 발생 (m1)
8. **회귀 테스트 추가** — `tests/test-bash-policy-headers.sh`:
   - "bash 4.0+" / "bash 4.0 전용" 표현이 sources/, install.sh, .harness-kit/ 에 0 매치 (M3 lint)

### Non-Functional Requirements

1. **하위 호환**: M1/M2 변경은 기존 정상 케이스 (단일 마커 쌍, 마커 존재) 영향 없음. 기존 회귀 테스트 (52 건) PASS 유지.
2. **bash 3.2 호환** (spec-14-02 정책): awk POSIX, sed BSD 호환만 사용.
3. **PR 응집성**: 6 변경 모두 *phase-14 회고 잔재* 라는 단일 주제. 한 PR 의 task 단위로 분리.

## 🚫 Out of Scope

- `tests/run.sh phase-N` 인프라 신설 — phase 템플릿 boilerplate 잔재. Icebox.
- `docs/harness-kit-bug-01,02` archive 처리 — phase-14 직접 결과물 아님. Icebox.
- `sdd_marker_append` 의 *모든* awk 헬퍼 (replace, update_row) 검증 — M1/M2 는 append 한정.
- 다른 곳의 grep 영역 미한정 점검 (`sdd:859, 941` 등) — 회고 메타 메모 #3 (새 헬퍼 1+ 호출자 검토) 에 기록만, 별도 phase 후보.
- 회고 메타 메모를 governance 문서 (`constitution.md`, `agent.md`) 에 반영 — Icebox.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = no 이므로 해당 사항 없음)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-14-05-phase-review-followup` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
