# fix(spec-14-04): make marker_append idempotent + scope spec_new grep to marker area

## 📋 Summary

### 배경 및 목적

phase-14 (정합성/멱등성 버그 일괄 수정) 의 마지막 spec. sdd 의 마커 처리 두 가지 정합성 버그를 한꺼번에 해결한다.

**버그 #1 — `sdd_marker_append()` 멱등 가드 부재** (원래 scope):
- 같은 라인을 두 번 호출하면 그대로 두 번 들어감.
- 4 호출 지점 (`queue_mark_done`, `spec_new`, `specx_new`, `specx_done`) 모두 잠재 중복 위험.
- 특히 `sdd specx done <slug>` 두 번 호출 시 즉시 재현됨.

**버그 #2 — `spec_new()` 의 grep 영역 미한정** (확장 scope, 본 spec 진행 중 발견):
- `grep -q "${short_id}" "$phase_file"` 가 *파일 전체* 검색.
- phase-N.md 본문 (설명 섹션) 에 spec ID 텍스트가 있으면 매치 → `sdd_marker_update_row` (no-op) 호출.
- 결과: spec 행이 마커 안에 영영 추가 안 됨. 본 phase 진행 중 spec-14-02, 03, 04 시작 시 매번 수동 보정 필요했던 직접 원인.

### 주요 변경 사항

- [x] `sources/bin/lib/common.sh:80` `sdd_marker_append` awk 본문에 in-marker 동일 라인 검사 추가
- [x] `sources/bin/lib/common.sh` `sdd_marker_grep(file, name, needle)` 신규 헬퍼 — 마커 내부 검색
- [x] `sources/bin/sdd:745` `grep -q` → `sdd_marker_grep` 1줄 교체
- [x] `.harness-kit/bin/lib/common.sh`, `.harness-kit/bin/sdd` 도그푸딩 동기화
- [x] 회귀 테스트 `tests/test-marker-append-guard.sh` 추가 — A(단위 2건) + B/C/D(통합 3건)
- [x] phase-14.md sdd:specs 마커에 spec-14-04 행 수동 보정 (본 PR 머지 후 자동 동기화 자가 회복)

### Phase 컨텍스트

- **Phase**: `phase-14` — 정합성 / 멱등성 버그 일괄 수정 (4 spec 중 마지막)
- **본 SPEC 의 역할**: sdd 마커의 자동 동기화 신뢰성 회복. 도그푸딩 중 "phase.md 가 안 갱신된다" 잔재의 근본 수정.
- **다음 단계**: phase-14 머지 후 `/hk-phase-ship` 으로 phase 통합 시나리오 4 건 검증 + go/no-go.

## 🎯 Key Review Points

1. **`sdd_marker_append` awk 변경의 회귀 위험**: 4 호출 지점 모두 의도가 "유일한 라인 추가". 정상 케이스 (다른 라인 추가) 는 영향 없음 — A-2 회귀 테스트로 확인.
2. **`sdd_marker_grep` 의 컨벤션**: `sdd_marker_replace` / `sdd_marker_update_row` 와 같은 awk 패턴 (start/end 비교, `in_section` 플래그). 4 마커 헬퍼가 일관된 통일.
3. **scope 확장 결정**: 원래 plan 은 가드만이었으나 spec 작성 중 grep 버그 발견 → plan 단계에서 사용자에게 명시적 동의 후 통합. constitution §5.5 (Idea Capture Gate) 와 §7.2 (Delegation Limits) 회색지대로, 같은 종류 + plan 단계 + 작은 LOC 라 통합이 합리적이었음.
4. **도그푸딩의 자가 검증**: 본 PR 의 회귀 케이스가 phase-14 진행 중 매번 발생한 phase.md sync 잔재 그 자체. 본 PR 머지 후 다음 phase 의 첫 spec 시작 시 자가 검증.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-marker-append-guard.sh
```

**결과 요약**:
- ✅ A-1: `sdd_marker_append` 같은 라인 두 번 → 1줄
- ✅ A-2: 다른 라인 추가 — 둘 다 보존 (회귀 점검)
- ✅ B: `sdd specx done <slug>` 두 번 → done 섹션 1줄
- ✅ C: `sdd phase done` 동일 phase 두 번 → done 섹션 1줄
- ✅ D: phase 본문 텍스트 매치 회피 — 마커 안 spec 행 정확히 1줄
- ✅ ALL 5 CHECKS PASSED

### 회귀 점검
```bash
bash tests/test-sdd-queue-redesign.sh           # 5/5 PASS
bash tests/test-sdd-phase-done-accuracy.sh      # 4/4 PASS
bash tests/test-sdd-spec-completeness.sh        # 4/4 PASS
bash tests/test-sdd-status-cross-check.sh       # 7/7 PASS
bash tests/test-sdd-queued-marker-removed.sh    # 7/7 PASS (spec-14-01)
bash tests/test-doctor-bash-version.sh          # 3/3 PASS (spec-14-02)
bash tests/test-gitignore-idempotent.sh         # 22/22 PASS (spec-14-03)
```

### 수동 검증 시나리오
1. 본 spec 작성 시 `sdd spec new marker-append-guard` 결과 — phase-14.md 마커에 행 부재 확인 (예상된 회귀 재현)
2. 본 PR 머지 후 다음 phase 첫 spec 시작 시 phase.md 자동 sync 여부 — 자가 검증

## 📦 Files Changed

### 🆕 New Files
- `specs/spec-14-04-marker-append-guard/`: spec.md, plan.md, task.md, walkthrough.md, pr_description.md
- `tests/test-marker-append-guard.sh`: 5 검증 (A 단위 + B/C/D 통합)

### 🛠 Modified Files
- `sources/bin/lib/common.sh`: `sdd_marker_append` awk 가드 + `sdd_marker_grep` 신규
- `sources/bin/sdd`: `spec_new` 의 grep → sdd_marker_grep
- `.harness-kit/bin/lib/common.sh`, `.harness-kit/bin/sdd`: 도그푸딩 동기화
- `backlog/queue.md`: active 갱신
- `backlog/phase-14.md`: sdd:specs 마커 spec-14-04 행 수동 보정

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (5/5)
- [x] 회귀 테스트 통과 (52건 모두 PASS — 본 phase 4 spec + sdd 핵심 4 회귀)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check — 본 spec 은 bash/markdown 만이라 해당 없음
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- Phase: `backlog/phase-14.md`
- Walkthrough: `specs/spec-14-04-marker-append-guard/walkthrough.md`
