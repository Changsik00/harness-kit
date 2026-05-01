# fix(spec-14-05): phase-14 review followup — marker edge cases + bash policy headers

## 📋 Summary

### 배경 및 목적

phase-14 (정합성/멱등성 버그 일괄 수정) 의 4 spec 머지 후 phase 회고 (Opus sub-agent 비판 검증) 에서 *모두 phase-14 자체 변경의 직접 결과물 결함* 6건 발견. 한 PR 에서 정리.

| 잔재 | 출처 | 심각도 |
|---|---|---|
| **M1** `sdd_marker_append` 다중 마커 쌍에서 멱등 깨짐 | spec-14-04 | Major |
| **M2** `sdd_marker_append` 마커 부재 silent no-op | spec-14-04 | Major |
| **m1** `sdd_marker_grep` 부분 일치 false positive 위험 | spec-14-04 | Minor |
| **M3** 8 파일에 "bash 4.0+" 헤더 주석 잔존 | spec-14-02 잔재 | Major |
| **M4** `install.sh` `sed && rm` 의 set -e 비효과 | spec-14-03 | Major |
| **m2** `phase-14.md` 수동 보정 row 양식 불일치 | chore 부산물 | Minor |

### 주요 변경 사항

- [x] **M1** `sdd_marker_append` awk 보강 — `in_section` 게이트 + 첫 end 직후 `found` reset → 다중 마커 쌍 + 비대칭 영역에서 각 영역 독립 멱등
- [x] **M2** 마커 부재 사전 체크 — `grep -qF` start/end → stderr warn + return 1
- [x] **m1** `spec_new` 호출 needle 을 `\`${short_id}\`` (백틱 포함) — 부분 일치 회피
- [x] **M3** 8 파일 헤더 주석 "bash 4.0+" → "bash 3.2+" (sources/ 4 + .harness-kit/ 4)
- [x] **M4** `install.sh:418-424` `sed && rm` → `sed || die` + `rm` 별 줄
- [x] **m2** `phase-14.md` 4 row 백틱 포함 양식으로 정규화
- [x] 회귀 테스트 2건 신규 (`test-marker-edge-cases.sh` 8 검증, `test-bash-policy-headers.sh` 4 검증)

### Phase 컨텍스트

- **Phase**: `phase-14` — 정합성 / 멱등성 버그 일괄 수정 (5 spec 중 마지막, 회고 후속)
- **본 SPEC 의 역할**: 회고에서 식별된 phase 직접 결과물 결함 정리 → phase 마무리 가능 상태로
- **다음 단계**: 본 PR 머지 후 `/hk-phase-ship` 으로 phase-14 통합 시나리오 검증 + go/no-go + Phase 정리

## 🎯 Key Review Points

1. **awk 의 `in_section` 게이트 (M1)**: `$0 == s && !in_section` — 중첩 start 마커 무시. 첫 end 마커 직후 `found = 0` reset → 다음 영역에 영향 없음. A-3 (비대칭 영역) 회귀 테스트로 정확히 검증.
2. **마커 부재 사전 체크 (M2)**: `grep -qF` (fixed string) 사용. 정규식 메타 회피 + 약간의 성능 이점. 호출자 (4 곳) 가 rc=1 을 받아 분기 가능 — 그러나 본 PR 에서는 호출자 측 분기 미추가 (silent 회피만이 목표).
3. **m1 호출자 쪽 변경**: 헬퍼 (`sdd_marker_grep`) 자체는 부분 일치 유지, 호출자 (`spec_new`) 만 백틱 포함 needle. 마커 row 의 ID 가 항상 백틱이라는 *사실* 에 의존 — 그 가정을 walkthrough 에 명시.
4. **회고 메타 메모의 즉시 실천**: 본 PR 은 회고 메타 메모 #2 (정책 변경 시 헤더 grep) 를 직접 실행한 사례이자, #1 (수동 작업 반복 시 별건 처리) 의 적용 사례.

## 🧪 Verification

### 자동 테스트 (신규 2건)
```bash
bash tests/test-marker-edge-cases.sh    # 8/8
bash tests/test-bash-policy-headers.sh  # 4/4
```

**결과 요약**:
- ✅ A-1, A-2, A-3: 다중 마커 쌍 멱등 (비대칭 영역 포함)
- ✅ B-1, B-2, B-3: 마커 부재 → rc=1 + stderr
- ✅ C-1, C-2: 백틱 포함 needle 정확 매칭
- ✅ "bash 4.0+" 0 매치 (sources/ + install.sh + .harness-kit/)

### 회귀 점검 (10 스위트 모두 PASS)
```bash
# phase-14 4 spec
bash tests/test-sdd-queued-marker-removed.sh   # 7/7
bash tests/test-doctor-bash-version.sh         # 3/3
bash tests/test-gitignore-idempotent.sh        # 22/22
bash tests/test-marker-append-guard.sh         # 5/5

# sdd 핵심
bash tests/test-sdd-queue-redesign.sh          # 5/5
bash tests/test-sdd-phase-done-accuracy.sh     # 4/4
bash tests/test-sdd-spec-completeness.sh       # 4/4
bash tests/test-sdd-status-cross-check.sh      # 7/7
```

### 수동 검증
1. `grep -rn "bash 4\.0+" sources/ install.sh .harness-kit/` (templates 제외) → 0 매치
2. `phase-14.md` row 5건 모두 백틱 포함 양식
3. `bash .harness-kit/bin/sdd doctor` 정상 (회귀 — spec-14-02 효과)

## 📦 Files Changed

### 🆕 New Files
- `specs/spec-14-05-phase-review-followup/`: spec.md, plan.md, task.md, walkthrough.md, pr_description.md
- `tests/test-marker-edge-cases.sh`: 8 검증 (A 다중 쌍 3 + B 부재 3 + C 정확 매치 2)
- `tests/test-bash-policy-headers.sh`: 4 검증 (sources/, install.sh, .harness-kit/, 4.0+ 전용)

### 🛠 Modified Files
- `sources/bin/lib/common.sh`: `sdd_marker_append` awk 보강 (M1+M2)
- `sources/bin/sdd`: 헤더 주석 (M3) + spec_new needle 백틱 (m1)
- `sources/bin/bb-pr`: 헤더 주석 (M3)
- `sources/hooks/_lib.sh`: 인라인 주석 (M3)
- `install.sh`: 헤더 주석 (M3) + sed 견고화 (M4)
- `.harness-kit/bin/lib/common.sh`, `.harness-kit/bin/sdd`, `.harness-kit/bin/bb-pr`, `.harness-kit/hooks/_lib.sh`: 도그푸딩 동기화
- `backlog/queue.md`: active 갱신
- `backlog/phase-14.md`: sdd 자동 추가 + row 양식 정규화 (m2)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (12/12 신규 + 회귀 ~80건)
- [x] 회귀 테스트 통과 (10 스위트)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check — bash/markdown 만이라 해당 없음
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- Phase: `backlog/phase-14.md`
- Walkthrough: `specs/spec-14-05-phase-review-followup/walkthrough.md`
- 회고 결과: 본 conversation 중 Opus sub-agent 검증 (Major 4 + Minor 2)
