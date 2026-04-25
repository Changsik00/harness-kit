# fix(spec-14-02): relax doctor bash requirement to match actual code support

## 📋 Summary

### 배경 및 목적

`sdd doctor` 가 bash 4.0+ 를 required 로 검사하지만, 코드베이스에 bash 4+ 전용 기능 (`declare -A`, `mapfile`, globstar, `${var,,}`, `coproc` 등) 은 0건. macOS 기본 bash 3.2 에서 모든 sdd 명령이 정상 동작함에도 onboarding 첫 화면이 ❌ FAIL — false positive (Bug #02).

또한 `CLAUDE.md` 가 "bash 4.0+ 전용" 으로 명시하여 정책-코드 모순을 야기. 본 PR 은 doctor 의 요구사항과 정책을 모두 실제 코드 호환 범위 ("bash 3.2+") 로 정확화한다.

### 주요 변경 사항

- [x] `sources/bin/sdd:1427` 의 `_check_tool "bash" "4.0" "required"` → `"3.2"` + 힌트 문구 완화
- [x] `.harness-kit/bin/sdd` 도그푸딩 동기화
- [x] `CLAUDE.md` "필수 도구" 행: `bash 4.0+` → `bash 3.2+` (부연: macOS 기본 3.2.57 으로도 동작)
- [x] `CLAUDE.md` 작업 원칙 §3: "bash 4.0+ 전용" → "bash 3.2+ 호환" + 4+ 전용 기능 사용 금지 목록 명시
- [x] 회귀 테스트 `tests/test-doctor-bash-version.sh` 추가 — 향후 무심코 4.0 복귀 시 즉시 감지
- [x] phase-14.md sdd:specs 마커 수동 보정 (spec-14-01 Merged + spec-14-02 In Progress)
- [x] phase-14 의 본 PR 근거 자료 (`docs/harness-kit-bug-02-...md`) 포함

### Phase 컨텍스트

- **Phase**: `phase-14` — 정합성 / 멱등성 버그 일괄 수정 (4 spec 중 두 번째)
- **본 SPEC 의 역할**: doctor false positive 제거로 onboarding UX 회복 + 정책-코드 일치.

## 🎯 Key Review Points

1. **정책 변화의 의미**: "bash 4.0+ 전용" → "bash 3.2+ 호환" 은 *표현 변화* 이지 코드 동작 변화는 0 — homebrew bash 4+ 환경은 영향 없음.
2. **버전 체크 로직**: `_check_tool` 의 `-lt` major 비교 (`sdd:1387`). `min_ver "3.2"` 는 사실상 `major >= 3` — bash 3.x / 4.x / 5.x 모두 PASS. 의도대로 동작.
3. **도그푸딩 동기화**: `sources/bin/sdd` 와 `.harness-kit/bin/sdd` 두 파일 동시 갱신 필요. install.sh 의 sources → .harness-kit 복사 구조 때문 — spec-14 후속 spec (03, 04) 도 같은 패턴.
4. **phase-14.md specs 마커 보정**: 별건 sdd 마커 동기화 누락 이슈 — 근본 원인은 spec-14-04 (`sdd_marker_append` 가드) 에서 다룸. 본 PR 에서는 산물 정리만.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-doctor-bash-version.sh
```

**결과 요약**:
- ✅ Check 1 (lint): sources/bin/sdd 에 bash 4.x required 미사용
- ✅ Check 2 (실행): doctor 출력에 ❌ bash 없음
- ✅ Check 3 (실행): bash 라인 = PASS (`✅ bash 3.2.57`)
- ✅ ALL 3 CHECKS PASSED

### 회귀 점검
```bash
bash tests/test-hk-doctor.sh                # 6/6 PASS
bash tests/test-sdd-queued-marker-removed.sh # 7/7 PASS
```

### 수동 검증 시나리오
1. `bash .harness-kit/bin/sdd doctor` → 첫 화면 `✅ bash 3.2.57` (false positive 사라짐)
2. `grep -E "bash 4\.0\+? 전용" CLAUDE.md` → 0 매치 (정책 표현 갱신 완료)

## 📦 Files Changed

### 🆕 New Files
- `docs/harness-kit-bug-02-doctor-bash-version-false-positive.md`: 본 PR 의 근거 자료
- `specs/spec-14-02-doctor-bash-version/`: spec.md, plan.md, task.md, walkthrough.md, pr_description.md
- `tests/test-doctor-bash-version.sh`: 회귀 테스트 (lint + 실행 검증 3건)

### 🛠 Modified Files
- `sources/bin/sdd` (line 1427): bash 체크 min_ver `"4.0"` → `"3.2"` + 힌트 완화
- `.harness-kit/bin/sdd` (line 1427): 도그푸딩 동기화
- `CLAUDE.md` (line 10, 44): 필수 도구 행 + 작업 원칙 §3 갱신
- `backlog/queue.md`: active 갱신 (sdd spec new 결과)
- `backlog/phase-14.md`: sdd:specs 마커 수동 보정

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (3/3)
- [x] 회귀 테스트 통과 (hk-doctor 6/6, queued-marker 7/7)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check — 본 spec 은 bash/markdown 만이라 해당 없음
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- Phase: `backlog/phase-14.md`
- Walkthrough: `specs/spec-14-02-doctor-bash-version/walkthrough.md`
- 버그 리포트: `docs/harness-kit-bug-02-doctor-bash-version-false-positive.md`
